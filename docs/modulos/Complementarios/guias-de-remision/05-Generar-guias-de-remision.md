# Generar Guías de Remisión

:::danger IMPORTANTE:
Por disposición de SUNAT con respecto a las guías de remisión, es necesario agregar tokens de conexión adicionales. Tenemos una guía preparada en este **[artículo](./01-Configuracion-previa-guia-remision.md)**.
:::

En este artículo te enseñaremos cómo generar tus guías de remisión. Sigue estos pasos para realizarlo:

## Crear Guía de Remisión: Botón Nuevo

1. Ingresa al módulo de **Guías de remisión** y luego selecciona la subcategoría **G.R Remitente**.
2. En la parte superior derecha, selecciona el botón **Nuevo**.

![Alt text](img/guiactualizada1.jpg)

Tendrás que rellenar los siguientes campos necesarios:

![Alt text](img/guiactualizada2.jpg)

:::note El formulario va por secciones desde el 2026-09-18
**Datos de la guía**, **Motivo y modalidad**, **Destinatario y direcciones**, **Transporte**,
**Documentos relacionados**, **Bienes a trasladar** y **Antes de emitir**. Los campos son los
mismos que se describen aquí; las capturas son de la versión anterior.
:::

- **1. Establecimiento:** Selecciona el establecimiento.
- **2. Serie:** Selecciona la serie correspondiente.
- **3. Fecha de emisión:** Ingresa la fecha de emisión.
- **4. Fecha de traslado:** Ingresa la fecha de traslado.
- **5. Cliente:** Selecciona el cliente, si no está creado, podrá realizarlo paso a paso en este **[artículo](../../esenciales/clientes/01-clientes-creacion-individual.md)**, también puede crear un nuevo cliente seleccionando el botón **+Nuevo.**
- **6. Modo de traslado:** Selecciona si el modo es **transporte privado o público**.
- **7. Motivo de traslado:** Selecciona el motivo más adecuado, entre opciones como:
  - Venta
  - Compra
  - Traslado entre establecimientos de la misma empresa
  - Importación
  - Exportación
  - Otros no comprendidos en ningún código del catálogo
  - Venta sujeta a confirmación del comprador
- **8. Unidad de medida:** Selecciona entre las dos unidades disponibles por SUNAT: **KGM** (Kilogramos) o **TNE** (Toneladas).
- **9. Peso total:** Ingresa el peso total del producto.
- **Número de paquetes:** Ingresa el número total de paquetes que se trasladarán.

:::danger IMPORTANTE:
Todos los campos con el **[*]** son obligatorios.
:::

## Datos de Envío:

![Alt text](img/guiactualizada5.jpg)

- **Punto de partida:** Selecciona o crea un nuevo punto de partida con el botón **+Nuevo**.
- **Punto de llegada:** Selecciona o crea un nuevo punto de llegada con el botón **+Nuevo**.

:::danger IMPORTANTE:
Si el punto de llegada no carga correctamente, usa el botón **+Nuevo** y selecciona **Buscar** seguido de **Guardar** sin necesidad de llenar todos los campos.
:::



# DATOS DE MODELO DE TRASLADO 



## Datos del Modo de Traslado: Transporte Privado

![Alt text](img/guiactualizada6.jpg)

- **Datos del conductor:** Selecciona uno o varios conductores, también puedes crear un nuevo conductor con el botón **+Nuevo**.
- **Datos del vehículo:** Selecciona uno o varios vehículos y sus números de placas correspondientes, o crea un nuevo vehículo con el botón **+Nuevo**.

:::warning El campo «N° placa semirremolque» no se envía a SUNAT
Solo sale impreso en el PDF, sin constancia. Para que SUNAT reciba el remolque o semirremolque, regístralo en [Creación de vehículos](./09-Creacion-de-Vehiculos.md) con su placa y su constancia (TUC), y agrégalo como **segundo vehículo** en **Datos del vehículo**.
:::

## Datos del Modo de Traslado: Transporte Público

![Alt text](img/guiactualizada3.jpg)

- **Datos del transportista:** Selecciona el transportista o crea uno nuevo con el botón **+Nuevo**. Si el transportista tiene **autorización especial** registrada (ver [Creación de transportistas](./07-Creacion-de-transportistas.md)), viaja con la guía. Al elegirlo, debajo se ve lo que viajará de él: su **RUC**, su **registro MTC** (o que no lo tiene: SUNAT observará la guía) y su **autorización especial**.

### Registrar vehículos y conductores del transportista

Marca la casilla **Registrar vehículos y conductores del transportista** cuando declares el vehículo y el conductor de la empresa de transporte. Al marcarla aparecen los mismos datos del conductor y del vehículo que en transporte privado.

- **Conductor principal y placa son obligatorios para SUNAT.** Sin ellos rechaza la guía.
- La tabla de vehículos muestra el **TUC** y la **Aut. especial** (número y entidad) de cada vehículo, tal como están en [Creación de vehículos](./09-Creacion-de-Vehiculos.md).
- **Tracto y remolque:** el tracto es el primer vehículo y el remolque o semirremolque, el segundo; cada uno con **su propia** constancia (TUC). Aquí no hay campo de semirremolque: el remolque se declara siempre como segundo vehículo, y así sale en el XML y en el PDF (fila *Secundario*).
- **Materiales o residuos peligrosos:** la guía no tiene una casilla de «material peligroso». Se declara el permiso como **autorización especial** del transportista ([Creación de transportistas](./07-Creacion-de-transportistas.md)), de cada vehículo o de ambos, según a quién se otorgó. Si además quieres citar el permiso como documento, usa **Documento relacionado** (ver abajo).
- Si el vehículo principal **no tiene TUC**, aparece un aviso: SUNAT aceptará la guía pero la observará. La guía se guarda igual.
- La **fecha de traslado** no puede ser anterior a la **fecha de entrega al transportista**: SUNAT la rechaza.

