# 38 — Envío de Comprobantes por WhatsApp (QR Api)

> El negocio conecta su WhatsApp por QR en **Configuración → WhatsApp → «Envío de comprobantes»** y
> desde ahí salen los comprobantes: el PDF (y el XML, si se pide) los arma el servidor.
> La petición **no espera** al envío: deja la entrega en cola y responde al instante.

---

## En una línea

```
POST send-document  →  202 delivery_id  →  (cola)  →  evento whatsapp.receipt.updated  →  sent | failed | unconfirmed
```

Todas las rutas son del tenant y van con el token de siempre (`Authorization: Bearer …`).

| Método | Ruta | Para qué |
|---|---|---|
| `GET` | `/api/qrapi/status` | ¿Hay número conectado? ¿Qué se envía por defecto? |
| `POST` | `/api/qrapi/config` | Cambiar esas opciones (solo administrador) |
| `POST` | `/api/qrapi/send-document` | Poner un comprobante en cola |
| `GET` | `/api/qrapi/deliveries/{id}` | Cómo terminó ese envío |

---

## `GET /api/qrapi/status`

Consulta la conexión **en vivo**, con un tope de 5 s, y la guarda 15 s por número.

```json
{
  "success": true,
  "data": {
    "enabled": true,
    "instance_configured": true,
    "use_bot_instance": false,
    "pdf_format": "a4",
    "auto_send": false,
    "send_pdf": true,
    "send_xml": false,
    "connected": true,
    "state": "open",
    "connected_phone": "51987654321",
    "profile_name": "Mi Negocio",
    "messages": { "used": 12, "limit": 500, "unlimited": false, "exceeded": false }
  }
}
```

| Campo | Qué significa |
|---|---|
| `enabled` | El envío por WhatsApp está activo |
| `instance_configured` | Hay un número vinculado |
| `connected` | `true`/`false` en vivo; `null` si no se pudo confirmar a tiempo |
| `pdf_format` | `ticket` o `a4` |
| `auto_send` | Al emitir se envía solo, sin pedirlo |
| `send_pdf` / `send_xml` | Archivos que se adjuntan por defecto |
| `messages` | Cupo del plan; `exceeded: true` bloquea los envíos |

Si el servidor responde `404`/`405`, esa instalación todavía no tiene esta función.

---

## `POST /api/qrapi/config`

Cambia las opciones. **Solo el administrador** (`users.type = admin`): otros perfiles reciben `403`.
Van solo los campos que cambian.

```json
{ "auto_send": true, "send_xml": true }
```

| Campo | Regla |
|---|---|
| `enabled` | booleano |
| `pdf_format` | `a4` o `ticket` |
| `auto_send` | booleano |
| `send_pdf` / `send_xml` | booleanos; **uno de los dos** tiene que quedar en `true`, si no `422 INVALID_ATTACHMENTS` |

Responde `200` con el mismo `data` de `status`, sin volver a preguntar la conexión.

---

## `POST /api/qrapi/send-document`

```json
{
  "document_id": 13,
  "phone_number": "987654321",
  "message": "Su comprobante B001-13 ...",
  "attachments": ["pdf", "xml"]
}
```

| Campo | Regla |
|---|---|
| `document_id` | Id de `documents`. Requerido si no mandas `sale_note_id` |
| `sale_note_id` | Id de `sale_notes`. Requerido si no mandas `document_id` |
| `phone_number` | 9 dígitos, u 11 con `51` |
| `message` | Opcional: el texto que acompaña al archivo en el chat |
| `attachments` | Opcional: `["pdf"]`, `["xml"]` o los dos. Sin este campo se usa lo configurado |

### Respuesta

`202`

```json
{
  "success": true,
  "status": "queued",
  "message": "Comprobante en cola para enviarse por WhatsApp.",
  "data": { "delivery_id": 41, "status": "queued", "deduplicated": false }
}
```

- **Sin esperas:** responde en menos de un segundo; el envío ocurre después.
- **Sin duplicados:** si repites el mismo comprobante y celular antes de 5 minutos, devuelve la
  entrega anterior con `deduplicated: true`.

### Errores

