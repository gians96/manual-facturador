# 36 — Envío Automático del Comprobante por Correo (`acciones.enviar_email`)

> Al emitir, el backend puede mandar el comprobante al correo del cliente sin que hagas una segunda llamada.
> Lo decide el objeto **`acciones`** del payload **o** el interruptor del tenant. Basta con que uno de los dos lo pida.

---

## La regla en una línea

```
se envía  =  acciones.enviar_email == true   O   interruptor del tenant activo
```

El interruptor es **Configuración → Avanzado → pestaña POS → tarjeta "PDF e Impresión" → "Enviar PDF automático al correo del cliente"**.

Consecuencias prácticas:

- Si el tenant tiene el interruptor **activo**, no toques el payload: los comprobantes salen por correo solos.
- Si lo tiene **apagado**, manda `"acciones": { "enviar_email": true }` en las emisiones que quieras enviar.
- Mandar `"enviar_email": false` **no cancela** el envío cuando el interruptor está activo. El payload solo puede forzar, nunca suprimir.

:::info Antes esto no funcionaba desde la API
El interruptor existía, pero solo lo leía el navegador: el POS web lanzaba una segunda petición a `POST documents/email`, una ruta con sesión, inalcanzable para un cliente de la API. Quien emitía por `POST /api/documents` no recibía ningún correo aunque el interruptor estuviera encendido. Ahora el backend lo aplica en la propia emisión.
:::

---

## Request

### El objeto `acciones`

El wrapper va **en español**, igual que el resto del payload de la API offline.

```json
{
  "serie": "F001",
  "numero": "#",
  "fecha_de_emision": "2026-09-03",
  "codigo_tipo_documento": "01",
  "acciones": {
    "enviar_email": true,
    "formato_pdf": "a4"
  }
}
```

| Campo | Tipo | Requerido | Descripción |
|---|---|---|---|
| `enviar_email` | `bool` | No | Fuerza el envío del comprobante al correo del cliente. Omitido, decide el interruptor del tenant. |
| `formato_pdf` | `string` | No | Formato del PDF que se genera al emitir: `a4` (por defecto), `a5`, `ticket`, `ticket_58`, `ticket_50`. |
| `enviar_xml_firmado` | `bool` | No | Si el XML firmado se remite a SUNAT en el acto. Por defecto `true`, pero la configuración del tenant lo modula: en boletas del grupo `02` exige además el interruptor de envío automático a SUNAT. |
| `auto_print` | `bool` | No | Impresión automática en servidor. Campo en inglés dentro del wrapper español. |
| `name_printer` | `string\|null` | No | Impresora destino de la impresión automática. |
| `client_public_ip` | `string\|null` | No | IP pública del cliente. Solo se usa si el tenant tiene configurada impresión local de restaurante. |

Si omites `acciones` por completo, el objeto se resuelve con los valores por defecto y el envío queda en manos del interruptor.

:::warning `formato_pdf` no siempre manda en el adjunto
`formato_pdf` decide el PDF que se genera **durante la emisión**. Si ese archivo ya no está en disco cuando se envía el correo —la purga de PDF antiguos se lo llevó—, se regenera **en A4**, sin consultar el formato original. Un ticket reenviado semanas después puede llegar como A4.
:::

---

## Response

**El correo no altera la respuesta de la emisión.** Un comprobante aceptado por SUNAT es válido aunque el correo falle, así que el envío va envuelto y su resultado no aparece en el JSON:

```json
{
  "success": true,
  "data": {
    "number": "F001-123",
    "filename": "20123456789-01-F001-123",
    "external_id": "b0c1...",
    "state_type_id": "05"
  }
}
```

Para saber si el correo salió de verdad, consulta la tabla de log (más abajo). No infieras nada del `success` de la emisión.

La relación inversa también se cumple, y sorprende más: **el correo no mira el resultado de SUNAT**. Si el comprobante se guarda pero SUNAT lo rechaza, el correo sale igual. El cliente puede recibir un comprobante que aún no está aceptado.

