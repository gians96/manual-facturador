---
sidebar_position: 4

---
# Plantillas PDF - Guías de remisión

En este artículo te enseñaremos a diseñar el PDF A4 de tus guías de remisión sobre una **hoja** que se parece al PDF: arrastras los bloques, se acomodan solos y, con un clic, cambias su ancho, letra, colores o qué datos muestran. Lo que ves en la hoja se aplica al instante; la **vista previa PDF** te muestra el resultado exacto.

:::info importante

Esta opción solo aparece para usuarios **administradores**. Cambia el PDF **A4** de la guía remitente (09) y de la guía transportista (31); los tickets no cambian.

:::

## Cómo entrar

Ingresa al módulo de **Configuración**, luego en la categoría **Plantillas PDF** selecciona **PDF - Guías de remisión**.

También puedes llegar desde **Configuración → Empresa → Avanzado → pestaña Extra**: en la tarjeta **Guías de Remisión**, selecciona el botón **Editar plantillas de guía**.

## La barra de arriba

- **Guía remitente (09) / Guía transportista (31):** cada tipo de guía tiene su propia plantilla.
- **Editar para:** **Toda la empresa** o un establecimiento. La etiqueta de al lado indica qué usa hoy ese alcance:
  - **Predeterminada:** el diseño de fábrica, el mismo para todas las empresas.
  - **Usa la de la empresa:** el establecimiento todavía no tiene una propia.
  - **Personalizada:** ya la guardaste para ese alcance.
- **Vista previa PDF:** abre el PDF real con los cambios, aunque no los hayas guardado.
- **Restaurar:** vuelve atrás (ver más abajo).
- **Guardar:** se activa cuando hay cambios. Arriba a la derecha verás **Cambios sin guardar** o la fecha en que se guardó.
- **Estilo general:** letra, espaciado, colores y bordes de toda la plantilla.
- **Ver con:** **Guía de ejemplo** (datos ficticios que llenan todos los bloques: en la guía remitente, un retorno a almacén con motivo 13, tracto y remolque con su constancia, autorización especial del transportista y 297 bultos) o **Guía real** (busca una guía tuya por serie-número, como `T001-209`, o solo por el número, como `209`).

No tienes que crear nada: abres la página y editas directamente.

## Editar la hoja

### Mover bloques

Arrastra cualquier bloque a otra posición. Los bloques **se acomodan solos en filas**: si caben juntos van lado a lado y, si no, bajan a la fila siguiente. La **cabecera** (logo, empresa, RUC y número) va siempre primero y el **cierre** (QR) siempre al final.

### Clic (o clic derecho) sobre un bloque

Se abre un panel con todo lo que puedes cambiar de ese bloque:

- **Ancho:** **1/3**, **1/2**, **2/3** o **Todo**. Vehículos, Conductores, Documentos relacionados y Bienes son tablas y van siempre a lo ancho.
- **Letra:** **A−** y **A+** achican o agrandan la letra solo de ese bloque; el botón del medio muestra el tamaño y lo devuelve al general.
- **Título:** escribe otro título (hasta 40 caracteres; vacío = el de siempre). También puedes hacer **doble clic** sobre el bloque. Los dos cuadros de color cambian el **fondo** y el **texto** del título de ese bloque.
- **Alinear:** izquierda, centro o derecha. En las tablas alinea solo el título.
- **Mostrar:** los datos opcionales del bloque, por ejemplo **Vendedor** o **Teléfono del destinatario**. En **Bienes** está además **Columnas de la tabla…**.
- **↑ / ↓:** sube o baja el bloque una posición.
- **Restablecer:** devuelve ese bloque a como venía.
- **Ocultar:** solo en los bloques que no van a SUNAT.

Cierra el panel con la **X**, con **Esc** o haciendo clic fuera.

### Cómo se reparte una fila

Los anchos suman una fila completa: por ejemplo **1/3 + 1/3 + 1/3**, **1/2 + 1/2** o **2/3 + 1/3**. Si un bloque no cabe en la fila, pasa a la siguiente. Cuando en una guía un bloque de la fila no tiene datos (por ejemplo **Comprador** fuera del motivo 03), los demás de esa fila **se reparten el espacio**; si queda uno solo, va a lo ancho. En la hoja, un bloque sin datos en la guía que estás viendo sale tenue y dice cuándo se imprime.

:::info Lo que viaja a SUNAT tiene candado

Los bloques con datos que viajan a SUNAT se pueden mover, cambiar de ancho, renombrar y dar formato, pero **no se ocultan**: Remitente, Destinatario, Datos del traslado, Pagador del flete, Punto de partida, Punto de llegada, Comprador, Datos aduaneros y de carga, Transportista, Vehículos, Conductores, Documentos relacionados y Bienes. El PDF es la representación impresa de la guía firmada y no puede decir menos que ella.

:::

### Bloques ocultos

A la izquierda está **Bloques ocultos**: **Referencias internas** (el comprobante, pedido o nota de venta de origen), **Campos personalizados** y **Observaciones** cuando están apagados. Arrástralos a la hoja o selecciona **Mostrar** para volver a imprimirlos, y arrastra ahí un bloque para ocultarlo.

Para una empresa que nunca los cambió, los datos opcionales vienen así:

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

### Columnas de la tabla de bienes

En el panel de **Bienes**, selecciona **Columnas de la tabla…**. Arrastra las columnas para ordenarlas y elige el ancho de cada una en % (de 3 a 60), o marca **Auto** para que ocupe el espacio que sobra. Si los anchos suman más de 95 %, al guardar se ajustan.

