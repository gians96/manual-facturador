---
sidebar_position: 2.1
title: "Errores de la API: qué significa cada respuesta"
sidebar_label: "Errores de la API"
---

# Errores de la API: qué significa cada respuesta

Aplica a `POST /api/documents` (facturas, boletas y notas) y a
`POST /api/offline/sync-batch`, que comparte el mismo pipeline de validación:
los mismos códigos llegan por las dos vías, con distinto sobre.

## Antes que nada: la cabecera

```
Content-Type: application/json
```

**Es obligatoria.** Sin ella el servidor trata el cuerpo como un formulario y descarta el
comprobante. Es, con diferencia, la causa número uno de consultas sobre esta API: como el
JSON nunca llega a leerse, la respuesta acusaba la falta de campos que **sí** venían en el
envío, y la depuración salía disparada en la dirección equivocada.

Hoy el error lo dice de frente:

```json
{
  "success": false,
  "message": "No se pudo interpretar el cuerpo como JSON. Envía la cabecera 'Content-Type: application/json'; sin ella el servidor lo trata como formulario y descarta el comprobante. Recibido: application/x-www-form-urlencoded.",
  "error_code": "MISSING_CONTENT_TYPE"
}
```

## Forma de la respuesta

El sobre no cambia nunca: `success` y `message` están siempre.

```json
{
  "success": false,
  "message": "Texto accionable en español",
  "error_code": "MISSING_FIELDS",
  "errors": { "faltantes": ["totales", "items"] }
}
```

`error_code` y `errors` son **añadidos y opcionales**: aparecen en los errores de entrada y
sirven para ramificar en tu código sin tener que leer el texto del mensaje. Si tu integración
ya funciona leyendo solo `success` y `message`, sigue funcionando igual.

## Códigos de estado

| Código | Significa |
|---|---|
| `200` | Comprobante emitido |
| `400` | El cuerpo no se pudo interpretar |
| `401` | Token ausente o inválido |
| `403` | Emisión bloqueada por licencia |
| `422` | Falta un campo, un catálogo no es válido o una regla de negocio no se cumple |
| `500` | Fallo real del servidor |

Un dato mal enviado **nunca** devuelve 500. Si recibes un 500, no es culpa de tu payload.

> **Cambio de comportamiento (2026-09-05).** El comprobante duplicado, que era la última
> excepción a esa regla, ahora sale con **409** y `error_code: "DUPLICATE_DOCUMENT"`. El
> `message` no ha cambiado.

> **Cambio de comportamiento (2026-09-02).** Los errores de negocio —serie incorrecta,
> ubigeo, fecha fuera de plazo— antes salían con **500**. Ahora salen con **422**, que es lo
> que son. El `message` es el mismo de siempre.

## 400 · el cuerpo no llegó

| `error_code` | Qué revisar |
|---|---|
| `MISSING_CONTENT_TYPE` | Falta la cabecera. El mensaje te dice qué `Content-Type` llegó |
| `INVALID_JSON` | Sintaxis rota. El mensaje incluye el motivo exacto: comillas, comas, llaves |
| `EMPTY_BODY` | No llegó cuerpo. Si tu cliente anunció tamaño y no llegó nada, puede haberse excedido el límite del servidor |
| `BODY_IS_LIST` | Enviaste `[{...}]`. Este endpoint procesa **un comprobante por petición** |

## 422 · el comprobante no es válido

### `MISSING_FIELDS`

Se informan **todos los que faltan de una vez**, no de uno en uno:

```
Faltan campos obligatorios: totales, items.
```

Obligatorios: `serie_documento`, `numero_documento`, `codigo_tipo_documento`,
`codigo_tipo_moneda`, `datos_del_cliente_o_receptor` (con
`codigo_tipo_documento_identidad`, `numero_documento` y
`apellidos_y_nombres_o_razon_social`), `totales` (con `total_venta`) e `items`.

En listas, el mensaje **numera la línea** — con ocho ítems iguales, «falta descripcion» no
diría cuál corregir:

```
Ítem #2: falta 'descripcion'.
Pago #1: falta 'codigo_destino_pago'. Si no aplica, envíalo como null.
Para notas de crédito y débito es obligatorio 'documento_afectado'.
```

### Referencias a otros documentos

