# 15 — Sincronización Batch (Sync-Batch)

> `POST /api/offline/sync-batch`  
> **Controller:** `Modules\Offline\Http\Controllers\OfflineSyncController@syncBatch`  
> **Auth:** `Bearer {token}`  
> **Uso:** Enviar múltiples comprobantes creados offline en una sola petición.

---

## Descripción

El endpoint principal de sincronización. Recibe un array de comprobantes creados offline y los procesa secuencialmente. Cada comprobante se intenta crear; si falla, el error se registra individualmente sin afectar a los demás.

:::tip ¿Buscas el estado, el XML, el PDF o el CDR?
La fila del lote no los trae, pero te da el `external_id`, y con él llegas a todo:
[estado, XML, PDF y CDR de lo que sincronizaste](#estado-xml-pdf-y-cdr).
:::

:::tip ¿Una guía rechazada que no cambia al reenviarla?
Si la reenvías con su mismo `offline_id` y sin su `external_id`, el lote no lee el `data` y la
corrección no se aplica. Cómo hacerlo:
[corregir una guía rechazada por el lote](#corregir-una-guía-rechazada-por-el-lote).
:::

---

## Request

### Headers

```
Content-Type: application/json
Accept: application/json
Authorization: Bearer {token}
```

### Payload

```json
{
    "sales": [
        {
            "doc_type": "80",
            "offline_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
            "cash_id": 4,
            "data": {
                "document_type_id": "80",
                "prefix": "NV",
                "series_id": 10,
                "date_of_issue": "2026-04-18",
                "time_of_issue": "14:30:00",
                "customer_id": 5,
                "currency_type_id": "PEN",
                "seller_id": 1,
                "payments": [
                    {
                        "payment_method_type_id": "01",
                        "payment": 102,
                        "payment_received": 110
                    }
                ],
                "datos_del_cliente_o_receptor": {
                    "codigo_tipo_documento_identidad": "1",
                    "numero_documento": "76251607",
                    "apellidos_y_nombres_o_razon_social": "ARIAS BONIFACIO, GIANMARCOS DANIEL"
                },
                "items": [
                    {
                        "item_id": 3,
                        "item": { "id": 3, "internal_id": "FFF", "description": "Producto KG", "unit_type_id": "KGM", "sale_affectation_igv_type_id": "10", "has_igv": true, "unit_price": 102 },
                        "quantity": 1,
                        "unit_price": 102,
                        "unit_value": 86.44,
                        "total_value": 86.44,
                        "percentage_igv": 18,
                        "total_base_igv": 86.44,
                        "total_igv": 15.56,
                        "total": 102,
                        "total_taxes": 15.56,
                        "affectation_igv_type_id": "10",
                        "price_type_id": "01"
                    }
                ],
                "total_taxed": 86.44,
                "total_igv": 15.56,
                "total_taxes": 15.56,
                "total_value": 86.44,
                "subtotal": 102,
                "total": 102
            }
        },
        {
            "doc_type": "03",
            "offline_id": "b2c3d4e5-f6a7-8901-bcde-f12345678901",
            "cash_id": 4,
            "data": {
                "serie_documento": "B001",
                "numero_documento": "90",
                "fecha_de_emision": "2026-04-18",
                "hora_de_emision": "14:35:00",
                "codigo_tipo_operacion": "0101",
                "codigo_tipo_documento": "03",
                "codigo_tipo_moneda": "PEN",
                "codigo_vendedor": 1,
                "datos_del_cliente_o_receptor": {
                    "codigo_tipo_documento_identidad": "1",
                    "numero_documento": "76251607",
                    "apellidos_y_nombres_o_razon_social": "ARIAS BONIFACIO, GIANMARCOS DANIEL"
                },
                "items": [
                    {
                        "codigo_interno": "ASD",
                        "descripcion": "Precio",
                        "unidad_de_medida": "NIU",
                        "cantidad": 1,
                        "valor_unitario": 3.13,
                        "precio_unitario": 3.69,
                        "codigo_tipo_precio": "01",
                        "codigo_tipo_afectacion_igv": "10",
                        "total_base_igv": 3.13,
                        "porcentaje_igv": 18,
                        "total_igv": 0.56,
                        "total_impuestos": 0.56,
                        "total_valor_item": 3.13,
                        "total_item": 3.69
                    }
                ],
                "pagos": [
                    {
                        "codigo_metodo_pago": "01",
                        "monto": 3.69,
                        "pago_recibido": 5.00
                    }
                ],
                "totales": {
                    "total_operaciones_gravadas": 3.13,
                    "total_igv": 0.56,
                    "total_impuestos": 0.56,
                    "total_valor": 3.13,
                    "total_venta": 3.69
                }
            }
        },
        {
            "doc_type": "09",
            "offline_id": "c3d4e5f6-a7b8-9012-cdef-123456789012",
            "data": {
                "serie_documento": "T001",
                "numero_documento": "13",
                "fecha_de_emision": "2026-04-18",
                "hora_de_emision": "09:00:00",
                "codigo_tipo_documento": "09",
                "codigo_modo_transporte": "02",
                "codigo_motivo_traslado": "04",
                "fecha_de_traslado": "2026-04-19",
                "peso_total": 10.0,
                "unidad_peso_total": "KGM",
                "direccion_partida": { "ubigeo": "150101", "direccion": "Av. Principal 123" },
                "direccion_llegada": { "ubigeo": "150132", "direccion": "Jr. Los Olivos 456" },
                "chofer": { "codigo_tipo_documento_identidad": "1", "numero_documento": "12345678", "nombres": "PEREZ, JUAN", "numero_licencia": "Q12345678" },
                "vehiculo": { "numero_de_placa": "ABC123" },
                "datos_del_cliente_o_receptor": { "codigo_tipo_documento_identidad": "6", "numero_documento": "20123456789", "apellidos_y_nombres_o_razon_social": "EMPRESA DEMO S.A.C." },
                "items": [
                    { "codigo_interno": "ASD", "descripcion": "Mercadería trasladada", "unidad_de_medida": "NIU", "cantidad": 10 }
                ]
            }
        }
    ]
}
```

---

## Estructura del Payload

### `sales[]` — Array de comprobantes

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `doc_type` | string | **Sí** | Código tipo: `"80"`, `"01"`, `"03"`, `"07"`, `"08"`, `"09"`, `"31"` |
| `offline_id` | string | **Sí** | UUID v4 generado por Flutter. Clave de idempotencia |
| `cash_id` | int | No | ID de servidor de la caja donde registrar la venta |
| `cash_offline_id` | string | No | UUID de la caja creada sin conexión, si aún no tiene ID de servidor |
| `data` | object | **Sí** | Payload completo del comprobante (ver endpoints individuales) |

:::tip Cuál de los dos mandar
Manda `cash_id` cuando la caja ya se sincronizó y conoces su ID de servidor. Manda
`cash_offline_id` cuando la caja se abrió sin conexión y viaja en el mismo lote, dentro de
`cash_openings[]`: el backend resuelve el UUID contra la caja recién creada. Puedes mandar
los dos; se intenta primero `cash_id`.

Si no mandas ninguno, la venta se registra en la caja que ese usuario tenga abierta en ese
momento.
:::

### Formato del `data` según `doc_type`

| `doc_type` | Formato del `data` | Referencia |
|------------|-------------------|------------|
| `"80"` | Campos en **inglés** (SaleNote) | [12-nota-venta.md](12-nota-venta.md) |
| `"01"`, `"03"` | Campos en **español** (DocumentTransform) | [09-boleta-factura.md](09-boleta-factura.md) |
| `"07"` | Campos en **español** + `codigo_tipo_nota` + `documento_afectado` | [10-nota-credito.md](10-nota-credito.md) |
| `"08"` | Campos en **español** + `codigo_tipo_nota` + `documento_afectado` | [11-nota-debito.md](11-nota-debito.md) |
| `"09"` | Campos en **español** (DispatchTransform) | [13-guia-remision-remitente.md](13-guia-remision-remitente.md) |
| `"31"` | Campos en **español** (DispatchTransform) | [14-guia-remision-transportista.md](14-guia-remision-transportista.md) |

---

## Response (200 OK)

```json
{
    "success": true,
    "message": "Sincronización completada",
    "data": {
        "results": [
            {
                "index": 0,
                "success": true,
                "offline_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
                "doc_type": "80",
                "data": {
                    "id": 25,
                    "number": "NV01-25",
                    "external_id": "4611364d-2bc8-482c-9eea-4162216d582b",
                    "cash_registered": true
                },
                "cash_registered": true,
                "cash_error_code": null,
                "cash_message": null
            },
            {
                "index": 1,
                "success": true,
                "offline_id": "b2c3d4e5-f6a7-8901-bcde-f12345678901",
                "doc_type": "03",
                "data": {
                    "id": 123,
                    "number": "B001-90",
                    "external_id": "4506ba3e-fd30-44b3-9646-603d8236a02f",
                    "warnings": [],
                    "cash_registered": true
                },
                "cash_registered": true,
                "cash_error_code": null,
                "cash_message": null
            },
            {
                "index": 2,
                "success": true,
                "offline_id": "c3d4e5f6-a7b8-9012-cdef-123456789012",
                "doc_type": "09",
                "data": {
                    "id": 45,
                    "number": "T001-13",
                    "external_id": "xyz-dispatch-uuid",
                    "filename": "20123456789-09-T001-13",
                    "signed": true,
                    "sign_message": null,
                    "warnings": [],
                    "cash_registered": true
                },
                "cash_registered": true,
                "cash_error_code": null,
                "cash_message": null
            }
        ],
        "total": 3,
        "success_count": 3,
        "error_count": 0
    }
}
```

### La fila de un comprobante no trae el estado

Lo que ves arriba es todo lo que devuelve una fila de boleta, factura o nota: `id`, `number`,
`external_id` y `warnings`. **No hay `state_type_id`, ni `links`, ni la respuesta de SUNAT.**

Eso no significa que el comprobante no se haya enviado. `sync-batch` reutiliza por dentro el
mismo motor que `POST /api/documents`: una **factura** sale hacia SUNAT si el envío automático
está activo, y una **boleta** solo si además está activo el envío individual de boletas —que es
como se crean las empresas nuevas—. En ese caso queda **aceptada** en el mismo lote, solo que la
fila no te lo cuenta. Comprobado el 2026-09-21 contra SUNAT beta: en un mismo lote, con el envío
individual apagado, la factura quedó en `05` y la boleta en `01`.

Para saber en qué estado quedó, con el `external_id` que acabas de recibir:

```
GET /api/document_check_server/{external_id}
```

→ [26 — Consultar el estado de un comprobante](26-envio-diferido-update-estado.md#3-consultar-el-estado-de-un-comprobante)

Si no guardaste el `external_id`, pregunta por la serie y el número con `POST /api/documents/status`
→ [26 — Consultar por serie-número](26-envio-diferido-update-estado.md#por-serie-numero).

Si la empresa tiene apagado el envío individual, una **boleta** recién sincronizada está en `01`
(Registrado): no la declara el lote sino un resumen diario, que la pasa a `03` y, al consultarlo, a
`05`. Qué llamar después —y cómo anularla y de dónde sale su CDR, que es el del resumen—:
[39 — Ciclo de la boleta](39-ciclo-de-la-boleta.md). Facturas y boletas de envío individual:
[40](40-ciclo-de-la-factura-y-envio-individual.md).

:::warning El `doc_type` de la fila no es el estado

En la fila de una boleta, `doc_type` vale `"03"`, y en la tabla de estados el `03` es
**Enviado**. Son dos catálogos distintos que coinciden en el texto:

- **`doc_type`** — el tipo de comprobante: `01` Factura · `03` Boleta · `07` NC · `08` ND ·
  `09` GRE remitente · `31` GRE transportista · `20` Retención · `80` Nota de venta.
- **`state_type_id`** — el estado ante SUNAT: `01` Registrado · `03` Enviado · `05` Aceptado ·
  `07` Observado · `09` Rechazado · `11` Anulado · `13` Por anular.

Una fila con `doc_type: "03"` es una **boleta**, en el estado que sea.
:::

:::info Las guías sí traen `state_type_id`, pero solo a veces

En las filas `09` y `31` aparece **únicamente cuando `was_duplicate` es `true`** — es el estado
de la guía que ya estaba. Ver [`signed` y `sign_message`](#signed-y-sign_message). En boletas y
facturas no aparece nunca.
:::

### Estado, XML, PDF y CDR de lo que sincronizaste {#estado-xml-pdf-y-cdr}

La fila es un **acuse de recibo**, no el comprobante. `sync-batch` crea exactamente el mismo
comprobante que `POST /api/documents`; lo único distinto es la respuesta, que aquí se reduce a lo
imprescindible para cada fila del lote. Todo lo demás lo sacas del **`external_id`** que te
devuelve:

| Lo que `POST /api/documents` trae en su respuesta | Cómo lo obtienes después de `sync-batch` |
|---|---|
| `data.state_type_id` | `GET /api/document_check_server/{external_id}` (con token) |
| `links.xml` | `GET /downloads/document/xml/{external_id}` |
| `links.pdf` | `GET /downloads/document/pdf/{external_id}`, o con el formato: `…/a4`, `…/ticket` |
| `links.cdr` | `GET /downloads/document/cdr/{external_id}`, **solo si el comprobante tiene CDR propio** (tabla de abajo) |
| `data.print_ticket` | `GET /print/document/{external_id}/ticket` (o `/a4`) |
| `response` (lo que contestó SUNAT) | Está dentro del CDR: `ResponseCode` y `Description` |

**Las URL de `/downloads` y `/print` las armas tú**: son siempre iguales, cambia solo el
`external_id`. Van contra la misma dirección a la que llamas al lote, y **no piden token**. Si
llamas por IP con la cabecera `Host` —como en una instalación local—, descarga con esa misma
cabecera. Para que alguien las abra en un navegador, usa el dominio de la empresa.

:::warning El `external_id` abre los archivos
Como las descargas no piden token, quien tenga el `external_id` puede bajar el XML y el PDF, con
los datos del cliente. Guárdalo como guardas el token: no lo pongas en URLs públicas ni en correos
a terceros.
:::

Ejemplo con la F001-3 de la prueba del 2026-09-21:

```
GET /api/document_check_server/978f1b9a-6bff-4cd1-ac1d-d18b75787262   → {"state_type_id":"05", "file_cdr":"UEsDB…"}
GET /downloads/document/xml/978f1b9a-6bff-4cd1-ac1d-d18b75787262       → 200 text/xml
GET /downloads/document/pdf/978f1b9a-6bff-4cd1-ac1d-d18b75787262/a4    → 200 application/pdf
GET /downloads/document/cdr/978f1b9a-6bff-4cd1-ac1d-d18b75787262       → 200 application/zip
```

#### No todo comprobante tiene CDR propio

El XML y el PDF existen desde que la fila vuelve con `success: true`. El CDR es la respuesta de
SUNAT, y solo existe si SUNAT respondió **por ese comprobante**:

| Comprobante | ¿CDR propio? | Dónde está |
|---|---|---|
| Factura y notas de factura en `05` o `07` | Sí | `/downloads/document/cdr/{external_id}`. En `05` viene también en `file_cdr` de `document_check_server`, en base64 |
| Factura en `01` | Todavía no: no se envió | Envíala con `POST /api/documents/send` y después pídelo → [26](26-envio-diferido-update-estado.md#1-enviar-documento-a-sunat) |
| Boleta de **envío individual** en `05` | Sí | `/downloads/document/cdr/{external_id}`. `file_cdr` llega `null`: solo se llena en facturas |
| Boleta que se declara **por resumen** | No, nunca | El CDR es el del resumen: `/downloads/summary/cdr/{external_id del resumen}` → [39](39-ciclo-de-la-boleta.md#paso-4) |
| Nota de venta (`80`) | No es comprobante electrónico: no tiene XML ni CDR | Solo PDF: `/sale-notes/print/{external_id}/a4` o `/ticket` |
| Guía (`09`, `31`) aceptada | Sí | `/downloads/dispatch/xml/{external_id}`, `…/pdf/…` y `…/cdr/…`. El envío y la consulta del ticket van aparte → [guías](../../guias-de-remision.md) |

Pedir el CDR de un comprobante que no lo tiene responde **HTTP 500**: una página de error HTML o,
con `Accept: application/json`, `Unable to retrieve the file_size for file at location: cdr/…`.
No es una caída ni se arregla reintentando. Por eso el orden es: primero el estado, y el CDR solo
si le corresponde.

Comprobado en vivo el 2026-09-21: F001-3 (factura aceptada), B001-10 (envío individual, CDR
propio), B001-9 (en `01`, esperando el resumen: su CDR da 500, su XML y su PDF dan 200), NV01-182
(nota de venta, solo PDF) y V999-90005 (guía, los tres archivos).

#### Desde SQL Server

Con el `external_id` de la fila ya guardado, las tres URL salen de concatenar:

```sql
-- @Base: la dirección a la que llamas al lote, sin la ruta. Por ejemplo 'http://127.0.0.1:8080'.
-- @ExternalId: data.external_id de la fila de sync-batch.
SELECT CONCAT(@Base, '/downloads/document/xml/', @ExternalId)       AS url_xml,
       CONCAT(@Base, '/downloads/document/pdf/', @ExternalId, '/a4') AS url_pdf,
       CONCAT(@Base, '/downloads/document/cdr/', @ExternalId)       AS url_cdr;  -- solo si le corresponde
```

Y el estado, con la misma llamada que ya haces al lote pero por `GET` a
`/api/document_check_server/{external_id}`, leyendo `JSON_VALUE(@Resp, '$.state_type_id')`.

#### Sin pasar por la API

- **El panel:** el listado de comprobantes tiene los botones *XML*, *PDF* y *CDR* de cada uno.
- **La consulta pública `/buscar`** del dominio de la empresa: el cliente final encuentra su
  comprobante con su RUC o DNI, la fecha, el tipo, la serie, el número y el total, y lo descarga.
- **El envío automático al cliente**, por correo ([36](36-envio-automatico-por-correo.md)) o por
  WhatsApp ([38](38-envio-de-comprobantes-por-whatsapp.md)).

Si necesitas todo el recorrido —del `01` al CDR y la anulación—:
[39 — Ciclo de la boleta](39-ciclo-de-la-boleta.md) (por resumen) y
[40 — Ciclo de la factura y de la boleta de envío individual](40-ciclo-de-la-factura-y-envio-individual.md).

### Response con errores parciales

```json
{
    "success": true,
    "message": "Sincronización completada con errores",
    "data": {
        "results": [
            {
                "index": 0,
                "success": true,
                "offline_id": "a1b2c3d4-...",
                "doc_type": "80",
                "data": { "id": 25, "number": "NV01-25" }
            },
            {
                "index": 1,
                "success": false,
                "offline_id": "b2c3d4e5-...",
                "doc_type": "03",
                "message": "La serie ingresada B001, es incorrecta.",
                "error_code": "INVALID_SERIES"
            },
            {
                "index": 2,
                "success": true,
                "offline_id": "b2c3d4e5-...",
                "doc_type": "03",
                "data": { "id": 123, "number": "B001-90" },
                "was_duplicate": true
            }
        ],
        "total": 3,
        "success_count": 2,
        "error_count": 1
    }
}
```

### Avisos de facturas, boletas y notas — `data.warnings`

:::info Desde el 2026-09-16
Las filas `01`, `03`, `07` y `08` emitidas traen `data.warnings`, como las guías (ver más abajo).
Es un campo **añadido**: si tu integración no lo lee, sigue funcionando igual.
:::

Un aviso **no es un fallo**: el comprobante ya está emitido con su número y la fila sigue con
`success: true`. Márcala como sincronizada y corrige el dato en tu sistema para las próximas
ventas. **No la reenvíes**: con el mismo `offline_id` volvería como `was_duplicate`, y esas filas
no traen `warnings`.

**Trata `data.warnings` como opcional.** Falta en dos casos, aunque la fila sea correcta:

- las filas con `was_duplicate: true`, que se arman con el comprobante que ya existía;
- el duplicado que el servidor recupera de un error 1062 de MySQL (la misma serie y número ya
  estaban emitidos): la fila llega con `success: true` y los datos del comprobante existente, sin
  `warnings`.

Hoy el único aviso de estas filas es `CODIGO_PRODUCTO_SUNAT_IGNORADO`: un `codigo_producto_sunat`
que no tiene 8 dígitos y no sustituye al código registrado en el producto.

```json
{
    "index": 0,
    "success": true,
    "offline_id": "e5f6a7b8-c9d0-4e12-9f34-56789abcdef0",
    "doc_type": "01",
    "data": {
        "id": 124,
        "number": "F001-58",
        "external_id": "8c2d4e6f-1a3b-4c5d-8e7f-9a0b1c2d3e4f",
        "warnings": [
            {
                "codigo": "CODIGO_PRODUCTO_SUNAT_IGNORADO",
                "campo": "items.0.codigo_producto_sunat",
                "mensaje": "Ítem #1: 'codigo_producto_sunat' llegó como '200020001' y no es válido: debe tener 8 dígitos (catálogo 25 de SUNAT), por ejemplo '11101906'. El comprobante lleva el código registrado en el producto; si esta línea creó el producto, quedó registrado con ese mismo valor y conviene corregirlo en Productos."
            }
        ],
        "cash_registered": true
    },
    "cash_registered": true,
    "cash_error_code": null,
    "cash_message": null
}
```

Las claves son las mismas que en los avisos de guía: `codigo`, `campo` y `mensaje`. `campo` cuenta
las líneas desde 0 (`items.0` es la primera) y el `mensaje`, desde 1 («Ítem #1»). Qué hace el
servidor con cada valor de `codigo_producto_sunat`:
[Errores de la API → avisos](../../errores-de-la-api.md#codigo_producto_sunat_ignorado).

---

## Flujo Interno del Backend

```
syncBatch(Request $request)
│
├── foreach sales as $index => $sale
│   │
│   ├── Verificar offline_id → ¿ya existe en BD?
│   │   ├── SÍ → retornar datos existentes (was_duplicate: true)
│   │   └── NO → continuar procesamiento
│   │
│   ├── switch(doc_type)
│   │   ├── "80"  → processSaleNote($sale['data'])
│   │   │          → SaleNoteController internamente
│   │   │          → Guardar offline_id en sale_notes.offline_id
│   │   │
│   │   ├── "01","03","07","08" → processDocument($sale['data'])
│   │   │          → DocumentTransform → Validation → Input
│   │   │            └─ Validation incluye validateDateOfIssue()
│   │   │               ⚠ rechaza si la fecha excede shipping_time_days
│   │   │          → Facturalo::save()
│   │   │          → Guardar offline_id en documents.offline_id
│   │   │
│   │   ├── "09"  → processDispatch($sale['data'])
│   │   │          → DispatchTransform → Validation → Input
│   │   │          → save()
│   │   │          → Guardar offline_id en dispatches.offline_id
│   │   │
│   │   └── "31"  → processDispatchCarrier($sale['data'])
│   │              → Similar a "09" pero con DispatchCarrierController
│   │              → Guardar offline_id en dispatches.offline_id
│   │
│   ├── Registrar en caja → registerInCash(cash_id, document/sale_note)
│   │   └── CashDocument::firstOrCreate() → idempotente
│   │
│   └── Agregar resultado (success/error) al array results[]
│
└── Retornar response con results[], total, success_count, error_count
```

---

## Manejo de Errores por Tipo

### Documento duplicado (filename unique constraint)

Si un documento `01`/`03`/`07`/`08` tiene un filename que ya existe, el backend:
1. Captura el error MySQL 1062 (duplicate entry)
2. Busca el documento existente por filename
3. Retorna los datos del documento existente como éxito con `was_duplicate: true`

### Nota de Venta duplicada

La tabla `sale_notes` **NO tiene constraint unique** en filename. Por eso la verificación de `offline_id` es **crítica** para evitar duplicados.

### Error de validación

Si los datos no pasan la validación (serie incorrecta, cliente no encontrado, etc.), se retorna `success: false` con el mensaje de error. Los demás comprobantes continúan procesándose.

### Códigos de error — `error_code`

> Si lo que tienes es un síntoma y no un código —«todo el lote falla igual desde ayer», «se
> reenvía sin fin», «SUNAT rechaza lo que la API aceptó»— empieza por
> [Solución de problemas](../../solucion-de-problemas.md).

:::info Desde el 2026-09-04
**Toda** fila fallida de `results[]` trae `error_code`, un código estable para ramificar sin
tener que leer el texto del `message`. Es un campo **añadido**: si tu integración solo lee
`success` y `message`, sigue funcionando igual.
:::

| `error_code` | Significa | ¿Reintentar? |
|---|---|---|
| `MISSING_FIELDS` | Falta `doc_type`/`data`, o un campo obligatorio del comprobante. Desde el 2026-09-09 el `message` **nombra el campo** y `errors.faltantes` lo lista | ❌ No, sin corregir |
| `NO_ITEMS` | El comprobante llegó sin ítems | ❌ No, sin corregir |
| `INVALID_PAYLOAD` | No pasó la validación previa o una regla de negocio | ❌ No, sin corregir |
| `INVALID_REFERENCE` | Un código enviado no existe en el catálogo destino | ❌ No, sin corregir |
| `NULL_NOT_ALLOWED` | Se envió `null` en un campo que no lo admite | ❌ No, sin corregir |
| `INVALID_ENCODING` | El cuerpo no es UTF-8 válido | ❌ No, sin corregir |
| `VALUE_TOO_LONG` · `VALUE_OUT_OF_RANGE` | Texto o importe fuera del ancho del campo | ❌ No, sin corregir |
| `CONFLICT_NUMBER` | El correlativo ya lo usó **otra** venta | ⚠️ Renumerar y reemitir |
| `DISPATCH_NOT_FOUND` · `DISPATCH_ALREADY_ACCEPTED` · `DISPATCH_NUMBER_TAKEN` | Solo guías: una corrección con `external_id` que no se puede aplicar, porque la guía no existe, SUNAT ya la aceptó, o SUNAT ya tiene su número (`1032`/`1033`) → [corregir una guía rechazada por el lote](#corregir-una-guía-rechazada-por-el-lote) | ❌ No |
| `DATABASE_ERROR` | Fallo de base de datos **del servidor**, no de tu payload. Desde el 2026-09-15 `errors.tipo` dice cuál (ver abajo) | ⚠️ Según `errors.tipo` |
| `PROCESSING_ERROR` | Excepción que el servidor no sabe atribuir. **Ya no incluye campos ausentes del payload** | ⚠️ Uno, y escalar con el `offline_id` |

:::warning Si reintentas `PROCESSING_ERROR` sin límite, ponle tope
Hasta el 2026-09-09 **un campo ausente del payload salía con este código**, y con este texto:

> El payload no contiene los campos requeridos por el servidor. Revise los ítems del documento antes de reintentar.

Dos problemas a la vez. El código decía «es del servidor, reintenta», así que un error
permanente entraba en bucle; y el mensaje mandaba a revisar los ítems aunque el campo que
faltara fuera de cabecera. Un integrador de guías de remisión estuvo reintentando
indefinidamente un payload que el servidor nunca iba a aceptar, mirando el único sitio donde no
estaba el problema.

Ahora esa familia sale como `MISSING_FIELDS` nombrando el campo. `PROCESSING_ERROR` y
`DATABASE_ERROR` siguen admitiendo reintento, pero **uno** y luego escalar: un fallo que se
repite casi nunca se arregla volviendo a enviar lo mismo.
:::

#### `DATABASE_ERROR`: qué dice `errors.tipo`

:::info Desde el 2026-09-15
Antes este código llegaba con el texto *«Error de base de datos al procesar el documento. Revise el
payload e intente nuevamente.»*, aunque el fallo fuera del servidor. Ahora el `message` dice qué
pasó y el bloque `errors` lo da estructurado. `error_code` no cambia: si solo lees `success` y
`message`, sigue funcionando igual.
:::

```json
{
  "index": 0,
  "offline_id": "8F0E2C31-6A4B-4D2E-9B7C-3E5D1A2F4B60",
  "success": false,
  "doc_type": "09",
  "message": "La base de datos del servidor está desactualizada: falta la columna 'seal_number' en la tabla 'dispatches'. No es un problema del payload y reintentar no lo arregla hasta que se actualice el servidor: avisa a soporte técnico.",
  "error_code": "DATABASE_ERROR",
  "errors": { "tipo": "esquema_desactualizado", "codigo_mysql": 1054, "tabla": "dispatches", "columna": "seal_number" }
}
```

| `errors.tipo` | Qué pasó | ¿Reintentar? |
|---|---|---|
| `esquema_desactualizado` | Al servidor le falta una actualización de base de datos. Trae `tabla` y, si aplica, `columna` | ❌ No: avisa a soporte con el `offline_id` y reenvía cuando confirmen |
| `bloqueo_temporal` | La base de datos estaba ocupada y canceló la operación | ✅ Una vez |
| `restriccion_no_atribuible` | Un dato que **pone el servidor**, no tu payload, no cumple una restricción de la base. Trae `restriccion` y `tabla` | ❌ No: se repetirá igual. Avisa a soporte con el `offline_id` y el nombre de la `restriccion` |
| `no_clasificado` | Otro fallo de base de datos. Trae `sqlstate` y `codigo_mysql` | ⚠️ Uno, y escalar con el `offline_id` |

:::warning `restriccion_no_atribuible` no se arregla reintentando
Desde el **2026-09-17**. Antes este caso llegaba como `no_clasificado`, que la tabla publica como
«reintenta una vez», y el nombre de la restricción —lo único que permite localizar el fallo— solo
existía en el log del servidor.

No hay nada que corregir en tu payload: el valor que la base rechaza lo escribe el servidor, así
que reenviar lo mismo dará el mismo error. Manda a soporte el `offline_id` y el `restriccion` que
viene en `errors`.

```json
{
  "message": "El servidor intentó guardar un dato que no cumple la restricción 'dispatch_addresses_person_id_foreign' de la tabla 'dispatch_addresses' (MySQL 1452). No es un problema del payload y reintentar no lo arregla: avisa a soporte técnico.",
  "error_code": "DATABASE_ERROR",
  "errors": { "tipo": "restriccion_no_atribuible", "codigo_mysql": 1452, "tabla": "dispatch_addresses", "restriccion": "dispatch_addresses_person_id_foreign" }
}
```

Ojo con la diferencia: cuando el valor rechazado **sí** viene de tu payload, el error no es este,
sino `INVALID_REFERENCE`, que nombra el campo que enviaste y, si el catálogo es del propio
sistema, lista los valores válidos.
:::

La respuesta nunca trae el SQL ni datos internos de la base: soporte encuentra el detalle en el log
del servidor buscando el `offline_id`.

Los códigos de validación llegan por esta vía exactamente igual que por `/api/documents`:
ver **[Errores de la API](../../errores-de-la-api.md)** para el catálogo completo, los
mensajes literales y qué corregir en cada caso.

---

## Registro en caja — `cash_registered` y `cash_error_code`

:::info Desde el 2026-09-09
`cash_error_code` es nuevo. `cash_registered` existía pero no estaba documentado.
Ambos viajan en filas con `success: true`, porque **el registro en caja es independiente de
la emisión**: una venta puede emitirse correctamente y no llegar a su caja.
:::

Cada fila de `results[]` lleva estos dos campos:

| Campo | Tipo | Significa |
|---|---|---|
| `cash_registered` | bool | `true` si la venta está en una caja, ya sea porque se registró ahora o porque ya lo estaba |
| `cash_error_code` | string \| null | `null` cuando `cash_registered` es `true`. Si no, cuál de los cuatro fallos fue |
| `cash_message` | string \| null | Frase lista para enseñar al cajero: nombra la caja concreta y dice si hay que reintentar |

Ejemplo de una fila con fallo de caja. Fíjate en que `success` es `true`:

```json
{
  "index": 0,
  "offline_id": "7c445379-377a-4219-8763-eeb08fff84d2",
  "success": true,
  "doc_type": "01",
  "data": { "id": 8, "number": "B001-8" },
  "was_duplicate": true,
  "cash_registered": false,
  "cash_error_code": "CASH_NOT_FOUND",
  "cash_message": "La venta se emitió correctamente, pero la caja #999999 no existe en el servidor. Envía su apertura en cash_openings y reintenta esta venta UNA vez."
}
```

`cash_message` empieza siempre por «La venta se emitió correctamente» a propósito: el fallo
llega en una fila de éxito y, sin esa frase, un cajero puede creer que la venta se perdió y
volver a emitirla.

### La idempotencia se comprueba antes que el payload

:::info Desde el 2026-09-09
Si el `offline_id` corresponde a una venta **ya sincronizada**, el servidor la devuelve como
`was_duplicate: true` **sin mirar el `data`**. Puedes reenviarla con el payload vacío.
:::

Antes se validaba primero, así que un reenvío con el payload incompleto —o con un formato
que hubiera cambiado desde que la venta se emitió— salía como `INVALID_PAYLOAD` en vez de
como duplicado, y esa fila se quedaba atascada para siempre reintentando algo que el
servidor nunca iba a aceptar.

`data` sigue siendo obligatorio para una venta que **no** está sincronizada todavía; en ese
caso el error es `MISSING_FIELDS`.

**Esto incluye las correcciones.** Si reenvías una guía rechazada con su mismo `offline_id` y el
JSON corregido, pero **sin su `external_id`**, vuelve como `was_duplicate` y la corrección no se
aplica. Con el `external_id`, desde el 2026-09-18, se corrige →
[corregir una guía rechazada por el lote](#corregir-una-guía-rechazada-por-el-lote).

### `cash_summary` — el recuento del lote

`data.cash_summary` trae cuántas ventas cayeron en cada desenlace, para ver de un vistazo si
el lote entero choca contra lo mismo sin recorrer `results[]`:

```json
"cash_summary": { "already_registered": 1948, "CASH_CLOSED": 22 }
```

Las claves son los `cash_error_code` más `ok`, `already_registered` y `not_applicable`.

### Los cuatro códigos

| `cash_error_code` | Significa | Qué debe hacer el app |
|---|---|---|
| `CASH_NOT_FOUND` | La caja que pediste no existe en el servidor | Mandar su apertura en `cash_openings[]` y reintentar **una** vez |
| `CASH_OTHER_USER` | La caja existe pero pertenece a otro usuario | ❌ No reintentar. Es un error de datos del app |
| `CASH_CLOSED` | La caja existe y es tuya, pero ya se cerró | ❌ No reintentar. Ver abajo |
| `CASH_NONE_OPEN` | No mandaste caja y el usuario no tiene ninguna abierta | Abrir caja y reintentar |

### Regla que evita el bucle infinito

**Con `cash_registered: true`, da la venta por terminada y no la vuelvas a enviar.** Vale
igual que `was_duplicate: true`.

Esto no es un detalle de estilo. Hasta el 2026-09-09 el backend respondía `false` a toda
venta cuya caja original ya estuviera cerrada, aunque la venta estuviera perfectamente
registrada en otra caja. Como el estado «pendiente de caja» vive solo en el SQLite del app,
el lote entero se reenviaba en cada sincronización: en un tenant real eso eran **7.250 avisos
por lote para 2.086 ventas, de las que 2.064 estaban bien**. Desde esa fecha el backend
responde `true` con `cash_error_code: null` en cuanto la venta ya figura en cualquier caja.

### Por qué `CASH_CLOSED` no se reintenta

Una caja cerrada no vuelve a abrirse, así que el reintento no puede tener éxito nunca.

Ocurre cuando la venta se emitió sin conexión durante un turno y se sincronizó después de
cerrarlo. En ese caso la venta **ya quedó registrada** en la caja que estuviera abierta al
sincronizar, así que su importe no se ha perdido: cuenta en el arqueo del día en que se
sincronizó, no en el del turno en que se hizo. Volver a engancharla a su caja original la
contaría dos veces.

### Comprobantes que no pasan por caja

Los `doc_type` `09`, `31` (guías de remisión) y `20` (retención) no mueven el efectivo del
cajón. Siempre devuelven `cash_registered: true` y `cash_error_code: null`.

La retención se excluyó el 2026-09-09: la columna `cash_documents.document_id` tiene clave
foránea contra `documents`, y el id de un `doc_type` `20` pertenece a `retentions`. O tumbaba
la venta entera con un error de integridad, o —peor— enganchaba la caja a un documento ajeno
cuyo id coincidiera, falseando el arqueo sin dar ningún error.

#### Antes: un mensaje que no nombraba nada

Hasta el 2026-09-04, cualquier violación de restricción de la base salía como:

```json
{
  "index": 4,
  "offline_id": "C9C52DCB-D5C4-4476-A8CE-8989F1351DF1",
  "success": false,
  "doc_type": "01",
  "message": "Error de base de datos al procesar el documento. Revise el payload e intente nuevamente."
}
```

Un lote entero podía devolver esa frase por **tres causas distintas** sin manera de
distinguirlas. Ahora cada una nombra su campo:

```json
{
  "index": 4,
  "offline_id": "C9C52DCB-D5C4-4476-A8CE-8989F1351DF1",
  "success": false,
  "doc_type": "01",
  "message": "El valor enviado en 'codigo_condicion_de_pago' no existe. No es un catálogo de SUNAT: son las condiciones de pago del propio tenant. Para crédito con cuotas usa 02; el 03 que ofrece el panel es estado de pantalla y nunca se envía por API. Valores válidos en este tenant: 01, 02.",
  "error_code": "INVALID_REFERENCE",
  "errors": {
    "campo": "codigo_condicion_de_pago",
    "valores_validos": ["01", "02"]
  }
}
```

:::warning Los tres tropiezos más frecuentes al integrar desde un ERP propio

1. **`codigo_condicion_de_pago: "03"`** — por API solo existen `01` Contado y `02` Crédito
   (este último es el que corresponde si envías `cuotas`). El `03` que ves en el panel es
   estado de pantalla: se convierte a `02` antes de enviar. Ojo, en un tenant que sí tenga
   la fila `03` **no falla**, emite sin `FormaPago` y sin cuotas. Ver
   [Condiciones de Pago](09-boleta-factura.md#condiciones-de-pago-codigo_condicion_de_pago).
2. **`ubigeo: ""`** — la cadena vacía no es «sin dato». Omite la clave o envía `null`.
3. **`codigo_tipo_documento_identidad: null`** — obligatorio: `6` para RUC, `1` para DNI.

Los tres devolvían el mismo mensaje genérico y hacían fallar el lote completo.
:::

### Fecha de emisión fuera de plazo

:::warning `sync-batch` aplica la MISMA validación de fecha que `/api/documents`
Para `doc_type` `01`/`03`/`07`/`08`, `processDocument()` invoca la **misma clase** `Api\DocumentValidation` que usa `POST /api/documents`, la cual llama a `Functions::validateDateOfIssue()`. **Sincronizar por la vía offline no evita el control de plazo.**
:::

Con la configuración por defecto (`shipping_time_days = 4`, `restrict_receipt_date = true`), un comprobante con más de **3 días** de antigüedad se rechaza:

```json
{
  "index": 1,
  "offline_id": "c3d4-e5f6-...",
  "success": false,
  "doc_type": "01",
  "message": "La fecha de emisión no puede ser menor a 4 día(s).",
  "error_code": "ISSUE_DATE_OUT_OF_RANGE"
}
```

A diferencia de `/api/documents` (que responde con un status de error — **422**, o **500** en versiones anteriores a 2026-09-02), aquí el HTTP es **200** y el fallo viaja dentro de `results[]`: el resto del lote se sincroniza sin problema. `sync-batch` atrapa la excepción en su `try/catch` por venta, así que el cambio de status del endpoint directo **no le afecta**.

**Es un error permanente**, no transitorio: reintentar mañana empeora la diferencia de días. Márcalo como `ERROR_PERMANENTE` y sácalo de la cola de reintentos automáticos — puedes detectarlo por `error_code: "ISSUE_DATE_OUT_OF_RANGE"` sin leer el texto.

Los `doc_type` `80` (nota de venta), `09`/`31` (guías) y `20` (retención) **no** pasan por esta validación.

📘 Regla completa, cálculo, asimetrías web/API y configuración: **[35 — Plazo de la Fecha de Emisión](35-plazo-fecha-emision.md)**.

---

## Guías de remisión por lote — `09` y `31`

:::info Desde el 2026-09-09
Esta página describía las guías como pendientes de implementar. **No lo están: el lote acepta
`09` y `31` desde hace tiempo**, con su propia idempotencia por `offline_id` contra la tabla
`dispatches`. Si tu integración las estaba mandando de una en una por `POST /api/dispatches` (la
`09`) o por `POST /api/dispatch-carrier` (la `31`), puedes pasarlas al lote sin cambiar el `data`.
:::

Los siete tipos que acepta `sync-batch` y dónde se guarda su `offline_id`:

| `doc_type` | Tabla `offline_id` | Pasa por caja |
|---|---|---|
| `"80"` nota de venta | `sale_notes.offline_id` | Sí |
| `"01"` `"03"` `"07"` `"08"` | `documents.offline_id` | Sí |
| `"09"` `"31"` guías de remisión | `dispatches.offline_id` | No |
| `"20"` retención | `retentions.offline_id` | No |

### La `31` por lote: el mismo `data` que `POST /api/dispatch-carrier`

**No hay un formato de lote para la guía transportista.** El `data` de una fila
`"doc_type": "31"` es, campo por campo, el JSON de
[14 — Guía Transportista](14-guia-remision-transportista.md), y pasa por el mismo código. Lo único
que añade el lote es el sobre: `doc_type`, `offline_id` y `data`. Lo mismo vale para la `09` y
[13 — Guía Remitente](13-guia-remision-remitente.md).

La confusión habitual es otra: partir del [ejemplo de la `09`](#ejemplo-completo-de-una-fila-09)
para armar una `31`. Son dos guías distintas y cada una lleva sus bloques:

| Qué | Guía remitente `09` | Guía transportista `31` |
|---|---|---|
| Quién la emite | El dueño de la mercadería | La empresa de transporte |
| Remitente | Tu empresa: sale del token | `datos_remitente` |
| Destinatario | `datos_del_cliente_o_receptor` | `datos_destinatario` |
| Punto de partida | `direccion_partida` | `direcciones_proveedores.remitente` |
| Punto de llegada | `direccion_llegada` | `direcciones_proveedores.destinatario` |
| Transportista | `transportista`, en transporte público (`01`) | No va: el transportista eres tú. Si lo mandas, se descarta con el aviso `TRANSPORTISTA_IGNORADO` |
| Conductor | `chofer`, en transporte privado (`02`) | `chofer`, siempre |
| Quién paga el flete | — | `pagador_flete` |

Hay un [ejemplo completo de una fila `31`](#ejemplo-completo-de-una-fila-31) más abajo, con la
respuesta y los [errores típicos](#errores-típicos-de-la-31-por-lote).

### Los ítems de una guía no llevan precio

Es la duda más frecuente al integrar guías desde un ERP, porque el ejemplo de esta página
copiaba los ítems de una factura. **Una guía de remisión no tiene importes**: la tabla
`dispatch_items` no tiene columna de precio y el XML `DespatchAdvice` solo emite tres cosas por
línea — cantidad, descripción y código de producto.

Manda solo esto:

```json
{ "codigo_interno": "200020001", "descripcion": "CONCENTRADO DE COBRE",
  "unidad_de_medida": "TNE", "cantidad": 9.57 }
```

| Campo | Requerido |
|---|---|
| `codigo_interno` | **Sí**. Sin él todas las líneas se agrupan en un mismo producto y la guía sale con un solo detalle |
| `cantidad` | **Sí**, mayor que 0. Se guarda con 4 decimales: si envías más, se redondea y avisa `REDONDEO_CANTIDAD` |
| `descripcion` | Solo si el `codigo_interno` **no existe todavía** y hay que crear el producto |
| `unidad_de_medida` | Obligatoria al crear el producto. **Si la envías con un producto que ya existe, es la que viaja en el XML** de esa línea; si no, se usa la del producto |
| `valor_unitario` | Opcional incluso al crear: el producto nace con precio 0, visible en el panel para corregirlo |

`precio_unitario`, `total_item`, `porcentaje_igv`, `total_base_igv` y el resto del bloque de una
factura se aceptan por compatibilidad y **se descartan**: no llegan al XML.

### Qué pide cada tipo

Comunes a `09` y `31`: `serie_documento`, `numero_documento`, `codigo_tipo_documento`,
`fecha_de_emision`, `hora_de_emision`, `fecha_de_traslado`, `unidad_peso_total`, `peso_total`,
`items`.

Solo `09`: `datos_del_cliente_o_receptor`, `direccion_partida`, `direccion_llegada`,
`codigo_modo_transporte`, `codigo_motivo_traslado`, y **según la modalidad**: `transportista`
si es `01` (transporte público) o `chofer` si es `02` (transporte privado).

Solo `31`: `datos_remitente`, `datos_destinatario`, `chofer` y **el punto de partida y el de
llegada**, cada uno con `ubigeo` y `direccion`, por una de estas tres vías:

1. `direcciones_proveedores.remitente` (partida) y `direcciones_proveedores.destinatario`
   (llegada). Es la recomendada.
2. `direccion_remitente_id` / `direccion_destinatario_id`: el id de una dirección ya registrada.
3. `direccion_partida` / `direccion_llegada`, la forma de la `09`. Solo se usa si no llega ninguna
   de las otras dos. Si llegan las dos formas, manda `direcciones_proveedores` y la fila avisa
   `DIRECCION_PARTIDA_IGNORADA` / `DIRECCION_LLEGADA_IGNORADA`.

:::warning Desde el 2026-09-19, una `31` sin partida o sin llegada no se emite
Vuelve `MISSING_FIELDS` con lo que falta en `errors.faltantes` (por ejemplo
`direcciones_proveedores.remitente`), **sin gastar el número**. Antes se emitía igual: se firmaba
con `cac:DespatchAddress/cbc:ID` vacío y SUNAT la rechazaba con **2775** («El XML no contiene el
atributo o no existe información del código de ubigeo»), con el correlativo ya consumido.

También desde esa fecha, en la `31` la forma de la `09` ya no se descarta: si no mandas
`direcciones_proveedores`, `direccion_partida` y `direccion_llegada` son la partida y la llegada.
Antes se aceptaban y se tiraban sin avisar, y era la causa más común del 2775.
:::

`datos_del_emisor` es **opcional** en ambos: si no lo mandas se usa el establecimiento del
usuario del token, igual que en `POST /api/documents`.

`datos_del_cliente_o_receptor.codigo_pais` también es **opcional** desde el 2026-09-09: si no lo
mandas se asume `PE`, que es lo que ya hacían el panel y la API de notas de venta. Si el cliente
**ya existe** con otro país, no se le toca.

### `signed` y `sign_message`

:::info Desde el 2026-09-09
Las filas de guía traen dos campos nuevos dentro de `data`. Son **añadidos**: si tu integración
solo lee `success` y `data.number`, sigue funcionando igual.
:::

| Campo | Significa |
|---|---|
| `signed` | `true` si el XML se generó, se firmó y el PDF se creó |
| `sign_message` | El motivo cuando `signed` es `false`; `null` si todo fue bien |
| `warnings` | Desde el 2026-09-14. Los avisos previos de la guía: lo que SUNAT va a observar o rechazar y lo que el sistema va a guardar distinto de como lo enviaste, igual que en `POST /api/dispatches`. No convierten la fila en fallo. Ver [avisos antes de emitir](../../guias-de-remision.md#avisos-antes-de-emitir) |
| `state_type_id` | Desde el 2026-09-18, solo en las filas `was_duplicate`: el estado de la guía que ya estaba (`01` Registrado, `03` Enviado, `05` Aceptado, `09` Rechazado, `11` Anulado). Si es `09`, la fila trae además en `warnings` el aviso `GUIA_RECHAZADA_SIN_CORREGIR` → [corregir una guía rechazada por el lote](#corregir-una-guía-rechazada-por-el-lote) |

Antes, si la firma fallaba, la guía volvía como `success: true` sin decirlo: una guía sin firmar
era indistinguible de una firmada.

:::warning `signed: false` NO se reenvía por sync-batch
La guía **ya está emitida** y su correlativo consumido; reenviarla volvería como duplicada. Lo
que hay que hacer es rehacer el archivo y mandarla con `POST /api/dispatches/send`.
:::

:::caution Una corrección con `signed: false` sí se reenvía
Desde el 2026-09-19, si **corriges** una guía por el lote (`was_corrected: true`) y la firma falla,
el servidor retira el XML firmado anterior y la fila trae el aviso `CORRECCION_SIN_FIRMA`. Antes
ese archivo se quedaba, y `POST /api/dispatches/send` lo mandaba: a SUNAT le llegaba la guía **sin
corregir** y la volvía a rechazar por lo mismo. Ahora `send` responde que la guía no tiene XML
firmado. Reenvía la misma fila de corrección y, cuando vuelva con `signed: true`, envíala.
:::

### Ejemplo completo de una fila `09`

Una guía remitente de transporte público con vehículos y conductores del transportista, con datos
ficticios. Lleva **a propósito** dos descuidos para que veas cómo vuelven los avisos: el peso con
tres decimales y el documento relacionado sin `descripcion`.

```json
{
    "sales": [
        {
            "doc_type": "09",
            "offline_id": "d4e5f6a7-b8c9-4012-8def-234567890123",
            "data": {
                "serie_documento": "T001",
                "numero_documento": "14",
                "fecha_de_emision": "2026-09-11",
                "hora_de_emision": "10:00:00",
                "codigo_tipo_documento": "09",
                "datos_del_cliente_o_receptor": {
                    "codigo_tipo_documento_identidad": "6",
                    "numero_documento": "20000000001",
                    "apellidos_y_nombres_o_razon_social": "MINERA DEMO S.A.C.",
                    "ubigeo": "150101",
                    "direccion": "Av. Ejemplo 123 - Lima"
                },
                "codigo_modo_transporte": "01",
                "codigo_motivo_traslado": "14",
                "descripcion_motivo_traslado": "Venta sujeta a confirmación del comprador",
                "fecha_de_traslado": "2026-09-12",
                "fecha_entrega_transporte": "2026-09-11",
                "indicador_de_transbordo": false,
                "indicador_vehiculos_conductores_transportista": true,
                "unidad_peso_total": "TNE",
                "peso_total": 34.825,
                "numero_de_bultos": 1,
                "direccion_partida": { "ubigeo": "150101", "direccion": "Av. Almacén 456 - Lima" },
                "direccion_llegada": { "ubigeo": "070101", "direccion": "Jr. Destino 789 - Callao" },
                "transportista": {
                    "codigo_tipo_documento_identidad": "6",
                    "numero_documento": "20000000002",
                    "apellidos_y_nombres_o_razon_social": "TRANSPORTES DEMO S.R.L.",
                    "numero_mtc": "1500001CNG",
                    "numero_autorizacion_especial": "1500002MRP",
                    "codigo_entidad_autorizadora": "06"
                },
                "chofer": {
                    "codigo_tipo_documento_identidad": "1",
                    "numero_documento": "12345678",
                    "nombres": "PEREZ GARCIA, JUAN",
                    "numero_licencia": "Q12345678"
                },
                "vehiculo": {
                    "numero_de_placa": "ABC123",
                    "certificado_habilitacion_vehicular": "15MRP00000001E",
                    "numero_autorizacion_especial": "1500003CNG",
                    "codigo_entidad_autorizadora": "06"
                },
                "vehiculo_secundario": [
                    { "numero_de_placa": "DEF456", "certificado_habilitacion_vehicular": "15MRP00000002E",
                      "numero_autorizacion_especial": "1500004CNG", "codigo_entidad_autorizadora": "06" }
                ],
                "documento_relacionado": [
                    { "numero": "1500002MRP", "empresa": "TRANSPORTES DEMO S.R.L.", "ruc": "20000000002",
                      "documento": { "id": "76" } }
                ],
                "items": [
                    { "codigo_interno": "P0001", "descripcion": "RESIDUOS SOLIDOS NO PELIGROSOS",
                      "unidad_de_medida": "TNE", "cantidad": 34.825 }
                ]
            }
        }
    ]
}
```

La entidad `06` (MTC) es de ejemplo: en cada autorización va el código D-37 de la entidad que la
otorgó.

La fila vuelve con `success: true`, firmada, y con los dos avisos en `data.warnings`:

```json
{
    "success": true,
    "message": "Sincronización completada",
    "data": {
        "results": [
            {
                "index": 0,
                "success": true,
                "offline_id": "d4e5f6a7-b8c9-4012-8def-234567890123",
                "doc_type": "09",
                "data": {
                    "id": 46,
                    "number": "T001-14",
                    "external_id": "7b1e0c4a-2f5d-4e8b-9c3a-5d6e7f8a9b0c",
                    "filename": "20123456789-09-T001-14",
                    "signed": true,
                    "sign_message": null,
                    "warnings": [
                        {
                            "codigo": "4371",
                            "campo": "documento_relacionado.0.documento.descripcion",
                            "mensaje": "El documento relacionado «76» no tiene descripción. SUNAT aceptará la guía pero la observará."
                        },
                        {
                            "codigo": "REDONDEO_PESO",
                            "campo": "peso_total",
                            "mensaje": "El peso total se guarda con 2 decimales: 34.825 se registrará como 34.83."
                        }
                    ]
                }
            }
        ],
        "total": 1,
        "success_count": 1,
        "error_count": 0
    }
}
```

Ninguno de los dos convierte la fila en fallo: la guía ya está emitida con el número `T001-14`. El
peso quedó en `34.83` y la cantidad, que admite 4 decimales, en `34.825`. Para que SUNAT no la
observe, corrige la descripción con el `external_id` antes de enviarla. Por el lote se hace como
se explica justo abajo; fuera del lote, como en
[corregir una guía rechazada](../../guias-de-remision.md#corregir-una-guía-rechazada).

### Ejemplo completo de una fila `31`

Una guía transportista de transporte privado con los datos de una integración real, con datos
ficticios: el remitente y el destinatario son terceros y las direcciones van en
`direcciones_proveedores`.

```json
{
    "sales": [
        {
            "doc_type": "31",
            "offline_id": "9d4dda7d-563f-4f16-99e6-777af5a7da7f",
            "data": {
                "serie_documento": "V001",
                "numero_documento": "1",
                "fecha_de_emision": "2026-09-19",
                "hora_de_emision": "10:00:00",
                "codigo_tipo_documento": "31",
                "codigo_modo_transporte": "02",
                "codigo_motivo_traslado": "01",
                "descripcion_motivo_traslado": "VENTA",
                "fecha_de_traslado": "2026-09-19",
                "indicador_de_transbordo": false,
                "unidad_peso_total": "TNE",
                "peso_total": 1.0,
                "numero_de_bultos": 1,
                "direcciones_proveedores": {
                    "remitente": { "ubigeo": "110301", "direccion": "Cal. Bolognesi 251 - Nasca" },
                    "destinatario": { "ubigeo": "110305", "direccion": "Mz. 10 Lt. 10 Ampliación Portachuelo" }
                },
                "datos_remitente": {
                    "codigo_tipo_documento_identidad": "6",
                    "numero_documento": "20000000001",
                    "apellidos_y_nombres_o_razon_social": "MINERA DEMO S.A.C."
                },
                "datos_destinatario": {
                    "codigo_tipo_documento_identidad": "6",
                    "numero_documento": "20000000003",
                    "apellidos_y_nombres_o_razon_social": "COMERCIAL DEMO S.A.C."
                },
                "chofer": {
                    "codigo_tipo_documento_identidad": "1",
                    "numero_documento": "12345678",
                    "nombres": "PEREZ GARCIA, JUAN",
                    "numero_licencia": "Q12345678"
                },
                "vehiculo": {
                    "numero_de_placa": "ABC123",
                    "modelo": "HILUX",
                    "marca": "TOYOTA",
                    "certificado_habilitacion_vehicular": "15M24000001E"
                },
                "pagador_flete": {
                    "indicador_pagador_flete": "Remitente",
                    "codigo_tipo_documento_identidad": "6",
                    "numero": "20000000001",
                    "nombres": "MINERA DEMO S.A.C."
                },
                "items": [
                    { "codigo_interno": "2000022003", "descripcion": "MINERAL MOLIDO DE COBRE",
                      "unidad_de_medida": "TNE", "cantidad": 1.0 }
                ]
            }
        }
    ]
}
```

No lleva `vehiculo_secundario` porque no hay segundo vehículo: una fila con solo
`"codigo_entidad_autorizadora": "06"` no es un vehículo (ver los errores típicos, abajo).

La fila vuelve firmada y con su `external_id`. **Guárdalo junto al `offline_id`**: es lo que
necesitas para enviarla, consultarla y, si SUNAT la rechaza, corregirla.

```json
{
    "index": 0,
    "offline_id": "9d4dda7d-563f-4f16-99e6-777af5a7da7f",
    "success": true,
    "doc_type": "31",
    "data": {
        "id": 58,
        "number": "V001-1",
        "external_id": "50cca68a-ddb7-4c1e-ac0c-33cda4b89eab",
        "filename": "20123456789-31-V001-1",
        "signed": true,
        "sign_message": null,
        "warnings": [],
        "cash_registered": true
    },
    "cash_registered": true,
    "cash_error_code": null,
    "cash_message": null
}
```

`warnings` puede traer observaciones de SUNAT que no impiden emitir, como `4391` si tu empresa no
tiene registrado su número del MTC → [avisos antes de emitir](../../guias-de-remision.md#avisos-antes-de-emitir).

El lote **no la envía a SUNAT**. Después vienen `send` y la consulta del ticket, como en el
[ciclo de una guía rechazada](#el-ciclo-completo-corregir-enviar-y-consultar).

### Errores típicos de la `31` por lote

| Lo que ves | Por qué | Qué hacer |
|---|---|---|
| SUNAT rechaza con **2775** (`cac:DespatchAddress/cbc:ID` vacío) | La guía se emitió sin ubigeo de partida. Pasaba, antes del 2026-09-19, al mandar `direccion_partida` en vez de `direcciones_proveedores` | Corrígela con su `external_id` y `direcciones_proveedores` ([abajo](#corregir-una-guía-rechazada-por-el-lote)). Desde el 2026-09-19 ya no se puede emitir así |
| `MISSING_FIELDS` con `direcciones_proveedores.remitente` o `.destinatario` | Falta el punto de partida o el de llegada | Manda el bloque con `ubigeo` y `direccion`. No se gastó ningún número |
| `INVALID_UBIGEO` | El ubigeo no está en el catálogo de distritos | Seis dígitos del catálogo INEI. `errors.campo` dice cuál |
| Aviso `VEHICULO_SECUNDARIO_VACIO` | Una fila de `vehiculo_secundario` sin placa ni datos, por ejemplo solo `"codigo_entidad_autorizadora": "06"` | Nada: no se declaró. Si no hay segundo vehículo, no mandes la fila. Antes salía al XML como un vehículo con la placa vacía |
| Avisos `DIRECCION_PARTIDA_IGNORADA` / `DIRECCION_LLEGADA_IGNORADA` | Mandaste las dos formas de dirección | Nada: se usó `direcciones_proveedores`. Quita la otra para no confundirte |
| SUNAT rechaza con **2108** («Presentación fuera de fecha») | Reenviaste una corrección con la `fecha_de_emision` de hace días | Fechas de hoy en `fecha_de_emision`, `hora_de_emision` y `fecha_de_traslado` |
| Reenvías la corrección y vuelve `was_duplicate`, sin `was_corrected` | La fila no lleva el `external_id` de la guía, o la guía no está Registrada ni Rechazada | `data.warnings` dice qué pasó: `GUIA_RECHAZADA_SIN_CORREGIR` o `CORRECCION_NO_APLICADA` |
| `was_corrected: true` con `signed: false` | La corrección se guardó pero no se pudo firmar | No la envíes: reenvía la fila. Viene con el aviso `CORRECCION_SIN_FIRMA` |
| `DISPATCH_NUMBER_TAKEN` | SUNAT ya tiene ese número (rechazo `1032`/`1033`) | Con ese número ya no pasa: emite otra guía con otro número y otro `offline_id` |

### Corregir una guía rechazada por el lote

Una guía que SUNAT rechaza **se corrige, no se vuelve a emitir**: conserva su serie, su número y
su `external_id`. Por el lote se puede, pero no reenviando la fila tal cual: la fila tiene que
llevar el `external_id` de la guía.

:::danger Reenviar la fila tal cual no corrige la guía
El `offline_id` se comprueba **antes** de leer el `data`
([ver arriba](#la-idempotencia-se-comprueba-antes-que-el-payload)). Si la guía ya está
sincronizada con ese `offline_id` y la fila no trae su `external_id`, vuelve con `success: true`
y `was_duplicate: true`, y **el JSON corregido no se aplica**: la guía sigue con los datos de la
primera vez. Si luego la envías a SUNAT, le llega el mismo XML de antes y la vuelve a rechazar.

Le pasó a un integrador real. Una guía de transportista rechazada con `2775` se reenvió por el
lote más de 320 veces, siempre con el mismo `offline_id`. Todas las respuestas decían
`success: true` y SUNAT la rechazó todas las veces.
:::

:::info Desde el 2026-09-18
- **Basta con el `external_id`.** Con el mismo `offline_id` de siempre, la guía se corrige si
  está Registrada (`01`) o Rechazada (`09`). Antes hacía falta además un `offline_id` nuevo, y
  esa forma sigue valiendo.
- La fila de una corrección trae **`was_corrected: true`**.
- La fila `was_duplicate` de una guía trae su **`state_type_id`**. Si la guía está rechazada,
  trae además el aviso **`GUIA_RECHAZADA_SIN_CORREGIR`**, que dice que el reenvío no cambió nada.

En un servidor anterior, con el mismo `offline_id` no se corrige nunca: usa uno nuevo, como se
explica abajo. Si no sabes de qué fecha es tu instalación, pregúntale a soporte.
:::

:::info Desde el 2026-09-19
Un reenvío que no corrige ya **no calla nunca**. Además de `GUIA_RECHAZADA_SIN_CORREGIR`:

- **`CORRECCION_NO_APLICADA`**: la fila trae un `external_id` pero la guía no se tocó. Dice por qué:
  es el de otra guía (y te da el bueno), o la guía está Enviada (`03`), Aceptada (`05`) o Anulada
  (`11`). La más traicionera es la `03`: se envió y nadie consultó el ticket, así que aún no se
  sabe si SUNAT la rechazó. Consúltalo primero y, si vuelve rechazada, reenvía la fila.
- **`GUIA_NUMERO_OCUPADO`** en el duplicado, y **`DISPATCH_NUMBER_TAKEN`** si intentas corregirla:
  SUNAT la rechazó porque ya tiene ese número (`1032`/`1033`). Con ese número no vuelve a pasar.
  Emite otra con otro número y otro `offline_id`; y si diste de baja en el portal de SUNAT la guía
  que allí ocupa ese número, márcala como anulada con
  [`POST /api/dispatches/{external_id}/anular`](../../tenant/Guia-remision/anular-guia-remision.api.mdx).
- **`CORRECCION_SIN_FIRMA`**: la corrección se guardó pero no se pudo firmar. Ver
  [`signed` y `sign_message`](#signed-y-sign_message).
:::

Para corregirla por el lote, la fila lleva:

1. **El `external_id` de la guía dentro de `data`.** Es el que volvió en `data.external_id` al
   emitirla, y también viene en las filas `was_duplicate`.
2. **El JSON completo y corregido**, no solo lo que cambia. Reemplaza todo lo que tenía la guía,
   ítems incluidos.
3. **Las fechas de hoy** en `fecha_de_emision`, `hora_de_emision` y `fecha_de_traslado`. Con la
   emisión de hace días, SUNAT rechaza con `2108` (presentación fuera de fecha); y un traslado
   anterior a la emisión, con `3343`.
4. **El `offline_id` de siempre.** También vale uno nuevo, que es lo único que funciona en un
   servidor anterior al 2026-09-18, pero entonces la guía se queda con él (ver abajo).

```json
{
    "sales": [
        {
            "doc_type": "31",
            "offline_id": "e0fb965a-77c5-44c7-baf9-db2d290a2393",
            "data": {
                "external_id": "0f6e2d8c-7a3b-4e51-b9c4-1a2d3e4f5a6b",
                "serie_documento": "V001",
                "numero_documento": "1",
                "fecha_de_emision": "2026-09-18",
                "hora_de_emision": "10:00:00",
                "fecha_de_traslado": "2026-09-18",
                "...": "resto del payload ya corregido"
            }
        }
    ]
}
```

La fila vuelve con `success: true` y `was_corrected: true`, con **el mismo `number` y el mismo
`external_id`**, sin `was_duplicate` y con los `warnings` del JSON nuevo:

```json
{
    "index": 0,
    "offline_id": "e0fb965a-77c5-44c7-baf9-db2d290a2393",
    "success": true,
    "doc_type": "31",
    "data": {
        "id": 5,
        "number": "V001-1",
        "external_id": "0f6e2d8c-7a3b-4e51-b9c4-1a2d3e4f5a6b",
        "filename": "20123456789-31-V001-1",
        "signed": true,
        "sign_message": null,
        "warnings": [],
        "cash_registered": true
    },
    "was_corrected": true,
    "cash_registered": true,
    "cash_error_code": null,
    "cash_message": null
}
```

La guía se vuelve a firmar, se rehace el PDF y queda en **Registrado** (`01`). Si la empresa tiene
activo el envío automático por correo, el cliente vuelve a recibir la guía.

:::info Comprobado contra SUNAT el 2026-09-19
Una guía de transportista rechazada con **2775** (partida sin ubigeo) se corrigió por el lote con su
mismo `offline_id` y su `external_id`, se reenvió con `send` y SUNAT la **aceptó con el mismo
número**. Un rechazo no deja el número ocupado: eso solo pasa con `1032`/`1033`.
:::

**El lote no la envía a SUNAT.** Hasta que la reenvíes, la consulta del ticket devuelve el
rechazo anterior.

#### El ciclo completo: corregir, enviar y consultar

Son tres llamadas, las mismas para la `09` y la `31`:

1. **Corregir**: la fila del lote con el `external_id` dentro de `data`, como arriba. Sigue solo
   si vuelve `was_corrected: true` **y** `data.signed: true`. Si no, `data.warnings` dice qué
   pasó.
2. **Enviar**: `POST /api/dispatches/send` con `{"external_id": "…"}`. No hay ruta propia de la
   transportista: la busca por `external_id` sea `09` o `31`. La guía pasa a Enviada (`03`) con
   un ticket nuevo.
3. **Consultar el ticket**: `POST /api/dispatches/status_ticket` con el mismo `external_id`, y leer
   `data.state_type_id`:
   - `05`: aceptada. Fin.
   - `09`: rechazada otra vez; `message` y `code` dicen por qué. Vuelve al paso 1 con eso
     corregido, salvo `1032`/`1033` (número ocupado), que se resuelve emitiendo otra.
   - Sigue en `03`: SUNAT aún no responde. Vuelve a consultar más tarde. **No la corrijas
     mientras tanto**: una Enviada no se corrige por el lote (`CORRECCION_NO_APLICADA`).

```
Lote (corregir) ──► was_corrected + signed ──► send ──► status_ticket
      ▲                                                      │
      └──────────────── 09 rechazada (no 1032/1033) ─────────┘
```

Para leer el rechazo → [cuando el envío falla](../../guias-de-remision.md#cuando-el-envío-falla-cómo-leer-el-aviso).

Qué hace cada forma de reenviar la guía:

| Lo que mandas en la fila | Qué pasa |
|---|---|
| El mismo `offline_id` + su `external_id`, con la guía Registrada o Rechazada | **Corrige esa guía** y conserva el `offline_id`. `was_corrected: true` |
| El mismo `offline_id` + su `external_id`, con la guía Enviada (`03`), Aceptada (`05`) o Anulada (`11`) | `was_duplicate: true` con su `state_type_id` y, desde el 2026-09-19, el aviso `CORRECCION_NO_APLICADA`, que dice qué hacer. No se toca |
| El mismo `offline_id` sin `external_id`, o con el de otra guía | `was_duplicate: true` con su `state_type_id`. El `data` no se lee y la guía no cambia; si está rechazada, llega el aviso `GUIA_RECHAZADA_SIN_CORREGIR`, y con el `external_id` de otra guía en cualquier otro estado, `CORRECCION_NO_APLICADA` con el bueno |
| El `external_id` de una guía rechazada porque SUNAT ya tiene su número (`1032`/`1033`), con cualquier `offline_id` | `DISPATCH_NUMBER_TAKEN`. Sin él, el duplicado avisa `GUIA_NUMERO_OCUPADO`. Emite otra con otro número y otro `offline_id` |
| Un `offline_id` nuevo sin `external_id`, con el número de la guía | `CONFLICT_NUMBER`. El número ya está registrado con otro `offline_id` y, sin el `external_id`, el servidor no sabe que es la misma guía |
| Un `offline_id` nuevo + el `external_id` de la guía | **Corrige esa guía**, que se queda con el `offline_id` nuevo. `was_corrected: true` |
| Un `offline_id` nuevo + un `external_id` que no existe | `DISPATCH_NOT_FOUND`. No registra otra guía en su lugar |
| Un `offline_id` nuevo + el `external_id` de una guía aceptada | `DISPATCH_ALREADY_ACCEPTED`. La baja se hace en el portal de SUNAT |

En un servidor anterior al 2026-09-18, las tres filas con el mismo `offline_id` son un
`was_duplicate` sin `state_type_id` ni aviso, y ninguna corrección trae `was_corrected`.

Así vuelve una fila `was_duplicate` de una guía rechazada:

```json
{
    "index": 0,
    "offline_id": "e0fb965a-77c5-44c7-baf9-db2d290a2393",
    "success": true,
    "doc_type": "31",
    "data": {
        "id": 5,
        "number": "V001-1",
        "external_id": "0f6e2d8c-7a3b-4e51-b9c4-1a2d3e4f5a6b",
        "filename": "20123456789-31-V001-1",
        "state_type_id": "09",
        "cash_registered": true,
        "warnings": [
            {
                "codigo": "GUIA_RECHAZADA_SIN_CORREGIR",
                "campo": "external_id",
                "mensaje": "La guía V001-1 está rechazada por SUNAT y ya estaba sincronizada con este offline_id, así que este reenvío no cambió nada. Para corregirla, reenvíala con el JSON corregido y \"external_id\": \"0f6e2d8c-7a3b-4e51-b9c4-1a2d3e4f5a6b\" dentro de data; después vuelve a enviarla a SUNAT."
            }
        ]
    },
    "was_duplicate": true,
    "cash_registered": true,
    "cash_error_code": null,
    "cash_message": null
}
```

El aviso solo sale con la guía en `09`: en una Registrada, reenviar con el mismo `offline_id`
suele ser un reintento normal.

:::warning Con un `offline_id` nuevo, la guía se queda con él
Si corriges con un `offline_id` nuevo, el servidor lo guarda en la guía. **Guárdalo en tu
registro en lugar del viejo**, porque el viejo ya no la reconoce: un reenvío con él ya no vuelve
como `was_duplicate`. Sin `external_id` choca con `CONFLICT_NUMBER`; con él, la corrige otra vez.
Con el `offline_id` de siempre no pasa nada de esto.
:::

**Si prefieres no usar el lote**, corrige la guía fuera de él. Manda el mismo JSON, con su
`external_id`, a `POST /api/dispatch-carrier` (transportista) o a `POST /api/dispatches`
(remitente). La corrección es la misma y **la guía conserva su `offline_id`**, así que tu registro
no cambia → [corregir una guía rechazada](../../guias-de-remision.md#corregir-una-guía-rechazada).

:::caution Corrige solo guías Registradas (`01`) o Rechazadas (`09`)
Con el mismo `offline_id`, el lote ya no toca las demás: devuelve `was_duplicate`. Pero con un
`offline_id` nuevo, o por `POST /api/dispatch-carrier`, el servidor solo impide corregir las
**aceptadas**. Una guía **enviada** (`03`), con el ticket todavía en proceso, se deja
sobrescribir, y el sistema se queda con datos que SUNAT nunca recibió →
[por qué](../../guias-de-remision.md#registrar-o-actualizar-lo-decide-el-external_id).
:::

#### Desde SQL Server

Si el lote lo arma un procedimiento almacenado, la corrección son cuatro `JSON_MODIFY` sobre la
fila: el `external_id` y las fechas. Hazlo **solo** con las guías que SUNAT rechazó y de las que
tienes el `external_id`. Para un reintento normal (se cortó la red, no sabes si llegó), reenvía la
fila tal cual: ahí `was_duplicate` es justo lo que quieres.

```sql
-- @Json: una fila de sales[] (doc_type, offline_id, data) ya corregida.
-- @ExternalId: el external_id que devolvió la API al emitir la guía.
SET @Json = JSON_MODIFY(@Json, '$.data.external_id',       LOWER(@ExternalId));
SET @Json = JSON_MODIFY(@Json, '$.data.fecha_de_emision',  CONVERT(CHAR(10), GETDATE(), 23));  -- AAAA-MM-DD
SET @Json = JSON_MODIFY(@Json, '$.data.hora_de_emision',   CONVERT(CHAR(8),  GETDATE(), 108)); -- hh:mm:ss
SET @Json = JSON_MODIFY(@Json, '$.data.fecha_de_traslado', CONVERT(CHAR(10), GETDATE(), 23));
-- El offline_id se queda como está.
```

Si el procedimiento arma `vehiculo_secundario` aunque no haya segundo vehículo, quítalo: con
`NULL`, `JSON_MODIFY` borra la clave.

```sql
IF @PlacaSecundaria IS NULL
    SET @Json = JSON_MODIFY(@Json, '$.data.vehiculo_secundario', NULL);
```

En un servidor anterior al 2026-09-18, añade un `offline_id` nuevo y guárdalo en tu tabla, porque
la guía se queda con él:

```sql
DECLARE @OfflineId UNIQUEIDENTIFIER = NEWID();
SET @Json = JSON_MODIFY(@Json, '$.offline_id', CONVERT(VARCHAR(36), @OfflineId));
UPDATE dbo.MisGuias SET OFFLINE_ID = @OfflineId WHERE Id = @Id;
```

Al leer la respuesta, mira `was_corrected`: si la fila vuelve con `was_duplicate: true`, no se
corrigió nada.

Ver también [13 — Guía Remitente](13-guia-remision-remitente.md),
[14 — Guía Transportista](14-guia-remision-transportista.md) y
[16 — Idempotencia](16-idempotencia.md).

---

## Notas para Flutter

### Orden de sincronización

```
1. Primero: Notas de Venta (80) — sin dependencias
2. Segundo: Boletas/Facturas (01/03) — sin dependencias
3. Tercero: NC/ND (07/08) — requieren external_id del documento afectado
4. Cuarto: Guías (09/31) — independientes pero menos urgentes
```

> **NC/ND (07/08)** referencia un `external_id` que solo existe después de sincronizar el documento original. Flutter debe sincronizar facturas/boletas primero, obtener sus `external_id`, y luego sincronizar las notas de crédito/débito que los referencian.

### Retry logic

- Si un comprobante falla con error de red → reintentar todo el batch
- Si un comprobante tiene `was_duplicate: true` → marcarlo como sincronizado exitosamente. En una
  guía que corregiste, significa lo contrario de lo que esperas: **no cambió nada** →
  [corregir una guía rechazada por el lote](#corregir-una-guía-rechazada-por-el-lote)
- Exponential backoff: 1s, 2s, 4s, 8s, 16s (máx. 5 intentos)

:::danger Nunca reencoles una venta por `cash_registered: false`
La emisión y el registro en caja son cosas distintas. Con `success: true` la venta **ya está
en el servidor**: volver a enviarla no la registra en caja y sí llena el log. De los cuatro
`cash_error_code`, solo `CASH_NOT_FOUND` y `CASH_NONE_OPEN` admiten **un** reintento, y
después de corregir la causa: mandar la apertura de caja que falta, o abrir una.
:::

Para decidir si reintentar, **ramifica por `error_code`, no por el texto del mensaje**: solo
`DATABASE_ERROR` y `PROCESSING_ERROR` pueden ser del servidor, y aun así con tope — desde el
2026-09-09 ya no incluyen los campos ausentes del payload, que salen como `MISSING_FIELDS`.
Todos los demás son del payload y reintentarlos sin corregirlo solo gasta la cola.

```dart
// Ninguno de los dos es ilimitado: son «vuelve a intentarlo una vez y, si sigue,
// avisa». Sin el tope, un fallo permanente mal clasificado llena la cola para
// siempre — que es exactamente lo que pasó antes del 2026-09-09.
const reintentables = {'DATABASE_ERROR', 'PROCESSING_ERROR'};
const maxReintentos = 3;

if (r['success'] == true) {
  marcarSincronizado(r);                       // incluye was_duplicate: true
  if (r['cash_registered'] == false) {
    // La venta está emitida. Esto se anota para el usuario, NO se reencola.
    anotarIncidenciaDeCaja(r['cash_error_code']);
  }
} else if (reintentables.contains(r['error_code']) && intentosDe(r) < maxReintentos) {
  encolarReintento(r);
} else {
  marcarErrorPermanente(r, r['message']);      // el mensaje ya nombra el campo a corregir
}
```

### Tamaño del batch

- Recomendado: máximo **50 comprobantes** por batch
- Si hay más, dividir en múltiples llamadas

:::caution Por encima de 500 el servidor lo anota
No hay tope: el lote se procesa igual, porque rechazarlo dejaría sin sincronizar justo al
cliente que más lo necesita. Pero a partir de **500 ventas** el servidor escribe un aviso en
su log, porque casi siempre significa que el cliente está reenviando ventas ya sincronizadas
en vez de vaciar su cola. Revisa `cash_summary`: si `already_registered` es alto, tu cola no
se está vaciando.
:::