---

## Dónde se aplica — matriz por endpoint

| Endpoint | Comprobante | ¿Envío automático? |
|---|---|---|
| `POST /api/documents` | Boleta, factura, NC, ND | ✅ |
| `POST /api/sale-note` | Nota de venta (80) | ✅ |
| `POST /api/sale-note/{id}/generate-cpe` | CPE desde nota de venta | ✅ |
| `POST /api/quotations` | Cotización | ✅ |
| `POST /api/dispatches` | Guía de remisión remitente (09) | ✅ |
| `POST /api/dispatch-carrier` | Guía de remisión transportista (31) | ⚠️ En la práctica no envía: ver abajo |
| `POST /api/retentions` | Comprobante de retención (20) | ❌ sin plantilla de correo |
| `POST /api/perceptions` | Comprobante de percepción (40) | ❌ sin plantilla de correo |
| `POST /api/purchase-settlements` | Liquidación de compra | ❌ sin plantilla de correo |

Los tres últimos no tienen plantilla de correo propia. No fallan: registran el motivo en el log y siguen adelante.

**La guía transportista (31) no registra cliente.** La validación de guías solo resuelve la persona cuando el tipo **no** es `31`, así que el comprobante nace sin destinatario y el envío no encuentra a quién escribir. Para esas guías usa el envío manual con un destinatario explícito.

### `sync-batch` envía solo dos de los cinco tipos

`POST /api/offline/sync-batch` no es un caso único: reparte por tipo de documento y cada rama se comporta distinto.

| Tipo en el lote | Ruta interna | ¿Envía correo? |
|---|---|---|
| `01`, `03`, `07`, `08` | `DocumentController@store` | ✅ |
| `80` | `SaleNoteController@store` | ✅ |
| `09`, `31`, `20` | Replican el pipeline de emisión en el propio controlador | ❌ nunca llaman al envío |

:::warning Un lote grande son muchos envíos SMTP seguidos
Para los tipos que sí envían, **cada venta del lote dispara su propio envío**, y el envío es síncrono. Sincronizar 50 ventas acumuladas con el interruptor activo puede añadir un par de minutos a la petición, según lo rápido que responda tu servidor SMTP. Si sincronizas lotes grandes, súbele el timeout al cliente o parte el lote.
:::

### Reintentar una emisión no reenvía el correo

Si repites una emisión con el mismo `offline_id`, el backend devuelve el comprobante existente y **sale antes de llegar al envío**. No hay correos duplicados por reintentar, pero tampoco hay segunda oportunidad si el primer envío falló: para eso está el envío manual.

---

## A qué correo se envía

Al **cliente del comprobante**, tomado de su ficha: el campo *"Correo electrónico"* de Clientes.

**El correo que mandas en el payload sí cuenta.** El bloque `datos_del_cliente_o_receptor` se resuelve *antes* de construir el comprobante: si el cliente no existe se crea con ese `correo_electronico`, y si existe se actualiza. O sea, el correo que viaja en la emisión es el que acabará recibiendo el comprobante.

- Si en ese campo hay **varias direcciones separadas por coma o punto y coma**, se envía a todas. Al separarlas se eliminan **todos** los espacios, así que `a@x.com, b@y.com` funciona.
- Si el cliente **no tiene correo**, no se envía nada. No es un error: la emisión responde `200` igualmente y el motivo queda en el log. Es lo normal en boletas a cliente genérico.
- Los *Correos Opcionales* de la ficha **no** se usan en el envío automático.

---

## Qué llega al cliente

**Depende del tipo de comprobante.** Solo el comprobante electrónico lleva algo más que el PDF:

| Adjunto | Factura / Boleta / NC / ND | Nota de venta | Cotización | Guía de remisión |
|---|---|---|---|---|
| PDF | ✅ Siempre. Se regenera si la purga se lo llevó. | ✅ | ✅ | ✅ |
| XML firmado | ✅ Siempre. Nunca se regenera. | ❌ | ❌ | ❌ |
| CDR de SUNAT | ✅ Si existe y no es boleta (`03`). Se adjunta el XML extraído del zip, como `R-{filename}.xml`. | ❌ | ❌ | ❌ |
| Constancia de detracción | ✅ Si el comprobante tiene detracción con imagen cargada. | ❌ | ❌ | ❌ |

La nota de venta, la cotización y la guía de remisión llegan **únicamente con el PDF**. En las dos primeras es lo esperable —no son comprobantes electrónicos, no existe XML—; en la guía de remisión sí existe XML firmado y aun así no se adjunta.

Sobre el XML del comprobante electrónico: se adjunta **sin comprobar antes que exista**, a propósito. El PDF es un artefacto que se regenera; el XML firmado es el comprobante legal y no se regenera nunca, así que si falta se prefiere que el envío falle a mandar un correo incompleto. Ojo: ese fallo es visible **en el log del servidor**, no en la respuesta de la emisión, que sigue siendo `200`.

**No hay límite de tamaño ni compresión.** Los adjuntos se cargan en memoria tal cual. Un comprobante con cientos de ítems puede generar un PDF que el servidor de correo del destinatario rechace.

### Asunto y remitente

| Comprobante | Asunto | Nombre del remitente |
|---|---|---|
| Factura / boleta / NC / ND | *Envio de Comprobante de Pago Electrónico* | Comprobante electrónico |
| Nota de venta | *Envio de Nota de Venta* | Nota de Venta |
| Cotización | *Envio de Cotización* | Cotización |
| Guía de remisión | *Envio de guía* | Guía |

Solo el comprobante electrónico admite plantilla personalizada (`tenant.template_document_mail`); con ella el asunto pasa a ser `Folio {folio}`. Los otros tres tienen asunto y plantilla fijos.

---

## Requisito previo: correo configurado

Sin configuración de correo no se envía nada, y el intento queda registrado con el motivo *"No hay configuración de correo electrónico"*.

La cuenta de correo se resuelve en **dos capas**:

1. **La de la plataforma**, que configura el administrador de tenants en su panel. Es la que se usa por defecto para todas las empresas.
2. **La propia de cada tenant**, en **Configuración → Avanzado → pestaña Correo**. Son cinco campos repartidos en dos tarjetas: *Servidor SMTP* (dirección del host, puerto y encriptación) y las credenciales (nombre de usuario y contraseña). **Los cinco deben estar completos**; con cuatro, la del tenant se ignora y se sigue usando la de la plataforma.

Configurar la propia solo tiene sentido si quieres que los comprobantes salgan desde tu dirección y tu dominio. Si no configuras nada, salen igualmente con la cuenta de la plataforma — el panel te lo avisa con un mensaje en esa misma pestaña.

:::warning La capa de la plataforma habilita la del tenant
Si el administrador **no** ha configurado la cuenta de la plataforma, el sistema se queda con la del archivo de entorno del servidor y **la cuenta propia del tenant no llega a aplicarse**, por completa que esté. En una instalación recién montada, lo primero es configurar la global.
:::

📘 Cómo rellenarlo (puertos, TLS/SSL, contraseñas de aplicación de Gmail): **[Configuración SMTP segura](../../../../guias-adicionales/Configuracion/configuracion-smtp-segura.md)**.

---

## Cómo saber si el correo salió

Cada intento que llega a la fase de envío deja una fila en la tabla **`email_send_log`** de la base de datos del tenant:

| Columna | Contenido |
|---|---|
| `relation_id` | Id del comprobante **dentro de su propio modelo** |
| `relation_model` | Clase con namespace completo: `App\Models\Tenant\Document`, `...\SaleNote`, `...\Quotation`, `...\Dispatch` |
| `email` | Destinatarios a los que se intentó enviar |
| `sendit` | `1` si el correo salió, `0` si falló |
| `created_at` | Momento del intento |

