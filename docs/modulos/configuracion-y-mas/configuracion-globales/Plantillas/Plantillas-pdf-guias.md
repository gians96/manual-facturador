---
sidebar_position: 4

---
# Plantillas PDF - Guías de remisión

En este artículo te enseñaremos a diseñar el PDF A4 de tus guías de remisión: qué bloques salen, en qué orden y con qué formato. Cada empresa crea sus propias plantillas y decide cuál usa toda la empresa y, si quiere, cuál usa cada establecimiento.

:::info importante

Esta opción solo aparece para usuarios **administradores**. Cambia el PDF **A4** de la guía remitente (09) y de la guía transportista (31); los tickets no cambian.

:::

## Cómo entrar

Ingresa al módulo de **Configuración**, luego en la categoría **Plantillas PDF** selecciona **PDF - Guías de remisión**.

También puedes llegar desde **Configuración → Empresa → Avanzado → pestaña Extra**: en la tarjeta **Guías de Remisión**, selecciona el botón **Editar plantillas de guía**.

Arriba verás dos pestañas, **Guía remitente (09)** y **Guía transportista (31)**. Cada tipo de guía tiene sus propias plantillas y su propia asignación.

## Editar el formato paso a paso

1. Elige la pestaña de la guía: **Guía remitente (09)** o **Guía transportista (31)**.
2. En la tarjeta **Predeterminada**, selecciona **Personalizar**. Escribe un nombre y selecciona **Crear y editar**: se crea tu copia y se abre el editor.
3. En **Bloques**, arrastra cada bloque para ordenarlo, apaga los que no quieres imprimir y marca o desmarca sus datos opcionales (por ejemplo **Vendedor**, o **Serie** y **Modelo** en **Bienes**).
4. En **Formato**, cambia la letra, el espaciado, los colores y los bordes.
5. Revisa el resultado en **Vista previa**, a la derecha: se actualiza sola.
6. Selecciona **Guardar y usar en la empresa**. Desde ese momento las guías de ese tipo se imprimen con tu plantilla.

Para volver a cambiarla, selecciona **Editar** en su tarjeta o haz clic en su nombre.

## La plantilla Predeterminada

Todas las empresas parten de la **Predeterminada**, el diseño que se imprime si no eliges otro. **No se edita**: para personalizarla, selecciona **Personalizar** en su tarjeta y trabajas sobre una copia.

La Predeterminada de tu empresa conserva los datos opcionales que tenías elegidos antes en la tarjeta **Guías de Remisión** (vendedor, teléfonos, columnas de los productos, términos…). Al duplicarla, la copia sale igual a lo que ya imprimías.

## Crear, editar y eliminar plantillas

En **Plantillas** ves la Predeterminada y las plantillas de tu empresa, cada una en una tarjeta:

- **Personalizar** (en la Predeterminada) o **Nueva plantilla:** crea una copia de la Predeterminada. Escribe un nombre y se abre el editor.
- **Vista previa:** muestra el PDF con esa plantilla.
- **Editar** (o clic en el nombre): abre el editor. Solo en tus plantillas.
- **Duplicar** (en el botón **⋯**): crea una copia de esa plantilla y abre el editor.
- **Renombrar** y **Eliminar** (en el botón **⋯**): solo en tus plantillas. Si eliminas una plantilla que está en uso, donde se usaba se vuelve a imprimir con la Predeterminada.

Puedes tener hasta **20 plantillas** por tipo de guía. Cada tarjeta indica si la plantilla está **En uso en la empresa** y en qué establecimientos.

## Asignar la plantilla en uso

En **Plantilla en uso**:

1. En **Toda la empresa**, elige la plantilla que usarán las guías de ese tipo. Deja **Predeterminada** si no quieres cambiar nada.
2. Si tienes más de un establecimiento, en **Por establecimiento (opcional)** puedes elegir otra plantilla para alguno de ellos. **La de la empresa** significa que ese establecimiento usa la de arriba.

La asignación se guarda al elegirla. Para imprimir una guía, el sistema usa la plantilla de su establecimiento; si no tiene, la de la empresa; y si tampoco hay, la Predeterminada.

## El editor

El editor ocupa toda la pantalla. Arriba puedes cambiar el nombre de la plantilla y están los botones **Cerrar**, **Guardar** (se activa cuando hay cambios) y **Guardar y usar en la empresa**, que guarda y la deja asignada a toda la empresa. Si la plantilla ya está en uso, ese botón se reemplaza por la etiqueta **En uso en la empresa**. Debajo hay tres columnas: **Bloques**, **Formato** y **Vista previa**.

### Bloques

Cada sección del PDF es un bloque. Arrastra un bloque desde el ícono de su izquierda para cambiar el orden.

- La **Cabecera** (logo, empresa, RUC y número) va siempre primero y el **Cierre** (QR y representación impresa) siempre al final. Estos dos no se mueven.
- **Título:** escribe otro título para el bloque, de hasta 40 caracteres. Si lo dejas vacío, usa el de siempre.
- **Completo / Media:** un bloque **Completo** ocupa todo el ancho de la hoja y uno en **Media**, la mitad. **Dos bloques en Media seguidos se imprimen lado a lado**, y el editor lo indica con «Se imprime junto a: …». Si en una guía uno de los dos no tiene nada que imprimir, el otro sale solo a todo el ancho. Vehículos, Conductores, Documentos relacionados y Bienes son tablas y van siempre a ancho completo.
- El ícono de información explica cuándo aparece un bloque: por ejemplo, **Transportista** solo sale en transporte público y **Comprador**, solo en el motivo 03.

:::info Lo que viaja a SUNAT tiene candado

