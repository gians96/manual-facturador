# 15 — Sincronización Batch (Sync-Batch)

> `POST /api/offline/sync-batch`  
> **Controller:** `Modules\Offline\Http\Controllers\OfflineSyncController@syncBatch`  
> **Auth:** `Bearer {token}`  
> **Uso:** Enviar múltiples comprobantes creados offline en una sola petición.

---

## Descripción

El endpoint principal de sincronización. Recibe un array de comprobantes creados offline y los procesa secuencialmente. Cada comprobante se intenta crear; si falla, el error se registra individualmente sin afectar a los demás.

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
                "codigo_tipo_documento": "09",
                "codigo_modo_transporte": "02",
                "codigo_motivo_traslado": "04",
                "fecha_de_traslado": "2026-04-19",
                "peso_total": 10.0,
                "unidad_peso_total": "KGM",
                "direccion_partida": { "ubigeo": "150101", "direccion": "Av. Principal 123" },
                "direccion_llegada": { "ubigeo": "150132", "direccion": "Jr. Los Olivos 456" },
                "chofer": { "codigo_tipo_documento_identidad": "1", "numero_documento": "12345678", "nombres": "JUAN PEREZ", "numero_licencia": "Q12345678" },
                "vehiculo": { "numero_de_placa": "ABC-123" },
                "datos_del_cliente_o_receptor": { "codigo_tipo_documento_identidad": "6", "numero_documento": "20123456789", "apellidos_y_nombres_o_razon_social": "EMPRESA DEMO S.A.C." },
                "items": [
                    { "codigo_interno": "ASD", "descripcion": "Precio", "unidad_de_medida": "NIU", "cantidad": 10, "valor_unitario": 3.13, "precio_unitario": 3.69, "codigo_tipo_precio": "01", "codigo_tipo_afectacion_igv": "10", "total_base_igv": 31.3, "porcentaje_igv": 18, "total_igv": 5.63, "total_impuestos": 5.63, "total_valor_item": 31.3, "total_item": 36.93 }
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
                    "filename": "NV01-25-20260418",
                    "state_type_id": "01"
                },
                "cash_registered": true,
                "cash_error_code": null
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
                    "filename": "20123456789-03-B001-90",
                    "state_type_id": "01"
                }
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
                    "filename": "20123456789-09-T001-13"
                }
            }
        ],
        "total": 3,
        "success_count": 3,
        "error_count": 0
    }
}
```

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

:::info Desde el 2026-09-04
**Toda** fila fallida de `results[]` trae `error_code`, un código estable para ramificar sin
tener que leer el texto del `message`. Es un campo **añadido**: si tu integración solo lee
`success` y `message`, sigue funcionando igual.
:::

| `error_code` | Significa | ¿Reintentar? |
|---|---|---|
| `MISSING_FIELDS` | Falta `doc_type`/`data`, o un campo obligatorio del comprobante | ❌ No, sin corregir |
| `INVALID_PAYLOAD` | No pasó la validación previa o una regla de negocio | ❌ No, sin corregir |
| `INVALID_REFERENCE` | Un código enviado no existe en el catálogo destino | ❌ No, sin corregir |
| `NULL_NOT_ALLOWED` | Se envió `null` en un campo que no lo admite | ❌ No, sin corregir |
| `INVALID_ENCODING` | El cuerpo no es UTF-8 válido | ❌ No, sin corregir |
| `VALUE_TOO_LONG` · `VALUE_OUT_OF_RANGE` | Texto o importe fuera del ancho del campo | ❌ No, sin corregir |
| `CONFLICT_NUMBER` | El correlativo ya lo usó **otra** venta | ⚠️ Renumerar y reemitir |
| `DATABASE_ERROR` · `PROCESSING_ERROR` | **No es tu payload.** Fallo del servidor | ✅ Sí |

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

## ⚠️ FIX NECESARIO — Extensión del Controller

### Estado actual

El controller `OfflineSyncController@syncBatch` solo maneja:
- `doc_type: "80"` → `processSaleNote()`
- `doc_type: "01"` / `"03"` → `processDocument()`

### Extensión necesaria

Agregar soporte para:

| `doc_type` | Método nuevo | Tabla `offline_id` |
|------------|-------------|-------------------|
| `"07"` | Reusar `processDocument()` | `documents.offline_id` |
| `"08"` | Reusar `processDocument()` | `documents.offline_id` |
| `"09"` | `processDispatch()` (nuevo) | `dispatches.offline_id` |
| `"31"` | `processDispatchCarrier()` (nuevo) | `dispatches.offline_id` |

Ver detalles de implementación en [16-idempotencia.md](16-idempotencia.md).

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
- Si un comprobante tiene `was_duplicate: true` → marcarlo como sincronizado exitosamente
- Exponential backoff: 1s, 2s, 4s, 8s, 16s (máx. 5 intentos)

:::danger Nunca reencoles una venta por `cash_registered: false`
La emisión y el registro en caja son cosas distintas. Con `success: true` la venta **ya está
en el servidor**: volver a enviarla no la registra en caja y sí llena el log. De los cuatro
`cash_error_code`, solo `CASH_NOT_FOUND` y `CASH_NONE_OPEN` admiten **un** reintento, y
después de corregir la causa: mandar la apertura de caja que falta, o abrir una.
:::

Para decidir si reintentar, **ramifica por `error_code`, no por el texto del mensaje**: solo
`DATABASE_ERROR` y `PROCESSING_ERROR` son del servidor y merecen otro intento. Todos los
demás son del payload y reintentarlos sin corregirlo solo gasta la cola.

```dart
const reintentables = {'DATABASE_ERROR', 'PROCESSING_ERROR'};

if (r['success'] == true) {
  marcarSincronizado(r);                       // incluye was_duplicate: true
  if (r['cash_registered'] == false) {
    // La venta está emitida. Esto se anota para el usuario, NO se reencola.
    anotarIncidenciaDeCaja(r['cash_error_code']);
  }
} else if (reintentables.contains(r['error_code'])) {
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