`REFERENCE_NOT_FOUND`, `MALFORMED_REFERENCE`, `AMBIGUOUS_REFERENCE`, `INVALID_DOCUMENT_TYPE`
y `DISPATCH_ALREADY_LINKED` salen de las claves que enlazan guías con comprobantes. Qué
significa cada una y qué clave usar en cada caso:
[Documentos relacionados](./documentos-relacionados.md).

No confundir `MALFORMED_REFERENCE` —el bloque que enviaste no tiene la forma de una
referencia— con `INVALID_REFERENCE`, más abajo, que es un código que no existe en su
catálogo.

### `INVALID_UNIT_TYPE`

```
La unidad de medida 'TON' no existe en el catálogo 03 de SUNAT.
Para ese caso el código correcto suele ser 'TNE'.
```

Los códigos del catálogo 03 no siempre son los intuitivos. Los que más se confunden:

| Enviado | Correcto | |
|---|---|---|
| `TON`, `TM`, `TN` | `TNE` | Toneladas |
| `KG` | `KGM` | Kilogramos |
| `UND`, `UNI`, `U` | `NIU` | Unidad |
| `LT`, `L` | `LTR` | Litros |
| `MT`, `M` | `MTR` | Metros |
| `CAJA` | `BX` | Caja |
| `SERVICIO` | `ZZ` | Servicio |

### `TOTALS_MISMATCH`

```
'totales.total_operaciones_gravadas' (5000.00) no coincide con la suma de
'total_valor_item' de los ítems (100.00).
```

Solo salta ante un descuadre real. Las diferencias de céntimos por redondeo **pasan sin
problema**, y la comprobación se omite por completo en comprobantes con cargos, descuentos,
anticipos, ISC, operaciones gratuitas o afectaciones mixtas.

### Reglas de negocio

Mismos mensajes de siempre, ahora con 422 y con un `error_code` para ramificar sin leer el
texto. **Los mensajes no han cambiado**: si tu integración los compara, sigue funcionando.

| Mensaje | `error_code` |
|---|---|
| `La serie ingresada F001, es incorrecta.` | `INVALID_SERIES` |
| `La fecha de emisión no puede ser menor a {N} día(s).` | `ISSUE_DATE_OUT_OF_RANGE` |
| `El código ubigeo debe contener 6 dígitos` · `El código ubigeo es incorrecto` | `INVALID_UBIGEO` |
| `El tipo doc. identidad {X} del cliente no es válido.` | `INVALID_IDENTITY_DOCUMENT_TYPE` |
| `Para empresas NRUS solo están disponibles las series de Boleta de venta electrónica y Nota de venta.` | `SERIES_NOT_ALLOWED_NRUS` |
| `El código ingresado del establecimiento es incorrecto.` | `INVALID_ESTABLISHMENT` |
| `No se encontró el documento con código externo {X}.` | `AFFECTED_DOCUMENT_NOT_FOUND` |
| `No se enviaron documentos para la anulación.` | `NO_DOCUMENTS` |

### `POST /api/documents/send` — desde 2026-09-07

| Mensaje | `error_code` |
|---|---|
| `El documento con código externo {X}, no se encuentra registrado.` | `DOCUMENT_NOT_FOUND` |
| `El tipo de documento {NN} es inválido, no es posible enviar.` | `DOCUMENT_NOT_SENDABLE` |
| `Falta 'external_id': es el UUID que devolvió la emisión del documento.` | `MISSING_FIELDS` |

Fíjate en que `DOCUMENT_NOT_FOUND` **no es** `AFFECTED_DOCUMENT_NOT_FOUND`, aunque los mensajes
se parezcan: aquel es el documento *afectado* por una nota; este es el que quieres enviar.

`DOCUMENT_NOT_SENDABLE` significa que el documento existe pero es del grupo `02`, y ese endpoint
solo envía facturas y sus notas. Las boletas y las notas de boleta van por
`POST /api/summaries`. **No lo reintentes**: no va a cambiar.

Los tres salían antes como `500` sin `error_code` —y el último devolvía `200` con cuerpo vacío—.

### Notas de crédito y débito — desde 2026-09-07

