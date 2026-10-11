# 22 — Inventario: Movimientos de Stock

> `POST /api/inventory/transaction`  
> **Auth:** `Bearer {token}`

---

## Descripción

Endpoint para registrar movimientos de inventario (ingresos y salidas) independientes de ventas. Las ventas descuentan stock automáticamente (ver [23-stock-por-establecimiento.md](23-stock-por-establecimiento.md)). Este endpoint es para ajustes manuales: recepciones de mercadería, mermas, transferencias, etc.

---

## 1. Ingreso de Stock

```
POST /api/inventory/transaction
Authorization: Bearer {token}
Content-Type: application/json
```

### Payload

```json
{
    "type": "input",
    "inventory_transaction_id": "03",
    "item_code": "PROD001",
    "quantity": 100,
    "warehouse_id": 1
}
```

### Campos

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `type` | string | **Sí** | `"input"` = Ingreso |
| `inventory_transaction_id` | string | **Sí** | Código del tipo de transacción (ver tabla abajo) |
| `item_code` | string | **Sí** | `internal_id` del producto |
| `quantity` | float | **Sí** | Cantidad a ingresar |
| `warehouse_id` | int | **Sí** | ID del almacén destino |

### Response (200 OK)

```json
{
    "success": true,
    "message": "Ingreso registrado correctamente"
}
```

> **Nota:** La API retorna `succes` (sin doble `s`) en la respuesta real. Es un typo del backend.

---

## 2. Salida de Stock

```
POST /api/inventory/transaction
Authorization: Bearer {token}
Content-Type: application/json
```

### Payload

```json
{
    "type": "output",
    "inventory_transaction_id": "03",
    "item_code": "PROD001",
    "quantity": 3,
    "warehouse_id": 1
}
```

### Campos

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `type` | string | **Sí** | `"output"` = Salida |
| `inventory_transaction_id` | string | **Sí** | Código del tipo de transacción |
| `item_code` | string | **Sí** | `internal_id` del producto |
| `quantity` | float | **Sí** | Cantidad a retirar |
| `warehouse_id` | int | **Sí** | ID del almacén origen |

### Response (200 OK)

```json
{
    "success": true,
    "message": "Salida registrada correctamente"
}
```

---

## Tipos de Transacción de Inventario

### Ingresos (`type: "input"`)

| Código | Descripción |
|--------|-------------|
| `02` | Compra Nacional |
| `03` | Producción |
| `05` | Transferencia entre almacenes |
| `07` | Devolución |
| `09` | Inventario inicial |
| `99` | Otros |

### Salidas (`type: "output"`)

| Código | Descripción |
|--------|-------------|
| `01` | Venta |
| `03` | Consumo interno |
| `05` | Transferencia entre almacenes |
| `07` | Merma / Desmedro |
| `99` | Otros |

---

## Notas para Offline

- **Las ventas NO requieren este endpoint.** Al emitir un comprobante (boleta/factura/nota de venta), el stock se descuenta automáticamente via Model Events del backend. Ver [23-stock-por-establecimiento.md](23-stock-por-establecimiento.md).
- **Este endpoint es para ajustes manuales:** recepción de mercadería, mermas, transferencias entre almacenes.
- **Para Flutter offline:** Se puede registrar un movimiento de inventario al sincronizar, pero es un caso poco común en operación POS. Los movimientos de inventario normalmente se hacen desde la web.
- **`item_code` = `internal_id`:** Usar el código interno del producto, no el ID numérico.
- **`warehouse_id`:** Obtenerlo de la descarga de datos de empresa → `establishments[].warehouse.id`.
- **Productos con lotes o series** (desde 2026-10-10):
  - **Salida de un producto con lotes:** se reparte por vencimiento en el servidor, como en la web (*Inventario › Movimientos*), y crea su guía interna. La respuesta agrega `data.lots` con lo que salió de cada lote.
  - **Ingreso de un producto con lotes** (la API no recibe lote ni vencimiento) y **cualquier movimiento de un producto con series:** responde `success: false` con un mensaje que lleva a la web.
  - **`type` que no sea `input` u `output`, o un `inventory_transaction_id` que no existe:** responde `success: false` con un mensaje claro.
  - Los productos sin lotes ni series no cambian.
