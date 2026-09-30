# 07 — Caja (Apertura, Cierre y Verificación)

> **Uso offline:** Gestión de caja para controlar turnos de venta. Cada comprobante se asocia a la caja abierta del usuario.

---

## 1. Verificar Caja Abierta

> `GET /api/cash/opening_cash`  
> **Controller:** `Tenant\Api\CashController@opening_cash`

### Response — Caja abierta

```json
{
    "success": true,
    "message": "Verificar si existe caja abierta",
    "data": {
        "cash_id": 4,
        "description": "REF 2026-04-18 (Administrador)"
    }
}
```

### Response — Sin caja abierta

```json
{
    "success": false,
    "message": "Verificar si existe caja abierta",
    "data": {
        "cash_id": null,
        "description": ""
    }
}
```

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `success` | bool | `true` si hay caja abierta, `false` si no |
| `data.cash_id` | int\|null | ID de la caja abierta. Se usa en `POST /api/cash/cash_document` |
| `data.description` | string | Referencia de la caja |

---

## 2. Aperturar Caja

> `POST /api/cash/open`  
> **Controller:** `Tenant\CashController@open`

Solo abre cajas. Una caja se edita desde el panel.

### Payload

```json
{
    "beginning_balance": 12,
    "reference_number": "restaurant",
    "offline_id": "5d2c7a1e-8b4f-4c3a-9e6d-1f2a3b4c5d6e"
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `beginning_balance` | float | **Sí** | Monto inicial en caja (saldo de apertura) |
| `reference_number` | string | No | Referencia: `"restaurant"` o libre |
| `offline_id` | string | No | UUID de la apertura hecha en el dispositivo. Si reintentas con el mismo, te devuelve la misma caja y no abre otra |
| `date_opening` · `time_opening` | string | No | Si no los mandas, el servidor usa la fecha y la hora de ese momento |
| `user_id` | int | No | La caja es del usuario del token. Solo un administrador puede abrirla para otro usuario, que tiene que ser vendedor o administrador. `0` o vacío equivale al usuario del token |
| `id` | — | **No se envía** | Si llega un `id`, la caja no se toca y la respuesta es `CASH_OPEN_WITH_ID` (ver abajo) |

:::info Desde el 2026-09-30
`POST /api/cash/open` **solo abre**. Antes, si llegaba un `id`, actualizaba esa caja con todo lo que
viniera en el cuerpo: así se podía reabrir una caja cerrada o reescribir su arqueo. Ahora `state`,
`final_balance`, `income`, `date_closed`, `time_closed` y `apply_restaurant` se ignoran: la caja nace
abierta y con los totales en cero. Si no eres administrador, el `user_id` también se ignora.
:::

### Response (200 OK)

```json
{
    "success": true,
    "was_duplicate": false,
    "message": "Caja aperturada con éxito",
    "data": {
        "cash_id": 4,
        "offline_id": "5d2c7a1e-8b4f-4c3a-9e6d-1f2a3b4c5d6e"
    }
}
```

Si reintentas con el mismo `offline_id`, recibes la caja que ya se abrió:

```json
{
    "success": true,
    "message": "Caja aperturada previamente",
    "was_duplicate": true,
    "data": {
        "cash_id": 4,
        "offline_id": "5d2c7a1e-8b4f-4c3a-9e6d-1f2a3b4c5d6e"
    }
}
```

### Rechazos

Llegan con HTTP 200, `success: false`, un `error_code` y el `message`. No se abre ninguna caja.

```json
{
    "success": false,
    "error_code": "CASH_OPEN_WITH_ID",
    "message": "Para abrir una caja no se envía id; una caja se edita desde el panel."
}
```

| `error_code` | Cuándo |
|---|---|
| `CASH_OPEN_WITH_ID` | Llegó un `id`. Quítalo: este endpoint no edita |
| `CASH_INVALID_USER` | Un administrador pidió abrir la caja para un usuario que no existe o que no puede tener caja |
| `CASH_ALREADY_OPEN` | Solo con «una caja abierta por usuario» activado en el servidor (ver abajo) |

:::note Una caja abierta por usuario (`single_open_cash_per_user`, apagado por defecto)
Si el servidor lo tiene activado y el usuario ya tiene otra caja abierta:

- **Con `offline_id`**, no se abre otra: se usa la que ya estaba abierta. La respuesta trae
  `success: true`, `merged_into_existing: true`, `beginning_balance_ignored` con el saldo que no se
  aplicó y `data.cash_id` de esa caja. Tu `offline_id` queda asociado a ella y sirve después para
  las ventas, `cash_document` y el cierre.
- **Sin `offline_id`**, se rechaza con `error_code: CASH_ALREADY_OPEN`. `data.open_cash_id` dice cuál
  es la caja abierta.
:::

---

## 3. Cerrar Caja

> `GET /api/cash/close/{cash_id}`  
> **Controller:** `Tenant\Api\CashController@close`

### URL

```
GET /api/cash/close/4
```

Solo cierra cajas del usuario del token. Puedes añadir `date_closed` y `time_closed` a la URL; si
no los mandas, se usan la fecha y la hora de ese momento.

### Response — Éxito

```json
{
    "success": true,
    "message": "Caja cerrada con éxito",
    "data": {
        "cash_id": 4,
        "offline_id": null,
        "was_duplicate": false
    }
}
```

### Response — La caja ya estaba cerrada

```json
{
    "success": true,
    "message": "Caja ya cerrada",
    "data": {
        "cash_id": 4,
        "offline_id": null,
        "was_duplicate": true
    }
}
```

No vuelve a calcular nada: el arqueo queda como estaba.

### Response — La caja no existe o es de otro usuario (HTTP 404)

```json
{
    "success": false,
    "message": "Caja no encontrada"
}
```

> El backend suma todos los documentos y notas de venta asociados a la caja, calcula `final_balance` e `income`, y cierra.
>
> Este endpoint no revisa las mesas. El aviso «No se puede cerrar caja, existe mesas abiertas» sale al cerrar desde el panel web.

---

## 4. Verificar Caja Específica

> `GET /api/cash/opening_cash_check/{cash_id}`  
> **Controller:** `Tenant\Api\CashController@opening_cash_check`

### Response

```json
{
    "success": true,
    "message": "Verificar si existe caja abierta",
    "data": {
        "cash_id": 4,
        "description": "REF 2026-04-18 (Administrador)"
    }
}
```

---

## 5. Asociar Venta a Caja

> `POST /api/cash/cash_document`  
> **Controller:** `Tenant\Api\CashController@cash_document`

### Payload

```json
{
    "cash_id": 4,
    "document_id": null,
    "sale_note_id": 25
}
```

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `cash_id` | int | ID de la caja abierta |
| `cash_offline_id` | string | UUID de la caja abierta sin conexión, si aún no tienes su ID de servidor |
| `document_id` | int\|null | ID del documento (Boleta/Factura/NC/ND). Mutualmente excluyente con `sale_note_id` |
| `sale_note_id` | int\|null | ID de la nota de venta. Mutualmente excluyente con `document_id` |
| `quotation_id` | int\|null | ID de cotización (opcional) |

> Se envía **uno** de los tres: `document_id`, `sale_note_id`, o `quotation_id`.

### Response

```json
{
    "success": true,
    "message": "Venta con éxito"
}
```

Si no mandas `cash_id` ni `cash_offline_id`, se usa la caja que el usuario tenga abierta. Si la caja
pedida no existe, es de otro usuario o está cerrada (o no pediste ninguna y el usuario no tiene una
abierta), la respuesta es HTTP 422:

```json
{
    "success": false,
    "message": "Caja no encontrada o cerrada"
}
```

### Idempotencia

El backend busca la venta en esa caja antes de crear nada, así que enviar el mismo `cash_id + document_id/sale_note_id` varias veces **no crea duplicados**.

:::info Desde el 2026-09-30
Tampoco duplica el crédito ni los pagos de caja de la venta. Antes, cada reintento creaba otro
crédito y otra fila por pago, y el arqueo contaba ese dinero dos veces.
:::

:::note Con el contexto de caja (`offline_sync_cash_context`, apagado por defecto)
Si el servidor lo tiene activado y mandas `cash_offline_id`, la venta se registra en **esa** caja o
en ninguna, aunque también mandes `cash_id`. Si no se puede, el 422 trae un `error_code`:

| `error_code` | Qué hacer |
|---|---|
| `CASH_NOT_FOUND` | Su apertura aún no llegó al servidor: sincronízala y reintenta |
| `CASH_OTHER_USER` | ❌ No reintentar: la caja es de otro usuario |
| `CASH_CLOSED` | ❌ No reintentar: la caja está cerrada |

Si la venta se emitió sin pago de caja (aviso `PAGO_SIN_CAJA` en el lote), al registrarla aquí por
primera vez en su caja se crea ese pago, una sola vez.
:::

---

## Notas para Offline

- **Apertura de caja** puede hacerse offline. Almacenar el `cash_id` local y sincronizar después.
- **Cada venta creada offline** debe guardarse con su `cash_id` local para asociarla al sincronizar.
- Al usar `sync-batch`, el backend registra cada comprobante en caja por su cuenta, así que no hace falta llamar a `POST /api/cash/cash_document` por separado. En qué caja queda y qué significa cada resultado: [registro en caja](15-sync-batch.md#registro-en-caja--cash_registered-y-cash_error_code).
- **Cierre de caja** requiere que todos los comprobantes pendientes se hayan sincronizado primero.