| Status | `error_code` | Qué pasó |
|---|---|---|
| 401 | — | Token ausente o vencido |
| 422 | `QR_API_DISABLED` | El envío por WhatsApp está apagado |
| 422 | `QR_API_NO_INSTANCE` | No hay número vinculado |
| 422 | `INVALID_PHONE` | El celular no es peruano de 9 dígitos |
| 404 | `DOCUMENT_NOT_FOUND` | Ese comprobante no existe |
| 422 | `INVALID_ATTACHMENTS` | `attachments` sin `pdf` ni `xml` |
| 422 | `WHATSAPP_QUOTA_EXCEEDED` | Se acabó el cupo de mensajes del plan |
| 502 | `SEND_FAILED` | No se pudo poner en cola |

---

## `GET /api/qrapi/deliveries/{id}`

```json
{
  "success": true,
  "data": {
    "delivery_id": 41,
    "document_id": 13,
    "sale_note_id": null,
    "attachments": ["pdf", "xml"],
    "source": "manual",
    "status": "sent",
    "error_code": null,
    "message": "Comprobante enviado por WhatsApp.",
    "sent_at": "2026-09-17T11:48:29-05:00",
    "updated_at": "2026-09-17T11:48:29-05:00"
  }
}
```

`404 DELIVERY_NOT_FOUND` si ese id no existe. Nunca devuelve el celular.

### Estados

| `status` | Final | Qué significa |
|---|---|---|
| `queued` | No | En cola |
| `sending` | No | Enviándose |
| `sent` | Sí | Llegó a WhatsApp |
| `failed` | Sí | No salió (mira `error_code`) |
| `unconfirmed` | Sí | **Pudo haber salido**: se cortó la respuesta. No se reintenta solo; revisa el chat antes de reenviar |

`error_code` de un `failed`: `SEND_FAILED`, `QR_API_DISCONNECTED`, `PDF_UNAVAILABLE`,
`XML_UNAVAILABLE`, `SEND_PARTIAL` (salió el PDF pero no el XML), `DOCUMENT_NOT_FOUND`,
`QR_API_DISABLED`, `QR_API_NO_INSTANCE`.

---

## Aviso en tiempo real

En cada estado final el servidor emite `whatsapp.receipt.updated` por el canal privado del catálogo
del tenant (`private-catalog.tenant.{clave}.{ruc}`), el mismo que ya escucha la app:

```json
{
  "event_id": "…",
  "delivery_id": 41,
  "document_id": 13,
  "sale_note_id": null,
  "attachments": ["pdf"],
  "source": "auto",
  "status": "sent",
  "error_code": null,
  "message": "Comprobante enviado por WhatsApp.",
  "updated_at": "2026-09-17T11:48:29-05:00"
}
```

Si no escuchas el socket, consulta `deliveries/{id}` unas pocas veces (por ejemplo a los 20, 45 y
90 s). No hace falta más: el envío suele tardar unos segundos.

---

## Envío automático al emitir

Con `auto_send` activo, al emitir se pone en cola el WhatsApp al celular del cliente, sin una segunda
llamada. Es el equivalente por WhatsApp de
[36 — Envío automático por correo](36-envio-automatico-por-correo.md).

La respuesta de la emisión (`POST /api/documents`, `POST /api/sale-notes`) trae:

```json
{ "success": true, "data": { "...": "" },
  "whatsapp_delivery": { "delivery_id": 41, "status": "queued", "attachments": ["pdf"] } }
```

Va en `null` si el envío automático está apagado, el cliente no tiene celular válido, no hay número
conectado o se acabó el cupo. **Nunca hace fallar la emisión.**

---

## Adjuntos: PDF y XML

| `attachments` | Qué llega al cliente |
|---|---|
| `["pdf"]` | El PDF con el texto |
| `["pdf","xml"]` | El PDF con el texto y, seguido, el XML firmado |
| `["xml"]` | Solo el XML firmado |
| Nota de venta | Siempre solo el PDF (no tiene XML) |

- El cupo del plan cuenta **una vez por comprobante**, aunque lleve los dos archivos.
- Si el PDF salió y el XML no, la entrega queda `failed` con `SEND_PARTIAL`: el PDF ya llegó, así que
  reenviar manda el comprobante dos veces.

---

## Qué necesita el servidor

- El worker `laravel-whatsapp-worker` (cola `whatsapp`) corriendo: lo instala el script de
  actualización. Sin él las entregas se quedan en `queued`.
- Un servidor Evolution: el propio del servidor (recomendado) o el proxy externo. Se elige en
  **Configuraciones → Servidor Evolution** del panel del superadmin.
