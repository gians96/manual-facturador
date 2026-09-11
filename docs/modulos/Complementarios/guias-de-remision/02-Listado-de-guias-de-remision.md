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
- **Opciones** (en la fila): reimprimir, descargar el CDR, enviar por correo y por WhatsApp.
  **No consulta nada a SUNAT**, y solo aparece cuando la guía ya está *Aceptada*.

Los botones de cada fila dependen del estado de la guía:

| Estado | Botón que aparece |
|---|---|
| Registrado | **Enviar a Sunat** |
| Enviado | **Consultar ticket** |
| Aceptado | **Opciones** y **Generar comprobante** |

**Editar** aparece en cualquier estado menos *Aceptado*.

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
