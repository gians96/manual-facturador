# Importar masivamente

Un solo Excel sirve para **crear y editar productos**, sus **presentaciones con precio**, sus **lotes** y su **stock**. Antes de guardar nada, el sistema muestra una **vista previa** con los errores de cada fila para que los corrija en el Excel.

Ingresa al módulo de **Productos/Servicios** y luego selecciona la subcategoría **Productos**. En la parte superior derecha selecciona el botón **Importar** y después **Productos**.

![img1](img/Importar-masivamente_01.jpg)

:::tip También desde Inventario
En **Inventario › Movimientos › Importar › Pasar a lotes (stock actual)** se abre la misma importación, con el título **Inventario y lotes con Excel** y el modo **Conteo** ya elegido: es la forma de hacer la toma de inventario con un Excel.
:::

La ventana va en pasos numerados: arriba el **Almacén**, después **1** consiga el Excel, **2** elija qué es la columna Stock, **3** suba el archivo y **4** revise la vista previa. Al pie, al lado de los botones, se lee qué falta para poder importar.

## 1. Consiga el archivo

En el paso **1 · Consiga el Excel** hay tres opciones:

- **Plantilla de ejemplo:** el formato con una o dos filas de ejemplo. **Bórrelas antes de subirla**: si no, se crea ese producto con su stock (la vista previa lo avisa: «Es el producto de ejemplo de la plantilla»). Con el giro **Farmacia** activo trae los nombres de farmacia (Laboratorio, Acción farmacológica, Principio activo) y las presentaciones **BLÍSTER** y **CAJA**.
- **Mis productos con su stock:** sus productos actuales en el mismo formato, con una fila por lote y su saldo en el almacén elegido. Corrija las cantidades con lo que cuente y súbalo con el modo **Conteo**.
- **Mis productos sin stock:** lo mismo, con la columna Stock vacía. Sirve para escribir lo que llega (modo **Ingreso**) o para cambiar solo datos y precios.

Debajo, **Cómo llenar el Excel** despliega las reglas del archivo.

  La descarga trae una segunda hoja, **Avisos**, con lo que conviene revisar: productos con stock negativo (su celda Stock va vacía), lotes que no cuadran con el stock, un lote con dos vencimientos, cantidades con decimales en productos por unidades y presentaciones que no tienen columna.

:::tip Contar mientras se vende
La descarga «Mis productos con su stock» guarda en una hoja oculta los saldos de ese momento. Si mientras cuenta se vende un producto y usted no toca su fila, al subirla en **Conteo** esa fila se toma como **no contada** y las ventas no se deshacen (la vista previa lo avisa). Si contó un producto, escriba su cantidad.
:::

## Llene el Excel

| Columna | Qué va |
|---|---|
| **A** Nombre | Nombre del producto. Obligatorio para un producto nuevo. |
| **B** Código Interno | **Identifica al producto**: si existe, se actualiza; si no, se crea. Hasta 30 caracteres. |
| **C–K** | Modelo, código SUNAT, unidad, moneda (PEN o USD), precio de venta, afectación del IGV (10 = gravado), Tiene IGV (SI/NO), precio de compra y su afectación. |
| **L** Stock | Depende del modo que elija al importar (ver abajo). El **0** es válido. |
| **M** Stock mínimo | |
| **N–Q** | Categoría, marca o laboratorio, descripción o acción farmacológica, nombre secundario o principio activo. Una categoría o marca que no existe se crea. |
| **R** Código lote · **S** Fec. Vencimiento | El lote de esa fila (vencimiento dd/mm/aaaa). |
| **T** Cód barras | |
| **U–AB** Presentaciones | 4 presentaciones de 2 columnas cada una (ver abajo). |

:::info Las reglas del archivo
- **Celda vacía = no se cambia.** El nombre y los demás textos se corrigen volviendo a subir el archivo con el mismo código interno.
- **Imagen URL** (columna opcional): la imagen se descarga una vez. Si vuelve a subir el archivo con la misma dirección, no se descarga de nuevo ni cuenta como cambio. Para reemplazarla, use otra dirección o súbala en el producto.
- **Varias filas con el mismo código interno son el mismo producto, una por lote.** Los datos del producto se toman de la primera fila que los tenga; en las demás basta el código, el lote, el vencimiento y el stock.
- **La unidad de un producto existente no se cambia** por importación (se hace en el producto).
- Un producto con un error no se toca; los demás sí se importan.
:::

