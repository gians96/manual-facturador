# Guías de transportistas

En este artículo te enseñaremos a como generar tus guías de remisión. Sigue estos pasos para realizarlo:

Ingresa al módulo de **Guías de remisión** y luego selecciona la subcategoría **G.R Transportista**. En la parte superior derecha selecciona el botón Nuevo.

![Alt text](img/guiatransportista1.jpg)

Tendrá que rellenar los siguientes campos:

![Alt text](img/guiatransportista2.jpg)

- **1. Establecimiento:** Selecciona el establecimiento.
- **2. Serie:** Selecciona la serie.

:::info IMPORTANTE
 La serie previamente configurada en el módulo **Configuraciones y mas**, categoría **Locales y series**, la series inicia **V001**.
:::

- **3. Fecha de emisión:** Ingresa la fecha de emisión.
- **4. Fecha de traslado:** Ingresa la fecha de traslado.
- **5. Unidad de medida:** Selecciona la unidad de medida que más se acomode a sus requerimientos.
- **6. Peso total:** Ingresa el peso total del producto.
- **7. Remitente:** Selecciona al remitente, también puede crear un nuevo punto de llegada seleccionando el botón +Nuevo.
- **8. Punto de partida:** Selecciona el punto de partida correspondiente, también puede crear un nuevo punto de partida seleccionando el botón +Nuevo.
- **9. Destinatario:** Selecciona el destinatario correspondiente, también puede crear un nuevo punto de partida seleccionando el botón +Nuevo.
- **10 . Punto de llegada:** Selecciona el punto de llegada, también puede crear un nuevo punto de llegada seleccionando el botón +Nuevo.

:::info IMPORTANTE

 Si el punto de llegada no carga una vez seleccionado el cliente, selecciona el botón +Nuevo y sin necesidad de llenar algún dato seguido selecciona el botón Buscar y una vez cargado los datos selecciona el botón **Guardar**.

![Alt text](img/guiactualizada5.jpg)

:::

- **Datos del vehículo:** Selecciona uno o varios vehículos y sus números de placas correspondientes, o crea un nuevo vehículo con el botón **+Nuevo** (entra directo en la tabla). El primero es el **principal**; los demás, hasta dos, son secundarios (por ejemplo, el remolque). La tabla muestra el **TUC** y la **Aut. especial** de cada vehículo, tal como están en [Creación de vehículos](./09-Creacion-de-Vehiculos.md): en esta guía los dos viajan siempre a SUNAT. Un vehículo sin TUC muestra un aviso: SUNAT aceptará la guía pero la observará.
- **Datos del conductor:** Selecciona uno o varios conductores, también puedes crear un nuevo conductor con el botón **+Nuevo**.

:::warning El remitente no puede ser tu empresa
En esta guía tu empresa es el **transportista**, y SUNAT rechaza una guía cuyo remitente es el
propio transportista. El sistema no te deja emitirla. Si trasladas tu propia carga, emite una
[guía de remisión remitente](./05-Generar-guias-de-remision.md) en transporte privado.
:::

## Autorización especial de la empresa (materiales o residuos peligrosos)

La guía **no tiene una casilla de «material peligroso»**. Lo que se declara es el **permiso**:
la autorización especial de tu empresa de transporte, con la entidad que la otorgó (catálogo D-37).

Debajo de los vehículos y conductores aparece el bloque **Autorización especial de la empresa**:

- **Registro MTC:** el de tu empresa, tal como está en [Empresa](../../configuracion-y-mas/configuracion-globales/Empresa/empresa.md). Si dice «sin registrar», SUNAT aceptará la guía pero la observará: regístralo en Empresa.
- **N° de autorización** y **Entidad emisora (D-37):** vienen ya con la autorización registrada en Empresa. Puedes cambiarlas **solo para esta guía**, o usar **Quitar de esta guía** si este traslado no la lleva. Van juntas: con una sola, el sistema no deja guardar.

Si los vehículos también tienen su propia autorización, se registra en cada vehículo y viaja con él.

### El permiso como documento relacionado

Con **Documento relacionado** puedes citar, además de la guía de remisión remitente, los permisos
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

Al guardar, el sistema muestra los **avisos de SUNAT** para esa guía (lo que va a observar o
rechazar), sin bloquearla.


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
