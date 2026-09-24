# 26 — Envío Diferido, Consulta y Actualización de Estado

> **Endpoints:**  
> `POST /api/documents/send`  
> `POST /api/documents/updatedocumentstatus`  
> `GET /api/document_check_server/{external_id}`  
> `POST /api/documents/status` — el estado por serie-número, sin el `external_id`  
> **Auth:** `Bearer {token}`

---

## Descripción

Cuando se crea un documento con `acciones.enviar_xml_firmado: false`, el documento queda en estado **Registrado** (`01`) sin enviarse a SUNAT. Estos endpoints permiten enviarlo después y actualizar su estado manualmente.

Ref detalle: [09-boleta-factura.md](09-boleta-factura.md) → sección "Factura Sin Enviar a SUNAT".

### Envío Diferido vs Contingencia

| Aspecto | Envío Diferido (**este doc**) | Contingencia ([27](27-contingencia.md)) |
|---------|-------------------------------|-----------------------------------------|
| Cuándo usar | Hay conexión pero se decide **postergar** el envío a SUNAT | **No hay** conexión o SUNAT caído al momento de emitir |
| Serie usada | Serie **regular** (`F001`, `B001`) | Serie de **contingencia** (empieza con `0`: `0001`, `0F01`) |
| Creación del doc | `acciones.enviar_xml_firmado: false` | Payload idéntico a factura normal pero con serie de contingencia |
| Estado inicial SUNAT | `01` (Registrado) | `01` (Registrado) |
| Acción posterior | `POST /api/documents/send` para enviar a SUNAT | Mismo: `POST /api/documents/send` dentro del plazo de 7 días |
| Plazo SUNAT | Sin plazo estricto (mientras no se declare el período) | **7 días calendario** desde emisión |
| Validez legal | Válido al momento del envío | Válido desde la emisión (serie de contingencia habilitada) |

---

## 1. Enviar Documento a SUNAT

```
POST /api/documents/send
Authorization: Bearer {token}
Content-Type: application/json
```

### Payload