### Documento relacionado

El botón **Documento relacionado** ofrece, además de **Factura** y **Boleta**, los documentos del
catálogo 61 de SUNAT que solo admite la guía remitente (`71` a `78`). Entre ellos está la
**autorización para manejo y recojo de residuos sólidos (`76`)**:

- Un permiso tiene **un solo número** (por ejemplo `1502607MRP`), sin serie. Hasta 100 caracteres y
  **sin espacios**, o SUNAT lo rechaza.
- El RUC se precarga con el del **transportista elegido**, que es quien tiene la autorización de
  residuos. Se puede corregir.

:::tip Editar una guía conserva su transporte
Al usar **Editar** en una guía registrada o rechazada, el formulario muestra el transportista, los conductores y los vehículos que tenía la guía, aunque alguno ya no esté activo en el catálogo. Antes los reemplazaba por los predeterminados.
:::

:::info IMPORTANTE
- Las unidades de medida válidas según SUNAT son: **KGM y TNE**.
- El sistema usa por defecto la dirección del cliente seleccionado, pero puedes agregar una nueva dirección desde el módulo de clientes.
- Para registrar una empresa de transportistas, es obligatorio contar con el MTC, que puedes solicitar en el siguiente link:
  **[https://www.mtc.gob.pe/tramitesenlinea/tweb_tLinea/tw_consultadgtt/Frm_rep_intra_mercancia.aspx](https://www.mtc.gob.pe/tramitesenlinea/tweb_tLinea/tw_consultadgtt/Frm_rep_intra_mercancia.aspx)**.
- La placa del vehículo no puede contener guiones ni minúsculas.
- En caso de elegir esta opción, tendrá que especificar la fecha de entrega al transportista.
:::

## Agregar Producto:

1. Para agregar el producto a trasladar:

![Alt text](img/remision_agregar_produc_1.jpg)

   - **1. Producto:** Ingresa el nombre del producto en la **Descripción**. Si necesitas crear uno nuevo, selecciona el botón **+Nuevo** y sigue los pasos en este **[artículo](../../esenciales/productos-servicios/03-productos-creacion-basica.md).**
   - **2. Cantidad:** Ingresa la cantidad del producto.

2. Una vez completado, selecciona el botón **Agregar** y luego **Generar**.

## Antes de emitir

Junto al botón **Generar**, la sección **Antes de emitir** dice, mientras llenas la guía, si ya se
puede emitir. Arriba muestra el estado (**No se puede emitir todavía**, **Se puede emitir** con
observaciones de SUNAT o **Lista para emitir**) y debajo, en tres grupos:

- **Por completar o corregir** (en rojo): lo que falta y sin lo cual SUNAT **rechaza** la guía
  (cliente, punto de partida y de llegada, fecha de entrega al transportista en transporte público,
  conductor con documento, nombre y licencia, vehículo, el documento aduanero de los motivos 08, 09
  y 19...) y lo que SUNAT rechaza seguro (la fecha de entrega anterior a la de emisión, una placa
  con guion, el destinatario igual a tu empresa en una venta...). **Esto sí impide generar la guía.**
- **SUNAT la aceptará con observaciones** (en ámbar): el transportista sin registro MTC, los
  vehículos sin TUC, la venta con entrega a terceros (`03`) sin comprador... **No impiden generar**:
  SUNAT acepta la guía y la observa.
- **Avisos** (en azul): consejos, como describir el traslado en el motivo **Otros** (`13`).

Cada punto es un enlace que te lleva al campo. Si pulsas **Generar** con algo por completar, el
formulario no envía la guía: marca en rojo los campos, te lleva al primero y lo dice en un mensaje.
Cada sección muestra además cuántas cosas le faltan, y junto al botón aparece un enlace con el total.

**Al generar, la guía se envía a SUNAT.** Después, el sistema muestra los avisos de SUNAT que
calcula el servidor para esa guía.

:::tip Generar una guía desde otra creada por API
Una guía emitida por la API no guarda el punto de partida ni el de llegada como direcciones
registradas. Al generar otra a partir de ella, el formulario los busca entre las direcciones; si no
están, deja el campo vacío (no elige otra sin avisar) y muestra la dirección original con un enlace
**Registrarlo**, que abre el alta ya rellenada.
:::

---

## Crear Guía de Remisión a partir de un Comprobante

**1. Si necesitas generar una guía de remisión a partir de una factura:**

Ingresa al módulo de **VENTAS** en la subcategoría **Listado de Comprobantes**.

Selecciona los tres puntos a la derecha de la factura en la lista de comprobantes y selecciona **Guía**.

![Alt text](img/remisin4.jpg)

2. Te redirigirá automáticamente a la sección de **Guías de Remisión**.

![Alt text](img/remisin5.jpg)

3. Algunos campos se completarán automáticamente con la información de la factura, y solo tendrás que completar los campos faltantes de la manera ya explicada anteriormente.

---
