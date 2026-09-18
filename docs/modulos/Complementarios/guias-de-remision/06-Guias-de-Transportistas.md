# Guías de transportistas

En este artículo te enseñaremos a como generar tus guías de remisión. Sigue estos pasos para realizarlo:

Ingresa al módulo de **Guías de remisión** y luego selecciona la subcategoría **G.R Transportista**. En la parte superior derecha selecciona el botón Nuevo.

![Alt text](img/guiatransportista1.jpg)

Tendrá que rellenar los siguientes campos:

![Alt text](img/guiatransportista2.jpg)

:::note Las capturas son de la versión anterior del formulario
Desde el 2026-09-18 el formulario se ordena en **secciones**, cada una con su título. Los campos
son los mismos.
:::

### Datos de la guía

**Establecimiento**, **serie**, **fecha de emisión**, **fecha de traslado**, **unidad de medida**,
**peso total** y **observaciones** (hasta 250 caracteres; el contador lo muestra).

:::info IMPORTANTE
 La serie previamente configurada en el módulo **Configuraciones y mas**, categoría **Locales y series**, la series inicia **V001**.
:::

### Remitente y destinatario

- **Remitente** y su **punto de partida**.
- **Destinatario** y su **punto de llegada**.

Cada uno se puede crear con **+ Nuevo**.

:::info IMPORTANTE

 Si el punto de llegada no carga una vez seleccionado el cliente, selecciona el botón +Nuevo y sin necesidad de llenar algún dato seguido selecciona el botón Buscar y una vez cargado los datos selecciona el botón **Guardar**.

![Alt text](img/guiactualizada5.jpg)

:::

:::warning El remitente no puede ser tu empresa
En esta guía tu empresa es el **transportista**, y SUNAT rechaza una guía cuyo remitente es el
propio transportista. El sistema no te deja emitirla. Si trasladas tu propia carga, emite una
[guía de remisión remitente](./05-Generar-guias-de-remision.md) en transporte privado.
:::

### Vehículos y conductores

- **Vehículos:** selecciona uno o varios, o crea uno con **+ Nuevo** (entra directo en la tabla).
  El primero es el **principal**; los demás, hasta dos, son secundarios (por ejemplo, el remolque).
  La tabla muestra el **TUC** y la **Aut. especial** de cada vehículo, tal como están en
  [Creación de vehículos](./09-Creacion-de-Vehiculos.md): en esta guía los dos viajan siempre a
  SUNAT. Un vehículo sin TUC muestra un aviso: SUNAT aceptará la guía pero la observará.
- **Conductores:** selecciona uno o varios, o crea uno con **+ Nuevo**. El primero es el principal.

### Autorización especial de la empresa (materiales o residuos peligrosos)

La guía **no tiene una casilla de «material peligroso»**. Lo que se declara es el **permiso**:
la autorización especial de tu empresa de transporte, con la entidad que la otorgó (catálogo D-37).

La sección se activa con la casilla **Declarar autorización especial**, como el pagador de flete:

- Viene **marcada** si tu empresa tiene una autorización registrada en
  [Empresa](../../configuracion-y-mas/configuracion-globales/Empresa/empresa.md), con el
  **N° de autorización** y la **Entidad emisora (D-37)** ya puestos. Puedes cambiarlos **solo para
  esta guía**; **Usar la de la empresa** los repone.
- **Desmárcala** si este traslado no lleva la autorización: la guía se emite sin ella. Si vuelves a
  marcarla, recupera lo que habías escrito.
- Si tu empresa no tiene ninguna, viene desmarcada; al marcarla escribes el número y eliges la
  entidad.
- La autorización viaja **completa o no viaja**: si la casilla queda marcada pero vacía, o falta el
  número o la entidad, **Antes de emitir** lo avisa y la guía se emite sin autorización. No
  impide generarla.

En la cabecera de la sección se ve siempre el **registro MTC** de tu empresa, porque viaja en todas
las guías de transportista. Si dice «sin registrar», SUNAT aceptará la guía pero la observará: el
enlace **Registrarlo en Empresa** lleva a la ficha.

Si los vehículos también tienen su propia autorización, se registra en cada vehículo y viaja con él.

### Pagador del flete

Se activa con la casilla **Agregar pagador de flete**: quién paga el transporte (el remitente, un
subcontratador u otro), con su documento y nombre. Sin pagador, SUNAT aceptará la guía pero la
observará.

### Documentos relacionados

Con **+ Agregar documento** puedes citar, además de la guía de remisión remitente, los permisos
del transportista: el **`67`** (permiso de operación especial MATPEL del MTC), el **`65`**
(circulación MATPEL en el Callao) y el `66`, `68`, `69` y `82`.

