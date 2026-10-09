# Configuración Previa

En este artículo te enseñaremos a realizar la configuración previa para empezar a utilizar el módulo Farmacia. Sigue estos pasos para realizarlo:

Ingresa al módulo de **Configuración**, y luego en la subcategoría **Empresa**, selecciona **Avanzado**.

![Alt text](img/avanzado-1.jpeg)

La configuración que debe estar activa :

![Alt text](img/farma-2.jpeg)

Nos permite que dentro del módulo de Farmacia, tengamos un catálogo propiamente de farmacia, que pueden ser exportados a **DIGEMID**.

:::danger
**Importante:** Al momento de preparar el archivo Excel para la importación, asegúrate de incluir **únicamente los productos que deseas subir al sistema**. No agregues productos innecesarios o que no vayas a utilizar, ya que esto podría generar confusión o registros no deseados en el módulo de Farmacia.
:::


![Alt text](img/farma-3.jpeg)


## Importante 

Para una correcta configuración del módulo de Farmacia, sigue estos pasos adicionales:

![Codigo DIGEMID Intro](img/config-empresa-empresa.png)

1. Ingresa a **Configuraciones Globales > Empresa > Empresa**.
2. Dirígete a la sección **Datos de la Empresa** y selecciona el apartado **Datos de Farmacia**.

![Codigo DIGEMID](img/codigo-digemid.png)

3. Es fundamental que ingreses correctamente el **código de observación DIGEMID**. Este dato es requerido para cumplir con las normativas y facilitar la exportación de información a DIGEMID.

Asegúrate de completar todos los campos solicitados para evitar inconvenientes en la gestión y reporte de productos farmacéuticos.

## Nombres de farmacia en los productos

En las versiones actuales, los elementos de farmacia se activan con el giro **Farmacia**, en **Configuración › Empresa › [Giro de negocio](../../configuracion-y-mas/configuracion-globales/Empresa/giro-de-negocio.md)**.

Con el giro activo, algunos campos del producto toman su nombre de farmacia. Los ves así en el formulario de producto, el listado, la ficha, Compras, el menú y la plantilla de importación:

| Nombre de siempre | En farmacia |
|---|---|
| Nombre secundario | Principio activo |
| Descripción | Acción farmacológica |
| Marca | Laboratorio |
| Marcas (menú y pantalla) | Laboratorios |

Los datos son los mismos: solo cambia el nombre que se muestra. Si desactivas el giro, vuelven los nombres de siempre.

Para crear medicamentos con varios lotes y con presentaciones en blíster o caja, sigue la guía [Productos: presentaciones y lotes](./Productos-Presentaciones-y-Lotes.md).