- **Ajuste de stock (`POST /api/pro8/inventory/stock`):** en un producto con lotes responde `success: false`; se ajusta desde la web, lote por lote.
- **`warehouse_id` es opcional** (desde 2026-10-10), aquí y en el ajuste: sin él, el movimiento va al almacén del establecimiento del usuario; si viene, tiene que existir (si no, 422).
- **Motivos y almacén:** `GET /api/inventory/transaction/tables` devuelve `{success, data: {warehouse: {id, description} | null, transactions: {input: [{id, name}], output: [{id, name}]}}}`, con los motivos de `inventory_transactions` por nombre. Los códigos de las tablas de abajo son de ejemplo: use los que devuelve este endpoint.

---

## Inventario › Movimientos completo (desde 2026-10-10)

Endpoints que usa la pantalla Inventario de la app para trabajar como la web. Requieren `permissions.manage_inventory` del bundle de login: admin, el módulo web de Productos o de Inventario, o el módulo de app Productos. Sin ese permiso responden 403. Para saber si el servidor los tiene, `GET /api/inventory/transaction/tables` trae `features: ["movements", "transfers", "lots_conversion", "stock_check"]`, además de `warehouses` y `can_manage`.

Desde 2026-10-11, `features` suma `excel_import_link` y las tablas traen `can_open_panel_inventory` (admin o módulo web Inventario). Con los dos, la app puede abrir en el navegador `{dominio}/inventory?importar=excel`: el Panel muestra solo el diálogo «Inventario y lotes con Excel». Un producto nuevo para ingresarle varios lotes se crea con `POST /api/pro8/items/save` sin stock inicial ([21 §5](21-productos-crud.md#5-ficha-de-producto-completa-de-la-app-pro8items-desde-2026-10-11)) y después se registra el Ingreso con `input_lots`.

| Método | Ruta | Qué hace |
|---|---|---|
| GET | `/api/pro8/inventory/records` | Una fila por producto y almacén, con el stock por lote (`lots`, `uncovered`, `excess`, `negative`), `series_enabled` e `item_barcode`. Parámetros: `search` (nombre, código, código de barras o el de una presentación), `item_id`, `warehouse_id`, `stock_filter` (`positive`, `zero` o `negative`), `per_page` (10 a 50) y `page`. |
| GET | `/api/pro8/inventory/items/{item}/lots` | Los lotes del producto con su saldo, el stock por almacén y la `snapshot` (huella) para el ajuste por lotes. |
| POST | `/api/pro8/inventory/items/{item}/lots-conversion` | Ajuste por lotes: `{snapshot, simulate, lots: [{id, quantity}], rows: [{code, date_of_due, quantity}], counts?, excess?}`. Con `simulate: 1` devuelve el `plan` sin escribir. 409 si la huella cambió. Un producto sin lotes o con series responde 422. |
| POST | `/api/pro8/inventory/movements` | `{type, item_id, warehouse_id?, inventory_transaction_id, quantity, comments?, input_lots?, IdLoteSelected?}`: ingreso con lotes, salida por vencimiento o con los lotes elegidos. Remover es una salida con el motivo `12` (Retiro). Deja una guía por movimiento. Los productos con series responden 422. |
| POST | `/api/pro8/inventory/transfers` | `{item_id, warehouse_id, warehouse_destination_id, quantity, detail?}`: traslado con la guía U4. El stock de origen lo verifica el servidor; los lotes no cambian. |
| POST | `/api/pro8/inventory/stock` | Ajuste «Stock Real» de siempre. Con `check_stock: true`, si el stock del sistema ya no es el `quantity` enviado, responde 409 con `data.stock`. |

Los errores de validación vienen como `{success: false, message, errors: {campo: [mensajes]}}`, con el status (422 o 409).