```json
{
    "external_id": "2dded172-cd17-4078-9c88-10a9b1177f2d"
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `external_id` | string (UUID) | **Sí** | UUID del documento retornado al crearlo |

### Response (200 OK)

```json
{
    "success": true,
    "data": {
        "number": "F001-122",
        "filename": "20123456789-01-F001-122",
        "external_id": "2dded172-cd17-4078-9c88-10a9b1177f2d",
        "state_type_id": "05",
        "state_type_description": "Aceptado"
    },
    "links": {
        "cdr": "https://demo.nt-suite.pro/downloads/document/cdr/2dded172..."
    },
    "response": {
        "code": "0",
        "description": "La Factura numero F001-122, ha sido aceptada",
        "notes": []
    }
}
```

### Response Error

```json
{
    "success": false,
    "message": "El documento ya fue enviado anteriormente"
}
```

> **Nota:** Si el documento ya fue enviado (estado `03` o superior), el endpoint retorna error. No es idempotente.

### Rechazos con `error_code` — todos `422`

| `error_code` | Cuándo | Qué hacer |
|---|---|---|
| `MISSING_FIELDS` | No mandaste `external_id` | Añadirlo. Es el UUID que devolvió la emisión |
| `DOCUMENT_NOT_FOUND` | Ese `external_id` no existe en el tenant | Revisar el UUID; puede ser de otro tenant |
| `DOCUMENT_NOT_SENDABLE` | El documento es del grupo `02` | **No reintentar.** Usar `POST /api/summaries` |

:::danger Este endpoint **solo** envía facturas y sus notas

Acepta únicamente documentos del grupo `01`. Con una boleta, o con una nota de crédito o débito asociada a una boleta, responde `DOCUMENT_NOT_SENDABLE`. Esos comprobantes se declaran en el **resumen diario** (`POST /api/summaries`), no de uno en uno — es lo que SUNAT espera, y no hay forma de forzarlo por aquí.

Recuerda que el grupo de una nota lo hereda su documento afectado, no su serie: una `FC01` contra una boleta es grupo `02`. Ver [10-nota-credito.md](10-nota-credito.md#como-llega-a-sunat).

**Cambio de comportamiento (2026-09-07).** Los tres rechazos salían como **`500`** sin `error_code`, y el de `external_id` ausente ni siquiera eso: devolvía `200` con cuerpo vacío. Un cliente con reintento sobre 5xx los repetía indefinidamente.
:::

---

## 2. Actualizar Estado de Documento

```
POST /api/documents/updatedocumentstatus
Authorization: Bearer {token}
Content-Type: application/json
```

### Payload

```json
{
    "externail_id": "2dded172-cd17-4078-9c88-10a9b1177f2d",
    "state_type_id": "05"
}
```

> **⚠️ IMPORTANTE:** El campo se llama `externail_id` (con typo). NO es `external_id`. Este es un typo histórico de la API que se mantiene por retrocompatibilidad.

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `externail_id` | string (UUID) | **Sí** | UUID del documento (con typo: `externail`) |
| `state_type_id` | string | **Sí** | Nuevo código de estado |

### Estados disponibles

| Código | Estado | Descripción |
|--------|--------|-------------|
| `01` | Registrado | Creado pero no enviado a SUNAT |
| `03` | Enviado | Enviado a SUNAT (esperando respuesta) |
| `05` | Aceptado | Aceptado por SUNAT |
| `07` | Observado | Aceptado con observaciones por SUNAT |
| `09` | Rechazado | Rechazado por SUNAT |
| `11` | Anulado | Documento anulado |
| `13` | Por anular | En proceso de anulación (Resumen de Anulados) |

### Response (200 OK)

```json
{
    "success": true,
    "message": "Estado del documento actualizado correctamente"
}
```

---

## 3. Consultar el Estado de un Comprobante

```
GET /api/document_check_server/{external_id}
Authorization: Bearer {token}
```

Devuelve el estado actual de un comprobante ya emitido, a partir del `external_id`. Es la forma
de enterarse de la respuesta de SUNAT cuando el comprobante se emitió por
[`sync-batch`](15-sync-batch.md), que **no la devuelve**: su fila trae `id`, `number` y
`external_id`, y nada del estado.

No confundir con el punto 2: aquel **escribe** el estado que tú le digas; este solo **lee** el
que hay.

### Response (200 OK)

```json
{
    "success": true,
    "state_type_id": "05",
    "file_cdr": "UEsDBBQAAAAIAMGKGFsc2h..."
}
```

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `state_type_id` | string | Estado actual. Los códigos, en la tabla de [Estados disponibles](#estados-disponibles) |
| `file_cdr` | string \| null | El **ZIP del CDR en base64** — no el XML suelto. Casi siempre `null`; ver abajo |

### `file_cdr` casi siempre llega en `null`

Trae contenido solo si se cumplen **las dos** condiciones:

1. `state_type_id` es `05` (Aceptado), **y**
2. el comprobante es del **grupo `01`** — facturas y sus notas.

:::warning Con una boleta es `null` aunque esté aceptada

Las boletas son grupo `02`, así que este endpoint nunca les devuelve el CDR: solo el
`state_type_id`. Y el CDR tampoco es de la boleta: una boleta declarada en un resumen diario **no
tiene CDR propio**. Su constancia es la del resumen que la declaró:

- el `links.cdr` que devuelve `POST /api/summaries/status` al consultar ese resumen, o
- `GET /downloads/summary/cdr/{external_id}`, con el `external_id` **del resumen**.

`GET /downloads/document/cdr/{external_id}` con el de la boleta responde **500**: ese archivo no
existe. Solo la boleta de envío individual tiene CDR propio, y se descarga justo por esa ruta
([40 — Ciclo de la factura y de la boleta de envío individual](40-ciclo-de-la-factura-y-envio-individual.md#cdr-propio)).

Del `01` al CDR, y la anulación: [39 — Ciclo de la boleta](39-ciclo-de-la-boleta.md).
:::

### Un `external_id` que no existe responde `500`

No hay `404` ni `error_code`. El comprobante inexistente —un UUID mal copiado, o uno de otro
tenant— revienta con un error interno de PHP:

```json
{
    "success": false,
    "message": "Attempt to read property \"state_type_id\" on null"
}
```

**No lo reintentes:** es permanente, no un fallo pasajero del servidor. Un `500` de este
endpoint significa «ese `external_id` no existe aquí». El mensaje es feo porque el endpoint no
comprueba el caso; se documenta tal cual para que puedas distinguirlo de una caída real.

:::info Este endpoint no está en el explorador de API

Nació para el flujo `documents_server` y quedó sin ficha OpenAPI. Funciona igual para cualquier
comprobante del tenant, se emitiera como se emitiera.
:::

---

## 4. Consultar por serie-número: `POST /api/documents/status` {#por-serie-numero}

```
POST /api/documents/status
Authorization: Bearer {token}
Content-Type: application/json
```

```json
{ "serie_number": "B001-53" }
```

Hace lo mismo que el punto 3, pero **no necesita el `external_id`**: busca el comprobante por su
serie y su número. Sirve cuando no guardaste la respuesta de la emisión —se cortó la conexión,
venció el tiempo de espera— o cuando un reenvío te devolvió `409 DUPLICATE_DOCUMENT` y quieres
saber qué hay con ese número. Entre otras cosas, te devuelve el `external_id` que te faltaba.

| | Punto 3: `document_check_server` | Punto 4: `documents/status` |
|---|---|---|
| Busca por | `external_id` | serie-número o `external_id` |
| Si no existe | `500` | `422 DOCUMENT_NOT_FOUND` |
| Devuelve | estado y `file_cdr` (ZIP en base64, solo de facturas y sus notas aceptadas) | estado, `external_id` y enlaces al XML, al PDF y al CDR |

### Payload

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `serie_number` | string | Uno de los dos | Serie y número con guion: `"F001-2"`. Admite ceros a la izquierda (`"B001-00000053"`) y la serie en minúsculas |
| `external_id` | string (UUID) | Uno de los dos | El que devolvió la emisión |

Si mandas los dos, tienen que ser **del mismo** comprobante; si no, responde `DOCUMENT_NOT_FOUND`.

Solo busca entre **facturas, boletas y sus notas** de la empresa del token. Con la serie de una
guía, una nota de venta o una retención responde `DOCUMENT_NOT_FOUND`.

### Response (200 OK)

```json
{
    "success": true,
    "data": {
        "number": "B001-53",
        "filename": "20123456789-03-B001-53",
        "external_id": "30bfd7b2-7e75-445c-80b9-50b5783bed82",
        "status_id": "05",
        "status": "Aceptado",
        "qr": "iVBORw0KGgoAAAANSUhEUgAA...",
        "number_to_letter": "Veintitres con 60/100"
    },
    "links": {
        "xml": "https://tu-dominio.com/downloads/document/xml/30bfd7b2-7e75-445c-80b9-50b5783bed82",
        "pdf": "https://tu-dominio.com/downloads/document/pdf/30bfd7b2-7e75-445c-80b9-50b5783bed82",
        "cdr": "https://tu-dominio.com/downloads/document/cdr/30bfd7b2-7e75-445c-80b9-50b5783bed82"
    }
}
```

| Campo | Descripción |
|-------|-------------|
| `data.number` | Serie y número **sin ceros a la izquierda**: `"B001-53"` aunque preguntes por `"B001-00000053"` |
| `data.external_id` | El UUID del comprobante. Lo piden el punto 3, `POST /api/documents/send`, las anulaciones y las descargas |
| `data.status_id` | Estado actual, con los códigos de [Estados disponibles](#estados-disponibles) |
| `data.status` | El mismo estado en texto: `Registrado`, `Enviado`, `Aceptado`… |
| `data.filename` | Nombre del archivo: RUC, tipo, serie y número |
| `data.qr` | Imagen del QR en base64 (PNG) |
| `data.number_to_letter` | El importe en letras |
| `links.xml`, `links.pdf` | Descargas públicas, sin token |
| `links.cdr` | Llega **siempre**, haya CDR o no: ver abajo |

:::warning `links.cdr` no dice que haya CDR

La URL se arma con el `external_id` y viene en todas las respuestas. Si el comprobante no tiene
CDR —uno en `01`, o una boleta declarada en un resumen diario—, esa descarga responde **500**.
Decide por `status_id`. El CDR de una boleta declarada por resumen es el del resumen:
[39 — Ciclo de la boleta](39-ciclo-de-la-boleta.md).
:::

### Rechazos con `error_code` — todos `422`

| `error_code` | Cuándo | `errors` |
|---|---|---|
| `MISSING_FIELDS` | No llega ni `serie_number` ni `external_id` | `faltantes: ["external_id", "serie_number"]` |
| `INVALID_SERIE_NUMBER` | `serie_number` no tiene la forma serie-número: `"B001"`, `"B001-ABC"` | `serie_number`, con lo que llegó |
| `DOCUMENT_NOT_FOUND` | No hay ningún comprobante con esa serie-número, o con ese `external_id`, en la empresa del token | — |

Sin token, `401`. **Ninguno se arregla reintentando.** Con `DOCUMENT_NOT_FOUND` sabes que ese
número **no está emitido** en el Facturador.

:::info Cambio de comportamiento (2026-09-21)

Antes de esa fecha respondía **sin token**. Un número inexistente, o un cuerpo sin ninguno de los
dos campos, daba `500` o un `200` con el cuerpo vacío, y con solo `external_id` fallaba: había que
mandar también `serie_number`. Si tu integración lo llamaba sin `Authorization`, desde entonces
recibe `401`: manda el Bearer de la empresa, como en el resto de la API. La respuesta de éxito no
cambió.
:::

Tampoco tiene ficha en el explorador de API: se documenta solo aquí.

---

## Flujo Completo de Envío Diferido

```
┌──────────────────────────────────────────────────────┐
│ Paso 1: Crear documento sin enviar                    │
│                                                       │
│ POST /api/documents                                   │
│ {                                                     │
│   "acciones": { "enviar_xml_firmado": false },        │
│   "...resto del payload..."                           │
│ }                                                     │
│ → state_type_id: "01" (Registrado)                    │
│ → Retorna external_id                                 │
└───────────────────────┬──────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────┐
│ Paso 2: Enviar a SUNAT cuando haya conexión           │
│                                                       │
│ POST /api/documents/send                              │
│ { "external_id": "2dded172-..." }                     │
│ → Si aceptado: state_type_id: "05"                    │
│ → Si rechazado: state_type_id: "09"                   │
└───────────────────────┬──────────────────────────────┘
                        │
                        ▼ (opcional)
