# Importar Listas de Precio

En esta área te ayudaremos a crear Listas de precios de manera masiva. Sigue estos pasos para realizarlo:

Ingresa al módulo de **Productos/Servicios** y luego selecciona subcategoría **Productos.** En la parte superior derecha selecciona el botón **Importar** después selecciona **L.Precios.**

![Alt text](img/Listas-de-Precio-Importar-Masivamente_01.jpg)

Posteriormente aparecerá una ventana de **Importar** productos. Selecciona Descargar formato para importar.

![Alt text](img/Listas-de-Precio-Importar-Masivamente_02.jpg)

Descargará un archivo en formato excel.

![Alt text](img/Listas-de-Precio-Importar-Masivamente_03.jpg)

En este archivo tendrá que completar los siguientes campos necesarios:

![Alt text](img/Listas-de-Precio-Importar-Masivamente_04.jpg)

**1.  Codigo interno:** Ingresa el código interno del producto. Debe existir: las filas con un código que no está registrado se omiten.

**2.  Unidad:** Ingresa el código de la unidad de la presentación, por ejemplo **BX** para caja.
- Para ver los códigos, dirígete a **Configuraciones y más** > **Configuraciones Globales**, luego ubica el submódulo de **Sunat** y selecciona la subcategoría **Listado de Unidades**.

:::danger IMPORTANTE:
Si no cuenta con un código interno en su empresa puede agregar por ejemplo 001, 002, etc.
:::

![Alt text](img/Importar-masivamente_05.jpg)

**3.  Factor:** Cuántas unidades del producto trae la presentación; es la cantidad que se descuenta del inventario al venderla.

**4.  Descripción:** El nombre de la presentación, por ejemplo «Caja x 12». Si el producto ya tiene una presentación con la misma unidad y la misma descripción, se actualizan sus precios; si no, se crea una nueva.

**5.  Precios:** Una columna por cada etiqueta de precio activa (**Precio 1**, **Precio 2**, **Precio 3** o los nombres que hayas puesto en **Configuración › Avanzado › Visual › Gestionar Etiquetas de Precios**). Completa con 0 los precios que no uses.

**6.  Qué precio cobra el POS:** El archivo no trae esa columna.
- Una presentación **nueva** cobra el primer precio, o el de la etiqueta de precio marcada por defecto.
- Una presentación que **ya existía** sigue cobrando el precio que tenía elegido.
- Para cambiarlo, edita el producto y, en la pestaña **Presentaciones**, abre los precios de la presentación y selecciona **Usar en POS** en el precio que quieras cobrar. Revisa la [Creación avanzada de productos](./02-Productos-Creacion-avanzada.md#sección-presentaciones).

![Alt text](img/Listas-de-Precio-Importar-Masivamente_06.jpg)

La imagen corresponde a una versión anterior del formato, que traía la columna **Precio por defecto**.

:::tip
Si tu cuenta admite una sola presentación por producto, el formato solo trae el **Codigo interno** y los precios, que se aplican a la presentación del producto.
:::

:::danger IMPORTANTE:
Ningún campo puede quedar vacío.
:::

Una vez rellenado el archivo excel, deberá seleccionar el botón **Selecciona un archivo (xlsx)**, para subir el archivo pdf correspondiente.

![Alt text](img/Listas-de-Precio-Importar-Masivamente_07.jpg)

Finalmente selecciona el botón **Procesar**, se observará el **[Listado de productos]**.
