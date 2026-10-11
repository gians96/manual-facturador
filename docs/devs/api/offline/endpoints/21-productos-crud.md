# 21 — Productos CRUD

> **Auth:** `Bearer {token}`  
> **Base URL:** `/api`

---

## Descripción

Endpoints para gestionar productos/ítems. Son necesarios para que Flutter pueda:

1. **Descargar / Buscar** el catálogo de productos vía `GET /api/document/search-items` (**ruta canónica**)
2. **Registrar** nuevos productos desde la app
3. **Editar** productos existentes

> ℹ️ El documento [03-items-categorias.md](03-items-categorias.md) describe los endpoints legacy `/api/sellnow/items` y `/api/sellnow/categories`. Ambos retornan el catálogo pero **`search-items` es la ruta oficial** para nuevas integraciones Flutter.

---

## 1. Registrar Producto

```
POST /api/item
Authorization: Bearer {token}
Content-Type: application/json
```

### Payload

```json
{
    "id": null,
    "item_type_id": "01",
    "internal_id": "PROD001",
    "item_code": null,
    "item_code_gs1": null,
    "description": "Aceite de Oliva 250ml",
    "name": "Aceite de Oliva 250ml",
    "second_name": null,
    "unit_type_id": "NIU",
    "currency_type_id": "PEN",
    "sale_unit_price": "25.00",
    "purchase_unit_price": 15,
    "has_isc": false,
    "system_isc_type_id": null,
    "percentage_isc": 0,
    "suggested_price": 0,
    "sale_affectation_igv_type_id": "10",
    "purchase_affectation_igv_type_id": "10",
    "calculate_quantity": false,
    "stock": 100,
    "stock_min": 10,
    "has_igv": true,
    "has_perception": false,
    "item_unit_types": [],
    "percentage_of_profit": 0,
    "percentage_perception": 0,
    "image": null,
    "image_url": null,
    "temp_path": null,
    "is_set": false,
    "account_id": null,
    "category_id": null,
    "brand_id": null,
    "date_of_due": null,
    "lot_code": null,
    "lots_enabled": false,
    "lots": []
}
```

### Campos principales

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | int\|null | No | `null` para crear nuevo, ID para actualizar |
| `item_type_id` | string | **Sí** | `"01"` = Producto, `"02"` = Servicio |
| `internal_id` | string | **Sí** | Código interno único del producto |
| `item_code` | string\|null | No | Código de producto SUNAT (8 dígitos, catálogo 25), por ejemplo `"11101906"`. Va al XML de los comprobantes que usan el código del producto. No se valida el formato: escribe solo los 8 dígitos o `null`. El código de barras va en `barcode` |
| `item_code_gs1` | string\|null | No | Código GS1 |
| `description` | string | **Sí** | Descripción del producto |
| `name` | string | **Sí** | Nombre del producto |
| `second_name` | string\|null | No | Nombre alternativo |
| `unit_type_id` | string | **Sí** | `"NIU"` (unidad), `"KGM"` (kg), `"BX"` (caja), etc. |
| `currency_type_id` | string | **Sí** | `"PEN"`, `"USD"` |
| `sale_unit_price` | string/float | **Sí** | Precio de venta unitario (con IGV si `has_igv=true`) |
| `purchase_unit_price` | float | No | Precio de compra |
| `has_isc` | bool | No | ¿Tiene ISC? Default `false` |
| `system_isc_type_id` | string\|null | No | Tipo de sistema ISC |
| `percentage_isc` | float | No | Porcentaje ISC |
| `suggested_price` | float | No | Precio sugerido |
| `sale_affectation_igv_type_id` | string | **Sí** | `"10"` Gravado, `"20"` Exonerado, `"30"` Inafecto |
| `purchase_affectation_igv_type_id` | string | No | Afectación IGV para compras |
| `calculate_quantity` | bool | No | Calcular cantidad automáticamente |
| `stock` | float | No | Stock inicial |
| `stock_min` | float | No | Stock mínimo (alerta) |
| `has_igv` | bool | **Sí** | `true` = el `sale_unit_price` incluye IGV |
| `has_perception` | bool | No | ¿Tiene percepción? |
| `item_unit_types` | array | No | Unidades de medida adicionales (presentaciones) |
| `percentage_of_profit` | float | No | Porcentaje de ganancia |
| `percentage_perception` | float | No | Porcentaje percepción |
| `image` | string\|null | No | Base64 de la imagen |
| `image_url` | string\|null | No | URL de la imagen |
| `is_set` | bool | No | ¿Es un combo/kit? |
| `category_id` | int\|null | No | ID de categoría |
| `brand_id` | int\|null | No | ID de marca |
| `lots_enabled` | bool | No | ¿Maneja lotes? |
| `lots` | array | No | Lotes iniciales |

