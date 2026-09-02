# 35 — Plazo de la Fecha de Emisión (`shipping_time_days`)

> El backend **rechaza** un comprobante cuya `fecha_de_emision` se aleja demasiado del día actual.
> Aplica por igual a `POST /api/documents` y a `POST /api/offline/sync-batch`: **no hay un endpoint que lo esquive**.

---

## La regla en una línea

Con la configuración por defecto (`shipping_time_days = 4`, `restrict_receipt_date = true`), un comprobante `01`/`03`/`07`/`08` **solo se acepta si su fecha de emisión está dentro de los 3 días anteriores al día de hoy**. Al cuarto día, el backend lanza:

```json
{
  "success": false,
  "message": "La fecha de emisión no puede ser menor a 4 día(s)."
}
```

El documento **no se guarda**: la validación corre antes de tocar la base de datos.

---

## Por qué existe

SUNAT otorga un plazo para remitir el CPE (hoy, 4 días calendario desde la emisión para facturas). Pasado ese plazo, el comprobante es rechazado en la recepción. La validación bloquea la emisión **antes** de que el documento exista, para no dejar en el sistema un CPE que ya nació imposible de enviar.

Las boletas que se remiten por **resumen diario** tienen un tratamiento distinto en SUNAT, pero —importante— **el sistema no hace esa distinción**: `01`, `03`, `07` y `08` se validan igual (ver [Diferencias entre la web y la API](#diferencias-entre-la-web-y-la-api)).

---

## El cálculo real (y por qué el margen son 3 días, no 4)

`app/CoreFacturalo/Requests/Api/Validation/Functions.php` → `validateDateOfIssue()`:

```php
$configuration = Configuration::select('shipping_time_days', 'restrict_receipt_date')->firstOrFail();

if ($configuration->restrict_receipt_date) {
    $today          = Carbon::now();
    $date_of_issue  = Carbon::parse($inputs['date_of_issue']);
    $difference_days = $configuration->shipping_time_days - $date_of_issue->diffInDays($today);

    if ($difference_days <= 0) {
        throw new Exception("La fecha de emisión no puede ser menor a {$configuration->shipping_time_days} día(s).");
    }
}
```

Dos detalles que cambian el resultado esperado:

**1. La condición es `<= 0`, no `< 0`.** Con `shipping_time_days = 4`:

| Antigüedad de `fecha_de_emision` | `diffInDays` | `difference_days` | Resultado |
|---|---|---|---|
| Hoy | 0 | 4 | ✅ Acepta |
| 1 día | 1 | 3 | ✅ Acepta |
| 2 días | 2 | 2 | ✅ Acepta |
| 3 días | 3 | 1 | ✅ Acepta |
| **4 días** | 4 | **0** | ❌ **Rechaza** |
| 8 días | 8 | −4 | ❌ Rechaza |

El valor configurado es el **primer día que falla**, no el último que pasa. Un `shipping_time_days = 4` da 3 días útiles de retroactividad.

**2. `diffInDays()` de Carbon 2 devuelve valor absoluto.** El proyecto usa `nesbot/carbon 2.73.0`, donde `diffInDays()` no lleva signo. Consecuencia: **una fecha futura también se rechaza** con el mismo mensaje. Una emisión adelantada 4 o más días falla exactamente igual que una atrasada.

> La hora no altera el límite. `Carbon::parse('YYYY-MM-DD')` cae a medianoche y `diffInDays()` trunca, así que la parte fraccionaria (las horas transcurridas de hoy) nunca empuja el resultado al día siguiente. El corte es siempre por días calendario.

---

## Dónde se aplica — matriz por endpoint

La validación vive en **un solo lugar** (`Api\DocumentValidation::validation()`, línea 39) y se alcanza por dos caminos:

| Endpoint | `doc_type` | ¿Valida la fecha? | Camino |
|---|---|---|---|
| `POST /api/documents` | `01`, `03`, `07`, `08` | ✅ **Sí** | Middleware `input.request:document,api` → `DocumentTransform` → `DocumentValidation` |
| `POST /api/offline/sync-batch` | `01`, `03`, `07`, `08` | ✅ **Sí** | `processDocument()` replica ese pipeline y llama a la **misma** `DocumentValidation` |
| `POST /api/offline/sync-batch` | `80` (nota de venta) | ❌ No | `SaleNoteController@store` — no pasa por `DocumentValidation` |
| `POST /api/offline/sync-batch` | `09` / `31` (guías) | ❌ No | `DispatchValidation` no incluye la función |
| `POST /api/offline/sync-batch` | `20` (retención) | ❌ No | `RetentionValidation` no incluye la función |
| `POST /api/sale-note/{id}/generate-cpe` | `01`, `03` | ❌ No | Arma el array a mano y llama directo a `Facturalo->save()` |

:::warning `sync-batch` NO es una vía de escape
`OfflineSyncController::processDocument()` (línea 532) invoca literalmente `DocumentValidation::validation($inputs)`, la misma clase que usa `/api/documents`. Reintentar por la ruta offline un documento rechazado por fecha **devuelve el mismo error**. El propio comentario del controller lo dice: *"Replica el pipeline del middleware `input.request:document,api` que no se ejecuta al llamar directamente al controller"*.

`OfflineSyncController` **nunca modifica `date_of_issue`**: reenvía la fecha del payload tal cual llegó desde Flutter.
:::

:::danger Los huecos no son funcionalidades
`generate-cpe` omite la validación porque construye el payload manualmente, no porque exista una excepción de negocio. SUNAT rechazará el comprobante igual si excede el plazo real. **No lo uses como atajo** para emitir con fecha antigua: la salida correcta es la configuración del tenant.
:::

---

## Flujo en el sistema

```
                    ┌──────────────────────────────────────┐
                    │  configurations (por tenant)          │
                    │  · restrict_receipt_date  (bool, true)│
                    │  · shipping_time_days     (int,  4)   │
                    └──────────────────┬───────────────────┘
                                       │ leídos en cada emisión
        ┌──────────────────────────────┼──────────────────────────────┐
        │                              │                              │
        ▼                              ▼                              ▼
┌───────────────────┐   ┌──────────────────────────┐   ┌────────────────────────┐
│  WEB (Vue)        │   │  API  /api/documents     │   │  OFFLINE  sync-batch   │
│  invoice.vue      │   │                          │   │  (Flutter → backend)   │
│                   │   │  middleware              │   │                        │
│  validateDate     │   │  input.request:          │   │  processDocument()     │
│  OfIssue()        │   │    document,api          │   │   1. DocumentTransform │
│  · bloquea el     │   │   1. DocumentTransform   │   │   2. DocumentValidation│
│    botón antes    │   │   2. DocumentValidation ─┼───┼──►  (MISMA clase)      │
│    de enviar      │   │   3. DocumentInput::set  │   │   3. DocumentInput::set│
└─────────┬─────────┘   └────────────┬─────────────┘   └───────────┬────────────┘
          │                          │                             │
          │                          ▼                             │
          │        ┌─────────────────────────────────────┐         │
          └───────►│ Functions::validateDateOfIssue()    │◄────────┘
                   │                                     │
                   │ restrict_receipt_date == false ─────┼──► pasa sin validar
                   │ difference_days <= 0 ───────────────┼──► throw Exception
                   │ else ───────────────────────────────┼──► continúa
                   └──────────────────┬──────────────────┘
                                      │ ok
                                      ▼
                            ┌──────────────────────┐
                            │ Facturalo::save()    │
                            │ → XML → firma → CDR  │
                            └──────────┬───────────┘
                                       │
                                       ▼
                     ┌─────────────────────────────────────┐
                     │ Documentos no enviados (web)        │
                     │ DocumentNotSentCollection           │
                     │ misma fórmula → expiration_days     │
                     │ "El plazo de envío caducó"          │
                     └─────────────────────────────────────┘
```

### Etapas

1. **Configuración (por tenant).** Dos columnas de `configurations`. `restrict_receipt_date` es el interruptor maestro: si está en `false`, `validateDateOfIssue()` retorna sin hacer nada y **ninguna** de las tres vías valida.
2. **Emisión.** Web, API y offline convergen en la misma función. La web además valida en el cliente para no dejar pulsar "Generar"; API y offline validan en servidor y devuelven excepción.
3. **Post-emisión.** El documento ya creado se mide con la **misma fórmula** en el listado *Documentos no enviados* (`modules/Document/Http/Resources/DocumentNotSentCollection.php`), que expone `expiration_days` y `is_expiration`, y muestra `"El plazo de envío caducó"` cuando `difference_days <= 0`. Es la misma cuenta, aplicada a documentos que ya existen y siguen sin enviarse.

---

## Diferencias entre la web y la API

El frontend web (`invoice.vue`, `invoiceupdate.vue`, `invoice_generate.vue`,
`option_documents.vue`) **no comparte código** con el backend: reimplementa la regla en JS para
no dejar pulsar "Generar". Hoy la condición es la misma que en PHP:

```js
let minDate = moment().subtract(this.configuration.shipping_time_days, 'days')

// Misma regla que el backend (Functions::validateDateOfIssue): el switch
// restrict_receipt_date decide si se valida, sin excepción por tipo de documento.
if (moment(this.form.date_of_issue) < minDate && this.config.restrict_receipt_date) {
    this.dateValidError()
}
```

:::info Antes de 2026-09-02 las facturas se comportaban distinto
Las cuatro vistas llevaban una rama previa, comentada como *"validar fecha de factura sin
considerar configuracion"*, que bloqueaba las facturas (`01`) **aunque `restrict_receipt_date`
estuviera apagado**. Apagar el switch desbloqueaba las facturas retroactivas por API y por
`sync-batch`, pero no en la interfaz web. Esa rama se eliminó: el switch ahora significa lo
mismo en las tres vías.

De ahí viene la creencia de que *"la restricción solo aplica a facturas"* — era cierta, pero
solo en la web y solo con el switch apagado.
:::

Lo que **sigue** siendo distinto entre cliente y servidor:

| Escenario | Web (Vue) | API / `sync-batch` (PHP) |
|---|---|---|
| Fecha **futura** lejana, switch encendido | El datepicker no la deja seleccionar (`datEmision`) | Rechaza a partir de `shipping_time_days` días |
| Fecha **futura** lejana, switch apagado | Permitida (`datEmision = {}`) | Aceptada |

El switch cumple aquí un segundo papel que `shipping_time_days` no puede expresar: además de
activar la validación, controla si el datepicker permite **fechas futuras**. `shipping_time_days`
solo mide hacia atrás.

---

## Configuración

Ambos campos viven en **Configuraciones globales → Empresa → Avanzado**, pestaña **Visual**:

| Campo en la UI | Columna | Sección de la pestaña | Default |
|---|---|---|---|
| **Restringir fecha de comprobante** (switch) | `restrict_receipt_date` | Comprobantes y Transacciones | `true` |
| **Días de plazo de envío** (numérico, mín. 1) | `shipping_time_days` | Interfaz y Parámetros Generales | `4` |

*El tooltip del campo numérico dice: "Validar fecha de emisión en Ventas/Comprobante electrónico".*

### Cuál mover

| Necesidad | Acción recomendada |
|---|---|
| Carga de histórico, migración, contingencia larga | Subir `shipping_time_days` (p. ej. a `8`) — mantiene un tope en lugar de eliminarlo |
| Desactivar por completo la validación en API/offline | `restrict_receipt_date = false` — deja de validar todos los tipos, sin tope |

Es configuración **por tenant**: cambiarla en una empresa no afecta a las demás.

:::info No confundir con el plazo de anulación
`shipping_time_days_voided` (default `7`) es un campo **distinto**, usado por `VoidedController` y `SummaryTrait` para el plazo de anulación mediante comunicación de baja. Ajustar uno no afecta al otro.
:::

---

## Cómo llega el error en cada endpoint

### `POST /api/documents`

La excepción sube y se serializa como error global, con el sobre `{success, message}` de siempre:

```json
{
  "success": false,
  "message": "La fecha de emisión no puede ser menor a 4 día(s)."
}
```

**El status HTTP depende de la versión del backend:**

| Versión | Status | Motivo |
|---|---|---|
| Desde *errores accionables de `/api/documents`* (2026-09-02) | **422** | `validateDateOfIssue()` lanza `ApiInputException`, que el `Handler` serializa con su propio status |
| Anteriores | **500** | Lanzaba `Exception` genérica y caía en el catch-all del `Handler` |

Trata el fallo por el **mensaje**, no por el status: es el único dato estable entre versiones. Esta excepción no trae `error_code`.

### `POST /api/offline/sync-batch`

El `try/catch` por venta la captura y la coloca en el elemento correspondiente de `results[]`. **HTTP 200** — el resto del lote se procesa con normalidad:

```json
{
  "success": true,
  "synced": 4,
  "failed": 1,
  "results": [
    { "index": 0, "offline_id": "a1b2...", "success": true,  "doc_type": "03", "data": { "id": 881, "number": "B001-142" } },
    {
      "index": 1,
      "offline_id": "c3d4-e5f6-...",
      "success": false,
      "doc_type": "01",
      "message": "La fecha de emisión no puede ser menor a 4 día(s)."
    }
  ]
}
```

---

## Notas para Flutter

- **Es un error permanente, no transitorio.** Reintentar el mismo payload mañana lo aleja más del límite: el `difference_days` empeora con el tiempo. Marca la venta como `ERROR_PERMANENTE` (no `PENDIENTE_SYNC`) y sácala de la cola de reintentos automáticos; requiere intervención humana.

- **Detecta el error por contenido del mensaje**, no por código HTTP: en `sync-batch` el HTTP es 200 y el fallo vive en `results[i].message`. Busca el literal `"La fecha de emisión no puede ser menor a"`.

- **Valida en el cliente antes de encolar.** `POST /api/login` devuelve ambos campos dentro de `app_configuration` (desde 2026-09-02; ver [01 — Autenticación](01-autenticacion.md)). Guárdalos junto al token y, al crear el comprobante local, replica la regla del **backend**:

  ```dart
  // rechaza si |hoy − fechaEmision| en días calendario >= shippingTimeDays
  final dias = DateTime.now().difference(fechaEmision).inDays.abs();
  final bloqueado = restrictReceiptDate && dias >= shippingTimeDays;
  ```

  Usa el valor absoluto: el backend rechaza las fechas futuras igual que las atrasadas. Si el backend es anterior y no envía los campos, asume el default (`true` / `4`).

- **Alerta antes del corte.** Con `shipping_time_days = 4` quedan 3 días de margen. Si una venta lleva 2 días en la cola sin sincronizar, avisa al operador: al día siguiente dejará de ser sincronizable.

- **La numeración no se libera sola.** Si el documento se rechaza por fecha, el correlativo local queda consumido en el dispositivo pero nunca se creó en el servidor. Consúltalo con `GET /api/offline/series-numbering` antes de reemitir para no dejar huecos ni colisionar.

- **Notas de venta (`80`) como plan B operativo.** No pasan por esta validación, pero **no son CPE**: no se envían a SUNAT. Sirven para no perder el registro de la venta, no para cumplir con la emisión electrónica.

---

## Relación con contingencia

Aquí hay un choque de plazos que conviene tener presente:

| Plazo | Valor | De dónde viene |
|---|---|---|
| Remisión de contingencia a SUNAT | 7 días calendario | Normativa SUNAT (ver [27 — Contingencia](27-contingencia.md)) |
| Aceptación de `fecha_de_emision` en el backend | 3 días útiles (`shipping_time_days = 4`) | Configuración del tenant |

Las series de contingencia (`0001`, `0F01`) usan `doc_type` `01`/`03`, así que **caen de lleno en esta validación**. Un lote de contingencia sincronizado al quinto día se rechaza aunque SUNAT todavía lo aceptaría.

**Si operas contingencia con ventanas largas de desconexión, sube `shipping_time_days` a `8` o más antes de necesitarlo.** Ajustarlo después no rescata los comprobantes ya rechazados: hay que reenviarlos una vez cambiada la configuración.

---

## Archivos del backend

| Archivo | Rol |
|---|---|
| `app/CoreFacturalo/Requests/Api/Validation/Functions.php` (`validateDateOfIssue`, L243) | La validación en sí |
| `app/CoreFacturalo/Requests/Api/Validation/DocumentValidation.php` (L39) | Único invocador |
| `app/CoreFacturalo/InputRequest.php` | Middleware `input.request` que encadena Transform → Validation → Input |
| `app/Http/Controllers/Tenant/Api/DocumentController.php` (L22) | Declara el middleware para `store` |
| `modules/Offline/Http/Controllers/OfflineSyncController.php` (`processDocument`, L532) | Replica el pipeline para `sync-batch` |
| `modules/Document/Http/Resources/DocumentNotSentCollection.php` (L53) | Misma fórmula para `expiration_days` post-emisión |
| `resources/js/views/tenant/configurations/form.vue` (L383, L609) | Los dos campos en la UI |
| `resources/js/views/tenant/documents/invoice.vue` (`validateDateOfIssue`) | Validación cliente — misma condición que el backend |
| `resources/js/views/tenant/documents/invoice.vue` (`datEmision`) | `picker-options`: el switch decide si se permiten fechas futuras |
| `database/migrations/tenant/2020_03_20_030559_add_columna_restrict_receipt_date.php` | `restrict_receipt_date`, default `true` |
| `database/migrations/tenant/2022_03_10_094902_tenant_add_shipping_time_days_to_configurations.php` | `shipping_time_days`, default `4` |