Los bloques con datos que viajan a SUNAT llevan un **candado**: se pueden mover, renombrar y dar formato, pero **no se ocultan**. Son Remitente, Destinatario, Datos del traslado, Pagador del flete, Punto de partida, Punto de llegada, Comprador, Datos aduaneros y de carga, Transportista, Vehículos, Conductores, Documentos relacionados y Bienes. El PDF es la representación impresa de la guía firmada y no puede decir menos que ella.

Solo tienen interruptor para ocultarse los bloques que no son fiscales: **Referencias internas** (el comprobante, pedido o nota de venta de origen), **Campos personalizados** y **Observaciones**. Los dos primeros existen solo en la guía remitente.

:::

Algunos bloques tienen **datos opcionales** que se marcan con una casilla. Para una empresa que nunca los cambió, vienen así:

| Bloque | Dato opcional | De fábrica |
|---|---|---|
| Destinatario (guía remitente) | Teléfono del destinatario | Se muestra |
| Destinatario (guía remitente) | Vendedor | Se muestra |
| Vehículos | Marca y modelo del vehículo | No se muestra |
| Conductores | Teléfono del conductor | No se muestra |
| Bienes | Serie, modelo, marca, lote y vencimiento de los productos | Se muestran |
| Cierre | Términos y condiciones | Se muestra |
| Referencias internas y Campos personalizados | Todo el bloque | Se muestra |
| Observaciones | Todo el bloque | **No se muestra** |

#### Columnas de Bienes

Dentro del bloque **Bienes** están sus columnas. Arrástralas para ordenarlas y elige el ancho de cada una en % (de 3 a 60), o marca **Auto** para que ocupe el espacio que sobra. Si los anchos suman más de 95 %, al guardar se ajustan.

- **Item, Código, Descripción, Unidad y Cantidad** tienen candado: se imprimen siempre.
- **Serie, Modelo, Marca, Lote y F. Venc.** tienen la casilla **Mostrar**. Aunque estén marcadas, solo aparecen si algún producto de la guía tiene ese dato.
- **Peso, Precio y Total** (solo en la guía remitente) indican «Según Configuración»: no dependen de la plantilla, sino de si la empresa tiene habilitados el peso y el precio en sus guías.

### Formato

- **Tamaño de letra:** de 7 a 10 pt, en pasos de medio punto. La Predeterminada usa 8 pt.
- **Espaciado:** compacto (el de la Predeterminada), normal o amplio.
- **Fondo de títulos**, **Texto de títulos** y **Bordes:** el color de cada uno. Si el texto de los títulos queda del mismo color que su fondo, el editor te avisa.
- **Grosor de bordes:** 0.5, 0.8 (el de la Predeterminada), 1 o 1.5 pt.

En **Cabecera**:

- **Ancho del logo:** de 10 % a 30 %. La Predeterminada usa 20 %.
- **Ancho del recuadro del RUC:** de 28 % a 45 %. La Predeterminada usa 36 %. Los datos de la empresa ocupan el resto, nunca menos del 30 %.
- **Alto del logo sin límite:** desmárcalo para fijar un alto máximo del logo, de 30 a 120 pt.

### Vista previa

La columna derecha muestra el **PDF real** con los cambios, aunque todavía no los hayas guardado. Se actualiza sola un momento después de cada cambio.

- **Guía de ejemplo:** una guía con datos ficticios que llena todos los bloques, para que veas dónde queda cada uno. Si tienes varios establecimientos, elige con cuál se arma.
- **Guía real:** busca una guía de tu empresa por serie-número.

La vista previa **no guarda nada ni modifica la guía**: ni sus datos ni su PDF.

Cuando termines, selecciona **Guardar y usar en la empresa**. Si solo seleccionas **Guardar**, la plantilla queda guardada pero empieza a usarse cuando la asignas en **Plantilla en uso** (a la empresa o a un establecimiento).

## Qué conviene saber

:::tip Deja «Bienes» cerca del final

Una lista de bienes larga ocupa varias hojas. Si subes el bloque **Bienes** o pones un bloque largo en media columna, el PDF puede saltar de página antes de tiempo y dejar huecos grandes. Revísalo en la vista previa con una guía real de muchos productos.

:::

- **Reimprimir usa la plantilla vigente.** Una guía no guarda la plantilla con la que se imprimió: al volver a descargarla o imprimirla sale con la plantilla asignada **hoy**. Los datos de la guía no cambian, solo el diseño.
- **Las observaciones no se imprimen por defecto** desde el 14 de septiembre de 2026, aunque viajan a SUNAT. Para que salgan, enciende el bloque **Observaciones** en tu plantilla.
- **Marca de agua:** si el establecimiento usa la plantilla PDF **marca_de_agua**, la guía conserva su logo de fondo; el resto del diseño lo decide la plantilla de guía.
- **Plantilla personalizable:** el engranaje de su tarjeta en **Plantillas PDF - PDF** abre **Columnas de comprobantes, notas de venta, cotizaciones y pedidos**. Esas columnas son de facturas, boletas, notas de venta, cotizaciones, pedidos y contratos, **no de las guías**: las columnas de la guía se eligen en el bloque **Bienes** de este editor.
- **Tus ajustes anteriores:** los interruptores de **Datos opcionales del PDF de la guía (A4)** que estaban en **Avanzado → Extra → Guías de Remisión** se conservan como valores de la Predeterminada de tu empresa. Esa tarjeta ahora solo tiene el botón **Editar plantillas de guía**.

Para las credenciales y el resto de ajustes de las guías, consulta el artículo **[Configuración previa - Guía de remisión](../../../Complementarios/guias-de-remision/01-Configuracion-previa-guia-remision.md)**.