┌──────────────────────────────────────────────────────┐
│ Paso 3: Actualizar estado manualmente                 │
│                                                       │
│ POST /api/documents/updatedocumentstatus              │
│ { "externail_id": "2dded172-...", "state_type_id": "05" } │
│ → Solo si se necesita forzar un estado específico     │
└──────────────────────────────────────────────────────┘
```

---

## Notas para Offline (Flutter)

### Cuándo usar envío diferido

1. **Servidor sin internet:** El Flutter sincronizó el comprobante al servidor vía WiFi local, pero el servidor no tiene internet para enviar a SUNAT. Crear con `acciones.enviar_xml_firmado: false`.
2. **Pre-generación:** Se desea generar el PDF localmente (para imprimir ticket) sin esperar respuesta de SUNAT.

### Cuándo NO usar envío diferido

1. **Flutter offline puro:** Si Flutter no tiene conexión al servidor, el comprobante se almacena en SQLite local. Al sincronizar con `sync-batch`, el servidor lo crea y decide si lo envía igual que `POST /api/documents`: una factura sale si el envío automático está activo; una boleta, solo si además está activo el envío individual ([37](37-envio-automatico-a-sunat.md), [40](40-ciclo-de-la-factura-y-envio-individual.md)).
2. **Operación normal:** Si el servidor tiene internet, no hay razón para no enviar.

### Flujo recomendado post-sync

La fila que devuelve `sync-batch` para una boleta o una factura **no trae el estado**, así que
el primer paso no es leerlo: es preguntarlo.

```
sync-batch → para cada documento creado:
  1. Guardar el external_id que devolvió la fila
  2. GET /api/document_check_server/{external_id}  → state_type_id
  3. Si state_type_id === "01" (Registrado, sin remitir):
       · factura o nota de factura → POST /api/documents/send
       · boleta o nota de boleta   → nada por documento: un POST /api/summaries por FECHA
                                     de emisión (no uno por boleta); guarda el external_id
                                     del resumen (ver 39)
  3b. Si es "03" y es una boleta: su resumen ya salió → POST /api/summaries/status
      con el external_id del resumen
  4. Si es "09" (Rechazado), corregir y reemitir. Reenviar el mismo no cambia nada
  5. Si es "05" (Aceptado), no hay nada que hacer
```

El paso 2 no es opcional. Un comprobante en `01` es válido, está firmado y tiene PDF, pero
**está sin declarar**; si das por hecho que emitir es enviar, nadie se entera hasta el cierre
del periodo. Qué decide que salga en `01` o en `05`:
[37 — Envío automático a SUNAT](37-envio-automatico-a-sunat.md).

### Campos a almacenar en SQLite (Flutter)

Para cada documento sincronizado:

| Campo | Descripción | De dónde sale |
|-------|-------------|---------------|
| `external_id` | UUID del documento en el servidor | La fila de `sync-batch` |
| `number` | Número del documento (ej: `F001-122`) | La fila de `sync-batch` |
| `state_type_id` | Estado actual (`01`, `03`, `05`, …) | **No viene en `sync-batch`.** `GET /api/document_check_server/{external_id}` |
| `needs_send` | Flag local: `true` si se creó con `enviar_xml_firmado: false` | Lo pones tú al emitir |
| `external_id` del resumen | Solo boletas y sus notas: el resumen que la declaró, y el que la anuló si se anula. Su CDR es el del resumen | La respuesta de `POST /api/summaries` → [39](39-ciclo-de-la-boleta.md#qué-guardar-por-cada-boleta) |
