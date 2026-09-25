# 41 — Anular una Nota de Crédito o de Débito

> **Endpoints:**  
> `POST /api/voided` y `POST /api/voided/status` — nota de una factura (comunicación de baja)  
> `POST /api/summaries` con `"3"` y `POST /api/summaries/status` — nota de una boleta (resumen de anulación)  
> `GET /api/document_check_server/{external_id}` y `POST /api/documents/status` — el estado de la nota  
> **Auth:** `Bearer {token}`. Las descargas de `/downloads/…` no lo piden.

---

## En una línea

Una nota se anula **igual que el comprobante al que modifica**: la de una factura, con una
**comunicación de baja** (`/api/voided`); la de una boleta, con un **resumen de anulación**
(`/api/summaries` con `"3"`), aunque se haya enviado sola. En los dos casos van el `external_id`
**de la nota** y **su** fecha de emisión, no los de la factura o boleta. Pedir la anulación deja la
nota en `13` (Por anular); pasa a `11` (Anulado) cuando consultas el ticket y SUNAT responde
`code: "0"`.

Da igual que sea de crédito (`07`) o de débito (`08`): las dos se anulan igual.

:::info Probado de punta a punta el 2026-09-25
Contra SUNAT beta. Notas de la factura FF01-6, del 24: la FC01-1 y la FD01-1, emitidas el 25, se
anularon juntas con la baja `RA-20260925-1`. Notas de la boleta BB01-15: la BC01-2 y la BD01-2, del
24, se declararon en el `RC-20260925-4` y se anularon juntas con el resumen `RC-20260925-5`. Desde el
panel se repitió con la FC01-3 (`RA-20260925-3`) y la BD01-3 (`RC-20260925-7`).

Con el cambio del mismo día, se repitió: la FC01-4, en `01`, dio 422 `DOCUMENT_NOT_VOIDABLE`; la
FC01-5 y la FD01-3 se anularon con `RA-20260925-4`, y la BC01-3 y la BD01-4 con `RC-20260925-9`, con un
solo movimiento de stock cada una. Volver a consultar las dos anulaciones no cambió nada.
:::

---

## Qué camino toma cada nota {#camino}

| La nota modifica… | Grupo | Anular | Fecha | Consultar | La consulta una tarea programada |
|---|---|---|---|---|---|
| Una factura (serie `F…`) | `01` | `POST /api/voided` | `dd-mm-aaaa` | `POST /api/voided/status` | Sí: «Consultar las comunicaciones de baja» |
| Una boleta (serie `B…`) | `02` | `POST /api/summaries` con `"3"` | `aaaa-mm-dd` | `POST /api/summaries/status` | No |