### Presentaciones (las 8 últimas columnas)

Cada presentación ocupa dos columnas: **el encabezado es su nombre** (BLÍSTER, CAJA, PAQUETE…), la primera celda dice **cuántas unidades trae** y la columna **PRECIO** es lo que cobra el POS.

| … | Cód barras | BLÍSTER | PRECIO | CAJA | PRECIO | PRESENTACIÓN 3 | PRECIO | PRESENTACIÓN 4 | PRECIO |
|---|---|---|---|---|---|---|---|---|---|
| … | 775000123 | 10 | 5.00 | 100 | 45.00 | | | | |

- En otros giros la plantilla trae **PRESENTACIÓN 1–4**: renombre el encabezado (PAQUETE, DOCENA…) antes de usar la columna.
- La unidad que va al comprobante sale del nombre: CAJA → BX, BLÍSTER → NIU, PAQUETE → PK, DOCENA → DZN; cualquier otro nombre → NIU.
- Para **crear** una presentación hacen falta las unidades y el precio; para **actualizarla** basta uno de los dos. **Nunca se borra** una presentación.

## 2. Elija el almacén y qué es la columna Stock

| Modo | Qué hace |
|---|---|
| **Conteo** | El Excel es lo que hay en el estante. El stock del almacén se ajusta al Excel con un movimiento de kardex «Stock Real». Si el producto maneja lotes, se cuenta lote por lote; los lotes registrados que no estén en el archivo **se conservan** (para vaciar uno, escriba 0). Un producto sin lotes que trae filas con lote **pasa a manejar lotes**. |
| **Ingreso** | El Excel es lo que entra: se **suma**. Con lote, el mismo código y vencimiento suma a ese lote, un código nuevo crea el lote y el mismo código con otra fecha es error. |
| **No tocar el stock** | Solo datos y precios: ignora Stock, lote y vencimiento. Un producto nuevo nace con stock 0. |

Pase el mouse por el ícono ⓘ de cada modo para ver su explicación.

## 3. Suba el archivo

Arrastre el Excel (.xlsx, .xls u .ods) a la zona **Suba el archivo** o haga clic en ella para elegirlo. La vista previa se arma sola. Si corrige el Excel, vuelva a arrastrarlo o elegirlo: reemplaza al anterior. **Quitar** deja la ventana sin archivo.

:::caution Un producto con stock en otro almacén
En **Conteo**, un producto con lotes que tiene stock en otro almacén no se importa: cuéntelo desde **Inventario › Movimientos › Ajuste**, que muestra cada almacén.
:::

## 4. Revise la vista previa e importe

Al elegir el archivo, el almacén y el modo aparece la **vista previa**; todavía no se guardó nada.

- **Los recuadros** dicen cuántos productos **se crean**, **se actualizan**, quedan **sin cambios** o tienen **errores** (esos no se importan). El de errores también cuenta las filas sin código interno, que se ignoran. Haga clic en uno para ver esos productos.
- **Errores y avisos:** la **fila** y la **columna** del Excel y qué pasa (por ejemplo «Fila 11, columna L: el stock "diez" no es un número»). Corrija esas celdas, guarde el Excel y vuelva a arrastrarlo: la vista previa se arma de nuevo. En el celular se muestran como tarjetas.
- **Productos:** cada producto con su estado, el stock antes → después, los lotes (nuevos, sumados, corregidos o que se conservan) y las presentaciones que se crean o actualizan. Arriba se filtran (Se crean, Se actualizan, Con errores o avisos…). Abra una fila para ver el detalle.

Cuando esté conforme, pulse **Importar N productos**. Se importan los productos sin errores y la tabla muestra el resultado.

:::danger IMPORTANTE
- Si hubo ventas, compras o movimientos de un producto entre la vista previa y **Importar**, ese producto no se importa: actualice la vista previa.
- Un usuario que solo tiene acceso a **Inventario** importa solo el stock: no cambia nombres, precios ni presentaciones, ni crea productos.
- Una fila de lote con la celda Stock vacía no se cuenta ni se ingresa: el lote se conserva.
- Con el modo **Ingreso**, importar dos veces el mismo archivo suma dos veces. Para corregir el stock use **Conteo**.
:::
