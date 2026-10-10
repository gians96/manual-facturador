# Productos: Presentaciones y Lotes

En este artículo te enseñaremos a crear un medicamento con varios lotes, a corregir un lote y a venderlo por unidad, blíster o caja con el precio correcto. Sigue estos pasos para realizarlo:

:::danger IMPORTANTE:
Esta guía supone que el giro **Farmacia** está activo. Revisa la [Configuración Previa](./Configuración-Previa.md).
:::

## Nombres de los campos en farmacia

Con el giro **Farmacia** activo, el formulario de producto usa estos nombres:

| Nombre de siempre | En farmacia |
|---|---|
| Nombre secundario | **Principio activo** |
| Descripción | **Acción farmacológica** |
| Marca | **Laboratorio** |

El menú **Marcas** también pasa a llamarse **Laboratorios**.

## Crear un medicamento con varios lotes

Como ejemplo, registraremos un medicamento que llegó en dos lotes:

| Lote | Vencimiento | Cantidad |
|---|---|---|
| L-A | 31/12/2026 | 30 unidades |
| L-B | 30/06/2027 | 20 unidades |

1. Ingresa al módulo **Productos/Servicios**, selecciona la subcategoría **Productos** y luego el botón **Nuevo**.
2. En la pestaña **General** completa el **Nombre**, el **Principio activo**, la **Acción farmacológica**, la **Unidad** (por ejemplo, **Unidades**, si vendes por tableta) y el **Precio Unitario**, que es el precio de una unidad. En el ejemplo, S/ 0.50.
3. Marca la casilla **¿Maneja lotes?**. Debajo aparece la tabla **Lotes del stock inicial**.
4. Selecciona **Agregar lote** y completa la primera fila: código **L-A**, vencimiento **31/12/2026** y cantidad **30**.
5. Selecciona otra vez **Agregar lote** y completa la segunda fila: código **L-B**, vencimiento **30/06/2027** y cantidad **20**.
6. La fila **Total** de la tabla muestra **50**, y el campo **Stock Inicial** muestra lo mismo con la leyenda «Suma de los lotes». Ese campo no se escribe a mano.
7. Selecciona el botón **Guardar**.

El producto queda con stock 50 repartido en dos lotes, y el kardex registra un solo movimiento de stock inicial por el total.

:::tip
- La tabla puede quedar vacía: el producto se crea con stock 0 y los lotes entran después por **Compras**.
- Si ya habías escrito un stock inicial antes de marcar **¿Maneja lotes?**, la tabla empieza con una fila por esa cantidad. Solo te falta completar el código y el vencimiento.
- El código de lote no se puede repetir en la tabla. Si la unidad es **Unidades** (NIU), las cantidades van en números enteros.
- Si una fecha ya pasó, el lote se marca como **vencido**.
:::

## Corregir un lote

Si escribiste mal un código o un vencimiento, puedes corregirlo después:

1. En el listado de productos, abre el producto para editarlo.
2. En la pestaña **General** verás la tabla **Lotes del producto**, con el **Código**, el **Vencimiento** y el **Saldo** de cada lote, sumando todos los almacenes.
3. Corrige el dato. En el ejemplo, cambia el código **L-B** por **L-B2** y el vencimiento por **31/07/2027**.
4. Selecciona el botón **Guardar**.

Cambian el código y el vencimiento, pero el saldo del lote (20) sigue igual. La cantidad de un lote no se edita en el formulario: la mueven las compras, las ventas y el inventario.

Debajo de la tabla verás el stock del producto en todos los almacenes. Si los lotes no cuadran con el stock (**stock sin lote**, **lotes de más** o un stock negativo), el pie de la tabla lo dice y ofrece **Cuadrar…**, que abre el conteo por lote (ver abajo).

:::danger IMPORTANTE:
El código nuevo no puede ser el de otro lote del mismo producto.
:::

## Pasar a lotes un medicamento que ya tiene stock

Si un medicamento se vendía **sin lotes** y ahora quiere manejarlos, el stock que ya tiene hay que **rotularlo** en lotes sin duplicarlo:

1. En **Productos**, edite el medicamento y marque **¿Maneja lotes?**. Si tiene stock, se abre **Pasar a lotes**.
2. Arriba ve el stock general del sistema. Cuente lo que hay en el estante, lote por lote: en **Lotes del stock** escriba código, vencimiento y cantidad de cada uno. Abajo, **Stock general antes → después** muestra si lo contado sube o baja el stock.
3. Pulse **Revisar** (paso 2 de 2): verá el stock general antes → después, el ajuste de kardex si lo contado no coincide con el sistema, y los lotes que se crean. Todavía no se guardó nada.
4. Pulse **Confirmar**. El stock queda en la suma de los lotes y el producto ya maneja lotes. No depende del botón Guardar del producto.

Si cancela, la casilla vuelve a desmarcarse: un producto con stock sin lote no se puede vender con lotes.

:::tip Muchos productos a la vez
Para pasar a lotes o hacer la toma de inventario de muchos medicamentos, use **Inventario › Movimientos › Importar › Pasar a lotes (stock actual)**: descargue **Mis productos con su stock**, escriba una fila por lote con lo que cuente y súbalo en modo **Conteo**. Ver **[Importar masivamente](../../esenciales/productos-servicios/05-Productos-Importar-masivamente.md)**.
:::

## Presentaciones: blíster y caja

En la pestaña **Presentaciones**, la farmacia ve una fila simple por presentación, con estas columnas:

- **Presentación:** la unidad de medida de la presentación, con su código SUNAT entre paréntesis, por ejemplo, **Unidades (NIU)** o **Caja (BX)**. Ese código es el que va al comprobante electrónico.
- **Descripción:** el texto que se muestra al vender, por ejemplo, «Blíster».
- **Contiene:** cuántas unidades del producto trae, por ejemplo, 10 en un blíster de 10 tabletas.
- **Precio de venta:** lo que cobran el POS y la app móvil por la presentación.
- **Por unidad:** el precio de venta dividido entre las unidades que contiene, y cuánto más barato o caro sale frente a la unidad suelta (el **Precio Unitario** del producto).

:::danger IMPORTANTE: el blíster va con Unidades (NIU)
SUNAT no tiene un código de unidad para el blíster. El código **U2** significa **una tableta**: si vendes un blíster con U2, el comprobante declara 1 tableta aunque se hayan vendido 10. Por eso el botón **+ Blíster** usa **Unidades (NIU)** y la descripción «Blíster». Si una presentación con más de una unidad tiene U2, el formulario te avisa.
:::

Siguiendo el ejemplo, agregaremos un blíster de 10 tabletas y una caja de 100:

1. Selecciona **+ Blíster**. Se agrega una fila con la unidad **Unidades (NIU)** y la descripción «Blíster». El campo **Contiene** aparece vacío, con el ejemplo «Ej. 10», y en rojo «Indica cuántas unidades trae» hasta que lo completes.
2. En **Contiene** escribe **10**.
3. Mientras el **Precio de venta** esté vacío, debajo aparece la sugerencia **Usar S/ 5.00 (0.50 × 10)**, que es el precio unitario por las unidades que contiene. Selecciónala para usar ese monto o escribe otro. La columna **Por unidad** muestra **S/ 0.50 c/u** e «Igual que la unidad».
4. Selecciona **+ Caja**. Se agrega una fila con la unidad **Caja (BX)** y la descripción «Caja». Si tu empresa desactivó la unidad Caja, el sistema pregunta si quieres activarla.
5. En **Contiene** escribe **100** y en **Precio de venta**, **45.00**. Las cajas suelen llevar descuento, por eso la sugerencia no se llena sola. La columna **Por unidad** muestra **S/ 0.45 c/u** y «10 % menos que la unidad».
6. Para cualquier otra presentación, selecciona **+ Otra presentación** y elige la unidad.
7. Selecciona el botón **Guardar**.

:::tip
Si no ves los botones **+ Blíster** y **+ Caja**, tu cuenta admite una sola presentación por producto, con la unidad del producto. En ese caso verás el botón **Agregar presentación**.
:::

## ¿Qué precio cobra el POS?

Cada presentación tiene hasta tres precios: **Precio 1**, **Precio 2** y **Precio 3**. Puedes cambiarles el nombre en **Configuración › Avanzado › Visual › Gestionar Etiquetas de Precios**. El **Precio de venta** de la fila es el precio que cobra el POS.

Para elegir otro, selecciona **Más precios** debajo del precio de venta. Se despliegan los precios de la presentación, cada uno en una tarjeta:

- La que cobran el POS y la app móvil lleva la marca **✓ Cobra el POS** y queda resaltada. Ese mismo precio va en la exportación de precios a DIGEMID.
- Para cambiarla, selecciona **Usar en POS** en otra tarjeta. El campo **Precio de venta** de la fila pasa a mostrar y editar ese precio, y **Por unidad** se recalcula.
- Si la tarjeta elegida está en 0, sale en **rojo**: la presentación se cobraría a S/ 0.00.

:::danger IMPORTANTE:
- Las presentaciones nuevas empiezan cobrando el primer precio, o la etiqueta de precio marcada por defecto.
- Al guardar, si una presentación se cobraría a S/ 0.00 y tiene otro precio con valor, el sistema te avisa para que elijas otro precio con **Usar en POS** antes de guardar.
- Antes, las presentaciones nuevas cobraban el **Precio 2** sin que se pudiera ver: si solo llenabas el primer precio, el POS las cobraba a S/ 0.00. Revisa las presentaciones de tus productos antiguos.
:::

## Vender una presentación con lotes

Al vender un blíster o una caja en el POS o en la app móvil, el sistema descuenta sus unidades de los lotes empezando por el que vence primero. Si ese lote no alcanza, el resto sale del lote siguiente, así que **una presentación puede salir de varios lotes**.

Por ejemplo, con los lotes L-A (30 unidades) y L-B (20 unidades), vender 4 blísters de 10 descuenta 40 unidades: 30 del lote L-A y 10 del lote L-B.

## Desmarcar «¿Maneja lotes?»

Si editas el producto y desmarcas **¿Maneja lotes?**, aparece el aviso «Los lotes se conservan; las ventas dejarán de pedir lote». Al guardar:

- Los lotes **no se borran**: quedan guardados e inactivos.
- Las ventas dejan de pedir lote.
- La app móvil deja de recibir los lotes del producto y sus alertas de vencimiento.

Si vuelves a marcar la casilla, los lotes reaparecen con su saldo.

:::danger IMPORTANTE:
Las ventas hechas mientras los lotes estaban desactivados no descontaron ningún lote. Al reactivarlos, los saldos de los lotes pueden sumar más que el stock del producto: se abre el conteo por lote, donde elige qué es lo real (el stock, descontando de los lotes que vencen primero, o los lotes, subiendo el stock) y corrige lo que haga falta.
:::