Lo decide el documento afectado, no la nota: la nota hereda el grupo de la factura o boleta que
modifica ([cómo](10-nota-credito.md#como-llega-a-sunat)). Por el camino equivocado la API responde
422 `AFFECTED_DOCUMENT_NOT_FOUND` y no envía nada.

Una misma llamada puede llevar varias notas, y también facturas o boletas, siempre que todas sean
del mismo grupo y tengan **la misma fecha de emisión**. Una factura y su nota solo pueden ir en la
misma llamada si se emitieron el mismo día.

---

## Antes de anular {#antes}

- **La nota tiene que estar aceptada (`05`) u observada (`07`).** Si no, la API responde 422
  `DOCUMENT_NOT_VOIDABLE` antes de enviar nada, con el estado en que está y qué hacer
  ([ejemplo](#no-anulable)). El panel solo ofrece *Anular* en `05`, y desde el 2026-09-25 también lo
  comprueba en el servidor.
- **Plazo.** El panel no envía la anulación de un comprobante emitido hace más de 7 días
  (*Configuración → Empresa → Avanzado*, pestaña *Contable*: «Días de plazo de envío de la
  comunicación de baja»). La API no aplica ese plazo: queda a lo que responda SUNAT al consultar el
  ticket.
- **La fecha es la de la nota.** Con la de la factura, la FC01-1 (del 25) dio 422
  `AFFECTED_DOCUMENT_NOT_FOUND` al mandarla con el `24-09-2026` de la FF01-6.
- **Anular la factura o la boleta no anula sus notas.** Cada comprobante se da de baja por su cuenta.

### Una nota que no se puede anular {#no-anulable}

```json
{
    "success": false,
    "message": "No se puede anular el comprobante FC01-4: está Registrado: todavía no llegó a SUNAT. Envíalo (una boleta, en su resumen diario) y anúlalo cuando esté aceptado. Solo se anula un comprobante Aceptado (05) u Observado (07).",
    "error_code": "DOCUMENT_NOT_VOIDABLE",
    "errors": {
        "external_id": "f7dd957f-1aa1-4490-a81f-3aeae3397ccb",
        "numero": "FC01-4",
        "estado": "01",
        "valores_validos": ["05", "07"]
    }
}
```

:::info Cambio de comportamiento (2026-09-25)
Antes la API aceptaba una nota en cualquier estado. La FC01-2, que nunca se había enviado (`01`), se
dio de baja sin error y SUNAT beta aceptó esa baja; en producción, SUNAT la rechaza al consultar el
ticket. Con una nota en `11` se podía pedir otra baja de algo ya anulado.
:::

---

## 1. Nota de una factura: `POST /api/voided` {#nota-de-factura}

```
POST /api/voided
```

```json
{
    "fecha_de_emision_de_documentos": "25-09-2026",
    "documentos": [
        { "external_id": "236ef1fe-9837-45ed-b5d5-41215bc79e42", "motivo_anulacion": "Nota de credito emitida por error" },
        { "external_id": "481af678-154e-4a9a-acab-0851bab35e59", "motivo_anulacion": "Nota de debito emitida por error" }
    ]
}
```

| Campo | Qué va |
|---|---|
| `fecha_de_emision_de_documentos` | La fecha de emisión **de las notas**, en `dd-mm-aaaa`: al revés que en `/api/summaries` |
| `documentos[].external_id` | El `external_id` **de la nota**, el que devolvió su emisión |
| `documentos[].motivo_anulacion` | **Obligatorio.** Viaja a SUNAT en la baja (`VoidReasonDescription`). Sin él, la llamada falla con un 500 y no se envía nada |

### Response (200 OK)

```json
{
    "success": true,
    "data": {
        "external_id": "639ab380-d7d4-49dd-b24f-54d0fcc4198a",
        "ticket": "1790346580134"
    }
}
```

Es el `external_id` **de la baja**, no el de la nota: guárdalo con cada nota que lleva. Las notas
pasan a `13` (Por anular), o a `03` (Enviado) si la empresa envía por un PSE o por el OSE SendFact.
En ese estado `GET /api/document_check_server/{external_id}` de la nota responde
`"state_type_id": "13"` y `"file_cdr": null`.

La baja lleva una línea por nota, con su tipo (`07` o `08`), su serie, su número y el motivo.

### Consultar la baja: `POST /api/voided/status` {#consultar-baja}

Con el `external_id` o con el `ticket` de la baja:

```json
{ "external_id": "639ab380-d7d4-49dd-b24f-54d0fcc4198a" }
```

```json
{
    "success": true,
    "data": {
        "filename": "20123456789-RA-20260925-1",
        "external_id": "639ab380-d7d4-49dd-b24f-54d0fcc4198a"
    },
    "links": {
        "xml": "https://tu-dominio.com/downloads/voided/xml/639ab380-d7d4-49dd-b24f-54d0fcc4198a",
        "cdr": "https://tu-dominio.com/downloads/voided/cdr/639ab380-d7d4-49dd-b24f-54d0fcc4198a"
    },
    "response": {
        "sent": true,
        "code": "0",
        "description": "La Comunicacion de baja RA-20260925-1, ha sido aceptada",
        "notes": [],
        "is_accepted": true,
        "status_code": 0
    }
}
```

Con `code: "0"` las notas pasan a `11` (Anulado). Esta respuesta, a diferencia de la de
`/api/summaries/status`, **no** trae la lista de comprobantes: el estado de cada nota se pregunta
con `GET /api/document_check_server/{external_id}` o con `POST /api/documents/status`
(`"status_id": "11"`, `"status": "Anulado"`).

`links.cdr` es el CDR **de la baja** (`R-20123456789-RA-20260925-1.zip`). La nota conserva el suyo,
el de su aceptación, en `/downloads/document/cdr/{external_id}`, que se sigue descargando después de
anulada.

Si SUNAT todavía procesa el ticket, la consulta responde HTTP 500 con
`Code: 98; Description: El procesamiento del comprobante aún no ha terminado`: consulta otra vez en
unos minutos. El resto de respuestas posibles son las de un resumen
([39 — Qué puede volver](39-ciclo-de-la-boleta.md#qué-puede-volver)). Si SUNAT rechaza,
[ver abajo](#rechazo).

Volver a consultar una baja ya resuelta no cambia ninguna nota. La excepción es una baja aceptada con
alguna nota que se quedó en `13`: la reconsulta la termina. En beta, la reconsulta respondió 500
`Code: 0127; Description: El ticket no existe`.

---

## 2. Nota de una boleta: `POST /api/summaries` con `"3"` {#nota-de-boleta}

```
POST /api/summaries
```

```json
{
    "fecha_de_emision_de_documentos": "2026-09-24",
    "codigo_tipo_proceso": "3",
    "documentos": [
        { "external_id": "39c6b867-b242-43bd-b402-1b57ca4e642c", "motivo_anulacion": "Nota de credito emitida por error" },
        { "external_id": "e1f81084-1fff-45eb-bc92-b4f363c8a85f", "motivo_anulacion": "Nota de debito emitida por error" }
    ]
}
```

| Campo | Qué va |
|---|---|
| `fecha_de_emision_de_documentos` | La fecha de emisión **de las notas**, en `aaaa-mm-dd` |
| `codigo_tipo_proceso` | `"3"`, **como texto** ([por qué](39-ciclo-de-la-boleta.md#paso-5)) |
| `documentos[].external_id` | El `external_id` **de la nota** |
| `documentos[].motivo_anulacion` | Opcional. Se guarda con la anulación, pero no viaja a SUNAT: el resumen no tiene campo de motivo |

### Response (200 OK)

```json
{
    "success": true,
    "data": {
        "external_id": "bdc008d0-a709-4700-aabf-0ba1f1eb93cd",
        "ticket": "1790346725383",
        "filename": "20123456789-RC-20260925-5",
        "date_of_reference": "2026-09-24",
        "summary_status_type_id": "3",
        "state_type_id": "03",
        "state_type_description": "Enviado",
        "documents": [
            {
                "id": 37,
                "external_id": "39c6b867-b242-43bd-b402-1b57ca4e642c",
                "offline_id": null,
                "document_type_id": "07",
                "series": "BC01",
                "number": 2,
                "number_full": "BC01-2",
                "currency_type_id": "PEN",
                "total": "59.00",
                "state_type_id": "13",
                "state_type_description": "Por anular"
            },
            {
                "id": 38,
                "external_id": "e1f81084-1fff-45eb-bc92-b4f363c8a85f",
                "offline_id": null,
                "document_type_id": "08",
                "series": "BD01",
                "number": 2,
                "number_full": "BD01-2",
                "currency_type_id": "PEN",
                "total": "59.00",
                "state_type_id": "13",
                "state_type_description": "Por anular"
            }
        ]
    }
}
```

Es un resumen nuevo (`RC-20260925-5`), con su propio `external_id` y su propio `ticket`:
guárdalos con cada nota que lleva. `summary_status_type_id: "3"` lo marca como anulación. El resumen
lleva cada nota con el estado `3` y su referencia a la boleta que modifica (`BillingReference` a la
BB01-15). Las notas pasan a `13` (Por anular), o a `03` si la empresa envía por un PSE o por el OSE
SendFact: **todavía no están anuladas**. Falta consultar el resumen.

**Solo notas ya declaradas.** Una nota de boleta en `01` todavía espera su resumen diario. Si hay
que anularla, declárala primero (`POST /api/summaries` con `"1"` y su consulta) y después anúlala.

### Consultar el resumen de anulación: `POST /api/summaries/status` {#consultar-resumen}

Con el `external_id` o el `ticket` **del resumen de anulación**, no los de la nota:

```
POST /api/summaries/status
```

```json
{ "external_id": "bdc008d0-a709-4700-aabf-0ba1f1eb93cd" }
```

o `{ "ticket": "1790346725383" }`.

### Response (200 OK) — aceptado

```json
{
    "success": true,
    "data": {
        "external_id": "bdc008d0-a709-4700-aabf-0ba1f1eb93cd",
        "ticket": "1790346725383",
        "filename": "20123456789-RC-20260925-5",
        "date_of_reference": "2026-09-24",
        "summary_status_type_id": "3",
        "state_type_id": "05",
        "state_type_description": "Aceptado",
        "documents": [
            {
                "id": 37,
                "external_id": "39c6b867-b242-43bd-b402-1b57ca4e642c",
                "offline_id": null,
                "document_type_id": "07",
                "series": "BC01",
                "number": 2,
                "number_full": "BC01-2",
                "currency_type_id": "PEN",
                "total": "59.00",
                "state_type_id": "11",
                "state_type_description": "Anulado"
            },
            {
                "id": 38,
                "external_id": "e1f81084-1fff-45eb-bc92-b4f363c8a85f",
                "offline_id": null,
                "document_type_id": "08",
                "series": "BD01",
                "number": 2,
                "number_full": "BD01-2",
                "currency_type_id": "PEN",
                "total": "59.00",
                "state_type_id": "11",
                "state_type_description": "Anulado"
            }
        ]
    },
    "links": {
        "xml": "https://tu-dominio.com/downloads/summary/xml/bdc008d0-a709-4700-aabf-0ba1f1eb93cd",
        "cdr": "https://tu-dominio.com/downloads/summary/cdr/bdc008d0-a709-4700-aabf-0ba1f1eb93cd"
    },
    "response": {
        "sent": true,
        "code": "0",
        "description": "El Resumen diario RC-20260925-5, ha sido aceptado",
        "notes": [],
        "is_accepted": true,
        "status_code": 0
    }
}
```

Con `response.code: "0"` las notas de `documents` quedan en `11` (Anulado). Ese es el estado de
cada nota; `data.state_type_id` (`05`) es el del resumen. `links.cdr` es el CDR **de la anulación**,
`R-20123456789-RC-20260925-5.zip`, cuyo XML dice `El Resumen diario RC-20260925-5, ha sido aceptado`.
SUNAT lo llama «Resumen diario» también cuando anula: lo que lo hace anulación es el
`summary_status_type_id: "3"`.

Mientras SUNAT procesa el ticket, la consulta responde HTTP 500 con
`Code: 98; Description: El procesamiento del comprobante aún no ha terminado`: consulta otra vez en
unos minutos. Las demás respuestas (PSE, OSE SendFact, `0127`, fallos de conexión) son las de
[39 — Qué puede volver](39-ciclo-de-la-boleta.md#qué-puede-volver). Si SUNAT rechaza,
[ver abajo](#rechazo).

- **Nada consulta este resumen por ti.** La tarea programada de resúmenes solo mira los de tipo
  `"1"`, y «Consultar las comunicaciones de baja» solo las bajas `RA`. Si no lo consultas, la nota se
  queda en `13`.
- **Volver a consultar un resumen ya resuelto no cambia ninguna nota**, salvo terminar las que se
  quedaron en vuelo si fue aceptado. Hasta el 2026-09-25,
  reconsultar el resumen `"1"` que declaró la nota la devolvía a `05` aunque ya estuviera anulada.
- **En el panel** es el botón *Enviar Baja* de la fila `RC-…` en *Comprobantes pendientes →
  Anulaciones*.

---

## Qué cambia en el sistema al anular la nota {#efectos}

El movimiento de stock ocurre al llegar a `11`, cuando consultas el ticket, no al pedir la anulación:

| | Al emitirse | Al quedar anulada (`11`) |
|---|---|---|
| Nota de crédito | Devuelve al almacén lo que lleva en `items` | Lo **vuelve a descontar** |
| Nota de débito | Descuenta lo que lleva en `items`, como una venta | Lo **devuelve** |

En la prueba del 2026-09-25, el kardex del producto registró `+1` al emitir la FC01-1 y `-1` al
anularla, y `-1` al emitir la FD01-1 y `+1` al anularla. Al anular una nota de crédito, sus series
vuelven a marcarse como vendidas y sus lotes se vuelven a descontar. La nota de crédito tipo `13`
no mueve stock ni al emitirse ni al anularse.

La factura o boleta afectada **no cambia**. Lo único que nota es el panel: mientras tiene una nota de
crédito tipo `01` (anulación de la operación) aceptada, no ofrece *Nota* en su menú; al anularse esa
nota, la opción vuelve.

---

## Si SUNAT rechaza la anulación {#rechazo}

Solo `response.code === "0"` confirma la anulación. Con un rechazo la anulación no ocurrió, y el
sistema lo refleja:

- La baja o el resumen queda en `09` (Rechazado).
- Cada nota que seguía en `13` vuelve al estado de antes: `05`, o `07` si su propio CDR traía
  observaciones. No se mueve stock.
- El servidor lo anota en su log con el código de SUNAT.

Lee `response.code` y `response.description`, corrige lo que diga SUNAT y pide la anulación otra vez.
El CDR del rechazo sale en `links.cdr` de la consulta.

Con un PSE o con el OSE SendFact pasa lo mismo: un código de CDR entre `2000` y `3999` cuenta como
rechazo y la nota vuelve desde `03`. Hasta el 2026-09-25 no se detectaba, y la anulación y la nota se
quedaban en `03`.

:::info Cambio de comportamiento (2026-09-25)
Hasta esa fecha, con envío directo a SUNAT o por un OSE, una baja rechazada dejaba la nota en `11`,
con el stock movido como si estuviera anulada. Un resumen `"3"` rechazado la devolvía a `01`, y el
resumen diario de la madrugada la volvía a declarar.

Para los comprobantes que quedaron así en tu servidor, `php artisan tenancy:run anulaciones:audit`
los lista sin tocar nada. Cada uno se regulariza con el
[Validador de documentos](../../../../modulos/Complementarios/reportes/General/validador-de-documentos.md),
que toma el estado de SUNAT, y un ajuste de inventario para el stock que movió la anulación.
:::

---

## Errores

Los de `POST /api/voided` salen **antes** de enviar nada a SUNAT: corrige el cuerpo y vuelve a
llamar. En las dos consultas, solo el `Code: 98` se reintenta tal cual.

| Llamada | HTTP | Mensaje | Causa |
|---|---|---|---|
| Las dos | 422 `NO_DOCUMENTS` | `No se enviaron documentos para la anulación.` | Falta `documentos`, o va vacío |
| Las dos | 422 `DOCUMENT_NOT_VOIDABLE` | `No se puede anular el comprobante … Solo se anula un comprobante Aceptado (05) u Observado (07).` | La nota está en `01`, `03`, `09`, `11` o `13`: `errors.estado` dice en cuál ([ejemplo](#no-anulable)). Desde el 2026-09-25 |
| Las dos | 422 `AFFECTED_DOCUMENT_NOT_FOUND` | `El código externo … no fue encontrado o la fecha indica no corresponde al documento.` | La fecha no es la de emisión de esa nota, la nota es del otro grupo (una de boleta por `/api/voided`, una de factura por `/api/summaries`), o el `external_id` no existe en esta empresa |
| `voided` | 500 | `Undefined array key "fecha_de_emision_de_documentos"` | Falta la fecha |
| `voided` | 500 | `The separation symbol could not be found` / `Trailing data` | La fecha no va en `dd-mm-aaaa`: por ejemplo, `2026-09-25` |
| `voided` | 500 | `SQLSTATE[23000]: Integrity constraint violation: 1048 Column 'description' cannot be null …` | Falta `motivo_anulacion` en alguna nota. No se guarda nada |
| `voided/status` | 500 | `Es requerido el código externo o ticket` | El cuerpo no trae ni `external_id` ni `ticket` |
| `voided/status` | 500 | `El código externo … es inválido, no se encontró anulación relacionada` | Casi siempre: mandaste el `external_id` de la **nota**, no el de la baja |
| `voided/status` | 500 | `Code: 98; Description: El procesamiento del comprobante aún no ha terminado` | SUNAT aún procesa el ticket. **Este sí se reintenta**, en unos minutos |
| `summaries/status` | 500 | `El código externo … es inválido, no se encontró resumen relacionado` | Casi siempre: mandaste el `external_id` de la **nota**, no el del resumen de anulación |
| `summaries/status` | 500 | `El ticket … es inválido, no se encontró resumen relacionado` | Ticket mal copiado o de otra empresa |
| `summaries/status` | 500 | `Code: 98; Description: El procesamiento del comprobante aún no ha terminado` | SUNAT aún procesa el ticket. **Este sí se reintenta**, en unos minutos |

Los errores propios de `/api/summaries` con `"3"` están en
[39 — Errores de este paso](39-ciclo-de-la-boleta.md#errores-de-este-paso).

---

## Desde el panel

El panel hace lo mismo: *Anular* en el menú ••• de la nota crea la baja o el resumen según el grupo,
y el botón *Enviar Baja* de *Comprobantes pendientes → Anulaciones* es la consulta. En una nota de
factura el panel exige el motivo; en una de boleta, no. Con un rechazo, el aviso dice «SUNAT rechazó
la anulación: …» y la fila queda en *Rechazado*, sin *Enviar Baja* y con su CDR. Paso a paso y con capturas:
[Anular notas de crédito y débito](../../../../guias-adicionales/tipos-de-comprobantes/anular-notas-de-credito-y-debito.md).

---

## Desde SQL Server

La fecha de `/api/voided` sale en `dd-mm-aaaa` con el estilo `105` de `CONVERT`; la de
`/api/summaries`, en `aaaa-mm-dd` con el `23`. Escríbelas como texto, igual que el `"3"`:

```sql
-- Nota de una factura.  URL: …/api/voided
DECLARE @Body NVARCHAR(MAX) = (
    SELECT CONVERT(CHAR(10), @FechaEmisionNota, 105) AS fecha_de_emision_de_documentos,  -- dd-mm-aaaa
           (SELECT LOWER(@ExternalIdNota) AS external_id,
                   @Motivo                AS motivo_anulacion                             -- obligatorio
            FOR JSON PATH)                          AS documentos
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
);

-- Nota de una boleta.  URL: …/api/summaries
SET @Body = (
    SELECT CONVERT(CHAR(10), @FechaEmisionNota, 23) AS fecha_de_emision_de_documentos,   -- aaaa-mm-dd
           '3'                                      AS codigo_tipo_proceso,              -- texto
           (SELECT LOWER(@ExternalIdNota) AS external_id,
                   @Motivo                AS motivo_anulacion
            FOR JSON PATH)                          AS documentos
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
);

-- Consultar.  URL: …/api/voided/status  o  …/api/summaries/status
SET @Body = (SELECT @ExternalIdAnulacion AS external_id FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
```

`@FechaEmisionNota` es la fecha de la nota, no la de la factura o boleta que modifica.

---

## Qué guardar por cada nota

| Campo | De dónde sale |
|---|---|
| `external_id` de la nota | La emisión de la nota (`data.external_id`, o su fila de `sync-batch`) |
| `external_id` y `ticket` de la anulación | La respuesta de `POST /api/voided` o de `POST /api/summaries` |
| `state_type_id` de la nota | `05` → `13` → `11` (`05` → `03` → `11` con un PSE o el OSE SendFact). Si SUNAT rechaza, vuelve a `05`/`07`. Por `document_check_server` o `documents/status` |
| CDR de la anulación | `links.cdr` de la consulta con `code: "0"` |

Ver también [10 — Nota de crédito](10-nota-credito.md), [11 — Nota de débito](11-nota-debito.md),
[39 — Ciclo de la boleta](39-ciclo-de-la-boleta.md) y
[40 — Ciclo de la factura](40-ciclo-de-la-factura-y-envio-individual.md#anular-factura).
