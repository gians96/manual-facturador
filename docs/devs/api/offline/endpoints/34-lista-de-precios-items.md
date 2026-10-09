# 34 — Lista de Precios por Item (`item_unit_types`)

> Cada item puede tener **múltiples precios de venta** (lista de precios) asociados a unidades de medida distintas. Al momento de vender, Flutter puede permitir que el operador elija uno.

---

## Concepto

En Facturador, la "lista de precios" **no** es una tabla de listas de precios globales (tipo "Mayorista", "Minorista"). Es una relación 1:N entre `items` y **unidades de medida de venta**:

- Un item puede venderse como "UNIDAD" (`NIU`) a S/ 5.00
- El mismo item puede venderse como "CAJA × 12" a S/ 50.00
- Cada presentación tiene hasta **3 precios** (`price1/2/3`) y la **posición del que cobra** (`price_default`)

Esto vive en la tabla `item_unit_types`:

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | int | PK |
| `item_id` | int | FK → items |
| `unit_type_id` | string | FK → `cat_unit_types` (ej: `NIU`, `BX`, `GLN`) |
| `quantity_unit` | decimal(12,4) | Factor de conversión (1 CAJA = 12 UNIDADES) |
| `description` | string | Descripción libre (ej: `"Paracetamol caja × 12"`) |
| `price1` | decimal(12,2) | Precio de la etiqueta en la posición 1 |
| `price2` | decimal(12,2) | Precio de la etiqueta en la posición 2 |
| `price3` | decimal(12,2) | Precio de la etiqueta en la posición 3 |
| `price_default` | tinyint | **Posición (1, 2 o 3) del precio que cobra la presentación**. La columna tiene valor por defecto `2` en la BD (ver [`price_default`](#price_default-qué-precio-cobra-la-presentación)) |
| `barcode` | string | Código de barras de esa presentación |

> `item_unit_types` también se conoce en el código como **"presentaciones"** o **"unidades de venta"**.

---

## Flag de Configuración: `select_available_price_list`

```sql
-- tabla `configurations`
select_available_price_list BOOLEAN DEFAULT FALSE
```

Se expone en la configuración offline (ver [20-configuracion-offline.md](20-configuracion-offline.md)):

```json
{
    "select_available_price_list": true
}
```

### Comportamiento

| Valor | Comportamiento en el POS |
|-------|--------------------------|
| `false` (default) | Agregar item usa **directamente** su `sale_unit_price` (precio plano del item) |
| `true` | Al agregar, si `item_unit_types` no está vacío → mostrar modal con las presentaciones disponibles y que el usuario elija precio |

### ¿Dónde se descarga?

En el endpoint de configuración general del tenant:

```
GET /api/offline/configurations   (o payload del login)
```

El campo `select_available_price_list` viene dentro del objeto `configuration`. Flutter lo cachea en `SharedPreferences` al iniciar sesión.

---

## Dónde vienen los precios

El endpoint **`GET /api/document/search-items`** ya retorna el array `item_unit_types` por cada item de `data.items` (el delta `GET /api/catalog/delta` usa el mismo formato):

```json
{
    "id": 25,
    "description": "Paracetamol 500mg",
    "unit_type_id": "NIU",
    "sale_unit_price": "5.00",
    "currency_type_id": "PEN",
    "item_unit_types": [
        {
            "id": 101,
            "description": "Blíster × 10 tabletas",
            "unit_type_id": "NIU",
            "quantity_unit": 1,
            "price1": 5.00,
            "price2": 4.50,
            "price3": 4.00,
            "price_default": 1
        },
        {
            "id": 102,
            "description": "Caja × 10 blísters",
            "unit_type_id": "BX",
            "quantity_unit": 10,
            "price1": 45.00,
            "price2": 42.00,
            "price3": 40.00,
            "price_default": 1
        }
    ]
}
```

> **Ref:** `app/Services/Tenant/MobileCatalogItemTransformer.php` → `transform()`, compartido por `MobileController::searchItems()` y `CatalogSyncController::delta()`. Cada presentación trae solo `id`, `description`, `unit_type_id`, `quantity_unit`, `price1`, `price2`, `price3` y `price_default`. Los precios salen tal como están en las columnas (decimales de MySQL, pueden llegar como texto: `"45.00"`).

### Campos clave

| Campo | Uso |
|-------|-----|
| `id` | **Este es el `item_unit_type_id`** que se envía en el payload al vender |
| `description` | Texto a mostrar en el selector |
| `unit_type_id` | Código SUNAT de la unidad (`NIU`, `BX`, `GLN`, `KGM`, etc.) — se envía en `unidad_de_medida` |
| `quantity_unit` | Factor: cuántas unidades base equivale (para kardex/stock) |
| `price1/2/3` | Los 3 precios posibles, uno por posición de etiqueta |
| `price_default` | Posición (`1`, `2` o `3`) del precio que **cobra** la presentación. Es el que se usa si el usuario no elige |

### `price_default`: qué precio cobra la presentación

`price_default` no es un precio: es la **posición** (1, 2 o 3) del precio que cobra la presentación. Todos los lectores cobran `price{price_default}`:

- el POS web (`priceFromPresentation` en `resources/js/views/tenant/pos/index.vue`);
- el app (`ItemUnitType.defaultPrice`, que cae en `price1` si el valor no es 2 ni 3);
- la exportación de precios a DIGEMID (`CatDigemid::updatePrices`).

En el panel se elige en la columna **Cobra el POS** de la pestaña Presentaciones del producto. Desde 2026-10-08:

- **Las presentaciones nuevas del formulario nacen en `1`**, o en la posición de la etiqueta de precio marcada `is_default` si está activa y entre 1 y 3 (si no, la menor posición activa entre 1 y 3).
- **El backend normaliza al guardar** (`ItemUnitType::normalizePriceDefault`, llamado desde `ItemController`): si el valor recibido no es 1, 2 ni 3, conserva el guardado si es válido; si tampoco, guarda `1`.

Antes, el formulario creaba cada presentación con `price_default = 2` y sin selector: si solo se llenaba el primer precio, el POS, el app y DIGEMID cobraban S/ 0. Esas presentaciones siguen en la BD con `2` hasta que alguien las corrija en el formulario. Además, la columna tiene **valor por defecto `2`**, así que una presentación creada por otro camino sin indicar `price_default` también nace en 2. El cliente **no debe suponer** `price_default = 1`: debe cobrar siempre `price{price_default}`.

#### Precios por etiqueta y `price1/2/3`

Los nombres de los precios son **etiquetas** (`price_labels`, se configuran en *Configuración › Avanzado › Visual › Gestionar Etiquetas de Precios*), y el formulario guarda el precio de cada etiqueta en `item_unit_type_prices`. Al guardar el producto, `ItemController::syncLegacyPriceColumns` copia esos precios a las columnas **por posición de la etiqueta**: posición 1 → `price1`, 2 → `price2`, 3 → `price3`. Si una posición no tiene precio por etiqueta, la columna conserva su valor.

- Las etiquetas en posición 4 o mayor **no llegan** a `price1/2/3`: no viajan al app ni se pueden elegir en **Cobra el POS**.
- El app recibe solo las columnas `price1/2/3` y `price_default`, no `item_unit_type_prices`. Los nombres de las etiquetas activas están en `GET /api/price-labels/active` (`MobileController::priceLabels`).

---

## Cómo Elegir el Precio en Flutter

### Caso A — `select_available_price_list = false`

Flujo simple (no se muestra nada al operador):

```dart
cartItem.unitPrice = item.saleUnitPrice;          // "5.00"
cartItem.unitTypeId = item.unitTypeId;            // "NIU"
cartItem.itemUnitTypeId = null;                    // no se envía
```

### Caso B — `select_available_price_list = true`

Al agregar, si `item.itemUnitTypes` tiene ≥ 1 entrada:

```
┌──────────────────────────────────────────┐
│ Paracetamol 500mg — Elegir presentación   │
├──────────────────────────────────────────┤
│ ○ Blíster × 10                            │
│   • Precio 1: S/ 5.00  ★ default          │
│   • Precio 2: S/ 4.50                     │
│   • Precio 3: S/ 4.00                     │
├──────────────────────────────────────────┤
│ ○ Caja × 10 blísters                      │
│   • Precio 1: S/ 45.00 ★ default          │
│   • Precio 2: S/ 42.00                    │
│   • Precio 3: S/ 40.00                    │
└──────────────────────────────────────────┘
```

Al confirmar:

```dart
final presentation = item.itemUnitTypes[selectedIndex];
final selectedPrice = selectedPriceNumber == 1
    ? presentation.price1
    : (selectedPriceNumber == 2 ? presentation.price2 : presentation.price3);

cartItem.itemUnitTypeId = presentation.id;           // 102
cartItem.unitTypeId = presentation.unitTypeId;       // "BX"
cartItem.unitPrice = selectedPrice;                  // 42.00
cartItem.quantityUnit = presentation.quantityUnit;   // 10 (para kardex)
```

---

## Payload del Documento con Presentación Elegida

Al emitir el comprobante, el item lleva los campos **ya mapeados a la presentación seleccionada**:

```json
{
    "items": [
        {
            "codigo_interno": "MED-001",
            "descripcion": "Paracetamol 500mg — Caja × 10 blísters",
            "unidad_de_medida": "BX",
            "cantidad": 2,
            "valor_unitario": 35.59,
            "precio_unitario": 42.00,
            "codigo_tipo_precio": "01",
            "codigo_tipo_afectacion_igv": "10",
            "item_unit_type_id": 102,
            "quantity_unit": 10,
            "total_base_igv": 71.19,
            "porcentaje_igv": 18,
            "total_igv": 12.81,
            "total_impuestos": 12.81,
            "total_valor_item": 71.19,
            "total_item": 84.00
        }
    ]
}
```

### Campos específicos de presentación

| Campo API | Descripción |
|-----------|-------------|
| `unidad_de_medida` | `unit_type_id` de la presentación elegida |
| `precio_unitario` | Precio elegido (1, 2 o 3) |
| `valor_unitario` | `precio_unitario / (1 + igv%)` si afectación `10` |
| `item_unit_type_id` | **ID del `item_unit_types` seleccionado** (entero) |
| `quantity_unit` | Factor de conversión (informativo, se usa en kardex) |

> El `item_unit_type_id` es **clave** para que el kardex descuente correctamente el stock base (el descuento real = `cantidad × quantity_unit`).

---

## Filtrado por Establecimiento / Usuario

Las presentaciones (`item_unit_types`) **no** se filtran por establecimiento — son parte del catálogo del item. Sin embargo:

- El **item** ya viene filtrado por warehouse del establecimiento (ver [33-validacion-contrato-offline.md](33-validacion-contrato-offline.md)).
- Por lo tanto, Flutter sólo ve presentaciones de items que puede vender.
- **No hay asignación de presentaciones por usuario.** Si un tenant quiere restringir "solo caja, no unidades" para un vendedor, debe crear items distintos o usar `disabled` a nivel item.

---

## Casos Especiales

### Item con 1 sola presentación

Aunque `select_available_price_list = true`, si el item tiene **exactamente una** entrada en `item_unit_types`, Flutter puede saltarse el selector y usar directamente la `price_default` de esa presentación.

### Item sin `item_unit_types`

Algunos items (especialmente servicios `unit_type_id == 'ZZ'`) pueden no tener presentaciones. En ese caso:

- Usar `sale_unit_price` plano del item.
- No enviar `item_unit_type_id` en el payload.

### Override manual de precio (descuento en línea)

Si `configuration.edit_sale_unit_price = true` (otro flag), el operador puede **editar el precio manualmente** tras elegir presentación. Flutter actualiza `precio_unitario` y recalcula `valor_unitario`, IGV e impuestos localmente.

---

## Almacenamiento Local (SQLite)

```sql
CREATE TABLE item_unit_types (
  id INTEGER PRIMARY KEY,
  item_id INTEGER NOT NULL,
  unit_type_id TEXT,
  description TEXT,
  quantity_unit REAL,
  price1 REAL,
  price2 REAL,
  price3 REAL,
  price_default INTEGER,
  barcode TEXT,
  FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE
);

CREATE INDEX idx_iut_item ON item_unit_types(item_id);
CREATE INDEX idx_iut_barcode ON item_unit_types(barcode);
```

Al llamar `search-items`, persistir el array completo en esta tabla.

---

## Búsqueda por Código de Barras de Presentación

Cada `item_unit_type` puede tener su propio `barcode` (caja con código distinto a la unidad).

> **Ojo:** hoy `search-items` y el delta **no** incluyen el `barcode` de la presentación (ver los campos de `MobileCatalogItemTransformer` arriba). Esta búsqueda local solo sirve si el cliente obtiene ese dato por otra vía.

```dart
// Buscar por barcode local
final match = await db.query(
  'item_unit_types',
  where: 'barcode = ?',
  whereArgs: [scannedCode],
);
if (match.isNotEmpty) {
    final iut = match.first;
    final item = await db.getItem(iut['item_id']);
    // Agregar con esa presentación automáticamente
    addToCart(item, presentation: iut);
}
```

---

## Resumen

| # | Verificación | Cómo lo resuelve Facturador |
|---|--------------|------------------------|
| ✅ | ¿Hay lista de precios por item? | `item_unit_types[]` en `search-items` |
| ✅ | ¿Se puede elegir al vender? | Sí, si `configuration.select_available_price_list = true` |
| ✅ | ¿Los precios están asignados? | Sí, por item (no por usuario ni establecimiento) |
| ✅ | ¿Se descargan offline? | Sí, vienen en el payload de `search-items` |
| ✅ | ¿Se envían en la venta? | Sí, como `item_unit_type_id` + `unidad_de_medida` + `precio_unitario` elegidos |

---

## Referencias de Código

| Archivo | Línea | Propósito |
|---------|-------|-----------|
| `app/Services/Tenant/MobileCatalogItemTransformer.php` | `transform()` | Formato de `item_unit_types` en `search-items` y en el delta |
| `app/Models/Tenant/ItemUnitType.php` | `normalizePriceDefault()` | `price_default` siempre 1, 2 o 3 al guardar desde el formulario |
| `app/Http/Controllers/Tenant/ItemController.php` | `syncLegacyPriceColumns()` | Copia los precios por etiqueta (posiciones 1-3) a `price1/2/3` |
| `database/migrations/tenant/2019_05_07_160954_tenant_item_unit_types_table.php` | 15 | Schema `item_unit_types` |
| `database/migrations/tenant/2021_08_09_131738_tenant_add_select_available_price_list_to_configurations.php` | 17 | Flag `select_available_price_list` |
| `app/Models/Tenant/Configuration.php` | 651, 2279 | Getter/setter del flag |
| `resources/js/views/tenant/pos/fast.vue` | 950 | Lógica POS web: abre modal si el flag está activo |
| `resources/js/views/tenant/pos/index.vue` | 1816 | Misma lógica en POS principal |
