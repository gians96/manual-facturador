# 10 — Nota de Crédito Electrónica

> `POST /api/documents`  
> **Controller:** `Tenant\Api\DocumentController@store`  
> **Middleware:** `input.request:document,api`  
> **Auth:** `Bearer {token}`  
> **Código tipo:** `"07"`

---

## Descripción

La nota de crédito **anula o corrige** una factura o boleta ya emitida. Se crea por el **mismo endpoint** que factura/boleta, con `codigo_tipo_documento: "07"` más tres campos propios: el tipo de nota, el motivo y la referencia al documento afectado.

> 📘 **Estructura común:** cliente, items, totales, idempotencia, `acciones` y forma de la respuesta son **idénticos** a los de factura/boleta. [09-boleta-factura.md](09-boleta-factura.md) es la referencia canónica; aquí solo va lo que cambia.

Lo que cambia no es solo el payload. **El documento afectado decide por dónde viaja la nota a SUNAT**, y eso es lo que sorprende a la mayoría de integraciones: una NC contra una factura sale al acto, una NC contra una boleta puede quedarse esperando el resumen diario. Está explicado en [Cómo llega la nota a SUNAT](#como-llega-a-sunat).

---

## Payload

```json
{
    "serie_documento": "FC01",
    "numero_documento": "#",
    "fecha_de_emision": "2026-04-18",
    "hora_de_emision": "15:00:00",
    "codigo_tipo_documento": "07",
    "codigo_tipo_moneda": "PEN",
    "codigo_tipo_nota": "01",
    "motivo_o_sustento_de_nota": "Anulación de la operación",
    "documento_afectado": {
        "external_id": "4506ba3e-fd30-44b3-9646-603d8236a02f"
    },
    "codigo_vendedor": 1,
    "datos_del_cliente_o_receptor": {
        "codigo_tipo_documento_identidad": "1",
        "numero_documento": "76251607",
        "apellidos_y_nombres_o_razon_social": "ARIAS BONIFACIO, GIANMARCOS DANIEL",
        "codigo_pais": "PE",
        "ubigeo": "",
        "direccion": null,
        "correo_electronico": null,
        "telefono": null
    },
    "items": [
        {
            "codigo_interno": "ASD",
            "descripcion": "Precio",
            "codigo_producto_sunat": null,
            "unidad_de_medida": "NIU",
            "cantidad": 1,
            "valor_unitario": 3.1271186440677967,
            "precio_unitario": 3.69,
            "codigo_tipo_precio": "01",
            "codigo_tipo_afectacion_igv": "10",
            "total_base_igv": 3.1271186440677967,
            "porcentaje_igv": 18,
            "total_igv": 0.5628813559322032,
            "total_impuestos": 0.5628813559322032,
            "total_valor_item": 3.1271186440677967,
            "total_item": 3.69
        }
    ],
    "totales": {
        "total_exportacion": 0,
        "total_operaciones_gravadas": 3.1271186440677967,
        "total_operaciones_inafectas": 0,
        "total_operaciones_exoneradas": 0,
        "total_operaciones_gratuitas": 0,
        "total_igv": 0.5628813559322032,
        "total_impuestos": 0.5628813559322032,
        "total_valor": 3.1271186440677967,
        "total_venta": 3.69
    }
}
```

---

## Campos propios de la nota

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `codigo_tipo_documento` | string | **Sí** | `"07"` |
| `codigo_tipo_nota` | string | **Sí** | Catálogo 09 de SUNAT. Sale en `<cbc:ResponseCode>` |
| `motivo_o_sustento_de_nota` | string | **Sí** | Texto libre. Sale en `<cbc:Description>` |
| `documento_afectado` | object | **Sí** | Referencia al comprobante que se corrige |

Los tres se comprueban **antes de emitir**, y si falta más de uno se informan juntos en la misma respuesta:

```json
{
  "success": false,
  "message": "Faltan campos obligatorios de la nota: codigo_tipo_nota, motivo_o_sustento_de_nota. Sin ellos el comprobante se emite y SUNAT lo rechaza, con el correlativo ya consumido.",
  "error_code": "MISSING_FIELDS",
  "errors": { "faltantes": ["codigo_tipo_nota", "motivo_o_sustento_de_nota"] }
}
```

Una cadena vacía o con solo espacios cuenta como ausente.

La excepción es `documento_afectado` **ausente por completo**: eso se comprueba antes y sale con su propio mensaje —`Para notas de crédito y débito es obligatorio 'documento_afectado'.`—, sin acumular los otros dos. Manda la clave, aunque sea incompleta, y verás la lista entera.

:::info Cambio de comportamiento (2026-09-07)

Antes cada uno fallaba de una forma distinta, y ninguna era útil. Sin `documento_afectado` sí había rechazo. Sin `motivo_o_sustento_de_nota` salía un **HTTP 500** con el SQL crudo, porque `notes.note_description` no admite nulos. Y sin `codigo_tipo_nota` **no fallaba nada**: la nota se emitía con `<cbc:ResponseCode>` vacío, se firmaba, se enviaba, y la rechazaba SUNAT — con el correlativo ya consumido y sin forma de recuperarlo.

:::

### Qué se ignora en una nota

Estos bloques del payload de venta **no** se procesan aquí. No es que se rechacen: se descartan en silencio, así que si los mandas esperando efecto no verás ningún error.

| Bloque | Qué pasa |
|---|---|
| `pagos[]` | Lo descarta el transform: solo se lee para `codigo_tipo_documento` `01` y `03` |
| `codigo_tipo_operacion` | Solo se lee para `01` y `03` |
| `fecha_de_vencimiento` | Solo se lee para `01` y `03` |
| `cuotas[]` | Se **guardan**, pero solo salen en el XML en el caso de la [nota tipo `13`](#nota-tipo-13) |

---

## `documento_afectado` — las dos formas, y por qué no dan igual {#documento-afectado}

### Forma preferida: `external_id`

```json
"documento_afectado": {
    "external_id": "4506ba3e-fd30-44b3-9646-603d8236a02f"
}
```

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `external_id` | string (UUID) | UUID que devolvió el backend al crear la factura o boleta |

El backend busca el documento, lo enlaza por id (`notes.affected_document_id`) y **hereda de él el grupo de envío**. Si no existe:

```json
{
  "success": false,
  "message": "No se encontró el documento con código externo 4506ba3e-….",
  "error_code": "AFFECTED_DOCUMENT_NOT_FOUND"
}
```

### Forma alternativa: serie, número y tipo

Para referenciar un comprobante que **no está en esta base** — el típico caso de una migración desde otro sistema:

```json
"documento_afectado": {
    "serie_documento": "F001",
    "numero_documento": "15",
    "codigo_tipo_documento": "01"
}
```

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `serie_documento` | string | Serie del documento afectado. Se normaliza a mayúsculas y sin espacios |
| `numero_documento` | string | Correlativo. Se canonicaliza (`00000015` → `15`) igual que el del propio comprobante |
| `codigo_tipo_documento` | string | `"01"` (Factura) o `"03"` (Boleta) |

Las tres son **obligatorias** en esta forma: si falta cualquiera se rechaza antes de emitir con `MISSING_FIELDS`, nombrándolas con el prefijo `documento_afectado.`. Un `external_id` presente pero vacío (`""`) cuenta como ausente y cae en esta rama, así que acabarás viendo las tres sub-claves en `faltantes`.

Lo que **no** se comprueba es que ese comprobante exista ni que los importes cuadren: se guarda como JSON literal en `notes.data_affected_document`. **SUNAT sí lo valida**: si la referencia no corresponde a un comprobante suyo, el rechazo llega en el CDR, no en la respuesta de la API.

:::warning La forma alternativa cambia la ruta de envío de una NC de boleta

Con `external_id` el backend puede mirar cómo se envió la boleta original. Sin él no puede: `affected_document_id` queda en `null`, la comprobación "¿la boleta afectada se envió de forma individual?" devuelve `false` y **la nota nunca sale individualmente**, aunque el tenant tenga los dos interruptores encendidos. Se queda en `01` (Registrado) esperando el resumen diario.

Si la boleta está en esta base, usa `external_id`. La forma por serie/número es para lo que no está.
:::

Si falta `documento_afectado` por completo, el mensaje es distinto y más directo: `Para notas de crédito y débito es obligatorio 'documento_afectado'.`, también con `error_code: "MISSING_FIELDS"`.

---

## Tipos de nota de crédito (`codigo_tipo_nota`)

Catálogo 09 de SUNAT. Un código que no exista se rechaza con `error_code: "INVALID_REFERENCE"` (HTTP 422), y el mensaje **enumera los valores válidos de tu tenant**, que salen de su propia tabla `cat_note_credit_types`:

```json
{
  "error_code": "INVALID_REFERENCE",
  "errors": {
    "campo": "codigo_tipo_nota",
    "valores_validos": ["01","02","03","04","05","06","07","08","09","10","11","12","13"]
  }
}
```

Esa lista importa: el `13` solo existe en las bases que corrieron la migración que lo añadió, así que no des por hecho que está. Hasta el 2026-09-07 este caso salía como **HTTP 500** con el SQL crudo.

| Código | Descripción |
|--------|-------------|
| `01` | Anulación de la operación |
| `02` | Anulación por error en el RUC |
| `03` | Corrección por error en la descripción |
| `04` | Descuento global |
| `05` | Descuento por ítem |
| `06` | Devolución total |
| `07` | Devolución por ítem |
| `08` | Bonificación |
| `09` | Disminución en el valor |
| `10` | Otros conceptos |
| `11` | Ajustes de operaciones de exportación |
| `12` | Ajustes afectos al IVAP |
| `13` | Corrección del monto neto pendiente de pago |

### Serie

| Documento afectado | Serie NC habitual |
|-------------------|----------|
| Factura (`F001`) | `FC01` |
| Boleta (`B001`) | `BC01` |

La serie debe existir para el tipo `07` en el establecimiento del token, o el envío se rechaza con `INVALID_SERIES`. Es la única comprobación que se hace sobre ella: **la serie no decide nada más**. No se verifica que una `BC01` vaya contra una boleta, y sobre todo, la ruta de envío no la fija la serie sino el documento afectado — ver abajo.

---

## Cómo llega la nota a SUNAT {#como-llega-a-sunat}

Esta es la parte que no se deduce del payload. Una nota **no elige** su forma de envío: la hereda.

### 1. La nota hereda el grupo del documento afectado

Al crearse, la nota copia el `group_id` del comprobante que corrige:

| Documento afectado | `group_id` de la nota | Ruta a SUNAT |
|---|---|---|
| Factura (`01`) | `01` | Envío **individual**, en la misma petición |
| Boleta (`03`) | `02` | Individual **solo si** el tenant lo tiene activado; si no, **resumen diario** |

Con la forma alternativa (sin `external_id`) el grupo se deduce del `codigo_tipo_documento` que mandes dentro de `documento_afectado`: `01` → grupo `01`, cualquier otro valor → grupo `02`.

### 2. Los interruptores del tenant deciden si sale ya

Están en **Configuración → Avanzado → pestaña Extra → tarjeta "Envío Automático de Comprobantes"**. La regla que aplica el backend a facturas, boletas y notas es:

```
grupo 01 (factura y sus notas):
    se envía = send_auto  Y  acciones.enviar_xml_firmado

grupo 02 (boleta y sus notas):
    se envía = send_auto  Y  acciones.enviar_xml_firmado  Y  envío individual de boletas
```

`acciones.enviar_xml_firmado` vale `true` si no lo mandas. Los dos interruptores están descritos en [37-envio-automatico-a-sunat.md](37-envio-automatico-a-sunat.md).

### 3. Para una NC de boleta hay una condición más

No basta con que el interruptor de envío individual esté encendido hoy: **la boleta afectada tiene que haberse enviado ella misma de forma individual**. El backend lo comprueba sobre el documento enlazado. Si esa boleta se fue por resumen, su nota también irá por resumen — que es justo lo que SUNAT espera.

De ahí se sigue el caso del recuadro de arriba: sin `external_id` no hay documento enlazado que comprobar, y la respuesta es siempre "no".

### 4. Qué ves en la respuesta

Cuando la nota **no** se envía en el acto, la emisión responde `200` igualmente:

| Campo | Valor |
|---|---|
| `data.state_type_id` | `"01"` |
| `data.state_type_description` | `"Registrado"` |
| `links.cdr` | `""` (cadena vacía) |
| `response` | `{}` |

No es un error. Es un comprobante emitido, firmado y con PDF, pendiente de remitirse.

### 5. Cómo se remite después

| Grupo de la nota | Cómo se envía después |
|---|---|
| `01` (nota de factura) | `POST /api/documents/send` con su `external_id` — ver [26-envio-diferido-update-estado.md](26-envio-diferido-update-estado.md) |
| `02` (nota de boleta) | `POST /api/summaries` con la fecha de emisión: la nota entra en el resumen diario junto a las boletas de ese día |

:::danger `POST /api/documents/send` rechaza las notas de boleta

El endpoint solo acepta documentos del grupo `01`. Con una nota de boleta responde:

```
El tipo de documento 07 es inválido, no es posible enviar.
```

No es un fallo: una nota asociada a una boleta se declara en el **resumen diario**, no de una en una. Para esas, el camino es `POST /api/summaries` con `fecha_de_referencia` igual a su fecha de emisión. El resumen recoge automáticamente todo lo del grupo `02` que ese día siga en estado `01` y no esté marcado como envío individual — boletas y notas juntas, cada nota con su `BillingReference` al comprobante que corrige.

**Nadie manda el resumen por ti.** No hay tarea programada que lo haga: si apagas el envío individual de boletas, alguien tiene que llamar a `POST /api/summaries` cada día, sea tu integración o un usuario desde el panel.
:::

---

## Nota de crédito tipo `13` — el único caso que lleva `cuotas[]` {#nota-tipo-13}

La NC tipo `13` (*corrección del monto neto pendiente de pago*) no corrige importes: corrige el **calendario de pago** de una venta al crédito. Es la única nota cuyo XML lleva bloques `FormaPago`, y para que salgan hacen falta **las dos cosas**:

```json
{
    "codigo_tipo_documento": "07",
    "codigo_tipo_nota": "13",
    "codigo_condicion_de_pago": "02",
    "motivo_o_sustento_de_nota": "Corrección del monto neto pendiente de pago",
    "documento_afectado": { "external_id": "…" },
    "cuotas": [
        { "fecha": "2026-07-18", "codigo_tipo_moneda": "PEN", "monto": 59 },
        { "fecha": "2026-08-18", "codigo_tipo_moneda": "PEN", "monto": 59 }
    ]
}
```

Produce en el XML el `FormaPago`/`Credito` con la suma de las cuotas, seguido de un `Cuota001`, `Cuota002`… por cada una, igual que en una factura a crédito. La estructura de `cuotas[]` es la misma que en [09-boleta-factura.md](09-boleta-factura.md#cuotas), incluida la trampa del nombre `codigo_metodo_de_pago` (con "de").

Además, el tipo `13` cambia dos cosas más en el XML: el `PayableAmount` del total se emite en `0.00`, y las líneas con importe `0` sí se declaran (en el resto de notas se omiten).

**Las dos condiciones son obligatorias y se validan:**

| Payload | Respuesta |
|---|---|
| `13` con `codigo_condicion_de_pago` en `01` (o ausente) | `422` · `INVALID_PAYMENT_CONDITION`, con `valores_validos: ["02"]` |
| `13` con un valor que no es `01` ni `02` (p. ej. `03`) | `422` · `INVALID_PAYMENT_CONDITION`, pero con el **mensaje general** del valor inválido y `valores_validos: ["01","02"]`: ese es el problema de fondo |
| `13` con `02` pero `cuotas` vacío o ausente | `422` · `MISSING_FIELDS`, con `faltantes: ["cuotas"]` |

:::info Cambio de comportamiento (2026-09-07)

Antes se aceptaban las dos combinaciones y el comprobante salía **sin bloque `FormaPago`, sin cuotas y con importe `0.00`**: una nota que no declaraba lo único que el tipo 13 sirve para declarar. Ahora se rechaza antes de emitir.

Ojo al ramificar por `error_code`: `INVALID_PAYMENT_CONDITION` ya no significa solo "el valor no está en `01`/`02`", sino también "es válido en general, pero este tipo de nota exige `02`". El mensaje y `errors.valores_validos` los distinguen.

:::

:::warning El tipo `13` con importes gravados lo rechaza SUNAT

Una nota tipo `13` que además lleve operaciones gravadas se emite, pero SUNAT la devuelve con el código **`3068`** (*"El código de tributo no debe repetirse a nivel de totales"*): la plantilla emite el subtotal de IGV dos veces. Es un defecto conocido de la plantilla, no de tu payload.

El uso normal del `13` —corregir el calendario de pago, con importes en `0`— se acepta sin problema. Si necesitas además ajustar importes, hazlo con otro tipo de nota.
:::

:::warning En cualquier otra nota, `cuotas[]` se guarda y no se emite

El backend acepta `cuotas[]` en **toda** nota de crédito y las persiste, pero la plantilla XML solo las escribe en el caso `13` + `02`. Con `02` y otro tipo de nota, el comprobante sale sin forma de pago y sin cuotas, sin ningún aviso.

En **nota de débito** ni siquiera se guardan: el bloque se descarta al crear el documento.
:::

---

## Response (200 OK)

Misma estructura que boleta/factura:

```json
{
    "success": true,
    "data": {
        "number": "FC01-3",
        "filename": "20123456789-07-FC01-3",
        "external_id": "uuid-nc",
        "state_type_id": "05",
        "state_type_description": "Aceptado",
        "id": 456,
        "print_ticket": "https://demo.nt-suite.pro/print/document/uuid-nc/ticket"
    },
    "links": {
        "xml": "https://…",
        "pdf": "https://…",
        "cdr": "https://…"
    },
    "response": {
        "code": "0",
        "description": "La Nota de Crédito numero FC01-3, ha sido aceptada"
    }
}
```

Con `state_type_id: "01"` el bloque `response` llega como `[]` —un arreglo vacío, no un objeto— y `links.cdr` como `""`: ver [Qué ves en la respuesta](#como-llega-a-sunat).

### Correo al cliente

La nota se manda por correo con las mismas reglas que cualquier otro comprobante: sale si el payload trae `acciones.enviar_email: true` **o** si el tenant tiene activo "Enviar PDF automático al correo del cliente". El envío ocurre **aunque la nota no se haya remitido a SUNAT**, porque el correo no mira el resultado del envío. Detalle en [36-envio-automatico-por-correo.md](36-envio-automatico-por-correo.md).

---

## Errores propios de esta emisión

| `error_code` | Cuándo |
|---|---|
| `MISSING_FIELDS` | Falta `codigo_tipo_nota`, `motivo_o_sustento_de_nota`, `documento_afectado` o sus sub-claves — o cualquier obligatorio del tronco común. También cuando el tipo `13` no trae `cuotas` |
| `INVALID_REFERENCE` | `codigo_tipo_nota` no existe en el catálogo del tenant. El mensaje lista los válidos |
| `NULL_NOT_ALLOWED` | `motivo_o_sustento_de_nota` llegó explícitamente como `null` por una vía que no pasa por la validación de entrada |
| `AFFECTED_DOCUMENT_NOT_FOUND` | El `external_id` de `documento_afectado` no existe en este tenant |
| `INVALID_SERIES` | La serie no está registrada para el tipo `07` en el establecimiento del token |
| `INVALID_PAYMENT_CONDITION` | `codigo_condicion_de_pago` distinto de `01`/`02`, o un tipo `13` sin `02` |

El catálogo completo y qué hacer con cada uno está en [Errores de la API](../../errores-de-la-api.md).

---

## Notas para offline

- **La NC necesita que el documento afectado esté sincronizado antes.** El `external_id` lo asigna el backend al crear la factura o boleta.
- Flujo:
  1. Emitir factura/boleta offline → sincronizar → guardar el `external_id` que devuelve el servidor.
  2. Crear la NC referenciando ese `external_id` → sincronizar.
- Si el original se creó offline y aún no se ha sincronizado, la NC debe **quedar en cola**: no la mandes con la forma alternativa por serie/número solo para desbloquearla, porque entonces la nota nunca podrá enviarse individualmente si el original era una boleta (ver el recuadro de `documento_afectado`).
- Los items y totales de la NC deben corresponder a lo que se corrige del original —total o parcial—. El backend no lo comprueba; SUNAT sí.
- La idempotencia por `offline_id` funciona igual que en factura/boleta: reintentar con el mismo `offline_id` devuelve la nota ya creada en vez de duplicarla. Ver [16-idempotencia.md](16-idempotencia.md).
