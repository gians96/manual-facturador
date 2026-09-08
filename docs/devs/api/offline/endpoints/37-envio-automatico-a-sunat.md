# 37 — Envío Automático de Comprobantes a SUNAT

> **Configuración → Avanzado → pestaña Extra → tarjeta "Envío Automático de Comprobantes"**
>
> No confundir con [36 — Envío automático **por correo**](36-envio-automatico-por-correo.md). Aquel decide si el cliente recibe el PDF; este decide si SUNAT recibe el XML.

---

## Por qué importa para quien integra

`POST /api/documents` responde `200` tanto si el comprobante se remitió a SUNAT como si no. Lo que cambia es el estado:

| | Se remitió | No se remitió |
|---|---|---|
| `data.state_type_id` | `"05"` (Aceptado) — o `"07"`, `"09"` según el CDR | `"01"` (Registrado) |
| `links.cdr` | URL del CDR | `""` |
| `response` | `{ "code": "0", "description": "…" }` | `[]` (arreglo vacío, no objeto) |

Un comprobante en `01` es válido, está firmado y tiene PDF: solo está **pendiente de remitir**. Si tu integración da por hecho que emitir es enviar, esos comprobantes se quedan sin declarar y nadie se entera hasta el cierre del periodo. Comprueba siempre `state_type_id`.

---

## Los tres interruptores

| Interruptor en pantalla | Columna | Qué gobierna de verdad |
|---|---|---|
| Envío de comprobantes automático | `send_auto` | Si al emitir por API o por panel el XML firmado sale hacia SUNAT en el acto. **Afecta a facturas, boletas y sus notas** |
| Envío de guía de remisión automático | `auto_send_dispatchs_to_sunat` | **Solo al panel.** La API de guías nunca envía sola |
| Enviar boletas y notas asociadas (Crédito y Débito) de forma individual | `ticket_single_shipment` | Si las boletas y sus notas van una a una, o esperan al resumen diario |

El tercero no aparece para usuarios de tipo *integrator*.

---

## La regla que aplica el backend

Al emitir por `POST /api/documents`, la decisión de enviar se resuelve así:

```
grupo 01  (factura, y notas de factura):
    enviar = send_auto  Y  acciones.enviar_xml_firmado

grupo 02  (boleta, y notas de boleta):
    enviar = send_auto  Y  acciones.enviar_xml_firmado  Y  ticket_single_shipment
```

Tres consecuencias que conviene tener claras:

1. **`acciones.enviar_xml_firmado` solo puede frenar, nunca forzar.** Vale `true` si no lo mandas, pero con `send_auto` apagado no envía nada aunque lo pongas en `true`. Es lo contrario de `acciones.enviar_email`, que sí fuerza.
2. **El grupo no lo decide la serie ni el tipo de documento de la nota**, sino el comprobante afectado: una NC contra una boleta es grupo `02` aunque su serie sea `FC01`. Ver [10-nota-credito.md](10-nota-credito.md#como-llega-a-sunat).
3. Comprobantes de retención, percepción y liquidación de compra **no pasan por esta regla**: se envían siempre.

### La condición extra de las notas de boleta

Para una NC o ND del grupo `02` no basta con que `ticket_single_shipment` esté encendido hoy. El backend mira **cómo se envió la boleta afectada**: si esa boleta se fue por resumen, su nota también irá por resumen. Es lo que SUNAT espera, y evita que una nota individual quede referida a una boleta que solo existe dentro de un resumen.

Esa comprobación necesita el documento enlazado. Si la nota referenció al original por serie y número en vez de por `external_id`, no hay nada que mirar y la respuesta es siempre "no": la nota queda para el resumen aunque los dos interruptores estén activos.

---

## Matriz completa

`send_auto` apagado deja todo en `01`, así que la tabla asume que está encendido:

| Comprobante | `ticket_single_shipment` | Resultado al emitir | Cómo se remite después |
|---|---|---|---|
| Factura (`01`) | *indiferente* | Enviada, `state_type_id` `05`/`07`/`09` | — |
| Boleta (`03`) | activo | Enviada individualmente | — |
| Boleta (`03`) | apagado | `01` Registrado | `POST /api/summaries` |
| NC/ND de factura | *indiferente* | Enviada | — |
| NC/ND de boleta enviada individualmente | activo | Enviada individualmente | — |
| NC/ND de boleta que fue por resumen | activo | `01` Registrado | `POST /api/summaries` |
| NC/ND de boleta | apagado | `01` Registrado | `POST /api/summaries` |
| NC/ND **de boleta** referenciada sin `external_id` | *indiferente* | `01` Registrado | `POST /api/summaries` |

Con `send_auto` apagado, todo lo del grupo `01` queda pendiente de `POST /api/documents/send` y todo lo del grupo `02`, de `POST /api/summaries`.

---

## Cómo remitir lo que quedó pendiente

### Grupo `01` — factura y sus notas

```
POST /api/documents/send
{ "external_id": "2dded172-cd17-4078-9c88-10a9b1177f2d" }
```

Detalle en [26-envio-diferido-update-estado.md](26-envio-diferido-update-estado.md).

:::danger Este endpoint rechaza todo lo del grupo `02`

Con una boleta o con una nota de boleta responde **`422`** con `error_code: "DOCUMENT_NOT_SENDABLE"` y el mensaje `El tipo de documento 03 es inválido, no es posible enviar.` El objeto `errors` trae el `grupo` del documento y un `como_enviar` con la salida correcta.

No es un fallo de tu llamada ni algo que reintentar: esos comprobantes se declaran en el resumen diario, no de uno en uno.

Los otros dos rechazos del endpoint también son `422`: `DOCUMENT_NOT_FOUND` si el `external_id` no existe, y `MISSING_FIELDS` si no lo mandas.

**Cambio de comportamiento (2026-09-07).** Los tres salían como **`500`** —el primero con el mensaje correcto pero sin `error_code`, y el tercero ni eso: sin `external_id` el endpoint devolvía `200` con cuerpo vacío, indistinguible de un envío correcto—. Un cliente que reintentara sobre 5xx repetía para siempre un fallo que nunca iba a resolverse solo.
:::

### Grupo `02` — boletas y sus notas

```
POST /api/summaries
{ "fecha_de_referencia": "2026-09-07", ... }
```

El resumen recoge automáticamente **todo** lo que ese día siga en grupo `02`, estado `01` y sin marca de envío individual —boletas y notas juntas, hasta 500 documentos por resumen—. Cada nota se declara con su `BillingReference` al comprobante que corrige.

:::warning Nadie manda el resumen por ti

No hay tarea programada que genere ni envíe el resumen diario. Si apagas el envío individual de boletas, alguien tiene que llamar a `POST /api/summaries` cada día —tu integración, o un usuario desde el panel—. Un tenant con el interruptor apagado y sin nadie que genere resúmenes acumula boletas en estado `01` indefinidamente.
:::

---

## La guía de remisión es un caso aparte

El interruptor "Envío de guía de remisión automático" **no tiene efecto en la API**. `POST /api/dispatches` firma, genera el PDF y devuelve el `external_id`, pero nunca remite a SUNAT: el envío es siempre una segunda llamada.

```
POST /api/dispatches/send
{ "external_id": "…" }
```

Lo que hace el interruptor es responder `data.send_sunat` en el endpoint **del panel**, para que el navegador decida si lanza el envío. Un cliente de la API que espere el mismo comportamiento se queda con guías sin declarar. Ver [13-guia-remision-remitente.md](13-guia-remision-remitente.md).

---

## Qué comprobar cuando "no llegó a SUNAT"

1. `data.state_type_id` de la respuesta de emisión. Si es `01`, no se intentó enviar: es configuración, no un fallo de red.
2. Si es `01` y esperabas envío: mira `send_auto`, y para boletas y sus notas, `ticket_single_shipment`.
3. Si la nota es de boleta y los dos están activos: comprueba si mandaste `documento_afectado.external_id`, y cómo se envió la boleta afectada.
4. Si el estado es `03` (Enviado) y no avanza, el envío salió pero no hay CDR: eso ya es SUNAT o el PSE, no esta configuración.
5. Estados y su significado, en [26-envio-diferido-update-estado.md](26-envio-diferido-update-estado.md).
