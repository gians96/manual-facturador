# 40 — Ciclo de la Factura y de la Boleta de Envío Individual

> **Endpoints:**  
> `GET /api/document_check_server/{external_id}` — estado del comprobante  
> `POST /api/documents/status` — el estado por serie-número, si no tienes el `external_id`  
> `POST /api/documents/send` — enviar una factura (o nota de factura) que quedó en `01`  
> `GET /downloads/document/cdr/{external_id}` — el CDR propio del comprobante  
> `POST /api/voided` y `POST /api/voided/status` — anular una factura (comunicación de baja)  
> `POST /api/summaries` y `POST /api/summaries/status` — anular una boleta, aunque se haya enviado sola  
> **Auth:** `Bearer {token}`. Las descargas de `/downloads/…` no lo piden.

---

## En una línea

La **factura** viaja sola a SUNAT y tiene **CDR propio**. La **boleta** también, si la empresa tiene
activo el **envío individual**, que es como se crean las empresas nuevas. Las dos se consultan con
su propio `external_id`. Lo que cambia es la anulación: la factura se anula con una **comunicación de
baja** (`/api/voided`) y la boleta, con un **resumen de anulación** (`"3"`), se haya enviado como se
haya enviado.

Si tu empresa tiene apagado el envío individual, tus boletas esperan al resumen diario:
[39 — Ciclo de la boleta](39-ciclo-de-la-boleta.md).

:::info Probado de punta a punta el 2026-09-21
Contra SUNAT beta, por `sync-batch`: la F001-2 salió aceptada en el mismo lote y se anuló con la
baja `RA-20260921-1`; la F001-3 se registró sin enviar y se envió después; la B001-6, con el envío
individual activo, salió aceptada en el lote y se anuló con el resumen `RC-20260921-9`.
:::

---

## Cómo se envía un comprobante «individualmente» {#como-se-envia}

No se pide por comprobante: lo decide la **configuración de la empresa**, en *Configuración →
Avanzado → pestaña Extra → Envío Automático de Comprobantes*:

| Interruptor | Columna | Empresas nuevas |
|---|---|---|
| Envío de comprobantes automático | `send_auto` | Encendido |
| Enviar boletas y notas asociadas (Crédito y Débito) de forma individual | `ticket_single_shipment` | Encendido |

Con eso, al emitir —por `POST /api/documents` o por `sync-batch`, que usa el mismo motor— el
servidor envía el XML a SUNAT **en la misma llamada**:

| Comprobante | Sale solo a SUNAT si… | Si no sale |
|---|---|---|
| Factura y sus notas | `send_auto` | Queda en `01`: la envías con `POST /api/documents/send` |
| Boleta | `send_auto` **y** `ticket_single_shipment` | Queda en `01` y espera el resumen diario → [39](39-ciclo-de-la-boleta.md) |
| Nota de boleta | Lo anterior **y** que su boleta se haya enviado sola | Igual que la boleta |

La boleta guarda la marca de envío individual al emitirse, según esté el interruptor en ese
momento. Cambiar el interruptor después no cambia las boletas ya emitidas.

`acciones.enviar_xml_firmado: false` en el comprobante **frena** el envío aunque todo esté
encendido; `true` no lo fuerza si está apagado. El detalle, con todas las combinaciones:
[37 — Envío automático a SUNAT](37-envio-automatico-a-sunat.md).

---

## 1. Emitir y leer el estado