| Situación | `error_code` |
|---|---|
| Falta `codigo_tipo_nota`, `motivo_o_sustento_de_nota` o `documento_afectado` (o sus sub-claves `serie_documento`/`numero_documento`/`codigo_tipo_documento` cuando no mandas `external_id`) | `MISSING_FIELDS` |
| `codigo_tipo_nota` no existe en el catálogo del tenant | `INVALID_REFERENCE` |
| Nota de crédito tipo `13` sin `codigo_condicion_de_pago: "02"` | `INVALID_PAYMENT_CONDITION` |
| Nota de crédito tipo `13` con `02` pero sin `cuotas` | `MISSING_FIELDS` |

Si faltan varios, se informan **todos en la misma respuesta** dentro de `errors.faltantes`. Una
cadena vacía cuenta como ausente, incluido un `documento_afectado.external_id` en `""`.

Antes de esa fecha: el tipo de nota ausente **no daba ningún error** —se emitía un comprobante
que SUNAT rechazaba, con el correlativo ya consumido—; el motivo ausente y el tipo fuera de
catálogo daban `500` con el SQL crudo; y el tipo `13` mal formado se emitía mudo.

### Catálogos que no existen — `INVALID_REFERENCE`

Cuando un código que envías no existe en el catálogo destino, el error **nombra el campo de
tu payload**, no la columna de la base. Y si el catálogo es del tenant, te dice qué valores
acepta:

```json
{
  "success": false,
  "message": "El valor enviado en 'codigo_condicion_de_pago' no existe. No es un catálogo de SUNAT: son las condiciones de pago del propio tenant. Para crédito con cuotas usa 02; el 03 que ofrece el panel es estado de pantalla y nunca se envía por API. Valores válidos en este tenant: 01, 02.",
  "error_code": "INVALID_REFERENCE",
  "errors": {
    "campo": "codigo_condicion_de_pago",
    "valores_validos": ["01", "02"]
  }
}
```

:::warning `codigo_condicion_de_pago` no es un catálogo de SUNAT

Es la confusión más frecuente de este bloque. Son las condiciones de pago **de tu empresa**,
y de fábrica hay exactamente dos:

| Código | Condición |
|---|---|
| `01` | Contado |
| `02` | Crédito — es el que corresponde cuando envías `cuotas` |

Si no envías la clave, se usa `01`.

**Cuidado con el `"03"`.** El panel muestra una opción "Crédito con cuotas" y algunos tenants
tienen además una fila `03` en su tabla de condiciones, pero **`03` es estado de pantalla, no
un código de la API**: el panel lo convierte a `02` antes de enviar. Si lo mandas tú:

- En un tenant **sin** esa fila recibes este error, antes de emitir. Es el caso bueno.
- En un tenant **con** esa fila **no hay error**: el comprobante se emite sin bloque
  `FormaPago` y descartando las cuotas en silencio, con el correlativo ya consumido.

