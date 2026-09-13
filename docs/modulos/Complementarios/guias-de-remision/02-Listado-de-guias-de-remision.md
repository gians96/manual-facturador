# Listado de Guías de Remisión

En esta área conocerás la pantalla donde viven todas tus guías: qué significa cada columna,
qué hace cada botón y cómo saber de un vistazo si una guía ya llegó a SUNAT.

Ingresa al módulo de **Guías de remisión** y luego a la subcategoría **G.R Remitente**
(o **G.R Transportista**, si emites como empresa de transporte).

## Las columnas

| Columna | Qué te dice |
|---|---|
| **Fecha Emisión** | El día en que se generó la guía. |
| **Cliente** | El destinatario de los bienes, con su documento de identidad. |
| **Número** | Serie y correlativo de la guía, por ejemplo `T001-4`. |
| **Estado** | En qué punto del envío a SUNAT está. Ver la tabla siguiente. |
| **Fecha Envío** | La fecha de traslado declarada, no la fecha en que se envió a SUNAT. |
| **N° Comprobante** | La factura o boleta ligada a esta guía, si la hay. |
| **Descargas** | Los tres archivos: **XML**, **PDF** y **CDR**. |
| **Acciones** | Los botones de la fila. |

:::tip La columna «N° Comprobante» se llena por dos caminos
Aparece tanto si la guía **nació desde un comprobante** (la emitiste con el botón «Guía»
del listado de comprobantes) como si **generó el comprobante después** (con «Generar
comprobante» desde esta misma pantalla). Son dos vínculos distintos por dentro, pero en
esta columna se ven igual.

Si la columna está vacía, esa guía **no está ligada a ningún comprobante** todavía.
:::

## Los estados

| Estado | Significa |
|---|---|
| **Registrado** | La guía existe, está firmada y tiene su PDF, pero **aún no se ha enviado a SUNAT**. |
| **Enviado** | Se envió y SUNAT entregó un número de ticket. Falta recoger la respuesta. |
| **Aceptado** | SUNAT la aceptó y ya hay CDR descargable. |
| **Rechazado** | SUNAT la rechazó. El motivo aparece al consultar el ticket. |
| **Anulado** | La guía fue dada de baja. |

Que una guía recién creada quede en **Registrado** es normal, no un fallo: a diferencia de
las facturas, las guías **no se envían en el mismo momento de emitirlas**. El envío es un
paso aparte. Si quieres el detalle técnico de por qué,
[aquí está explicado](/devs/api/guias-de-remision).

## Botones de acción

- **Nuevo:** abre el formulario para crear una guía desde cero. Ver
  [Generar Guías de Remisión](./05-Generar-guias-de-remision.md).
- **Generar comprobante desde múltiples guías:** emite **una sola factura o boleta** que
  cierra varias guías del mismo cliente a la vez. Ver
  [Generar comprobante desde una guía](./03-Generar-comprobante-desde-una-guia.md).
- **Generar comprobante** (en la fila): emite el comprobante de **esa** guía. Solo aparece
  si la guía aún no está facturada.
- **Opciones** (en la fila): descargar el PDF (A4, 80 mm, 58 mm) y el CDR, volver a consultar
  el CDR en SUNAT, y enviar por correo y por WhatsApp. Solo aparece cuando la guía ya está
  *Aceptada*. Si SUNAT la aceptó **con observaciones**, arriba sale un único aviso ámbar,
  «SUNAT aceptó la guía con N observaciones»; pulsa **Ver detalle** para desplegarlas.

Los botones de cada fila dependen del estado de la guía:

| Estado | Botones de la fila | Menú ⋮ |
|---|---|---|
| Registrado | **Enviar a Sunat** · **Editar** | **Volver a recrear** · **Eliminar** |
| Enviado | **Consultar ticket** | — |
| Aceptado | **Opciones** · **Generar comprobante** | **Marcar como anulada** |
| Rechazado | **Enviar a Sunat** · **Editar** | **Volver a recrear** · **Eliminar** |

Es igual en **G.R Remitente** y en **G.R Transportista**.

## Qué hacer con una guía rechazada

Una guía rechazada **no queda registrada en SUNAT**, así que tienes dos salidas:

- **Corregirla y reenviarla con el mismo número.** Pulsa **Editar**, corrige lo que indica el
  rechazo (el motivo aparece al consultar el ticket), guarda y pulsa **Enviar a Sunat**. La guía
  conserva su serie y su número.
- **Eliminarla**, desde el menú ⋮. Antes de borrarla, el sistema le pregunta a SUNAT; si SUNAT sí
  la tuviera, o no se pudiera consultar, no se borra nada.

:::info Si la guía la emitió una aplicación por API
Al **Editar** una guía de transportista creada por API, el remitente, el destinatario y el vehículo
pueden aparecer vacíos: la API guarda sus datos, pero no los vincula a las personas y vehículos
registrados. Elígelos otra vez en el formulario antes de guardar.
:::

## «No fue posible enviar» o «no tiene XML firmado»

Si al pulsar **Enviar a Sunat** el aviso dice que la guía **no tiene XML firmado**, la guía existe
pero sus archivos no llegaron a crearse. Abre el menú ⋮, pulsa **Volver a recrear** y vuelve a
enviarla.

**Volver a recrear** genera y firma otra vez el XML y el PDF con los datos actuales; no envía nada
a SUNAT. Solo aparece si tu usuario tiene el permiso **Recrear documentos**, en
**Configuración → Usuarios → editar usuario → Otros permisos**, que viene desmarcado.

:::caution Revisa la fecha antes de enviar
Recrear no cambia la fecha de emisión. Si la guía es de hace días, SUNAT la rechaza con **2108,
«Presentación fuera de fecha»**. Corrige la fecha con **Editar** y envíala de nuevo.
:::

Más detalle técnico: [El estado manda qué se puede hacer](/devs/api/guias-de-remision#el-estado-manda-qué-se-puede-hacer).

## De dónde vienen las guías

No todas nacen en esta pantalla. También se crean:

- Desde el **listado de comprobantes**, con la opción **Guía** del menú de tres puntos: la
  guía sale con el cliente y los productos ya rellenados, y queda ligada al comprobante.
  Ver [Lista de Comprobantes](../../esenciales/ventas/2-lista-de-comprobantes.md).
- Desde una **cotización**, un **pedido** o una **nota de venta**, con la misma idea.
- Desde la **API**, con `POST /api/dispatches`. Ver
  [Documentos relacionados](/devs/api/documentos-relacionados).

## Ver también

- [Configuración previa](./01-Configuracion-previa-guia-remision.md) — los tokens que SUNAT
  exige antes de poder emitir la primera guía.
- [Generar Guías de Remisión](./05-Generar-guias-de-remision.md)
- [Generar comprobante desde una guía](./03-Generar-comprobante-desde-una-guia.md)