La fila de `sync-batch` no trae el estado ([por qué](15-sync-batch.md#la-fila-de-un-comprobante-no-trae-el-estado)).
Pregúntalo con el `external_id` del comprobante:

```
GET /api/document_check_server/10c8046d-08a5-408f-9d6f-1dc1642ff1e6
```

```json
{ "success": true, "state_type_id": "05", "file_cdr": "UEsDBBQAAgAIACOcNV0…" }
```

| `state_type_id` | Qué significa |
|---|---|
| `05` Aceptado (o `07` Observado) | Salió en la misma emisión y SUNAT lo aceptó |
| `09` Rechazado | Salió y SUNAT lo rechazó: corrige y emite otro |
| `01` Registrado | No salió: está apagado el envío, o SUNAT no respondió al emitir |

`file_cdr` es el **ZIP del CDR en base64**, pero solo en las **facturas y sus notas** aceptadas. En
una boleta llega `null` aunque se haya enviado sola y tenga CDR: para ella usa la descarga del
paso 3.

Si emites por `POST /api/documents` en vez de `sync-batch`, la respuesta ya trae el estado, y
`links.cdr` cuando el comprobante salió a SUNAT en esa llamada.

¿No tienes el `external_id`, porque se cortó la conexión o no guardaste la respuesta? Pregunta por
la serie y el número:

```
POST /api/documents/status
```

```json
{ "serie_number": "F001-2" }
```

Responde con el estado (`data.status_id`) y el `external_id`, o con `422 DOCUMENT_NOT_FOUND` si ese
número no está emitido → [26 — Consultar por serie-número](26-envio-diferido-update-estado.md#por-serie-numero).

---

## 2. Una factura que quedó en `01`: `POST /api/documents/send` {#factura-en-01}

```
POST /api/documents/send
```

```json
{ "external_id": "978f1b9a-6bff-4cd1-ac1d-d18b75787262" }
```

```json
{
    "success": true,
    "data": {
        "number": "F001-3",
        "filename": "20123456789-01-F001-3",
        "external_id": "978f1b9a-6bff-4cd1-ac1d-d18b75787262",
        "state_type_id": "05",
        "state_type_description": "Aceptado"
    },
    "links": {
        "cdr": "https://tu-dominio.com/downloads/document/cdr/978f1b9a-6bff-4cd1-ac1d-d18b75787262"
    },
    "response": { "code": "0", "description": "La Factura numero F001-3, ha sido aceptada", "notes": [] }
}
```

Solo acepta **facturas y sus notas**. Con cualquier boleta responde 422 `DOCUMENT_NOT_SENDABLE`
→ [26 — Envío diferido](26-envio-diferido-update-estado.md#1-enviar-documento-a-sunat).

:::warning Una boleta de envío individual que quedó en `01` no tiene salida por la API
Si la boleta se marcó para envío individual y no salió —SUNAT no respondió al emitir, o `send_auto`
estaba apagado—, queda en `01` y:

- `POST /api/documents/send` la rechaza (`DOCUMENT_NOT_SENDABLE`), aunque su mensaje sugiera el
  resumen;
- el resumen diario **no la toma**, porque excluye las boletas de envío individual;
- la tarea «Enviar comprobantes pendientes a SUNAT» solo reintenta facturas.

Se destraba desde el panel: *Reenviar* en el listado de comprobantes, o pasarla a resumen con
*Enviar por resumen* →
[si mis boletas no se enviaron](../../../../guias-adicionales/Errores/Pasos-a-realizar-si-mis-boletas-no-se-enviaron.md).
:::

---

## 3. El CDR propio: `GET /downloads/document/cdr/{external_id}` {#cdr-propio}

Con el `external_id` **del comprobante** descargas su CDR, un ZIP `R-{RUC}-{tipo}-{serie}-{número}.zip`
cuyo XML dice, por ejemplo, `La Factura numero F001-2, ha sido aceptada`. Vale para las facturas y
sus notas aceptadas y para las boletas que se enviaron solas. No pide token.

Una boleta que se declaró en un resumen **no** tiene CDR propio: esa descarga responde 500 y su
constancia es la del resumen → [39 — el CDR es el del resumen](39-ciclo-de-la-boleta.md#paso-4).

---

## 4. Anular una factura: comunicación de baja {#anular-factura}

```
POST /api/voided
```

```json
{
    "fecha_de_emision_de_documentos": "2026-09-26",
    "documentos": [
        { "external_id": "3ab040b8-00e5-4548-9e90-767e9feb85b9", "motivo_anulacion": "Venta anulada" }
    ]
}
```

- **La fecha va en `aaaa-mm-dd` o en `dd-mm-aaaa`** (`"26-09-2026"`): valen las dos. Es la de
  emisión de la factura, y todas las del array deben ser de ese día. Hasta el 2026-09-26 solo valía
  `dd-mm-aaaa` y `aaaa-mm-dd` respondía 500 `The separation symbol could not be found`: en un
  servidor sin actualizar, usa `dd-mm-aaaa`.
- `motivo_anulacion` es obligatorio y es texto libre: viaja a SUNAT en la baja. Sin él, 422
  `MISSING_FIELDS`.
- El `external_id` puede ir en mayúsculas, como lo guarda un `uniqueidentifier` de SQL Server.
- Sirve para facturas y notas de factura. Una boleta aquí da 422 `AFFECTED_DOCUMENT_NOT_FOUND`.
- Una nota va con **su** `external_id` y **su** fecha, no las de la factura →
  [41 — Anular una nota](41-anular-notas-de-credito-y-debito.md#nota-de-factura).
- Solo se anula una factura o nota aceptada (`05`) u observada (`07`). Si no, 422
  `DOCUMENT_NOT_VOIDABLE`, antes de enviar nada. Desde el 2026-09-25; antes se aceptaba cualquier estado.

```json
{
    "success": true,
    "data": {
        "external_id": "45dd304a-3873-4e54-9470-26b61cfc0fb0",
        "ticket": "1790434357925",
        "filename": "20123456789-RA-20260926-1",
        "date_of_reference": "2026-09-26",
        "state_type_id": "03",
        "state_type_description": "Enviado",
        "documents": [
            {
                "id": 68,
                "external_id": "3ab040b8-00e5-4548-9e90-767e9feb85b9",
                "offline_id": null,
                "document_type_id": "01",
                "series": "F001",
                "number": 12,
                "number_full": "F001-12",
                "currency_type_id": "PEN",
                "total": "118.00",
                "state_type_id": "13",
                "state_type_description": "Por anular"
            }
        ]
    }
}
```

`external_id`, `ticket` y `state_type_id` son **de la baja** (`03`, Enviado). La factura está en
`documents`: pasa a `13` (Por anular); a `03` si la empresa envía por un PSE o por el OSE SendFact.
Un servidor sin actualizar (antes del 2026-09-26) solo devuelve `external_id` y `ticket`. Después se
consulta:

```
POST /api/voided/status
```

```json
{ "external_id": "45dd304a-3873-4e54-9470-26b61cfc0fb0" }
```

```json
{
    "success": true,
    "data": {
        "external_id": "45dd304a-3873-4e54-9470-26b61cfc0fb0",
        "ticket": "1790434357925",
        "filename": "20123456789-RA-20260926-1",
        "date_of_reference": "2026-09-26",
        "state_type_id": "05",
        "state_type_description": "Aceptado",
        "documents": [
            {
                "id": 68,
                "external_id": "3ab040b8-00e5-4548-9e90-767e9feb85b9",
                "offline_id": null,
                "document_type_id": "01",
                "series": "F001",
                "number": 12,
                "number_full": "F001-12",
                "currency_type_id": "PEN",
                "total": "118.00",
                "state_type_id": "11",
                "state_type_description": "Anulado"
            }
        ]
    },
    "links": {
        "xml": "https://tu-dominio.com/downloads/voided/xml/45dd304a-3873-4e54-9470-26b61cfc0fb0",
        "cdr": "https://tu-dominio.com/downloads/voided/cdr/45dd304a-3873-4e54-9470-26b61cfc0fb0"
    },
    "response": {
        "sent": true, "code": "0",
        "description": "La Comunicacion de baja RA-20260926-1, ha sido aceptada",
        "notes": [], "is_accepted": true, "status_code": 0
    }
}
```

Con `code: "0"` la factura queda en `11` (Anulado): es el `state_type_id` de su fila en `documents`.
El de arriba, `05`, es el de la baja, que nunca pasa a `11`. `links.cdr` es el CDR **de la baja**; la
factura conserva además el suyo, el de su aceptación. A diferencia de los resúmenes, las bajas sí las
consulta una tarea programada: «Consultar las comunicaciones de baja».

:::info Probado el 2026-09-26 contra SUNAT beta
F001-12 con `"2026-09-26"` y el `external_id` en mayúsculas (`RA-20260926-1`), y F001-13 con
`"26-09-2026"` (`RA-20260926-2`), consultada por `ticket`: las dos pasaron de `13` a `11`. Sin fecha,
con `2026/09/26`, con `2026-02-30`, con `documentos: null` o sin motivo, la llamada respondió 422 y
no se creó ninguna baja.
:::

Solo `code: "0"` es aceptación. Si SUNAT rechaza la baja, la factura vuelve a `05` (o `07`) y la baja
queda en `09`. Volver a consultar una baja ya resuelta no cambia nada. Hasta el 2026-09-25, con envío
directo a SUNAT, una baja rechazada dejaba la factura en `11` aunque para SUNAT siguiera aceptada
([41 — Si SUNAT rechaza](41-anular-notas-de-credito-y-debito.md#rechazo)).

---

## 5. Anular una boleta enviada sola: igual que cualquier boleta

Aunque la boleta tenga CDR propio, **no** se anula por `/api/voided`: va en un resumen de anulación
`"3"`, con su `external_id` y su fecha de emisión en `YYYY-MM-DD`. Pasa a `13` y, al consultar ese
resumen, a `11`. Son los pasos 5 y 6 de [39 — Ciclo de la boleta](39-ciclo-de-la-boleta.md#paso-5),
sin cambios.

---

## Resumen

| | Factura | Boleta de envío individual | Boleta por resumen |
|---|---|---|---|
| Sale a SUNAT | Al emitir, con `send_auto` | Al emitir, con `send_auto` y el envío individual | En el resumen diario → [39](39-ciclo-de-la-boleta.md) |
| Si quedó en `01` | `POST /api/documents/send` | Solo desde el panel | `POST /api/summaries` con `"1"` |
| Estado | `document_check_server`, o `documents/status` por serie-número | `document_check_server`, o `documents/status` por serie-número | `document_check_server`, o `documents/status` por serie-número |
| CDR | Propio: `/downloads/document/cdr/{external_id}` o `file_cdr` | Propio: `/downloads/document/cdr/{external_id}` | El del resumen |
| Anular | `POST /api/voided` (fecha `aaaa-mm-dd` o `dd-mm-aaaa`) + `/api/voided/status` | `POST /api/summaries` con `"3"` + `/status` | `POST /api/summaries` con `"3"` + `/status` |
| CDR de la anulación | `links.cdr` de la baja | `links.cdr` del resumen de anulación | `links.cdr` del resumen de anulación |