Para crédito con calendario de cuotas envía `02` + `cuotas`. Detalle en
[Boleta y Factura → Condiciones de Pago](offline/endpoints/09-boleta-factura.md#condiciones-de-pago-codigo_condicion_de_pago).
:::

Otros campos frecuentes de este bloque:

| Campo | Qué espera |
|---|---|
| `codigo_vendedor` | El **id numérico** del usuario vendedor en tu empresa, no un código propio |
| `datos_del_cliente_o_receptor.codigo_tipo_documento_identidad` | `6` para RUC (11 dígitos), `1` para DNI (8 dígitos) |
| `datos_del_cliente_o_receptor.ubigeo` | 6 dígitos existentes, o nada |
| `pagos[].codigo_metodo_pago` | Catálogo de métodos de pago de tu empresa |
| `items[].codigo_tipo_afectacion_igv` | Catálogo 07: `10` gravado, `20` exonerado, `30` inafecto |

### La cadena vacía no es lo mismo que nada

Si no tienes un dato opcional, **omite la clave o envíala como `null`**. No mandes `""`.

Es el error más silencioso de la API porque parece inofensivo: `""` es lo que devuelve
cualquier `SELECT` de un campo de texto vacío, así que sale solo de la consulta que arma el
JSON. Pero en un campo que apunta a un catálogo, `""` no significa «sin dato»: significa «el
código vacío», que no existe en ninguna tabla.

```json
"ubigeo": ""      // ❌  antes rompía el comprobante entero
"ubigeo": null    // ✅
                   // ✅  o simplemente no incluir la clave
```

Desde el 2026-09-04 el servidor normaliza `ubigeo`, `codigo_pais` y `codigo_tipo_direccion`
vacíos a `null`, así que ya no rompen. Pero `codigo_tipo_documento_identidad: ""` **sí**
sigue siendo un error —ahí no hay valor por defecto razonable— y sale como `MISSING_FIELDS`.

`codigo_pais` va un paso más allá desde el 2026-09-09: ausente, `null` o vacío se resuelve como
`"PE"`, que es lo que ya hacían el panel y la API de notas de venta. Antes, `persons.country_id`
era `NOT NULL` y este era el único camino que no le ponía defecto, así que omitirlo salía como
`NULL_NOT_ALLOWED` — pese a que esta misma documentación lo listaba como opcional con `"PE"` por
defecto. Si el cliente **ya existe** con otro país, se conserva el suyo: un defecto ciego se lo
habría cambiado a `PE` en cada emisión que omitiera el campo, y eso viaja al XML.

### `NULL_NOT_ALLOWED`

Enviaste la clave, pero con valor `null`, en un campo que no lo admite:

```
'datos_del_cliente_o_receptor.codigo_tipo_documento_identidad' llegó como null.
Es obligatorio y no admite null: '6' para RUC (11 dígitos), '1' para DNI (8 dígitos).
```

Es distinto de `MISSING_FIELDS`: ahí la clave no venía; aquí venía vacía.

### `INVALID_ENCODING` — el JSON no llega en UTF-8

```
El cuerpo contiene caracteres que no son UTF-8 válido. Envía el JSON codificado en
UTF-8 (sin BOM).
```

:::tip Si integras desde SQL Server

`sp_OAMethod` con `MSXML2.ServerXMLHTTP` **no** convierte el cuerpo a UTF-8 por su cuenta:
lo manda en la codificación de la instancia. El síntoma despista mucho, porque fallan
**solo** los comprobantes que llevan tildes, eñes o el símbolo `°` —`CONSTRUCCIÓN`,
`CAÑETE`, `N° 173`— mientras el resto del mismo lote entra sin problema.

Convierte el cuerpo a UTF-8 antes del `Send`.
:::

### `VALUE_TOO_LONG` y `VALUE_OUT_OF_RANGE`

El texto excede el ancho del campo, o el importe no cabe en 12 dígitos con 2 decimales.
Ambos nombran el campo del payload.

## Sincronización por lotes (`sync-batch`)

`POST /api/offline/sync-batch` **no** devuelve un status de error: responde `200` y cada
fallo viaja dentro de `results[]`, para que un comprobante malo no tumbe el lote entero.

Desde el 2026-09-04, **toda** fila fallida trae `error_code`:

```json
{
  "index": 4,
  "offline_id": "C9C52DCB-D5C4-4476-A8CE-8989F1351DF1",
  "success": false,
  "doc_type": "01",
  "message": "El valor enviado en 'codigo_condicion_de_pago' no existe. …",
  "error_code": "INVALID_REFERENCE",
  "errors": { "campo": "codigo_condicion_de_pago", "valores_validos": ["01", "02"] }
}
```

| `error_code` | Qué hacer |
|---|---|
| `MISSING_FIELDS` · `NO_ITEMS` · `INVALID_PAYLOAD` · `INVALID_REFERENCE` · `NULL_NOT_ALLOWED` · `INVALID_ENCODING` · `VALUE_TOO_LONG` · `VALUE_OUT_OF_RANGE` | Corregir el payload. **No reintentar** sin cambiarlo: el error es permanente |
| `CONFLICT_NUMBER` | El correlativo ya lo usó otra venta. Renumerar y reemitir |
| `DATABASE_ERROR` · `PROCESSING_ERROR` | No es tu payload. Reintentar **una vez** y, si persiste, avisar a soporte con el `offline_id` |

:::warning `PROCESSING_ERROR` era el cajón de sastre — ponle tope a los reintentos
Hasta el 2026-09-09, **un campo ausente del payload salía con este código**: el servidor lo leía
sin comprobar, PHP avisaba con «Undefined array key …» y el `catch` genérico lo etiquetaba como
fallo del servidor, con este texto fijo:

> El payload no contiene los campos requeridos por el servidor. Revise los ítems del documento antes de reintentar.

Dos problemas a la vez. El código decía «reintenta», así que un error **permanente** entraba en
bucle; y el mensaje mandaba a revisar los ítems aunque el campo que faltara fuera de cabecera.

Ahora esa familia sale como `MISSING_FIELDS` nombrando el campo, con su bloque `errors`. Pero si
tu integración reintenta `DATABASE_ERROR` o `PROCESSING_ERROR` sin límite, **ponle tope igual**:
un fallo que se repite casi nunca se arregla volviendo a enviar lo mismo.
:::

Un fallo con `success: true` y `was_duplicate: true` **no es un error**: es la idempotencia
por `offline_id` devolviendo el comprobante que ya estaba emitido. Márcalo como sincronizado.

## Valores que se aceptaban y no significaban lo enviado

Había una familia de casos que **no daba ningún error**: el comprobante se emitía y el problema
aparecía después —en SUNAT, en la contabilidad o en un reporte— con el correlativo ya consumido.
Desde el **2026-09-05** casi todos se corrigen solos o se rechazan antes de emitir.

### Ahora se normalizan solos

| Envías | Qué pasa ahora |
|---|---|
| `codigo_tipo_moneda: "usd"` | Se normaliza a `"USD"`. Antes pasaba la validación —la colación no distingue mayúsculas— y el XML salía con `currencyID="usd"` |
| `serie_documento: "f001"` | Se normaliza a `"F001"`, en el documento y en el nombre del archivo |
| `documento_afectado.numero_documento: "00000003"` | Se normaliza a `3`. Antes la referencia de la nota salía como `F001-00000003` apuntando a un `F001-3` |

No tienes que cambiar nada si ya enviabas mayúsculas: la normalización no altera esos envíos.

### Ahora se rechazan antes de emitir

| Envías | `error_code` |
|---|---|
| `fecha_de_emision: "01/09/2026"` — con barras se interpretaría como **9 de enero** | `INVALID_DATE_FORMAT` |
| `cuotas[].fecha` o `fecha_de_vencimiento` con barras | `INVALID_DATE_FORMAT` |
| Comprobante en moneda distinta de PEN **sin** `factor_tipo_de_cambio` | `MISSING_EXCHANGE_RATE` |
| `factor_tipo_de_cambio: 0` o no numérico | `INVALID_EXCHANGE_RATE` |
| `codigo_vendedor: "001"` | `INVALID_NUMERIC_ID` |
| `pagos[].codigo_destino_pago` que no sea `"cash"` ni el id de una cuenta — `"001"`, `"CASH"`, `"efectivo"` | `INVALID_PAYMENT_DESTINATION` |
| `codigo_condicion_de_pago: "03"` | `INVALID_PAYMENT_CONDITION` |
| Texto en una columna numérica (`numero_de_contenedor: "MSKU1234567"`) | `INVALID_NUMERIC_VALUE` |

:::tip La regla que los cubre todos
Manda cada campo **con el tipo y el formato que declara esta documentación**: fechas en
`YYYY-MM-DD`, códigos de catálogo como texto, e ids numéricos como números, sin ceros a la
izquierda. Casi todas estas trampas nacían de un `SELECT` que devolvió texto y se envió tal cual.
:::

### Lo que todavía es silencioso

Estos siguen sin dar error y conviene tenerlos presentes:

| Envías | Lo que ocurre |
|---|---|
| `items[]` con un `codigo_interno` que **ya existe** | La `descripcion` del payload se descarta: el XML lleva la descripción guardada en tu catálogo de productos, no la que enviaste |
| `unidad_de_medida` en un ítem que ya existe | No se revalida contra el catálogo 03: llega tal cual al `unitCode` del XML. Solo se valida al **crear** el ítem |
| `items[]` **sin** `codigo_interno` | Todas esas líneas se resuelven al mismo producto interno y acaban compartiendo descripción |

## Cosas que conviene saber

- **Los decimales no se rechazan.** Los importes se almacenan con dos decimales y se redondean
  solos. Enviar `151724.376` no da error.
- **Un comprobante duplicado devuelve 409** (`DUPLICATE_DOCUMENT`) con el mensaje
  `El documento: 01 F001-00005242 ya se encuentra registrado.` y el detalle de serie y número
  en `errors`. Por `sync-batch` no se reporta como fallo: si el `offline_id` coincide se
  devuelve el comprobante existente con `was_duplicate: true`, y si pertenece a otra venta se
  marca `conflict_number`.
- **Las guías de remisión no siguen este flujo.** Tienen su propio proceso de tres pasos:
  ver [Guías de remisión: cómo funcionan](./guias-de-remision.md).
