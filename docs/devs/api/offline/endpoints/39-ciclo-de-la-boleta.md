# 39 — Ciclo de la Boleta: Resumen Diario, Anulación y CDR

> **Endpoints:**  
> `POST /api/summaries` — resumen diario (`"1"`) y resumen de anulación (`"3"`)  
> `POST /api/summaries/status` — consultar el ticket de un resumen  
> `GET /api/document_check_server/{external_id}` — estado de una boleta  
> `GET /downloads/summary/cdr/{external_id}` — el CDR, con el `external_id` **del resumen**  
> **Auth:** `Bearer {token}`. Las descargas de `/downloads/…` no lo piden.

---

## En una línea

Si la empresa tiene apagado el envío individual, una boleta no viaja sola a SUNAT: **se declara
dentro de un resumen diario, y se anula dentro de otro resumen**. El ticket, la respuesta de SUNAT
y el CDR son **del resumen**, no de la boleta. Por eso, a partir del paso 2, la consulta
(`/api/summaries/status`) y la descarga del CDR van con el `external_id` del resumen. Qué boletas
lleva cada resumen, y el estado de cada una, viene en `documents`, en la respuesta del envío y en la
de la consulta.

Las empresas nuevas se crean con el **envío individual encendido**: sus boletas salen solas al
emitirse, con CDR propio, y no pasan por el resumen diario. Esta página es para las que lo tienen
apagado. Si es tu caso el otro: [40 — Ciclo de la factura y de la boleta de envío individual](40-ciclo-de-la-factura-y-envio-individual.md).

---

## El ciclo completo

```
 sync-batch  (o POST /api/documents)
      │
      ▼
 01 Registrado
      │   POST /api/summaries          "codigo_tipo_proceso": "1"         → resumen RC-…-1 y su ticket
      ▼
 03 Enviado
      │   POST /api/summaries/status   external_id del resumen RC-…-1
      ▼
 05 Aceptado ──────────────── CDR: links.cdr del resumen RC-…-1
      │
      │   (solo si la venta se anula)
      │   POST /api/summaries          "codigo_tipo_proceso": "3" + la boleta  → resumen RC-…-2 y su ticket
      ▼
 13 Por anular   (03 si la empresa envía por un PSE o por el OSE SendFact)
      │   POST /api/summaries/status   external_id del resumen RC-…-2
      ▼
 11 Anulado ───────────────── CDR: links.cdr del resumen RC-…-2
```