### Response (200 OK)

```json
{
    "success": true,
    "msg": "Producto registrado con éxito",
    "data": {
        "id": 150,
        "description": "Aceite de Oliva 250ml",
        "internal_id": "PROD001"
    }
}
```

---

## 2. Editar Producto

```
POST /api/items/{item_id}/update
Authorization: Bearer {token}
Content-Type: application/json
```

> **Nota:** Reemplace `{item_id}` con el ID del producto a editar.

### Payload

Mismo formato que registrar, pero con `id` obligatorio:

```json
{
    "id": 150,
    "item_type_id": "01",
    "internal_id": "PROD001",
    "item_code": null,
    "description": "Aceite de Oliva Premium 250ml",
    "name": "Aceite de Oliva Premium 250ml",
    "unit_type_id": "NIU",
    "currency_type_id": "PEN",
    "sale_unit_price": "30.00",
    "purchase_unit_price": 18,
    "sale_affectation_igv_type_id": "10",
    "has_igv": true,
    "stock": 100,
    "stock_min": 10,
    "...": "demás campos"
}
```

### Response (200 OK)

```json
{
    "success": true,
    "msg": "Producto editado con éxito",
    "data": {
        "id": 150,
        "description": "Aceite de Oliva Premium 250ml",
        "internal_id": "PROD001"
    }
}
```

---

## 3. Listar Productos

```
GET /api/document/search-items
Authorization: Bearer {token}
```

Retorna todos los productos activos.

### Response (200 OK)

```json
{
    "success": true,
    "data": [
        {
            "id": 3,
            "full_description": "FFF - Producto KG",
            "description": "Producto KG",
            "currency_type_id": "PEN",
            "internal_id": "FFF",
            "item_code": null,
            "currency_type_symbol": "S/",
            "sale_unit_price": "102.0000",
            "purchase_unit_price": "0.0000",
            "unit_type_id": "KGM",
            "sale_affectation_igv_type_id": "10",
            "purchase_affectation_igv_type_id": "10",
            "has_igv": true,
            "lots_enabled": false,
            "series_enabled": false,
            "lots": [],
            "warehouses": [
                {
                    "warehouse_id": 1,
                    "warehouse_description": "Almacén Principal",
                    "stock": "95.0000"
                }
            ],
            "item_unit_types": [],
            "category_id": null,
            "brand_id": null
        }
    ]
}
```

> **Para Flutter offline:** Este endpoint se usa en la descarga inicial para obtener el catálogo completo. El array `warehouses[]` contiene el stock por almacén.

---

## 4. Buscar Productos

```
GET /api/document/search-items?input={busqueda}
Authorization: Bearer {token}
```

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `input` | string | Busca por `internal_id` (código) o `description` (nombre) |

### Ejemplo

```
GET /api/document/search-items?input=aceite
```

Retorna el mismo formato que Listar, filtrado por el término de búsqueda.

---

## 5. Ficha de producto completa de la app (`pro8/items`, desde 2026-10-11)

Gestión de productos de la app, y «Nuevo producto» desde Inventario, guardan la misma ficha que
el formulario de Productos de la web y con su misma lógica.

### Permiso

Todas las escrituras de `/api/pro8/items*` y `/api/pro8/item-lots` piden
`permissions.manage_products` del bundle de login: alta, edición, `save`, borrar, duplicar,
inhabilitar, habilitar, acción masiva, importar y editar una serie.

Lo tiene:
- quien maneja el inventario (admin, o el módulo web Productos o Inventario, o el módulo de app Productos);
- quien tiene `items` entre sus `app_modules`, también los que salen de los permisos web.

Sin el permiso responden **403** `{success: false, message}`.

### Tablas: `GET /api/pro8/items/tables`

Además de unidades, monedas, afectaciones, almacenes, categorías, marcas y `configuration`
(`is_pharmacy`, `is_nrus`, `global_igv_handling`, `enable_list_product`), trae:

| Clave | Qué es |
|---|---|
| `attribute_types` | Tipos de atributo activos |
| `system_isc_types` | Tipos de ISC activos |
| `next_internal_id` | Sugerencia de código interno (solo una pista) |
| `price_labels` | Etiquetas de precio activas, por posición |
| `user_warehouse_id` | Almacén del establecimiento del usuario |
| `can_manage` | Si puede guardar productos |
| `features` | `["save", "initial_lots", "presentations", "warehouse_prices", "attributes", "without_initial_stock"]`. Sin esta clave el servidor es anterior: use la ficha corta (`POST /api/pro8/items`) |

