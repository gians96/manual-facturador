# Movimientos


En esta área te ayudaremos a utilizar los diferentes botones dentro del **Listado de Inventario**. Sigue estos pasos para realizarlo:

Ingresa al módulo de **Inventario**, luego selecciona la subcategoría **Movimientos.**

![Alt text](img/Movimientos_libres_de_Inventario_01.jpg)

## Botón ingreso

Este botón registra el ingreso de producto al almacén.

![Alt text](img/Movimientos_libres_de_Inventario_02.jpg)

Al seleccionar este botón aparecerá un pequeño formulario para llenar los datos de Ingreso de producto al almacén.

![Alt text](img/Movimientos_libres_de_Inventario_03.jpg)

Se completarán los siguientes datos:

* **Producto (*):** Selecciona el producto que desea ingresar.
* **Cantidad (*):** Ingresa la cantidad que desea ingresar.
* **Almacén (*):** Selecciona el almacén en donde el producto ingresará.
* **Motivo traslado (*):** Selecciona el motivo de ingreso del producto que más le convenga.
* **Fecha registro:** Selecciona la fecha de registro.
* **Comentarios:** Ingresa comentarios si es que tuviera.
  
Seguidamente selecciona el botón **Aceptar**, para guardar los cambios.

:::tip Producto que todavía no existe
No hace falta ir a Productos: con el botón **+** junto a «Producto», con **Crear producto "…"** cuando la búsqueda no encuentra nada o, con el lector de códigos, al escanear un código que no es de ningún producto, se abre el alta del producto **sin stock inicial** (el stock lo pone este ingreso, así no se duplica). Al guardarlo queda elegido en el ingreso con el motivo **Inventario inicial**. Si el código escaneado es de una presentación (por ejemplo la caja), se elige su producto.
:::

:::caution El ingreso suma
El ingreso **suma** a lo que ya hay. Si está contando lo que tiene en el estante (toma de inventario), use **Ajuste** o la importación en modo **Conteo** (ver **Importar** más abajo).
:::

## Botón salida

Este botón registra la salida de producto del almacén.

![Alt text](img/Movimientos_libres_de_Inventario_04.jpg)

Al seleccionar este botón aparecerá un pequeño formulario para llenar los datos de **Salida de producto del almacén.**

![Alt text](img/Movimientos_libres_de_Inventario_05.jpg)

Se completarán los siguientes datos:

* **Producto (*):** Selecciona el producto que desea registrar salida.
* **Cantidad (*):** Ingresa la cantidad que desea registrar salida.
* **Almacén (*):** Selecciona el almacén de donde el producto saldrá.
* **Motivo traslado (*):** Selecciona el motivo de la salida del producto que más le convenga.
* **Fecha registro:** Selecciona la fecha de salida.
* **Comentarios:** Ingresa comentarios si es que tuviera.

:::danger IMPORTANTE:
Todos los campos que cuentan con **(*)** son obligatorios.
:::
## Botón trasladar

Este botón se utiliza para mover producto entre almacenes.

![Alt text](img/Movimientos_libres_de_Inventario_06.jpg)

Al seleccionar este botón aparecerá un pequeño formulario para llenar los datos de **Traslado entre almacenes.**

![Alt text](img/Movimientos_libres_de_Inventario_07.jpg)

Los datos se autocompletan según el producto que se seleccionó.

Los siguientes datos se deben completar de manera obligatoria:

* **Cantidad a trasladar:** Ingresa la cantidad de producto que desea trasladar al otro almacén.
* **Almacén final:** Selecciona el almacén a donde se trasladará el producto.
  
## Botón remover

Este botón es similar al **botón salida**, la diferencia es que en este botón no te pide el motivo de la salida del producto.

![Alt text](img/Movimientos_libres_de_Inventario_08.jpg)

Al seleccionar este botón aparecerá un pequeño formulario para llenar los datos de **Retirar producto de almacén**

![Alt text](img/Movimientos_libres_de_Inventario_09.jpg)

Los datos se autocompletan según el producto que se selecciono.

