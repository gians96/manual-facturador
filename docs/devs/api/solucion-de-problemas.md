---
sidebar_position: 2.15
title: "Solución de problemas: del síntoma a la causa"
sidebar_label: "Solución de problemas"
---

# Solución de problemas: del síntoma a la causa

El resto de la documentación está organizada por **código de error** y por **endpoint**: si ya
sabes que recibiste un `INVALID_REFERENCE`, [Errores de la API](./errores-de-la-api.md) te dice
qué corregir. Esta página va al revés. Empieza por lo que **ves** —un mensaje raro, un
comprobante que se emitió pero no dice lo que enviaste, un lote que se reenvía sin fin— y te
lleva a la causa.

Casi todos los casos de aquí le pasaron a un integrador de verdad, y casi todos **ya están
arreglados**. Eso importa más de lo que parece: si tu servidor es anterior al arreglo, sigues
viendo el síntoma viejo. Al final hay una [tabla de fechas](#desde-cuando-esta-arreglado) para
preguntarle a soporte si tu instalación ya lo tiene.

## Las tres preguntas que ahorran una tarde

Antes de tocar el payload, contesta estas tres. La mayoría de las consultas de soporte se cierran
en la primera.

**1. ¿Mandas las dos cabeceras?** `Content-Type: application/json` y
`Accept: application/json`. Sin la primera, el servidor no ve ni un campo de tu JSON; sin la
segunda, un error puede volver como la pantalla de login en HTML en vez de como JSON.
→ [la cabecera](./errores-de-la-api.md#antes-que-nada-la-cabecera)

**2. ¿El fallo es de tu payload o del servidor?** No se decide por el código HTTP, se decide por
el `error_code`. Al emitir, un dato mal enviado **nunca** devuelve un 500; y hay errores del
servidor que llegan con HTTP 200 dentro de `results[]`. La excepción son los resúmenes de
boletas, `document_check_server` y las descargas: ahí un `external_id` equivocado todavía responde
500 → [39 — Ciclo de la boleta](offline/endpoints/39-ciclo-de-la-boleta.md).

**3. ¿Reintentar puede arreglarlo?** Si el error es permanente, reintentar solo gasta tiempo —y
en algunos casos gasta correlativos. La columna «¿Reintentar?» de
[la tabla de `error_code`](offline/endpoints/15-sync-batch.md) es la respuesta, y
[la lógica de reintento de referencia](offline/endpoints/15-sync-batch.md#retry-logic) es el
código que deberías tener.

:::tip La regla corta
Reintenta solo `bloqueo_temporal` y los fallos de red. Todo lo demás: corrige o escala.
:::

## Índice por síntoma

| Lo que ves | Ve a |
|---|---|
| «Faltan campos» que tú **sí** estás enviando | [Mando el campo y dice que falta](#mando-el-campo-y-dice-que-falta) |
| Ayer funcionaba, hoy **todo** el lote falla igual | [Todo el lote falla de golpe](#todo-el-lote-falla-de-golpe) |
| El mensaje dice «reintenta» y reintentar nunca funciona | [Todo el lote falla de golpe](#todo-el-lote-falla-de-golpe) |
| `success: true`, pero el comprobante no dice lo que envié | [Se emite y no significa lo que envié](#se-emite-y-no-significa-lo-que-envie) |
| El stock no baja al vender | [Se emite y no significa lo que envié](#se-emite-y-no-significa-lo-que-envie) |
| El lote se reenvía sin fin, aunque las filas vuelven bien | [El lote se reenvía sin fin](#el-lote-se-reenvia-sin-fin) |
| La API aceptó la guía y SUNAT la rechazó | [SUNAT rechaza lo que la API aceptó](#sunat-rechaza-lo-que-la-api-acepto) |
| Corregí la guía, la reenvié por el lote y SUNAT la rechaza igual | [La guía corregida no cambia](#la-guia-corregida-no-cambia) |
| La ficha del cliente aparece vaciada tras emitir | [La ficha del cliente se vacía](#la-ficha-del-cliente-se-vacia) |
| La guía salió, pero sin PDF ni XML | [La guía sale sin firmar](#la-guia-sale-sin-firmar) |
| Se cortó la conexión y no sé si se emitió | [No sé si se emitió](#no-se-si-se-emitio) |
| Enlacé la guía con el comprobante y el enlace no existe | [El enlace guía ↔ comprobante no existe](#el-enlace-guia-comprobante-no-existe) |
| La boleta sigue en `01` (Registrado) después del `sync-batch` | [39 — Por qué queda en `01` y cómo declararla](offline/endpoints/39-ciclo-de-la-boleta.md#paso-1) |
| La boleta enviada sola (envío individual) quedó en `01` y la API no la reenvía | [40 — Una boleta de envío individual en `01`](offline/endpoints/40-ciclo-de-la-factura-y-envio-individual.md#factura-en-01) |
| El CDR de una boleta aceptada da error 500 | [39 — El CDR es el del resumen](offline/endpoints/39-ciclo-de-la-boleta.md#paso-4) |
| Pedí anular una boleta y se anuló otra | [39 — `codigo_tipo_proceso` va como texto](offline/endpoints/39-ciclo-de-la-boleta.md#paso-5) |

---

## Mando el campo y dice que falta {#mando-el-campo-y-dice-que-falta}

**Síntoma.** Un 500 con texto crudo de PHP —`Undefined array key "totales"`— o un error que
acusa como ausentes campos que van en tu cuerpo. Fue la causa nº 1 de consultas de
`POST /api/documents`.

**Causa.** Falta `Content-Type: application/json`. Sin esa cabecera el cuerpo se trata como un
formulario y tu JSON entero se convierte en el **nombre de una clave**: no llega ni un campo.
El mismo mensaje salía además con JSON roto, cuerpo vacío, cuerpo enviado como lista
(`[{...}]`) y con una falta real de campo: cinco fallos distintos indistinguibles.

**Qué hacer.** Manda las dos cabeceras. Hoy cada caso tiene su código propio —400
`MISSING_CONTENT_TYPE`, `INVALID_JSON`, `EMPTY_BODY`, `BODY_IS_LIST`— y las faltas reales salen
como 422 `MISSING_FIELDS` con `errors.faltantes` y el número de ítem
(`Ítem #2: falta 'descripcion'.`).

:::warning Si solo fallan los comprobantes con tildes o ñ
Eso no es este caso: es el JSON que no llega en UTF-8, y tiene su propia sección con el ejemplo
de SQL Server → [`INVALID_ENCODING`](./errores-de-la-api.md).
:::

## Todo el lote falla de golpe {#todo-el-lote-falla-de-golpe}

**Síntoma.** De un día para otro, **todas** las filas vuelven con el mismo
`error_code: DATABASE_ERROR`, con el payload que ayer emitía. Y el mensaje te manda a revisar el
payload, o a reintentar, y ni una cosa ni la otra cambia nada.

**Causa.** Cuando falla el lote **entero** y de forma idéntica, la causa casi nunca está en el
payload: está en el servidor. Hubo dos casos reales, los dos con el mismo aspecto desde fuera:

- Una actualización cuyo paso de migraciones falló **en silencio** y terminó diciendo
  «completada». El `INSERT` de cada guía pedía columnas que la base de ese cliente no tenía.
- Un fallo del propio código que escribía un dato que la base rechaza por una restricción, en
  todas las guías de remisión remitente (`09`) en transporte público.

**Qué hacer.** Mira `errors.tipo`. Es lo que distingue «es tuyo» de «no es tuyo»:

| `errors.tipo` | Qué significa | Reintentar |
|---|---|---|
| `esquema_desactualizado` | Al servidor le falta una actualización de base de datos. Trae `tabla` y `columna` | ❌ No sirve hasta que se actualice |
| `restriccion_no_atribuible` | Un dato que **pone el servidor**, no tu payload, no cumple una restricción. Trae `restriccion` y `tabla` | ❌ No sirve: se repetirá igual |
| `bloqueo_temporal` | La base estaba ocupada y canceló la operación | ✅ Una vez |
| `no_clasificado` | Otro fallo de base de datos | ⚠️ Uno, y escalar |

Ninguno de esos cuatro se arregla tocando el payload. Escala con el bloque `errors` completo y un
`offline_id` → [qué mandar a soporte](#que-mandar-a-soporte). El detalle de la tabla, con
ejemplos de respuesta, está en
[`DATABASE_ERROR`: qué dice `errors.tipo`](offline/endpoints/15-sync-batch.md#database_error-qué-dice-errorstipo).

:::danger Un `error_code` que decía «reintenta» sobre un error permanente
Hasta el 2026-09-09, **un campo ausente de la cabecera** salía como `PROCESSING_ERROR` —un
código publicado como reintentable— y con un mensaje que mandaba a revisar los ítems, el único
sitio donde el problema no estaba. Un integrador de guías de remisión estuvo reintentando
indefinidamente un payload que el servidor nunca iba a aceptar.

Hoy esa familia sale como `MISSING_FIELDS` nombrando la clave. Pero **pon tope a los reintentos
igual**: un fallo que se repite casi nunca se arregla volviendo a enviar lo mismo.
:::

## Se emite y no significa lo que envié {#se-emite-y-no-significa-lo-que-envie}

El caso más incómodo: `success: true` y el comprobante guardado con algo distinto de lo que
mandaste. Estos son los reales, de más a menos frecuente.

**La condición de pago `"03"`.** `codigo_condicion_de_pago` no es un catálogo de SUNAT: es una
tabla del propio negocio, con dos filas —`01` contado y `02` crédito—. El `03` es un estado de la
pantalla de venta del panel, que lo convierte a `02` antes de enviar; nunca fue un valor de la
API. En los servidores donde esa fila llegó a existir, el comprobante se emitía **sin el bloque
de forma de pago y descartando todas las cuotas**. Manda `01` o `02` (omitirlo vale `01`), y para
crédito con cuotas, `02` + `cuotas[]`. Hoy es un 422 que lista los valores válidos de tu negocio
en `errors.valores_validos`.

**El código de producto SUNAT por línea.** `items[].codigo_producto_sunat` solo se usaba al
**crear** el producto; con un producto que ya existía —el caso normal— se descartaba sin avisar y
el XML salía con el del catálogo. Hoy un valor de 8 dígitos viaja al XML de ese comprobante sin
tocar tu catálogo, y si se ignora te lo dicen con un aviso
→ [`CODIGO_PRODUCTO_SUNAT_IGNORADO`](./errores-de-la-api.md#codigo_producto_sunat_ignorado).

**El stock que no baja.** La línea se resolvía solo por `codigo_interno`: si no coincidía, el
servidor **creaba un producto nuevo** con stock 0 y le aplicaba el descuento, así que el producto
real del panel no se movía nunca. Manda `items[].facturador_item_id` con el id real del catálogo:
se evalúa antes que `codigo_interno` y, si no existe, responde 422 `ITEM_NOT_FOUND` en vez de
inventar un producto. → [ítems y catálogo](./emision-items-y-catalogo.md)

**Valores que se aceptaban y no significaban lo enviado.** Una fecha `"01/09/2026"` emitida como
9 de enero, `usd` en vez de `USD`, una factura en dólares con tipo de cambio 1. Manda las fechas
en `YYYY-MM-DD`, la moneda y la serie en mayúsculas, y el tipo de cambio cuando la moneda no es
la local. → [Errores de la API](./errores-de-la-api.md)

:::info Fallos que todavía son silenciosos
Algunos no dan error ni aviso. Están listados, con lo que hay que hacer en cada uno, en
[lo que todavía es silencioso](./errores-de-la-api.md#lo-que-todavía-es-silencioso). Merece una
lectura antes de dar una integración por terminada.
:::

## El lote se reenvía sin fin {#el-lote-se-reenvia-sin-fin}

**Síntoma.** Las filas vuelven `success: true`, pero con `cash_registered: false`. El dispositivo
las considera pendientes y las manda otra vez, y otra. Un caso real generó 7.250 avisos de log en
un lote de 2.086 ventas.

**Causa.** La venta estaba emitida; lo que fallaba era registrarla en la caja del turno original,
cerrada hacía días. Una caja cerrada no se reabre, así que el fallo se repetía para siempre.

**Qué hacer.** Dos reglas:

1. **Con `cash_registered: true` la venta está terminada.** No la reenvíes.
2. Con `cash_registered: false`, ramifica por `cash_error_code` en vez de reencolar a ciegas.
   `CASH_NOT_FOUND` admite **un** reintento después de mandar la apertura de caja;
   `CASH_CLOSED` y `CASH_OTHER_USER` no se reintentan nunca.

El detalle de los cuatro códigos y la regla que corta el bucle está en
[registro en caja](offline/endpoints/15-sync-batch.md#registro-en-caja--cash_registered-y-cash_error_code).

## SUNAT rechaza lo que la API aceptó {#sunat-rechaza-lo-que-la-api-acepto}

La API valida su contrato; SUNAT valida el suyo. Un comprobante puede pasar el primero y morir en
el segundo **con el correlativo ya consumido**. Los rechazos reales más caros:

Dos cosas distintas, y conviene no confundirlas: un código **2000-3999** es un **rechazo** —el
comprobante no vale y el correlativo se consumió—, y un **4000+** es una **observación**: SUNAT
lo acepta, pero anota el defecto.

| Lo que SUNAT dice | Qué lo provocó |
|---|---|
| `3369` — rechazo: el código de establecimiento del punto de llegada está vacío | `"codigo_del_domicilio_fiscal": null` en la llegada, con destinatario con RUC. Omite la clave o manda un código real |
| `2567` — rechazo por la placa | Separadores en el número de placa |
| `2560`, `2775`, `3359`, `3443` — rechazos | Los [cinco tropiezos que cuestan una tarde](./guias-de-remision.md#cinco-tropiezos-que-cuestan-una-tarde) |
| `41xx` — observación sobre el ubigeo | El ubigeo enviado **como número**: `91201` en vez de `"091201"`. El cero inicial se pierde y el valor viaja así hasta el XML. Mándalo como cadena de 6 dígitos |

**Antes de emitir**, lee los avisos: la respuesta te dice qué va a observar o rechazar SUNAT y
qué se va a guardar distinto de como lo enviaste
→ [avisos antes de emitir](./guias-de-remision.md#avisos-antes-de-emitir).

**Si ya te la rechazaron**, la guía se corrige y se reenvía **con el mismo número**, mandando el
mismo identificador externo: no quemas un correlativo por cada rechazo
→ [corregir una guía rechazada](./guias-de-remision.md#corregir-una-guía-rechazada).

Para interpretar un código de SUNAT: [rechazos (2000-3999)](../../sunat-errores/errores-rechazo.md)
y [observaciones (4000+)](../../sunat-errores/observaciones.md), que **no** impiden la
aceptación.

## La guía corregida no cambia {#la-guia-corregida-no-cambia}

**Síntoma.** Corriges en tu sistema una guía rechazada y la reenvías por el lote. La fila vuelve
con `success: true`, la mandas a SUNAT y SUNAT la rechaza con el mismo código. Y así cada vez.

**Causa.** La reenviaste con su mismo `offline_id` y sin su `external_id`. El lote comprueba el
`offline_id` antes de leer el `data`, así que la fila vuelve con `was_duplicate: true` y el JSON
corregido no se aplica.
La guía sigue con los datos de la primera vez, y `send` manda el XML que se firmó entonces. En un
caso real, la misma guía se reenvió más de 320 veces.

Tampoco basta con cambiar los datos directamente en la base: `send` manda el XML firmado que ya
está guardado, sin volver a generarlo.

**Qué hacer.** Mira `was_duplicate`: si viene en `true`, no se corrigió nada. Desde el
2026-09-18 esa fila trae además el estado de la guía y, si está rechazada, el aviso
`GUIA_RECHAZADA_SIN_CORREGIR` con el `external_id` que falta. Desde el 2026-09-19, si la fila
traía un `external_id` y aun así no se corrigió, el aviso `CORRECCION_NO_APLICADA` dice por qué:
lo más común es que la guía siga Enviada (`03`) porque nadie consultó el ticket. Tienes dos
caminos:

- Reenvía la guía por el lote con su `external_id` dentro de `data`. Desde el 2026-09-18 vale con
  el mismo `offline_id` y la fila vuelve con `was_corrected: true`; en un servidor anterior, usa
  un `offline_id` nuevo.
- Corrígela con `POST /api/dispatch-carrier` o `POST /api/dispatches`, mandando su `external_id`.

Después, `send` y `status_ticket` →
[corregir una guía rechazada por el lote](offline/endpoints/15-sync-batch.md#corregir-una-guía-rechazada-por-el-lote).

## La ficha del cliente se vacía {#la-ficha-del-cliente-se-vacia}

:::warning Vigente — no está arreglado todavía
**Síntoma.** Después de emitir por la API, la ficha del cliente en el panel pierde ubigeo, nombre
comercial, correo, celular, condición, estado y percepción. Pasa también cuando la emisión
termina rechazada.

**Causa.** Cada emisión reescribe la ficha completa con lo que traiga
`datos_del_cliente_o_receptor`: lo que no mandas —o mandas vacío— se guarda como vacío.

**Qué hacer mientras tanto.** Manda el bloque del cliente **completo y con los valores reales**,
o limítate al tipo y número de documento y el nombre, comprobando en el panel que la ficha no
pierde datos. **Nunca mandes cadenas vacías**: en esta API `""` no significa «no tengo el dato»
→ [la cadena vacía no es lo mismo que nada](./errores-de-la-api.md#la-cadena-vacía-no-es-lo-mismo-que-nada).
:::

## La guía sale sin firmar {#la-guia-sale-sin-firmar}

**Síntoma.** Una guía vuelve por el lote con `success: true` pero con `signed: false` y un
`sign_message`. No hay PDF ni XML, y no se puede enviar a SUNAT.

**Causa.** La generación del XML, la firma y el PDF van en un bloque que **no** tumba la fila:
la guía queda emitida y su correlativo consumido aunque el archivo no se haya generado. Es
deliberado —revertir por una caída pasajera obligaría a renumerar—, y por eso `signed` existe:
antes una guía sin firmar era indistinguible de una firmada.

**Qué hacer.** **No la reenvíes por el lote**: volvería como duplicada. Hay que rehacer el
archivo y mandarla con `POST /api/dispatches/send`. Pasa a soporte el `sign_message` y la
serie-número. `signed: false` no invalida la guía.

## No sé si se emitió {#no-se-si-se-emitio}

**Síntoma.** Se cortó la conexión, o venció el tiempo de espera, y no sabes si el comprobante
quedó creado. Reintentar a ciegas puede duplicarlo.

**Qué hacer.** Manda siempre `offline_id`, y reenvía **con el mismo**: la respuesta te devuelve
el comprobante existente con `was_duplicate: true` y HTTP 200. Trátalo como un éxito, no como un
error → [idempotencia por `offline_id`](offline/endpoints/16-idempotencia.md).

Si el correlativo ya lo usó **otra** venta, es un conflicto de numeración, no un duplicado: hay
que renumerar y reemitir (HTTP 409 `DUPLICATE_DOCUMENT`; en el lote, `CONFLICT_NUMBER`).

Para comprobar si además llegó a SUNAT, el checklist está en
[qué comprobar cuando «no llegó a SUNAT»](offline/endpoints/37-envio-automatico-a-sunat.md#qué-comprobar-cuando-no-llegó-a-sunat).

:::info La fecha de emisión tiene plazo
Un comprobante rechazado por fecha es un error **permanente**: no entra en la cola de reintentos.
El cálculo real y cómo llega el error en cada endpoint, en
[plazo de la fecha de emisión](offline/endpoints/35-plazo-fecha-emision.md#cómo-llega-el-error-en-cada-endpoint).
:::

## El enlace guía ↔ comprobante no existe {#el-enlace-guia-comprobante-no-existe}

:::warning Vigente — no está arreglado todavía
**Síntoma.** Mandas `documento_relacionado` en la guía, o el bloque `guias` en el comprobante, la
respuesta es correcta… y el enlace no existe: la guía sigue apareciendo como pendiente en el
panel y se puede volver a facturar.

**Causa.** Esos campos son **solo texto** que acaba en el XML y el PDF. El enlace real en la base
de datos no se crea desde la API.

**Qué hacer mientras tanto.** No des el enlace por hecho: verifícalo en el panel, o evita el
doble facturado desde tu propio sistema.
:::

Para los errores de las referencias entre documentos —`REFERENCE_NOT_FOUND`,
`MALFORMED_REFERENCE`, `AMBIGUOUS_REFERENCE`— ve a
[documentos relacionados](./documentos-relacionados.md#errores).

---

## Qué mandar a soporte {#que-mandar-a-soporte}

Cuando el `errors.tipo` dice que no es tu payload, lo que decide si el caso se resuelve en una
hora o en tres días es lo que adjuntas. Manda esto:

- **El `offline_id`** de una fila fallida —o la serie-número si emites por `POST /api/documents`—.
  Es lo que permite encontrar tu petición en el registro del servidor.
- **El bloque `errors` completo**, tal cual. Ahí van `tipo`, `codigo_mysql`, `tabla`, `columna` o
  `restriccion`: es el dato que localiza el fallo.
- **La hora aproximada** de la llamada, con la zona horaria.
- **El `doc_type`** y el RUC de la empresa.
- **Si funcionaba antes**, cuándo dejó de funcionar. «Ayer emitía» es un dato de diagnóstico de
  primer orden: casi siempre significa que cambió el servidor, no tu payload.

No hace falta mandar el payload completo, ni el mensaje de la base de datos: el servidor no lo
devuelve a propósito —lleva tus datos y el nombre de la base del cliente— pero **sí** queda
entero en su registro, y con el `offline_id` soporte lo encuentra.

## Desde cuándo está arreglado {#desde-cuando-esta-arreglado}

No hay forma de consultar por API la versión de un servidor, así que la pregunta útil para
soporte es «¿mi instalación es posterior a esta fecha?». Todo lo de esta tabla se comporta como
el síntoma viejo en servidores anteriores.

| Desde | Qué cambió |
|---|---|
| 2026-09-02 | Las cabeceras ausentes, el JSON roto y el cuerpo vacío tienen código propio; la unidad de medida inválida es un 422 con sugerencia; la idempotencia por `offline_id` funciona |
| 2026-09-04 | Una violación de restricción nombra el campo del payload en español y lista los valores válidos, en vez de una frase genérica |
| 2026-09-05 | Fechas, moneda, serie y tipo de cambio se validan o se normalizan; un correlativo ya emitido es un 409, no un 500 |
| 2026-09-07 | Notas de crédito y débito validan lo suyo antes de emitir; `facturador_item_id` resuelve el producto por id |
| 2026-09-08 | El destino de pago en efectivo (`'cash'`) vuelve a aceptarse (regresión del 05-sep) |
| 2026-09-09 | `PROCESSING_ERROR` deja de ser el cajón de sastre; `cash_error_code` y `signed`/`sign_message` en la respuesta del lote |
| 2026-09-11 | Una guía rechazada se corrige por API con su mismo número, mandando su `external_id`; antes cada llamada se trataba como una guía nueva |
| 2026-09-15 | `DATABASE_ERROR` trae `errors.tipo` y deja de culpar al payload |
| 2026-09-16 | `codigo_del_domicilio_fiscal` en `null` ya no provoca el rechazo 3369; el código de producto SUNAT por línea llega al XML |
| 2026-09-17 | La dirección de llegada de la guía `09` deja de fallar con MySQL 1452; el ubigeo enviado como número es un 422 antes de emitir, en vez de viajar crudo al XML; nace `restriccion_no_atribuible` |
| 2026-09-18 | Una guía se corrige por el lote con su mismo `offline_id` si trae su `external_id` (`was_corrected: true`); el `was_duplicate` de una guía trae su estado y, si está rechazada, lo avisa |
| 2026-09-21 | En `POST /api/summaries`, `"codigo_tipo_proceso": 3` como número vale lo mismo que `"3"` (antes anulaba todo lo de la fecha en `01`); un tipo fuera de catálogo es 422 `INVALID_PROCESS_TYPE`, y la falta de fecha o tipo, 422 `MISSING_FIELDS` (antes 500) |

## Ver también

- [Errores de la API](./errores-de-la-api.md) — el catálogo completo de `error_code`, por código.
- [Sincronización por lotes](offline/endpoints/15-sync-batch.md) — la tabla de reintento y el
  registro en caja.
- [Guías de remisión](./guias-de-remision.md) — avisos previos, credenciales y corrección de
  rechazos.
- [Autenticación](./introduccion.md#autenticación) — el 401, el 403 por licencia y de dónde sale
  el token.
- [Guía de remisión remitente](offline/endpoints/13-guia-remision-remitente.md) — campo por
  campo, con lo que SUNAT rechaza en cada uno.