La ficha de un producto para editarlo viene de `GET /api/pro8/items/record/{id}`. Sus lotes vienen de
`GET /api/pro8/inventory/items/{id}/lots` ([22](22-inventario-movimientos.md)).

### Guardar: `POST /api/pro8/items/save`

Sin `id` crea; con `id` edita. Todo se guarda en una transacción.

```json
{
    "id": null,
    "description": "PARACETAMOL 500 MG",
    "second_name": "Paracetamol",
    "name": "Analgésico",
    "unit_type_id": "NIU",
    "currency_type_id": "PEN",
    "sale_unit_price": 1.5,
    "purchase_unit_price": 0.8,
    "sale_affectation_igv_type_id": "10",
    "purchase_affectation_igv_type_id": "10",
    "has_igv": true,
    "stock": 0,
    "stock_min": 5,
    "warehouse_id": 1,
    "barcode": "7750000000001",
    "sanitary": "RS-123",
    "cod_digemid": "DG-9",
    "lots_enabled": true,
    "initial_lots": [
        { "code": "L-001", "date_of_due": "2027-03-31", "quantity": 12 },
        { "code": "L-002", "date_of_due": "2026-12-31", "quantity": 8 }
    ],
    "series_enabled": false,
    "item_unit_types": [
        {
            "id": null, "description": "CAJA X10", "unit_type_id": "BX", "quantity_unit": 10,
            "price_default": 1,
            "prices": [{ "price_label_id": 1, "label": "Precio 1", "position": 1, "price": 14 }]
        }
    ],
    "removed_item_unit_type_ids": [],
    "item_warehouse_prices": [{ "warehouse_id": 1, "price": "1.40" }],
    "attributes": [{ "attribute_type_id": "C", "description": "Color", "value": "Rojo" }]
}
```

Respuesta: `{ "success": true, "message": "Producto registrado con éxito", "id": 633 }`.

- **Lotes del stock inicial** (solo al crear, con `lots_enabled`):
  - el stock es la suma de `initial_lots` y se registra un solo «Stock inicial» en el kardex de `warehouse_id`;
  - se crea un lote por fila;
  - sin filas, el producto entra con stock 0 y los lotes llegan por un Ingreso o una compra.
- **Series:** se marca `series_enabled` con `stock` 0; las series se registran en el Panel.
- **Al editar:**
  - no se manda el stock (cambia por movimientos);
  - la imagen se conserva y los lotes quedan como están;
  - activar lotes en un producto con stock sin cubrir responde 422 en `lots_enabled` (pase por «Pasar a lotes» en el Panel).
- **Campos fuera de la ficha** se ignoran: imagen, series, insumos, etiquetas, `active`. Los ids de presentaciones, precios y precios por almacén tienen que ser del producto.
- **Errores:** `{success: false, message, errors: {campo: [mensajes]}}`, con 403, 404 (el producto no existe) o 422. Las filas de lotes se nombran «Lote N: …».

### El endpoint de siempre: `POST /api/pro8/items`

La ficha corta de las apps anteriores sigue igual, con estos cambios (2026-10-11):
- exige el mismo permiso;
- `stock` tiene que ser un número no negativo;
- al editar no pisa el stock ni activa lotes sin cubrir;
- el alta ya no duplica el stock en otro almacén;
- un `id` que no existe responde 404.

`GET /api/pro8/items/records` busca solo por `description`, `internal_id`, `barcode`, `model`,
`brand` y `category`.

---

## Notas para Offline

- **Descarga inicial:** Usar `GET /api/document/search-items` (sin parámetro `input`) para descargar todo el catálogo con stock.
- **Creación offline:** Si Flutter necesita agregar productos nuevos que no estaban en el catálogo, puede sincronizarlos vía `POST /api/item` cuando haya conexión.
- **`force_create_if_not_exist`:** Los comprobantes (boleta/factura/nota de venta) aceptan este campo para crear ítems on-the-fly al sincronizar. Ver [12-nota-venta.md](12-nota-venta.md).
- **`internal_id` es único:** Si envías un producto con un `internal_id` que ya existe, el backend retorna error. Usar IDs generados localmente con prefijo para evitar colisiones (ej: `OFF-{uuid}`).