| Paso | Llamada | La boleta pasa a | Qué guardar |
|---|---|---|---|
| [1. Registrar](#paso-1) | `POST /api/offline/sync-batch` | `01` Registrado | El `external_id` de la boleta |
| [2. Declarar](#paso-2) | `POST /api/summaries` con `"1"` | `03` Enviado | El `external_id` y el `ticket` **del resumen**, en cada boleta de `documents` |
| [3. Consultar](#paso-3) | `POST /api/summaries/status` | `05` Aceptado | El `links.cdr` del resumen y el estado de cada boleta de `documents` |
| [5. Anular](#paso-5) | `POST /api/summaries` con `"3"` y la boleta | `13` Por anular (`03` con PSE u OSE SendFact) | El `external_id` y el `ticket` **del resumen de anulación** |
| [6. Consultar la anulación](#paso-6) | `POST /api/summaries/status` | `11` Anulado | El `links.cdr` del resumen de anulación |

El [paso 4](#paso-4) no es una llamada: es de dónde sale el CDR. Una boleta que no se anula termina
en el paso 3.

:::info Probado de punta a punta el 2026-09-21 y el 2026-09-22
El ciclo se corrió entero contra SUNAT beta: la B001-1 entró por `sync-batch`, se declaró en el
resumen `RC-20260921-1` y se anuló en el `RC-20260921-2`. El 2026-09-22 se repitió con la lista
`documents` de las respuestas, y con una boleta registrada después de enviar el resumen. Las
respuestas de ejemplo salen de esas pruebas, con el RUC, el dominio y el `offline_id` cambiados. Los
mensajes de error que la prueba no provocó están tomados del código.
:::

---

## 1. Registrar: la boleta queda en `01` {#paso-1}

`sync-batch` registra la boleta, la firma y le genera el PDF, pero **no la declara**. Su fila trae
`id`, `number` y `external_id`, y nada del estado
([por qué](15-sync-batch.md#la-fila-de-un-comprobante-no-trae-el-estado)). Si lo preguntas:

```
GET /api/document_check_server/c50fb61c-ed0c-4bc6-b70a-df7893a7eba8
```

```json
{ "success": true, "state_type_id": "01", "file_cdr": null }
```

Con el envío individual apagado, `01` en una boleta recién sincronizada es lo esperado, no un
fallo: está válida y firmada, pendiente del resumen.

Con el envío individual encendido, la boleta sale del lote ya aceptada. Si aun así queda en `01`,
es que no salió —`send_auto` apagado, o SUNAT no respondió—, y **el resumen no la va a tomar**,
porque excluye las boletas de envío individual. Esa se destraba desde el panel →
[40 — una boleta de envío individual en `01`](40-ciclo-de-la-factura-y-envio-individual.md#factura-en-01).
La matriz completa, en [37](37-envio-automatico-a-sunat.md#matriz-completa).

---

## 2. Declarar: `POST /api/summaries` con `"1"` {#paso-2}

```
POST /api/summaries
```

```json
{
    "fecha_de_emision_de_documentos": "2026-09-21",
    "codigo_tipo_proceso": "1"
}
```

| Campo | Qué va |
|---|---|
| `fecha_de_emision_de_documentos` | La fecha de **emisión de las boletas**, en `YYYY-MM-DD`; no la del día en que envías el resumen |
| `codigo_tipo_proceso` | `"1"`: declarar |

**No se manda la lista de boletas.** El resumen se lleva todas las del grupo `02` —boletas y sus
notas de crédito y débito— emitidas en esa fecha que sigan en `01`, que no sean de envío individual
y que se hayan emitido en el entorno que la empresa tiene ahora (demo o producción), hasta 500 por
resumen.

### Response (200 OK)

```json
{
    "success": true,
    "data": {
        "external_id": "b88390b6-1755-413e-acf4-c6f905ce8181",
        "ticket": "1790027776413",
        "filename": "20123456789-RC-20260921-1",
        "date_of_reference": "2026-09-21",
        "summary_status_type_id": "1",
        "state_type_id": "03",
        "state_type_description": "Enviado",
        "documents": [
            {
                "id": 123,
                "external_id": "c50fb61c-ed0c-4bc6-b70a-df7893a7eba8",
                "offline_id": "B2C3D4E5-F6A7-8901-BCDE-F12345678901",
                "document_type_id": "03",
                "series": "B001",
                "number": 1,
                "number_full": "B001-1",
                "currency_type_id": "PEN",
                "total": "118.00",
                "state_type_id": "03",
                "state_type_description": "Enviado"
            }
        ]
    }
}
```

`external_id` y `ticket` son **del resumen**, no de ninguna boleta: son los que sirven en el
paso 3. `documents` son las boletas que llevó este resumen, que ya pasaron a `03` (Enviado).

| Campo de `data` | Qué es |
|---|---|
| `external_id`, `ticket` | Del resumen. Con cualquiera de los dos se consulta en el paso 3 |
| `filename` | `RUC-RC-AAAAMMDD-N`. La fecha del nombre es la del día del envío, no la de las boletas |
| `date_of_reference` | La fecha de emisión de las boletas que mandaste |
| `summary_status_type_id` | `"1"` si declara, `"3"` si anula |
| `state_type_id`, `state_type_description` | El estado del resumen: `03` al enviarlo |
| `documents` | Una fila por comprobante del resumen, en el orden del XML |

| Campo de cada `documents[]` | Qué es |
|---|---|
| `offline_id` | El que mandaste a `sync-batch`, tal cual, mayúsculas incluidas. `null` si la boleta no entró por `sync-batch` |
| `external_id`, `id` | Los mismos que te devolvió la fila de `sync-batch` |
| `document_type_id` | `03` boleta; `07` y `08`, notas de crédito y débito de boleta |
| `series`, `number` | `B001` y `1`: la serie y el correlativo, por separado |
| `number_full` | `B001-1`: lo que la fila de `sync-batch` llama `number` |
| `currency_type_id`, `total` | La moneda y el total declarado. `total` es texto con dos decimales |
| `state_type_id`, `state_type_description` | El estado de la boleta después de la llamada |

### Cuadrar el resumen con tu base {#cuadrar}

Recorre `documents` y, en tu tabla, marca cada boleta con el `external_id` y el `ticket` del
resumen. Búscala por `offline_id`, que lo generaste tú, o por `external_id`. De paso, compara
`total` con el tuyo: es el importe que se declaró a SUNAT. Hay un
[ejemplo en SQL Server](#desde-sql-server).

- Una boleta pendiente en tu base que **no** está en `documents` no entró en este resumen: sigue en
  `01` e irá en el siguiente. Pasa si la registraste después de la llamada, si es de envío
  individual o si su fecha de emisión es otra.
- Si emites más boletas con esa misma fecha, o eran más de 500, vuelve a llamar con la misma
  fecha: el resumen nuevo solo lleva las que sigan en `01`, y su `documents` te dice cuáles.
- Una boleta que ya va en un resumen no entra en otro, salvo que SUNAT rechace el primero o que
  alguien lo elimine desde el panel mientras sigue en `03`: eso devuelve sus boletas a `01`, y si
  SUNAT ya lo había recibido, se declaran dos veces.
- **No lances dos resúmenes de la misma fecha a la vez**, por ejemplo tu integración a la misma
  hora que la [tarea programada](#tareas-programadas), o un reintento mientras el primero no ha
  respondido. La lista se arma al llegar la llamada y las boletas pasan a `03` cuando SUNAT
  responde: en ese intervalo, otra llamada se lleva las mismas. Si tu llamada se cortó por tiempo,
  antes de repetirla consulta una de las boletas. Si ya está en `03`, el resumen salió.

Lo más simple sigue siendo mandar el resumen **cuando el día ya cerró**, de madrugada del día
siguiente como la [tarea programada](#tareas-programadas). Así una sola llamada lleva todas las
boletas de esa fecha, si no pasan de 500.

:::note En un servidor anterior al 2026-09-22
La respuesta solo trae `external_id` y `ticket`: ni `documents` ni los demás campos. Para saber qué
boletas llevó, consulta cada una con `document_check_server`: las que pasaron a `03` van en este
resumen. Al actualizar el servidor llega la lista.
:::

Si esa fecha no tiene nada pendiente, responde **HTTP 500**:

```json
{ "success": false, "message": "No se encontraron documentos con fecha de emisión 2026-09-21." }
```

No es una caída: esa fecha no tiene nada que el resumen pueda llevar. Pasa si ya se declaró
todo, si la fecha no es la de emisión, si las boletas en `01` son de envío individual (ver el
[paso 1](#paso-1)) o si se emitieron en demo. No lo reintentes igual: mira primero cuál es.

---

## 3. Consultar el resumen: la boleta pasa a `05` {#paso-3}

```
POST /api/summaries/status
```

```json
{ "external_id": "b88390b6-1755-413e-acf4-c6f905ce8181" }
```

O `{ "ticket": "1790027776413" }`: basta uno de los dos. **Es el `external_id` del resumen.** Con
el de la boleta responde `El código externo … es inválido, no se encontró resumen relacionado`.

Consulta con el `external_id`: si la empresa envía por un PSE u OSE, `data.ticket` puede volver
`null` en el paso 2, y `{"ticket": null}` haría que el servidor tomara el primer resumen sin
ticket, que puede no ser el tuyo.

### Response (200 OK) — aceptado

```json
{
    "success": true,
    "data": {
        "external_id": "b88390b6-1755-413e-acf4-c6f905ce8181",
        "ticket": "1790027776413",
        "filename": "20123456789-RC-20260921-1",
        "date_of_reference": "2026-09-21",
        "summary_status_type_id": "1",
        "state_type_id": "05",
        "state_type_description": "Aceptado",
        "documents": [
            {
                "id": 123,
                "external_id": "c50fb61c-ed0c-4bc6-b70a-df7893a7eba8",
                "offline_id": "B2C3D4E5-F6A7-8901-BCDE-F12345678901",
                "document_type_id": "03",
                "series": "B001",
                "number": 1,
                "number_full": "B001-1",
                "currency_type_id": "PEN",
                "total": "118.00",
                "state_type_id": "05",
                "state_type_description": "Aceptado"
            }
        ]
    },
    "links": {
        "xml": "https://tu-dominio.com/downloads/summary/xml/b88390b6-1755-413e-acf4-c6f905ce8181",
        "cdr": "https://tu-dominio.com/downloads/summary/cdr/b88390b6-1755-413e-acf4-c6f905ce8181"
    },
    "response": {
        "sent": true,
        "code": "0",
        "description": "El Resumen diario RC-20260921-1, ha sido aceptado",
        "notes": [],
        "is_accepted": true,
        "status_code": 0
    }
}
```

`response.code: "0"` es la aceptación: las boletas del resumen quedan en `05` (Aceptado), y
`documents` ya las trae así. Con esta respuesta actualizas tu tabla sin consultar boleta a boleta.
`data` tiene los mismos campos que en el [paso 2](#paso-2); `documents` sale **después** de la
consulta, con el estado en que quedó cada boleta. `document_check_server` también lo devuelve así.

:::tip Solo cambian las boletas de `documents`
La lista quedó fija al enviar el resumen. Una boleta que registraste después, aunque sea de la
misma fecha, no cambia al consultarlo: sigue en `01` y va en el siguiente resumen.

Probado el 2026-09-22 contra SUNAT beta: la BB01-8 se registró después de enviar el
`RC-20260922-1`. Al consultarlo, la BB01-7, que era la que llevaba, pasó a `05`, y la BB01-8 siguió
en `01` hasta que la declaró el `RC-20260922-2`.
:::

### Qué puede volver

| Respuesta | Qué significa | Qué hacer |
|---|---|---|
| `response.code: "0"` | Aceptado. Las boletas de `documents` pasan a `05` | Guarda `links.cdr`, actualiza tus boletas con `documents` y no vuelvas a consultar este resumen |
| HTTP 500 `Code: 98; Description: El procesamiento del comprobante aún no ha terminado` | SUNAT aún procesa el ticket (empresa que envía directo a SUNAT o por un OSE) | **Consulta otra vez en unos minutos** |
| HTTP 200 **sin** `response.code`, con `response.description` | Lo mismo en una empresa que envía por un PSE: todavía no hay CDR | Consulta otra vez más tarde |
| HTTP 500 `Undefined variable $cdrResponse` | Lo mismo con el OSE SendFact: todavía no hay CDR. Es un fallo conocido del servidor | Trátalo como el 98 |
| `response.code` distinto de `"0"`, con `status_code: 99` | Envío directo a SUNAT: SUNAT **rechazó** el resumen. El resumen queda en `09` y sus boletas vuelven a `01`, y así salen en `documents` | Lee `response.description`, corrige y declara otra vez: un `POST /api/summaries` con la misma fecha las recoge |
| `response.code` distinto de `"0"`, con `status_code` igual a ese código | Envío por PSE: SUNAT rechazó, pero **nada cambia de estado**: el resumen y sus boletas siguen en `03`, e `is_accepted` sale `true` igual | No uses `is_accepted`. Un resumen nuevo no las recoge porque no están en `01`: pide a soporte que las destrabe |
| HTTP 500 `Code: 0127; Description: El ticket no existe` | SUNAT ya no reconoce el ticket. En beta pasó al volver a consultar un resumen que ya había respondido | Si ya tienes el `0` guardado, ignóralo: la consulta falla antes de tocar las boletas |
| HTTP 500 con otro `Code:` entre `0100` y `1999`, o `Code: HTTP` | SUNAT no pudo atender, o no hubo conexión | Si dice «El sistema no puede responder su solicitud» (0100, 0109, 0130–0138, 02xx) o es `Code: HTTP`, consulta más tarde. Si es de usuario o clave (0101–0113), corrígelo: reintentar no cambia nada |

**Regla corta: solo `response.code === "0"` es aceptación.** Lo demás, o se consulta más tarde, o
se corrige.

:::caution No vuelvas a consultar un resumen ya aceptado
Si SUNAT vuelve a contestar con `0`, el sistema pone otra vez en `05` **todas** las boletas del
resumen, estén como estén: una que anulaste después ([paso 5](#paso-5)) vuelve a `05` aunque en
SUNAT siga anulada. En la prueba en beta, la reconsulta respondió `0127` y la boleta siguió en
`11`; no cuentes con ninguna de las dos respuestas. Consulta hasta tener el `0` y guarda el
resultado: la tarea programada ya trabaja así, solo consulta resúmenes que siguen en `03`.
:::

---

## 4. El CDR es el del resumen, no el de la boleta {#paso-4}

Con `response.code: "0"`, `links.cdr` descarga un ZIP, `R-20123456789-RC-20260921-1.zip`, cuyo XML
dice `El Resumen diario RC-20260921-1, ha sido aceptado`. Es la constancia de **todas** las boletas
de ese resumen. La fecha del nombre es la del día en que **enviaste** el resumen, no la de emisión
de las boletas: si lo mandas de madrugada del día siguiente, se llama `RC-20260922-1`. Antes del
`0` el enlace viene igual, pero todavía no hay ZIP.

La boleta no tiene CDR propio, y ninguna ruta de la boleta lo devuelve:

| Lo que pides | Qué devuelve |
|---|---|
| `GET /downloads/summary/cdr/{external_id}` **del resumen** | El ZIP del CDR |
| `GET /downloads/document/cdr/{external_id}` **de la boleta** | **HTTP 500**: no existe ese archivo. Con `Accept: application/json` el mensaje es `Unable to retrieve the file_size for file at location: cdr/R-20123456789-03-B001-1.zip.`; sin esa cabecera, una página de error HTML |
| `GET /api/document_check_server/{external_id}` de la boleta | `file_cdr: null`, también en `05`: solo trae el CDR de las facturas |
| `links.cdr` de `POST /api/documents` | `""`. La fila de `sync-batch` ni siquiera trae `links` |

Por eso, en tu base, **el CDR de una boleta es el del resumen que la declaró**: guarda con cada
boleta el `external_id` de su resumen. El `documents` de la respuesta te dice qué boletas lleva
cada resumen ([cuadrar](#cuadrar)). Si luego se anula, tiene dos: el del resumen que la declaró y
el del resumen que la anuló.

Las URL de `links` no llevan token: con el `external_id` basta para descargarlas.

La boleta de envío individual es la excepción: esa sí tiene CDR propio, en
`/downloads/document/cdr/{external_id}` con el `external_id` de la boleta.
`document_check_server` tampoco se lo devuelve: su `file_cdr` solo se llena en las facturas →
[40](40-ciclo-de-la-factura-y-envio-individual.md#cdr-propio).

---

## 5. Anular: `POST /api/summaries` con `"3"` {#paso-5}

Una boleta no se anula con comunicación de baja —`POST /api/voided` es solo para facturas y sus
notas—: se anula con **otro resumen**, de tipo `"3"`, que esta vez **sí** lleva la lista.

```
POST /api/summaries
```

```json
{
    "fecha_de_emision_de_documentos": "2026-09-21",
    "codigo_tipo_proceso": "3",
    "documentos": [
        {
            "external_id": "c50fb61c-ed0c-4bc6-b70a-df7893a7eba8",
            "motivo_anulacion": "Venta anulada a pedido del cliente"
        }
    ]
}
```

| Campo | Qué va |
|---|---|
| `fecha_de_emision_de_documentos` | La fecha de **emisión del comprobante** que anulas, en `YYYY-MM-DD`. Todos los del array tienen que ser de esa fecha |
| `codigo_tipo_proceso` | `"3"`: anular. **Como texto, con comillas** (ver el aviso de abajo) |
| `documentos[].external_id` | El `external_id` **de la boleta**, el que devolvió su fila de `sync-batch` |
| `documentos[].motivo_anulacion` | Opcional. Se guarda con la anulación para tu registro, pero **no viaja a SUNAT**: el resumen no tiene campo de motivo |

### Response (200 OK)

```json
{
    "success": true,
    "data": {
        "external_id": "ecc708e0-b6e5-4b14-a938-3e8c4bee7f53",
        "ticket": "1790027810410",
        "filename": "20123456789-RC-20260921-2",
        "date_of_reference": "2026-09-21",
        "summary_status_type_id": "3",
        "state_type_id": "03",
        "state_type_description": "Enviado",
        "documents": [
            {
                "id": 123,
                "external_id": "c50fb61c-ed0c-4bc6-b70a-df7893a7eba8",
                "offline_id": "B2C3D4E5-F6A7-8901-BCDE-F12345678901",
                "document_type_id": "03",
                "series": "B001",
                "number": 1,
                "number_full": "B001-1",
                "currency_type_id": "PEN",
                "total": "118.00",
                "state_type_id": "13",
                "state_type_description": "Por anular"
            }
        ]
    }
}
```

Es un resumen nuevo (`RC-20260921-2`), con su propio `external_id` y su propio ticket;
`summary_status_type_id: "3"` lo marca como anulación. `documents` trae las boletas que anula, que
son las que mandaste. La boleta pasa a `13` (Por anular) si la empresa envía directo a SUNAT o por
un OSE, o a `03` (Enviado) si envía por un PSE o por el OSE SendFact. En los dos casos **todavía no
está anulada**: falta el [paso 6](#paso-6).

- **Anula solo boletas en `05`.** El panel solo ofrece «Anular» en una boleta aceptada; la API no
  lo comprueba y acepta cualquier boleta de esa fecha. Si la venta se anuló antes de declararla,
  declárala primero (pasos 2 y 3) y después anúlala.
- Varias boletas de la **misma fecha** van en un solo resumen de anulación; las de fechas
  distintas, en uno por fecha.
- Una nota de crédito o débito de boleta se anula igual: con su `external_id` y con **su** fecha de
  emisión, no la de la boleta que modifica.
- Una boleta que se envió sola (envío individual) también se anula así, no por `/api/voided`.

:::danger `codigo_tipo_proceso` va como texto: `"3"`, nunca `3`
En un servidor **anterior al 2026-09-21**, con el número `3` sin comillas el servidor **no lee
`documentos`**: arma un resumen de anulación con **todo lo de esa fecha que siga en `01`** —boletas
y notas de boleta— y lo envía. Responde `success: true` con su ticket, como si todo hubiera ido
bien.

Probado ese día: se pidió anular la B001-1 con `"codigo_tipo_proceso": 3`, y el resumen
`RC-20260921-3` anuló la **B001-2**, que estaba en `01` y nadie había pedido tocar. SUNAT lo aceptó.
Si esa fecha no tiene nada en `01`, la llamada falla con
`No se encontraron documentos con fecha de emisión …` y parece un problema de fechas. No lo es: es
el número. En SQL Server pasa en cuanto el valor sale de una columna `INT` o de un literal sin
comillas → [desde SQL Server](#desde-sql-server).

**Desde el 2026-09-21** el servidor trata `3` igual que `"3"`, y un valor fuera del catálogo
(`"03"`, `"4"`…) es un 422 `INVALID_PROCESS_TYPE`. Como no puedes saber por la API qué versión
tiene tu servidor, mándalo siempre como texto: funciona en las dos.
:::

### Errores de este paso

Todos son `422` y ninguno se reintenta: no se envió nada a SUNAT.

| `error_code` | Mensaje | Causa |
|---|---|---|
| `NO_DOCUMENTS` | `No se enviaron documentos para la anulación.` | Falta `documentos`, o va vacío |
| `AFFECTED_DOCUMENT_NOT_FOUND` | `El código externo … no fue encontrado o la fecha indica no corresponde al documento.` | La fecha no es la de emisión de ese comprobante, el `external_id` no existe en esta empresa, o es de una factura o de una nota de factura (esas se anulan con `POST /api/voided`) |
| `MISSING_FIELDS` | `Faltan campos obligatorios: …` | Falta la fecha o el tipo. Desde el 2026-09-21; antes, 500 `Undefined array key` |
| `INVALID_PROCESS_TYPE` | `'codigo_tipo_proceso' llegó como … Envía "1" … o "3" …` | Un tipo fuera del catálogo. Desde el 2026-09-21 |

---

## 6. Consultar la anulación: la boleta pasa a `11` {#paso-6}

La misma llamada del paso 3, con el `external_id` o el `ticket` **del resumen de anulación**:

```
POST /api/summaries/status
```

```json
{ "ticket": "1790027810410" }
```

### Response (200 OK) — aceptada

```json
{
    "success": true,
    "data": {
        "external_id": "ecc708e0-b6e5-4b14-a938-3e8c4bee7f53",
        "ticket": "1790027810410",
        "filename": "20123456789-RC-20260921-2",
        "date_of_reference": "2026-09-21",
        "summary_status_type_id": "3",
        "state_type_id": "05",
        "state_type_description": "Aceptado",
        "documents": [
            {
                "id": 123,
                "external_id": "c50fb61c-ed0c-4bc6-b70a-df7893a7eba8",
                "offline_id": "B2C3D4E5-F6A7-8901-BCDE-F12345678901",
                "document_type_id": "03",
                "series": "B001",
                "number": 1,
                "number_full": "B001-1",
                "currency_type_id": "PEN",
                "total": "118.00",
                "state_type_id": "11",
                "state_type_description": "Anulado"
            }
        ]
    },
    "links": {
        "xml": "https://tu-dominio.com/downloads/summary/xml/ecc708e0-b6e5-4b14-a938-3e8c4bee7f53",
        "cdr": "https://tu-dominio.com/downloads/summary/cdr/ecc708e0-b6e5-4b14-a938-3e8c4bee7f53"
    },
    "response": {
        "sent": true,
        "code": "0",
        "description": "El Resumen diario RC-20260921-2, ha sido aceptado",
        "notes": [],
        "is_accepted": true,
        "status_code": 0
    }
}
```

Con `code: "0"` las boletas del resumen pasan a `11` (Anulado), como ya las trae `documents`, y
`links.cdr` es **el CDR de la anulación**. El `state_type_id` de `data` es el del resumen (`05`,
aceptado); el de cada boleta está en `documents`. SUNAT también lo llama «Resumen diario»: lo que lo
hace una anulación es el `"3"` que enviaste, que vuelve en `summary_status_type_id`, no el texto de
la respuesta.

Las respuestas posibles son las del [paso 3](#qué-puede-volver), con una diferencia si SUNAT
**rechaza** la anulación y la empresa envía directo a SUNAT: la boleta no vuelve a `05` sino a
**`01`**, aunque para SUNAT siga aceptada. No la dejes así, porque el siguiente resumen diario de
esa fecha la declararía otra vez: corrige lo que diga `response.description` y repite el paso 5.

:::warning Nada consulta la anulación por ti
La tarea que consulta resúmenes solo mira los de tipo `"1"`, y «Consultar las comunicaciones de
baja» solo mira las bajas de facturas. Un resumen de anulación que nadie consulta deja la boleta en
`13` para siempre (en `03` si la empresa envía por un PSE o por el OSE SendFact). Este paso lo haces
tú: por la API, o en el panel desde *Comprobantes pendientes → Anulaciones*.
:::

---

## Lo que hace solo el servidor: las tareas programadas {#tareas-programadas}

Los pasos 2 y 3 pueden correr sin tu integración, con dos tareas del panel, en
*Tareas programadas* (`/tasks`):

| Tarea en pantalla | Hace | Cuándo |
|---|---|---|
| Enviar el resumen diario de boletas | El paso 2, con cada fecha que tenga boletas en `01` | De madrugada |
| Consultar el resultado del resumen diario | El paso 3, con los resúmenes `"1"` que siguen en `03` | Dos horas después |

Forman parte de la configuración recomendada, que se crea sola al dar de alta la empresa; si a la
tuya le faltan, esa pantalla lo avisa y ofrece *Aplicar configuración recomendada*. Solo corren con
el cron de la empresa encendido. Si están activas, tu integración no necesita los pasos 2 y 3: le
basta con leer el estado de cada boleta al día siguiente. Si además los llamas tú, no se pisan,
porque cada resumen solo lleva lo que siga en `01`, siempre que no llames **a la misma hora** que la
tarea ([por qué](#cuadrar)).

La anulación, pasos 5 y 6, **no** la hace ninguna tarea. Si a tu empresa le faltan las dos del
resumen, *Aplicar configuración recomendada* las crea con su hora; el alta a mano está en
[envío de boletas automático](../../../../guias-adicionales/tareas-programadas/envio-boletas-automatico.md).

Cada noche la tarea hace una llamada por fecha: con más de 500 boletas en una fecha, el resto sale
la noche siguiente, o puedes llamar tú otra vez con la misma fecha.

---

## Desde el panel

Todo el ciclo tiene su botón, por si hay que revisarlo o destrabarlo a mano:

- **Declarar y consultar:** *Comprobantes pendientes → Resúmenes* (`/summaries`). *Nuevo* elige la
  fecha y busca las boletas pendientes; *Consultar* es el paso 3. Desde ahí se descargan el XML y,
  cuando ya hay respuesta, el CDR de cada resumen. Paso a paso, con capturas (en versiones
  anteriores del menú la ruta era *Ventas → Resúmenes y Anulaciones*):
  [si mis boletas no se enviaron](../../../../guias-adicionales/Errores/Pasos-a-realizar-si-mis-boletas-no-se-enviaron.md).
- **Anular:** en el listado de comprobantes, la opción *Anular* de una boleta aceptada crea el
  resumen de anulación. Ese resumen no sale en *Resúmenes*: está en *Comprobantes pendientes →
  Anulaciones*, y el paso 6 es el botón *Enviar Baja* («Completar anulación») de su fila. El botón
  *Consultar documentos* de esa pantalla solo revisa las bajas de facturas.

---

## Desde SQL Server {#desde-sql-server}

Las llamadas son las mismas que ya haces con `sync-batch`; cambian la URL y el cuerpo. Lo que hay
que cuidar es que **`codigo_tipo_proceso` salga entre comillas** y que las fechas salgan en
`YYYY-MM-DD`: escríbelos como literal de texto, nunca desde una columna numérica.

```sql
-- Paso 2 — declarar las boletas de una fecha.  URL: …/api/summaries
DECLARE @Body NVARCHAR(MAX) = (
    SELECT CONVERT(CHAR(10), @FechaEmision, 23) AS fecha_de_emision_de_documentos,  -- AAAA-MM-DD
           '1'                                  AS codigo_tipo_proceso               -- texto
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
);

-- Paso 5 — anular una boleta.  URL: …/api/summaries
SET @Body = (
    SELECT CONVERT(CHAR(10), @FechaEmision, 23) AS fecha_de_emision_de_documentos,  -- la de la boleta
           '3'                                  AS codigo_tipo_proceso,              -- texto: "3", no 3
           (SELECT LOWER(@ExternalIdBoleta) AS external_id,
                   @Motivo                  AS motivo_anulacion
            FOR JSON PATH)                      AS documentos
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
);

-- Pasos 3 y 6 — consultar un resumen.  URL: …/api/summaries/status
SET @Body = (SELECT @ExternalIdResumen AS external_id FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
```

Al leer las respuestas:

```sql
-- Pasos 2 y 5: el resumen. Guarda estos dos con cada boleta de documents.
SELECT JSON_VALUE(@Resp, '$.data.external_id') AS external_id_resumen,
       JSON_VALUE(@Resp, '$.data.ticket')      AS ticket;

-- Pasos 3 y 6: aceptado solo si response.code = '0'; el CDR está en links.cdr.
SELECT JSON_VALUE(@Resp, '$.response.code')        AS codigo_sunat,
       JSON_VALUE(@Resp, '$.response.description') AS descripcion,
       JSON_VALUE(@Resp, '$.links.cdr')            AS url_cdr,
       JSON_VALUE(@Resp, '$.message')              AS error;  -- 'Code: 98; …' = consulta más tarde

-- Pasos 2, 3, 5 y 6: las boletas del resumen, una fila por boleta y con su estado.
SELECT d.*
FROM OPENJSON(@Resp, '$.data.documents')
WITH (
    id               INT           '$.id',
    external_id      VARCHAR(36)   '$.external_id',
    offline_id       VARCHAR(36)   '$.offline_id',
    document_type_id CHAR(2)       '$.document_type_id',
    series           VARCHAR(4)    '$.series',
    number           INT           '$.number',
    number_full      VARCHAR(20)   '$.number_full',
    total            DECIMAL(12,2) '$.total',
    state_type_id    CHAR(2)       '$.state_type_id'
) AS d;
```

Si la consulta falla, las tres primeras columnas salen en `NULL` y el motivo viene en `message`:
con `Code: 98` vuelves a consultar en unos minutos; con los demás, mira la tabla del
[paso 3](#qué-puede-volver). En ese caso no viene `documents`: las boletas no cambiaron.

Para [cuadrar](#cuadrar) tu tabla con la respuesta del paso 2 o del 3, cruza por `offline_id`. Los
nombres de tabla y columnas de este ejemplo son inventados; pon los tuyos:

```sql
UPDATE b
SET    b.EXTERNAL_ID_RESUMEN = JSON_VALUE(@Resp, '$.data.external_id'),
       b.TICKET_RESUMEN      = JSON_VALUE(@Resp, '$.data.ticket'),
       b.ESTADO_SUNAT        = d.state_type_id      -- 03 al enviar; 05 (o 01) al consultar
FROM   TU_TABLA_BOLETAS AS b
JOIN   OPENJSON(@Resp, '$.data.documents')
       WITH (offline_id VARCHAR(36), state_type_id CHAR(2)) AS d
       ON d.offline_id = b.OFFLINE_ID;
-- Una boleta que no entró por sync-batch trae offline_id null: crúzala por external_id.
-- En los pasos 5 y 6 guarda el resumen en otra columna: el que la declaró sigue valiendo.
```

---

## Qué guardar por cada boleta

| Campo | De dónde sale |
|---|---|
| `external_id` de la boleta | La fila de `sync-batch` |
| `state_type_id` | `documents[].state_type_id` de las respuestas de los pasos 2, 3, 5 y 6, o `GET /api/document_check_server/{external_id}`: `01` → `03` → `05`, y si se anula, `13` → `11` (`03` → `11` si la empresa envía por un PSE o por el OSE SendFact) |
| `external_id` y `ticket` del resumen que la declaró | La respuesta del paso 2, en cada boleta de su `documents` |
| CDR de la declaración | `links.cdr` del paso 3 |
| `external_id` y `ticket` del resumen que la anuló | La respuesta del paso 5, en cada boleta de su `documents` |
| CDR de la anulación | `links.cdr` del paso 6 |

---

## Errores de `/api/summaries/status` y del resumen diario

| Llamada | HTTP | Mensaje | Causa | ¿Reintentar? |
|---|---|---|---|---|
| `status` | 500 | `Es requerido el código externo o ticket` | El cuerpo no trae ni `external_id` ni `ticket` | No |
| `status` | 500 | `El código externo … es inválido, no se encontró resumen relacionado` | Casi siempre: mandaste el `external_id` de la **boleta** | No |
| `status` | 500 | `El ticket … es inválido, no se encontró resumen relacionado` | Ticket mal copiado o de otra empresa | No |
| `status` | 500 | `Code: 98; Description: El procesamiento del comprobante aún no ha terminado` | SUNAT aún procesa | **Sí**, en unos minutos |
| `status` | 500 | `Code: 0127; Description: El ticket no existe` | SUNAT ya no reconoce el ticket; en beta, al reconsultar un resumen que ya había respondido | No. Si ya tienes el `0`, ignóralo |
| `summaries` `"1"` | 500 | `No se encontraron documentos con fecha de emisión …` | Nada que declarar en esa fecha: ver el [paso 2](#paso-2) | No |
| `summaries` | 500 | `Code: 01xx`/`02xx`, `Code: HTTP` o `PSE. SEND - Code: …` | SUNAT o el PSE no pudieron atender el resumen. No se guarda nada y las boletas siguen en `01` | **Sí**, con la misma fecha |
| `summaries` | 500 | `Code: 2513` o `Code: 2920` — *Dato no cumple con formato de acuerdo al tipo de documento* | SUNAT **rechazó el resumen entero** porque uno de los comprobantes de esa fecha está mal armado, y no dice cuál. Casi siempre es una nota: su `documento_afectado.codigo_tipo_documento` no es `"03"` (p. ej. `"B3"`), o su serie no empieza con `B`. Desde el 2026-09-24 esas notas no se pueden emitir ([nota de crédito](10-nota-credito.md#documento-afectado)) | **No**: da el mismo error cada vez. Una nota anterior a esa fecha hay que retirarla (soporte) y reemitirla. Para declarar ya las boletas, crea el resumen desde el panel y quita la nota de la lista |
| `summaries` | 422 | `MISSING_FIELDS` / `INVALID_PROCESS_TYPE` | Falta la fecha o el tipo, o el tipo no es del catálogo. Desde el 2026-09-21; antes, 500 `Undefined array key "…"` | No |
| `summaries` | 400 | `MISSING_CONTENT_TYPE` / `EMPTY_BODY` / `INVALID_JSON` | Falta `Content-Type: application/json`, o el cuerpo no llegó o no es JSON | No, corrige |

Los errores de la anulación están en [su paso](#errores-de-este-paso).

Ver también [40 — Ciclo de la factura y de la boleta de envío individual](40-ciclo-de-la-factura-y-envio-individual.md),
[15 — Sync Batch](15-sync-batch.md),
[26 — Consultar el estado de un comprobante](26-envio-diferido-update-estado.md#3-consultar-el-estado-de-un-comprobante)
y [37 — Envío automático a SUNAT](37-envio-automatico-a-sunat.md).