- Un permiso tiene **un solo número** (por ejemplo `1500005MRP`): hasta 100 caracteres y sin espacios.
- El RUC se precarga con el de tu empresa; es opcional.
- Caben **dos** documentos si uno es un permiso (por ejemplo, la guía remitente y el permiso MATPEL);
  el sistema no deja agregar más de los que SUNAT admite.

:::danger La autorización de residuos (`76`) no es de esta guía
El `76` es un documento **solo de la guía remitente**: en una guía de transportista SUNAT la
rechaza. Por eso no aparece en esta lista.
:::

### Antes de emitir

Junto al botón **Generar**, la sección **Antes de emitir** dice, mientras llenas la guía, si ya se
puede emitir, en tres grupos:

- **Por completar o corregir** (en rojo), que **impide generar la guía**: lo que falta y sin lo cual
  SUNAT la rechaza (remitente y punto de partida, destinatario y punto de llegada, un peso mayor que
  0, el vehículo, el conductor con documento, nombre y licencia) y lo que SUNAT rechaza seguro (el
  remitente igual a tu empresa, una placa que no tenga de 6 a 8 letras y números). Una placa
  registrada con guion no bloquea: viaja sin él, y el formulario lo avisa.
- **SUNAT la aceptará con observaciones** (en ámbar), que **no impide generarla**: el registro MTC
  que falta o con otro formato, los vehículos sin TUC, la falta de pagador de flete o un pagador
  sin documento o nombre.
- **Avisos** (en azul): por ejemplo, una autorización especial incompleta, que no viajará.

Cada punto lleva a su campo. Si pulsas **Generar** con algo por completar, la guía no se envía: los
campos se marcan en rojo, el formulario te lleva al primero y un mensaje dice qué falta. **Al generar,
la guía se envía a SUNAT**; después se muestran los **avisos de SUNAT** que calcula el servidor.

Al generar una guía a partir de otra creada por **API**, el formulario busca el remitente, el
destinatario y sus direcciones entre los registrados. Lo que no encuentra lo muestra bajo su campo,
con un enlace **Registrarlo** que abre el alta ya rellenada.

## Agregar Producto:

1. Para agregar el producto a trasladar:

![Alt text](img/remision_agregar_produc_2.jpg)

   - **1. Producto:** Ingresa el nombre del producto en la **Descripción**. Si necesitas crear uno nuevo, selecciona el botón **+Nuevo** y sigue los pasos en este **[artículo](../../esenciales/productos-servicios/03-productos-creacion-basica.md).**
   - **2. Cantidad:** Ingresa la cantidad del producto.

2. Una vez completado, selecciona el botón **Agregar** y luego **Generar**.

## Corregir, recrear, eliminar o anular una guía de transportista

Desde el listado de **G.R Transportista**, una guía *Registrada* o *Rechazada* ofrece:

- **Editar:** abre el formulario con los datos de la guía (remitente, destinatario, sus
  direcciones, vehículos, conductores y carga). Los vehículos y conductores vuelven con su TUC y su
  autorización aunque ya no estén activos en el catálogo, y la autorización de la empresa es la que
  llevó esa guía. Corrige, guarda y pulsa **Enviar a Sunat**. La guía conserva su serie y su número.
- **Volver a recrear** (menú ⋮): vuelve a generar el XML y el PDF, para cuando la guía se guardó
  sin sus archivos. Necesita el permiso de usuario **Recrear documentos**.
- **Eliminar** (menú ⋮): antes de borrarla, el sistema le pregunta a SUNAT. Si SUNAT la tiene, o
  no responde, no se borra.

Y una guía ya *Aceptada* ofrece **Marcar como anulada** (menú ⋮), igual que en G.R Remitente:
deja el estado del sistema igual al de SUNAT después de haber dado la guía de baja **en el
portal de SUNAT**, que es el único sitio donde se anula de verdad y solo el mismo día de la
emisión. La guía anulada conserva su **XML**, su **PDF**, su **CDR** y el botón **Opciones**.
Ver [Marcar una guía como anulada](./02-Listado-de-guias-de-remision.md#marcar-una-guía-como-anulada).

:::danger SUNAT no anula las guías del transportista
Tampoco las del remitente: no existe comunicación de baja para las guías de remisión. Marcarla
como anulada aquí **solo actualiza el estado en el sistema**, no en SUNAT.
:::

:::info Guías emitidas por API
Si la guía la creó otra aplicación por API, al editarla puede que el remitente, el destinatario o
el vehículo aparezcan vacíos. Selecciónalos de nuevo antes de guardar.
:::

Todos los estados y botones: [Listado de Guías de Remisión](./02-Listado-de-guias-de-remision.md#qué-hacer-con-una-guía-rechazada).