El campo que debe completar es:

* **Cantidad a retirar:** Ingresa la cantidad de producto que retirará del almacén.
  
## Stock por lote en el listado

En un producto que maneja lotes, el número de la columna **Stock** se despliega: muestra el stock de ese almacén, el stock general (todos los almacenes) y el **stock de cada lote** con su vencimiento. Si los lotes no cuadran con el stock (stock sin lote, lotes de más o algún negativo) aparece un ⚠ y el detalle; se corrige con **Ajuste**.

:::info
Los lotes no tienen almacén: son los lotes del producto en todos los almacenes.
:::

## Botón ajuste

Este botón te ayuda a ajustar tu stock, en caso de que el stock del sistema no cuadre con el stock actual.

![Alt text](img/Movimientos_libres_de_Inventario_10.jpg)

Al seleccionar este botón aparecerá un pequeño formulario para llenar los datos de **Ajuste de stock.**

![Alt text](img/Movimientos_libres_de_Inventario_11.jpg)

Los datos se autocompletan según el producto que se selecciono.

El campo que debe completar es:

* **Stock real:** Ingresa el stock actual.

:::tip Producto con lotes: Ajuste por lotes
En un producto que maneja lotes, **Ajuste** abre **Ajuste de stock por lotes**: el stock general por almacén y el stock de cada lote con un campo **Conteo**. Cuente lo que hay en el estante lote por lote y agregue los lotes que encuentre y no estén registrados. Si los lotes suman más que el stock, elija qué es lo real: **el stock** (descuenta de los lotes que vencen primero) o **los lotes** (sube el stock); eso solo precarga los conteos, que puede corregir.

Pulse **Revisar** para ver qué va a pasar (el ajuste de stock con su movimiento de kardex y los lotes que se crean o corrigen) y **Confirmar** para guardarlo. Lo contado queda en el almacén de la fila donde pulsó Ajuste.

El **Ajuste masivo**, **Imp. Ajuste de stock** e **Importar stock por establecimientos** no cambian productos con lotes: los dejarían descuadrados.
:::

:::info Activar lotes en un producto con stock
Al marcar **¿Maneja lotes?** en un producto que ya tiene stock (en **Productos › Editar** o desde una compra) se abre **Pasar a lotes**: el mismo conteo por lote. Hasta que lo confirme, el producto sigue sin lotes, así no quedan ventas bloqueadas por falta de lote.
:::
## Botón Imp. Ajuste de stock

Este botón te ayuda a importar masivamente el ajuste de stock.

![Alt text](img/Movimientos_libres_de_Inventario_12.jpg)

Al seleccionar este botón aparecerá un pequeño formulario para llenar los datos de **Importar Ajuste de stock.**

![Alt text](img/Movimientos_libres_de_Inventario_13.jpg)

Primero selecciona el almacén en el que se modificará el stock. Después selecciona el botón **Descargar formato de ejemplo para importar** , se descargará un archivo excel.

![Alt text](img/Movimientos_libres_de_Inventario_14.jpg)

En el documento se completará:

* **Código interno:** Ingresa el código interno del producto.
* **Stock real:** Ingresa el stock real del producto.
  
Una vez rellenado el archivo excel, deberá seleccionar el botón **Seleccione un archivo (xlsx)** ,para subir el archivo correspondiente.

## Importar: Ingreso con lotes y Pasar a lotes

En **Importar**:

- **Ingreso con lotes (suma stock):** registra mercadería que entra con su lote. **Suma** al stock.
- **Pasar a lotes (stock actual):** abre la **[importación de productos](../productos-servicios/05-Productos-Importar-masivamente.md)** en modo **Conteo**: el Excel es lo que hay en el estante, por lote. Sirve para la toma de inventario y para rotular en lotes el stock que ya tiene, sin duplicarlo. Descargue sus productos «con el stock actual», corrija las cantidades y súbalo.

## Tres puntos

Para seleccionar todos los productos de la fila

![Alt text](img/Movimientos11.jpg)