- **Item, Código, Descripción, Unidad y Cantidad** tienen candado: se imprimen siempre.
- **Serie, Modelo, Marca, Lote y F. Venc.** tienen la casilla **Mostrar**. Aunque estén marcadas, solo aparecen si algún producto de la guía tiene ese dato.
- **Peso, Precio y Total** (solo en la guía remitente) indican «Según configuración»: dependen de si la empresa tiene habilitados el peso y el precio en sus guías.

### El código QR

El QR identifica la guía: el agente de transporte lo escanea para verificarla durante el trayecto. Haz clic sobre el QR (o sobre la franja del pie de página) y elige:

- **Código QR:**
  - **Pie de página** (así viene): el QR, la leyenda «Representación impresa de la guía…» y «Página X de Y» salen **al pie de cada hoja**. El QR nunca queda solo en una hoja aparte y se puede escanear en cualquiera.
  - **Junto a la cabecera:** al lado del recuadro del RUC, solo en la primera hoja. No ocupa espacio abajo, pero si la cabecera está muy llena el PDF lo achica un poco.
  - **Al final:** después de los bienes, como antes. Si no cabe en la hoja, pasa a la siguiente.
- **Tamaño:** **Pequeño** (20 mm), **Mediano** (25 mm, el de fábrica) o **Grande** (30 mm).
- **Términos y condiciones:** mostrar u ocultar. Siempre van al final del contenido.

En la hoja, el pie de página se ve como una franja al fondo con el rótulo **Pie de página: se repite al pie de cada hoja**. Si la guía todavía no tiene QR (aún no se envió a SUNAT), el PDF no lleva pie y solo imprime la leyenda al final.

:::info Establecimientos con papel membretado

Si el establecimiento usa las plantillas PDF **blank** o **brand** (cabecera y pie propios), el QR en **Pie de página** se imprime **al final**, para no taparlos.

:::

### Estilo general

- **Tamaño de letra:** de 7 a 10 pt, en pasos de medio punto. La Predeterminada usa 8 pt. La letra de un bloque con **A+/A−** se calcula sobre este tamaño.
- **Espaciado:** compacto (el de la Predeterminada), normal o amplio.
- **Fondo de títulos**, **Texto de títulos** y **Bordes:** el color de toda la plantilla. Un bloque con colores propios los conserva.
- **Grosor de bordes:** 0.5, 0.8 (el de la Predeterminada), 1 o 1.5 pt.
- **Ancho del logo** (10 % a 30 %), **Ancho del recuadro del RUC** (28 % a 45 %; los datos de la empresa ocupan el resto, nunca menos del 30 %) y **Alto del logo sin límite** (desmárcalo para fijar un alto máximo de 30 a 120 pt).

## Guardar, vista previa y restaurar

- **Guardar** aplica la plantilla al alcance elegido en **Editar para**. Desde ese momento las guías de ese tipo se imprimen así.
- **Vista previa PDF** usa la misma guía que estás viendo en la hoja (ejemplo o real). No guarda nada ni modifica la guía.
- **Restaurar**:
  - en **Toda la empresa**, vuelve a la **Predeterminada** (los establecimientos con plantilla propia no cambian);
  - en un establecimiento, vuelve a **usar la de la empresa**;
  - si todavía no guardaste, solo descarta los cambios.

Si cambias de tipo de guía o de alcance con cambios sin guardar, el sistema te pregunta antes de descartarlos.

Para imprimir una guía, el sistema usa la plantilla de su establecimiento; si no tiene, la de la empresa; y si tampoco hay, la Predeterminada.

## Qué conviene saber

:::tip La hoja es una aproximación

La hoja se dibuja en el navegador para que el cambio sea instantáneo. Las líneas **≈ fin de la hoja** son orientativas: dónde corta la página de verdad lo decide el PDF. Antes de guardar un cambio grande, ábrelo en **Vista previa PDF**, mejor con una guía real de muchos productos.

:::

- **Deja «Bienes» cerca del final.** Una lista larga ocupa varias hojas; si subes el bloque, las secciones que van después pueden pasar a otra hoja. Un bloque que no cabe en lo que queda de la hoja pasa entero a la siguiente, sin achicarse.
- **Reimprimir usa la plantilla vigente.** Una guía no guarda la plantilla con la que se imprimió: al volver a descargarla sale con la plantilla de **hoy**. Los datos de la guía no cambian, solo el diseño.
- **Las observaciones no se imprimen por defecto** desde el 14 de septiembre de 2026, aunque viajan a SUNAT. Para que salgan, muéstralas desde **Bloques ocultos**.
- **Marca de agua:** si el establecimiento usa la plantilla PDF **marca_de_agua**, la guía conserva su logo de fondo; el resto del diseño lo decide esta plantilla.
- **Plantilla personalizable:** el engranaje de su tarjeta en **Plantillas PDF - PDF** abre **Columnas de comprobantes, notas de venta, cotizaciones y pedidos**. Esas columnas son de facturas, boletas, notas de venta, cotizaciones, pedidos y contratos, **no de las guías**.
- **Tus ajustes anteriores:** los interruptores de **Datos opcionales del PDF de la guía (A4)** que estaban en **Avanzado → Extra → Guías de Remisión** se conservan como valores de la Predeterminada de tu empresa.

Para las credenciales y el resto de ajustes de las guías, consulta el artículo **[Configuración previa - Guía de remisión](../../../Complementarios/guias-de-remision/01-Configuracion-previa-guia-remision.md)**.