`relation_id` **no es único por sí solo**: la misma tabla la comparten todos los envíos del sistema, y una nota de venta con id 50 y un documento con id 50 producen filas con el mismo `relation_id`. Filtra siempre también por `relation_model`:

```sql
SELECT relation_id, email, sendit, created_at
FROM email_send_log
WHERE relation_model = 'App\\Models\\Tenant\\Document'
ORDER BY id DESC
LIMIT 20;
```

Lo que **no** deja fila: los casos que ni llegan a intentarse —cliente sin correo, o comprobante sin plantilla— se registran en el log de Laravel con el prefijo `[auto-mail]`. Y el detalle del error de un envío fallido va a un log aparte, `storage/logs/emails.log`, no al log general.

**No hay reintentos en ninguna capa.** El envío es síncrono y no se encola, así que un fallo puntual del SMTP se pierde: hay que reenviar a mano.

---

## Saber si el interruptor está activo desde el app

La clave `auto_send_pdf_email` viaja en dos sitios, con distinta envoltura:

```jsonc
// GET /api/configuration-web
{ "success": true, "data": { "auto_send_pdf_email": true, "...": "..." } }

// POST /api/login
{ "success": true, "app_configuration": { "auto_send_pdf_email": true, "...": "..." } }
```

Sirve para reflejarlo en la interfaz y avisar al vendedor cuando el cliente elegido no tiene correo registrado. **El envío lo hace el backend**: el app no necesita —ni debe— lanzar ninguna llamada extra.

📘 Ver también: **[20 — Configuración Offline](20-configuracion-offline.md)** y **[01 — Autenticación](01-autenticacion.md)**.

---

## Envío manual, cuando quieras mandarlo aparte

Para reenviar un comprobante ya emitido, o mandarlo a una dirección distinta de la del cliente:

```
POST /api/document/email
{ "id": 1234, "email": "otro@cliente.com" }
```

Equivalentes: `POST /api/sale-note/email` y `POST /api/quotations/email`, con los mismos dos campos.

A diferencia de la emisión, aquí la respuesta **sí dice la verdad**: `success: false` si el correo no salió.

---

## Archivos del backend

| Archivo | Rol |
|---|---|
| `app/CoreFacturalo/Requests/Api/Transform/Common/ActionTransform.php` | Traduce el wrapper `acciones` (español) a los nombres internos |
| `app/CoreFacturalo/Requests/Inputs/Common/ActionInput.php` | Resuelve `send_email` combinando payload y configuración (`sendEmail`) |
| `app/CoreFacturalo/Helpers/Mail/AutoDocumentMailer.php` | Punto único de envío: resuelve destinatario y plantilla por modelo, y nunca lanza |
| `app/CoreFacturalo/Facturalo.php` | `sendEmail()`, invocado por los controladores tras cerrar la transacción |
| `app/CoreFacturalo/Helpers/Storage/EnsuresPdfExists.php` | Regenera el PDF (en A4) si la purga de disco se lo llevó |
| `app/Http/Controllers/Tenant/EmailController.php` | Separa destinatarios, aplica la configuración de correo y escribe `email_send_log` |
| `app/Mail/Tenant/DocumentEmail.php` | Plantilla y adjuntos del comprobante electrónico |
| `app/Mail/Tenant/{SaleNoteEmail,QuotationEmail}.php`, `modules/Order/Mail/DispatchEmail.php` | Plantillas de nota de venta, cotización y guía — solo PDF |
| `modules/Offline/Http/Controllers/OfflineSyncController.php` | `processByDocType()`: reparte el lote por tipo |
| `app/Models/Tenant/Configuration.php` | Campo `auto_send_pdf_email` y resolución de la cuenta de correo |
