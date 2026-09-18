---
sidebar_position: 2.2
title: "Guías de remisión: cómo funcionan por dentro"
sidebar_label: "Guías de remisión: cómo funcionan"
---

# Guías de remisión: cómo funcionan por dentro

Las guías de remisión electrónicas (GRE) **se firman igual que una factura**, pero **no se
envían igual**. Esta página explica la diferencia, porque es la causa de casi todas las
preguntas sobre guías: por qué hay tres llamadas en vez de una, por qué no devuelven CDR al
momento y por qué necesitan credenciales aparte.

## ¿Se firman? Sí, exactamente igual

Una GRE es un XML **UBL 2.1** firmado con **XML-DSig**, usando el **mismo certificado
digital** que las facturas y boletas. No hay ninguna diferencia en la firma: mismo
certificado, mismo firmador, mismo resultado.

Lo que cambia es el **transporte**.

## SOAP con CDR vs REST con ticket

|  | Factura / boleta / nota | **Guía de remisión** |
|---|---|---|
| Formato | XML UBL 2.1 | **Igual** |
| Firma | Certificado digital (XML-DSig) | **Igual** |
| Transporte | SOAP (*Billing Service*) | **API REST** (*API GRE*) |
| Autenticación | Usuario y clave SOL | **OAuth2 · token Bearer** |
| Respuesta | **CDR** en la misma llamada | **Ticket**: hay que consultarlo aparte |
| ¿Se envía al emitir? | Sí, automáticamente | **No**, es una llamada aparte |

SUNAT publicó las guías en una API REST moderna en vez de en el servicio SOAP de siempre. Esa
API es **asíncrona**: acepta el envío y devuelve un número de ticket; el CDR con la
aceptación o el rechazo se recoge después.

## El flujo, en tres llamadas

```
1. POST /api/dispatches                → genera, FIRMA y crea el PDF. No envía nada a SUNAT.
2. POST /api/dispatches/send           → envía a SUNAT y obtiene el ticket (estado 03 Enviado).
3. POST /api/dispatches/status_ticket  → consulta el ticket y recoge el CDR.
```

Las tres reciben o devuelven el `external_id` que entrega el paso 1: **guárdalo**, es lo que
identifica la guía en los pasos 2 y 3.

Que el paso 1 no envíe es intencional, no un olvido. Es la diferencia más importante frente a
`POST /api/documents`, que sí envía a SUNAT dentro de la misma llamada.

## El QR y el PDF: cuándo aparecen

Esta es la pregunta que más llega de los integradores, y casi siempre en la misma forma:
«el PDF se descarga desde el minuto uno, pero no trae QR». Las dos mitades son ciertas y
ninguna es un fallo.

**El QR no lo genera el Facturador.** Lo emite SUNAT dentro del CDR, en el nodo
`cac:DocumentResponse` → `cac:DocumentReference` → `cbc:DocumentDescription`. El sistema lee esa
URL, la guarda en la guía y la convierte en imagen al dibujar el PDF. Antes de que exista CDR
no hay nada que dibujar: el QR de una guía sin respuesta de SUNAT sencillamente **no existe
todavía**.

Por eso el recorrido es este:

| Paso | Estado | XML | PDF | QR |
|---|---|---|---|---|
| 1. `POST /api/dispatches` | `01` Registrado | Firmado, ya existe | Ya existe | ❌ No |
| 2. `POST /api/dispatches/send` | `03` Enviado | Igual | Igual | ❌ No, SUNAT solo acusó recepción |
| 3. `POST /api/dispatches/status_ticket` con `codRespuesta 0` | `05` Aceptada | Igual | Sigue sin QR en disco | ✅ Sí, en la guía |

El paso 3 no es una sola llamada. Mientras SUNAT responda `98`, la guía sigue en proceso y hay
que volver a consultar. El QR aparece en la consulta que trae el CDR aceptado, no antes.

### Por qué se puede descargar antes de enviar

Porque el PDF y el XML se crean en el paso 1, y la ruta de descarga **no filtra por estado**:

```
GET /downloads/dispatch/pdf/{external_id}/{formato?}
GET /downloads/dispatch/xml/{external_id}
GET /downloads/dispatch/cdr/{external_id}
GET /print/dispatch/{external_id}/{formato}
```

Son rutas **públicas**: no piden sesión ni token, lo único que las protege es que el
`external_id` no se puede adivinar. Están pensadas para que el integrador y el cliente final
puedan enlazar el documento sin autenticarse.

Ese PDF temprano es un **borrador interno**. Sirve para revisar el contenido antes de enviar,
y no vale ante un control en carretera: sin QR, el fiscalizador no tiene qué escanear.

### Cómo obtener el PDF ya con QR

La descarga se **autorepara**. Cada vez que se pide el PDF de una guía remitente que ya tiene
QR, el sistema lo vuelve a generar antes de entregarlo. La receta para el integrador es la de
siempre:

1. Consultar el ticket hasta que el estado sea `05`.
2. Volver a llamar a `GET /downloads/dispatch/pdf/{external_id}`.

No hace falta ningún endpoint especial de "refrescar PDF", ni volver a emitir la guía.

:::note El diseño sale de la plantilla vigente
Cada vez que se regenera, el PDF A4 usa la plantilla de guía que la empresa tenga asignada en ese
momento, no la del día de la emisión. Si un administrador cambia la plantilla, las guías que vuelvas
a descargar saldrán con el diseño nuevo; los datos no cambian. →
[Plantillas PDF - Guías de remisión](../../modulos/configuracion-y-mas/configuracion-globales/Plantillas/Plantillas-pdf-guias.md)
:::

:::warning Consultar el ticket NO deja el QR en el archivo guardado
Por ningún camino. Medido sobre guías reales contra el emulador: tras emitir, enviar y
consultar el ticket una vez, la guía vuelve aceptada y el `qr_url` queda guardado, pero el PDF
en disco pesa unos 31 KB y **no contiene ninguna imagen**. Tras volver a pedirlo pasa a unos
99 KB con el QR dentro.

La causa está en cómo se encadenan dos líneas. `POST /api/dispatches/status_ticket` carga la
guía en memoria **antes** de consultar a SUNAT, y luego le pasa a la generación del PDF ese
mismo objeto, que sigue teniendo el `qr_url` vacío. Llama a regenerar, pero con datos viejos.
El botón *Consultar ticket* del panel llega al mismo controlador, así que le pasa lo mismo. El
modal que aparece al terminar de emitir va por otra ruta que ni siquiera intenta regenerar.

Lo que sí funciona es la descarga, y es lo único que hace falta:

- `GET /downloads/dispatch/pdf/{external_id}` vuelve a generar el PDF con datos frescos cada
  vez que la guía ya tiene QR. Esta es la vía normal.
- `GET /print/dispatch/{external_id}/{formato}` regenera siempre, y a diferencia de la
  descarga también cubre la guía transportista (`31`), que hoy queda fuera de esa
  regeneración automática.

El QR nunca se pierde: está guardado en la guía. Lo que puede quedar viejo es el archivo.
:::

:::danger El correo de la guía sale sin QR, siempre
El envío automático por correo se dispara al **emitir**, en el paso 1, cuando SUNAT todavía no
ha respondido nada. Y adjunta el archivo que hay en disco, sin pasar por la descarga que lo
regenera. El resultado es que el destinatario recibe un PDF sin código QR aunque la guía
acabe aceptada minutos después.

Si el cliente necesita el PDF con QR por correo, hay que reenviarlo a mano desde *Opciones*
una vez la guía figure como aceptada, y **después** de haberla descargado al menos una vez.
:::

### Enviar sola no basta

Si programas el envío automático de guías, **programa también la consulta del resultado**. Son
dos tareas distintas: la primera obtiene el ticket, la segunda recoge el CDR y con él el QR.
Con solo la primera activa, las guías se quedan en estado `03` para siempre y ningún PDF llega
a tener QR.

→ [Envío de guías de remisión automático](../../guias-adicionales/tareas-programadas/envio-guias-remision-automatico.md)

## Credenciales: son otras, no las de facturación

El token de la API GRE **no** se obtiene con el usuario y clave SOL que ya usas para
facturar. Hace falta registrar en SUNAT un *cliente API SOL*, que entrega:

- `client_id` y `client_secret`
- un **usuario SOL secundario** con permiso sobre guías

Con esos cuatro datos el sistema pide el token (`grant_type=password`) y lo guarda en caché
**un minuto** antes de volver a pedirlo. Si las guías fallan con error de autenticación y las
facturas siguen saliendo bien, casi siempre es que faltan o caducaron estas credenciales, no las
de facturación.

:::caution La caché del token no distingue demo de producción
La clave de caché se forma solo con el RUC de la empresa. Al cambiar **SOAP Tipo** de Producción
a Demo, o al revés, el token anterior sigue vivo hasta que expira, y nada lo invalida al guardar
la configuración. Durante ese minuto un envío puede salir firmado con el token del entorno que
acabas de abandonar, y el síntoma es un *no se encuentra autorizado* con todo aparentemente bien
puesto. Si acabas de cambiar de entorno y falla, espera un minuto y reintenta.
:::

## ¿Puede emitirlas un PSE? Sí. ¿Un OSE? No

Esta es la parte que más confusión genera, porque para facturas OSE y PSE son casi
intercambiables y **para guías no lo son**.

Desde **julio de 2022, SUNAT dejó a los OSE fuera del proceso de guías**. Una GRE solo puede
emitirse de dos maneras:

| Vía | ¿Sirve para guías? | Qué significa |
|---|---|---|
| **Contribuyente directo a SUNAT** | ✅ Sí | El sistema firma y envía por la API GRE con tus propias credenciales. Es el comportamiento por defecto. |
| **PSE** (Proveedor de Servicios Electrónicos) | ✅ Sí | El PSE emite **en tu nombre**. Requiere contratar el servicio y configurarlo en la empresa. |
| **OSE** (Operador de Servicios Electrónicos) | ❌ **No** | Los OSE quedaron fuera de las guías por norma. Sirven para facturas y boletas, no para GRE. |

Consecuencia práctica que sorprende a mucha gente: **si tu OSE tiene un panel donde ves tus
facturas, tus guías no van a aparecer ahí.** No es un fallo del sistema ni un envío perdido:
es que el OSE sencillamente no participa en el proceso. Para verlas en el panel de un
proveedor hay que contratar su servicio **PSE**, que es un producto distinto del OSE aunque
lo venda la misma empresa.

Cuando hay un PSE configurado, es él quien firma y envía; el sistema le entrega el XML y
recoge la respuesta.

## Los dos tipos de guía

| Código | Documento | Quién la emite |
|---|---|---|
| `09` | Guía de remisión **remitente** | Quien despacha la mercadería |
| `31` | Guía de remisión **transportista** | La empresa de transporte |

Ambas son UBL 2.1 con `CustomizationID 2.0` (versión GRE 2021) y siguen exactamente el mismo
flujo de tres pasos.

:::info La guía transportista tiene endpoint propio
La `09` se emite con `POST /api/dispatches`; la `31`, con **`POST /api/dispatch-carrier`**.
No son intercambiables: `/api/dispatches` anula los datos de partida y llegada para todo lo
que no sea tipo `09` y luego los exige, así que con una guía transportista responde siempre
422. Corregido el 2026-09-08, cuando tres páginas de esta documentación aún indicaban el
endpoint equivocado.
:::

## Enlazarlas con el comprobante

Emitir la guía es la mitad del trabajo: falta decir **qué comprobante la sustenta**, o qué
comprobante la factura. Son cuatro claves que se llaman parecido y hacen cosas distintas —
unas mandan texto al XML y otras relacionan los registros de verdad.

→ [Documentos relacionados: enlazar guías y comprobantes](./documentos-relacionados.md)

## Modo de pruebas

El sistema tiene un **modo demo** en el que las guías no llegan a SUNAT. Conviene saber a dónde
llegan de verdad, porque no es lo que la mayoría supone.

### Qué lo activa

**Configuración → Empresa → Empresa**, sección *Entorno del Sistema*, campo **SOAP Tipo**, opción
**Demo**. Es el mismo interruptor que decide a dónde van las facturas, no uno propio de guías.
Internamente queda como `soap_type_id = '01'`.

→ [Configuración de la empresa](../../modulos/configuracion-y-mas/configuracion-globales/Empresa/empresa.md)

### A dónde va la guía

|  | Demo | Producción |
|---|---|---|
| Token OAuth2 | `gre-test.nubefact.com/v1/clientessol/…` | `api-seguridad.sunat.gob.pe/v1/clientessol/…` |
| Envío | `gre-test.nubefact.com/v1/contribuyente/gem/…` | `api-cpe.sunat.gob.pe/v1/contribuyente/gem/…` |
| Ticket | `gre-test.nubefact.com/…/comprobantes/envios/{ticket}` | `api-cpe.sunat.gob.pe/…/comprobantes/envios/{ticket}` |

Esto vale para la vía **directa a SUNAT**, que es la configuración por defecto. Con un PSE
activo, o con el modo de envío puesto en OSE, la guía se desvía antes de llegar aquí y
**SOAP Tipo** ya no decide el destino. En ese caso, las credenciales guardadas en la empresa sí
se usan aunque estés en Demo.

:::info SUNAT no tiene ambiente de pruebas para esta API
La **API REST de guías**, que es la que usa el sistema, **no tiene beta**. SUNAT no publica uno.

El `e-beta.sunat.gob.pe` que aparece al buscar es el beta del servicio **SOAP** de guías: otra
plataforma, no la que consume este flujo.

Por eso el modo demo apunta a `gre-test.nubefact.com`, un **emulador que mantiene NubeFact**
imitando el contrato de la API GRE. No es un servicio de SUNAT, y tampoco es el panel de NubeFact.
Una guía de demo no aparece en ninguno de los dos.

Lo dice el propio NubeFact al anunciarlo: «Debido a que la SUNAT **NO** dispone de un servidor de
pruebas para validar los XML de las nuevas Guías de Remisión Electrónica (GRE)…».
→ [Servidor de pruebas gratuito de validación XML para las nuevas GRE](https://www.nubefact.com/blog/nubefact/nuevo-servidor-de-pruebas-gratuito-de-validacion-xml-para-las-nuevas-gre)
:::

### Qué se valida

El emulador respeta el mismo flujo asíncrono de tres pasos, así que lo que se prueba es la
estructura del XML y el recorrido completo. La guía se firma y se envía comprimida igual que en
producción, el envío devuelve un `numTicket`, y la consulta del ticket devuelve un `codRespuesta`
que el sistema interpreta igual en demo y en producción:

| `codRespuesta` | Estado de la guía |
|---|---|
| `0` | Aceptada |
| `98` | En proceso, hay que volver a consultar |
| `99` | Rechazada, con el motivo en `desError` |

En la práctica el emulador **responde `0` en la primera consulta**, un segundo después del
envío. El `98` es un caso de producción, donde SUNAT sí tarda. Conviene programar el bucle de
reintento igualmente, porque en producción hará falta, pero no te extrañe no verlo nunca en
demo.

Cuando hay CDR, se descarga, se guarda y de ahí sale la URL del QR. Igual que en producción.

:::warning Lo que el modo demo NO prueba
- **El CDR de demo no tiene valor fiscal.** La guía no queda registrada en SUNAT ni aparece en
  SUNAT SOL.
- **El emulador no consulta los padrones reales**: RUC del destinatario, series autorizadas, estado
  del contribuyente. Una guía aceptada en demo puede ser rechazada en producción.
- **Los correlativos avanzan igual.** Lo emitido en demo consume numeración de la serie. Revísala
  antes de pasar a producción.
- **Es un servicio de terceros.** Si está caído, el modo demo falla aunque el sistema esté bien.
- **El QR de demo es un marcador de posición.** El emulador devuelve literalmente
  `https://url-test?hashqr=test` como contenido del código. El cuadrito se dibuja y el recorrido
  se comprueba entero, pero ese QR no lleva a ninguna parte. Y el CDR de demo lo firma NubeFact,
  no SUNAT.
:::

## Cómo probar una guía en demo

### Lo que no hace falta

- **La credencial GRE de SUNAT SOL.** En demo el sistema **descarta** el usuario secundario y el
  *client id* / *client secret* que estén configurados, y usa los de prueba. Esos campos pueden
  quedar vacíos.

  Ojo con cuáles: el descarte afecta **solo** al bloque *Usuario Secundario Sunat*, dentro de
  *Guías electrónicas*. El formulario de empresa tiene otro par rotulado igual, el de la consulta
  integrada de RUC y DNI, que en demo **no** se sustituye y sigue apuntando a producción. Vaciarlo
  rompe esa consulta.
- **Un certificado digital propio.** En demo se firma con un certificado de prueba que viene
  incluido en el propio sistema. Es uno de demostración a nombre de *TU EMPRESA S.A.*, con un
  RUC que no es el tuyo, y **caducó en abril de 2019**. Firma igual porque nadie comprueba la
  fecha, y al emulador tampoco le importa. No te alarmes si abres el XML firmado y ves eso.

  En demo, además, el certificado propio **se ignora aunque lo tengas subido**: siempre se usa
  el de demostración. El tuyo solo entra en juego en Producción.

Es decir: se puede probar el flujo completo de guías **antes** de haber tramitado nada en SUNAT.

### Las credenciales de prueba

Van incorporadas, no hay que pedirlas ni configurarlas. Son las públicas del emulador:

| Dato | Valor |
|---|---|
| Usuario | el RUC de la empresa seguido de `MODDATOS` |
| Clave | `MODDATOS` |
| Client ID | `test-85e5b0ae-255c-4891-a595-0b98c65c9854` |
| Client Secret | `test-Hty/M6QshYvPgItX2P0+Kw==` |

El usuario lleva el **RUC real de la empresa**, no un RUC de prueba. Lo único que exige el emulador
es el sufijo `MODDATOS`.

:::danger No copies estos valores al formulario
La tabla está aquí para que sepas **con qué credenciales viaja tu prueba**, no para que las
escribas en *Configuración → Empresa*. Además de innecesario, hoy no se puede: la columna
`api_sunat_id` del tenant admite 36 caracteres y ese Client ID mide 41, así que **Guardar**
responde con un error 500 y se pierde el formulario entero, incluidas las secciones que no
tocaste.

El origen es que la columna se dimensionó para un UUID pelado, que es el formato del Client ID
real de SUNAT. El prefijo `test-` del emulador se sale por cinco caracteres. Un Client ID de
producción sí entra.

Para probar, lo único que hay que hacer es poner **SOAP Tipo** en **Demo** y dejar los cuatro
campos vacíos.
:::

### Pasos

1. Poner **SOAP Tipo** en **Demo**. Dejar vacíos los cuatro campos de *Usuario Secundario
   Sunat*.
2. Tener registrada la serie de guías del establecimiento. **La serie decide si la guía se
   firma**: una `09` tiene que empezar por `T` y una `31` por `V`. Con cualquier otra letra el
   panel guarda la guía y responde que se creó correctamente, pero no genera XML ni la firma,
   así que después no hay nada que enviar.
3. Emitir la guía. Recordar que la `09` va por `POST /api/dispatches` y la `31` por
   `POST /api/dispatch-carrier`.
4. Enviarla y consultar el ticket. En demo suele volver aceptada a la primera.
5. Descargar el PDF para que salga con el QR. Consultar el ticket no basta.

### Comprobar el emulador por separado

Cuando una prueba falla conviene saber si el problema es la guía o el emulador. Esta petición pide
un token y no envía nada:

```bash
curl -X POST \
  "https://gre-test.nubefact.com/v1/clientessol/test-85e5b0ae-255c-4891-a595-0b98c65c9854/oauth2/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "grant_type=password" \
  --data-urlencode "scope=https://api-cpe.sunat.gob.pe" \
  --data-urlencode "client_id=test-85e5b0ae-255c-4891-a595-0b98c65c9854" \
  --data-urlencode "client_secret=test-Hty/M6QshYvPgItX2P0+Kw==" \
  --data-urlencode "username=20000000001MODDATOS" \
  --data-urlencode "password=MODDATOS"
```

Responde con `access_token`, `token_type` y `expires_in`. El *client secret* lleva `/`, `+` y `=`,
así que hay que enviarlo codificado: por eso el ejemplo usa `--data-urlencode`.

### Pasar a producción

Cambiar **SOAP Tipo** a **Producción** exige lo que demo no pedía: el certificado digital propio y
la credencial GRE real, que se saca en SUNAT SOL marcando *GREE Emisión de Comprobantes* sobre
`/v1/contribuyente/gem`.

→ [Configuración previa de guías de remisión](../../modulos/Complementarios/guias-de-remision/01-Configuracion-previa-guia-remision.md)

## El estado manda qué se puede hacer

Una guía pasa por estos estados, y cada uno permite cosas distintas. Eliminar, recrear y marcar
como anulada lo comprueba también el servidor, no solo la pantalla. Corregir por API, no del
todo: lo explica el aviso de abajo.

| Estado | Qué se puede hacer | Por qué |
|---|---|---|
| **Registrado** | Editar · Enviar a SUNAT · **Volver a recrear** · **Eliminar** | SUNAT todavía no la ha visto |
| **Enviado** | Solo consultar el ticket | Está en manos de SUNAT y aún no hay respuesta |
| **Aceptado** | Opciones · Generar comprobante · **Marcar como anulada** | SUNAT ya la tiene |
| **Rechazado** | Editar y volver a enviar · **Volver a recrear** · **Eliminar** | SUNAT la rechazó y **no la registró** |
| **Anulado** | Opciones · descargar XML, PDF y **CDR** | Se marcó a mano para reflejar una baja hecha en el portal de SUNAT |

:::warning Una guía enviada no se edita
Aunque siga sin respuesta. Tocarla mientras SUNAT la procesa deja el sistema diciendo una cosa y
SUNAT otra. El panel solo ofrece **Editar** en una guía Registrada o Rechazada, pero al corregir
por API el servidor **solo frena las aceptadas**, así que esa comprobación te toca a ti →
[registrar o actualizar](#registrar-o-actualizar-lo-decide-el-external_id).
:::

### Eliminar: nunca lo que SUNAT tiene, y siempre preguntando antes

Se puede borrar una guía **Registrada** o **Rechazada**, remitente o transportista. Ninguna de las
dos está en SUNAT: la registrada no ha salido, y la rechazada salió, SUNAT la procesó y devolvió un
CDR de rechazo, pero **no la dio de alta**. Está comprobado en el portal: la consulta de *GRE
emitidas* devuelve las aceptadas y ninguna rechazada. Una guía enviada o aceptada no se borra:
dejaría un documento vivo en SUNAT que aquí no existe.

Pero el estado guardado **no demuestra lo que tiene SUNAT**. Un envío que vence por tiempo de espera
puede haber llegado igualmente, y con algunos proveedores el acuse tarda en reflejarse.

Por eso, **antes de borrar el sistema le pregunta a SUNAT**. No envía nada, solo consulta:

- Si SUNAT la tiene, la consulta corrige el estado y el borrado se cancela.
- Si la consulta no se puede hacer, **no se borra**.
- Para una rechazada hace falta además una **respuesta concluyente**: el CDR, o un código de rechazo
  de SUNAT (del `2000` al `3999`). Con un proveedor PSE, una caída llega con la misma forma que un
  rechazo, sin error y con el estado intacto, y solo el código las distingue. Borrar con cualquier
  otra respuesta sería borrar a ciegas.

Si la guía era la última de su serie, el número vuelve a quedar libre; si estaba en medio, queda un
hueco que SUNAT nunca registró.

En el panel está en el menú ⋮ de la fila. Por API,
[`DELETE /api/dispatches/{external_id}`](/devs/api/tenant/Guia-remision/eliminar-guia-remision):

| HTTP | `error_code` | Significa | Qué hacer |
|---|---|---|---|
| 422 | `DISPATCH_NOT_FOUND` | El `external_id` no existe | No reintentar |
| 409 | `DISPATCH_ALREADY_ACCEPTED` | SUNAT ya tiene la guía, o la consulta previa descubrió que sí la tenía | No reintentar. La baja va por el portal de SUNAT |
| 409 | `DISPATCH_PENDING_TICKET` | Está enviada y SUNAT aún no responde | Consultar el ticket y decidir con el resultado |
| 503 | `SUNAT_UNREACHABLE` | No se pudo confirmar con SUNAT que no la tiene | **Reintentar** más tarde |

Solo el `503` se reintenta: es el único error pasajero de los cuatro.

:::warning Si restauraste la base desde una copia
El borrado consulta a SUNAT con el ticket **guardado en la guía**. Si la base se restauró desde una
copia anterior, una guía que ahí figura rechazada pudo haberse corregido y reenviado después, y estar
**aceptada** en SUNAT con otro ticket. La consulta con el ticket viejo devolvería el rechazo antiguo y
la borraría. Tras una restauración, comprueba esas guías en el portal de SUNAT antes de borrarlas.
:::

### Volver a recrear: cuando la guía quedó sin sus archivos

Genera y firma otra vez el **XML** y el **PDF** con los datos actuales de la guía, igual que el
«Volver a recrear» de facturas y boletas. **No envía nada a SUNAT** ni cambia el estado.

Sirve cuando la guía existe pero sus archivos no llegaron a crearse, por ejemplo porque la emisión
falló a mitad. Al enviarla, el aviso lo dice así:

```
La guía V001-9 no tiene XML firmado. Usa «Volver a recrear» en el menú ⋮ y vuelve a enviarla.
```

Está en el menú ⋮ de la fila, con dos condiciones:

- El usuario tiene que tener el permiso **Recrear documentos** (Usuarios → editar el usuario →
  *Otros permisos*). Viene desmarcado.
- Solo en **Registrado** o **Rechazado**. Una guía enviada o aceptada ya tiene en SUNAT un XML
  concreto, y firmar otro dejaría dos documentos distintos con el mismo número.

:::caution Recrear no cambia la fecha
Se firma con los datos que tiene la guía. Si la emisión es de hace días, SUNAT puede rechazarla al
enviarla con `2108` («Presentación fuera de fecha»). En ese caso, corrige la fecha con **Editar** y
vuelve a enviarla.
:::

### Marcar como anulada: no da de baja en SUNAT

**SUNAT no tiene baja para las guías de remisión.** Ni para la remitente (`09`) ni para la
transportista (`31`): no existe comunicación de baja ni resumen que las anule, como sí lo hay
para facturas y boletas. La baja se hace **en el portal de SUNAT**, y **solo el mismo día de la
emisión**. Esta acción refleja en el sistema lo que ya se hizo allí, para que los dos digan lo
mismo. Antes había que entrar a la base de datos.

Está en el menú ⋮ de la fila, **solo en una guía Aceptada**, y pregunta antes de tocar nada:

> **¿Ya diste de baja esta guía en SUNAT?**
> La baja se hace en el portal de SUNAT, y solo el mismo día de la emisión. Esto marca la guía
> T001-4 como anulada en el sistema para que coincida con SUNAT.

Por dentro es una **acción del panel**, con la sesión del usuario:
`POST /dispatches/{id}/anular` y `POST /dispatch_carrier/{id}/anular` van al mismo sitio y hacen
lo mismo. **No hay endpoint equivalente con token**: no busques `anular` en `/api`.

Lo único que cambia es el estado, de **Aceptado** (`05`) a **Anulado** (`11`). No se genera
ningún XML, no se firma nada y no se envía nada a SUNAT. Desde cualquier otro estado responde:

```json
{"success": false, "message": "Solo se puede anular una guía aceptada por SUNAT."}
```

y cuando sí se puede:

```json
{"success": true, "message": "La guía T001-4 quedó marcada como anulada."}
```

:::danger Anular aquí no cambia nada en SUNAT
Solo actualiza el estado **en este sistema**. Para SUNAT la guía sigue exactamente como estaba,
y **no existe forma de anularla por API**, ni remitente ni transportista. Si hace falta la baja
de verdad, se hace en el portal de SUNAT y solo el mismo día de la emisión.
:::

**La guía anulada conserva sus archivos.** La fila sigue ofreciendo **XML**, **PDF** y **CDR**,
y el botón **Opciones** con el detalle, las descargas A4 / 80 mm / 58 mm y el reenvío por correo
y WhatsApp. Es a propósito: como SUNAT no da de baja las GRE, ese CDR de aceptación es la única
prueba de que la guía existió y de que SUNAT la aceptó; ocultarlo dejaba la guía anulada sin
respaldo descargable. Lo que sí desaparece es **Generar comprobante**: no se factura desde una
guía dada de baja.

Dentro de **Opciones**, el aviso de una guía anulada sale en ámbar —«Guía marcada como anulada
en el sistema. La baja se hace en el portal de SUNAT»— en lugar del verde del CDR de aceptación.

Eliminar, recrear y anular dejan rastro en la bitácora del sistema, con usuario y fecha.

## Aceptada con observaciones

**SUNAT puede aceptar una guía y observarla a la vez.** El código de respuesta viene `0` y los
reparos viajan aparte, en las notas del CDR. La guía es válida, pero SUNAT está señalando algo.

El sistema las guarda y las muestra: en el cuadro de opciones aparece un único aviso ámbar,
«SUNAT aceptó la guía con N observaciones», en lugar del verde de una guía limpia. La lista se
despliega con **Ver detalle**, y cada observación sale sin su cola técnica (`errorCode … (nodo: …)`);
el texto completo aparece al pasar el cursor.

Estas son las que aparecen de verdad en el tráfico corriente, tomadas de CDR reales:

| Código | Qué observa |
|---|---|
| 4186 | El campo observaciones supera los 250 caracteres |
| 4388 | Falta el indicador de pagador del flete |
| 4391 | El transportista no tiene número de registro del Ministerio de Transportes |
| 4398 | La placa no figura en las bases de SUNAT |
| 4412 | La licencia de conducir no figura en las bases de SUNAT |
| 4434 | En la guía de transportista no corresponde enviar el detalle de bienes |

:::tip Hoy observa, mañana puede rechazar
SUNAT viene endureciendo las reglas de la guía de remisión. Una observación de hoy puede ser un
rechazo el año que viene. Conviene corregirlas aunque la guía se acepte.
:::

## Avisos antes de emitir

La emisión devuelve un campo `warnings` con lo que SUNAT va a observar o rechazar, y con lo que el
sistema va a guardar distinto de como lo enviaste. **No bloquean nada**: la guía se emite y se firma
igual, y tú decides.

```json
{
  "success": true,
  "data": {
    "number": "V001-7",
    "external_id": "...",
    "warnings": [
      {"codigo": "2567", "campo": "vehiculo.numero_de_placa",
       "mensaje": "La placa «AKM-863» lleva separadores y SUNAT la rechaza. Envíala como «AKM863»."}
    ]
  }
}
```

Es un campo añadido: si no lo lees, todo sigue funcionando igual que antes.

Desde el 2026-09-14 también llega en cada fila de guía de `POST /api/offline/sync-batch`, dentro de
`data`, junto a `signed` y `sign_message`. Antes solo lo veía quien emitía por la API.

### Los avisos que existen hoy

Los de código numérico salen de reglas del pliego oficial de SUNAT, y la mayoría de rechazos reales
capturados emitiendo contra producción. Los de código **no numérico** son avisos del sistema: SUNAT
no los conoce, pero te dicen que la guía no va a quedar exactamente como la enviaste.

| Código | Campo | Qué mira |
|---|---|---|
| `2523` | `unidad_de_medida` del peso | Solo se admite `KGM` o `TNE`. La API acepta las 68 del catálogo y las vuelca al XML |
| `2523` | `peso_bruto_total` | SUNAT exige un decimal **positivo**: cero se rechaza |
| `2567` | `vehiculo.numero_de_placa` | Una placa con guiones o espacios se rechaza |
| `2560` | `datos_remitente` | Guía de transportista cuyo remitente es tu propia empresa, que ahí es el transportista. Rechazo seguro (comprobado contra producción); el panel no deja emitirla |
| `2570` | `chofer_secundario.N` | Conductor secundario con datos pero sin tipo de documento. Solo cuando la guía lleva los secundarios al XML: transporte privado, público con el indicador, o guía de transportista |
| `2692` | `documento_relacionado.N.documento.id` | Código del catálogo 61 que ese tipo de guía no admite. El caso típico: el `76` (residuos) en una guía de transportista, que es solo del remitente |
| `2775` | `direccion_partida.ubigeo` | Seis dígitos exactos, en partida y en llegada |
| `2775` | direcciones | Se descartan en la guía de transportista |
| `2566` | `vehiculo.numero_de_placa` | Con el indicador de vehículos y conductores del transportista, o en una guía de transportista, falta la placa del vehículo principal |
| `3345` · `3346` | `documento_relacionado` | Guía de transportista con más documentos relacionados de los que admite: hasta 2 si uno es un permiso (`65` a `69`) o una `31`; si no, 1, salvo una guía remitente electrónica |
| `3380` | `documento_relacionado.N.ruc` | Guía de transportista con una factura, boleta o guía relacionada sin un RUC de emisor de 11 dígitos: sale sin emisor y SUNAT la rechaza |
| `3357` | `chofer` | Con el indicador, el conductor principal no trae tipo, número, nombres o licencia |
| `3364` | `direccion_partida.ubigeo` | Debe coincidir con el ubigeo del puerto informado |
| `3409` | `documento_relacionado.N.ruc` | En un código que no es del remitente (`76`, `92`…) el `ruc` no tiene 11 dígitos: el XML lleva el RUC de tu empresa como emisor |
| `3440` | `documento_relacionado` | Importación y exportación exigen DAM o DS |
| `3441` | `documento_relacionado.numero` | El régimen aduanero del número no cuadra con el motivo |
| `3483` | `codigo_de_puerto` | El motivo `19` lo exige |
| `3493` | `documento_relacionado` | El motivo `19` exige `50`, `52`, `91` o `92` |
| `3616` | `fecha_de_traslado` | Con el indicador, el traslado empieza antes de la entrega al transportista |
| `3618` | `fecha_entrega_transporte` | Anterior a la de emisión. No aplica a la guía de transportista, que no tiene esa fecha |
| `4186` | `observaciones` | Más de 250 caracteres |
| `4190` | `descripcion_motivo_traslado` | Motivo `13` con una descripción de menos de 3 letras |
| `4371` | `documento_relacionado.N.documento.descripcion` | Documento relacionado con código y sin descripción: el XML sale con `cbc:DocumentType` vacío |
| `4372` | `documento_relacionado.N.documento.descripcion` | Descripción de más de 120 caracteres o con saltos de línea |
| `4391` | `transportista.numero_mtc` · `empresa.registro_mtc` | Sin registro del Ministerio de Transportes. En la guía de transportista es el de **tu empresa** (ficha de la empresa) |
| `4392` | `transportista.numero_mtc` · `empresa.registro_mtc` | Registro MTC con otro formato que el de SUNAT: hasta 20 letras mayúsculas y números, sin espacios ni guiones |
| `4394` · `4397` | `transportista.codigo_entidad_autorizadora` · `transportista.numero_autorizacion_especial` | Autorización especial del transportista sin entidad o sin número: **no se emite**. En la guía de transportista, en `datos_del_emisor.…` |
| `4395` | `transportista.codigo_entidad_autorizadora` | Entidad fuera del catálogo D-37: la autorización **no se emite**. En la guía de transportista, en `datos_del_emisor.…` |
| `4396` | `transportista.numero_autorizacion_especial` | Número de la autorización del transportista con menos de 3 o más de 50 caracteres, o con tabulaciones o saltos de línea. Viaja igual y SUNAT la observa |
| `4399` | `vehiculo.certificado_habilitacion_vehicular` | Con el indicador, o en una guía de transportista, un vehículo con placa y sin TUC. Un aviso por vehículo, principal o secundario |
| `4403` · `4405` | `vehiculo.codigo_entidad_autorizadora` · `vehiculo.numero_autorizacion_especial` | Lo mismo para la autorización de un vehículo: **no se emite** |
| `4406` | `vehiculo.numero_autorizacion_especial` | Lo mismo que `4396`, para el número de la autorización de un vehículo |
| `4407` | `vehiculo.codigo_entidad_autorizadora` | Entidad del vehículo fuera del D-37: **no se emite** |
| `REDONDEO_PESO` | `peso_total` | El peso se guarda con 2 decimales: el tercero se redondea (`34.825` queda en `34.83`) |
| `REDONDEO_CANTIDAD` | `items.N.cantidad` | La cantidad de un bien se guarda con 4 decimales y se redondea |
| `RECORTE_DESCRIPCION_MOTIVO` | `descripcion_motivo_traslado` | La descripción del motivo pasa de 100 caracteres: viaja cortada en `cbc:HandlingInstructions`. En la guía de transportista no aplica |
| `SECUNDARIO_INCOMPLETO` | `chofer_secundario.N` · `vehiculo_secundario.N.numero_de_placa` | Conductor secundario a medias (sale con datos vacíos), o vehículo secundario con TUC o autorización y sin placa (sale con la placa vacía). Mismas condiciones que `2570` |
| `AUTORIZACION_NO_EMITIDA` | `vehiculo.numero_autorizacion_especial` · `vehiculo_secundario.N.numero_autorizacion_especial` | Autorización de un vehículo completa y válida, pero en una guía remitente sin el régimen: transporte privado (`02`), o público (`01`) sin `indicador_vehiculos_conductores_transportista`. Se guarda, pero **no viaja en el XML**. La del transportista sí viaja en cualquier caso, y en la guía de transportista viajan todas |
| `AUTORIZACION_NO_EMITIDA` | `datos_del_emisor.numero_autorizacion_especial` | Autorización de `datos_del_emisor` en una guía remitente: solo existe en la de transportista |
| `TRANSPORTISTA_IGNORADO` | `transportista` | Bloque `transportista` en una guía de transportista: ahí el transportista es tu empresa y el bloque se descarta. El MTC sale de la ficha y la autorización va en `datos_del_emisor` |

Como en el pliego de SUNAT, los códigos que empiezan por `2` o `3` son rechazos y los que empiezan
por `4`, observaciones. `3409` es la excepción: SUNAT no llega a verlo, porque el XML pone el RUC de
tu empresa en su lugar, y el documento viaja como emitido por quien no lo emitió. Con `4394`,
`4395`, `4397`, `4403`, `4405`, `4407` y `AUTORIZACION_NO_EMITIDA` la guía sale **sin** esa
autorización, porque el sistema nunca inventa la entidad que falta ni emite lo que la guía no
admite; con `4396` y `4406` la autorización sí viaja, y SUNAT la observa. Los de un vehículo
secundario nombran su posición: `vehiculo_secundario.0.…`.

Los códigos **no numéricos** (`REDONDEO_PESO`, `REDONDEO_CANTIDAD`, `SECUNDARIO_INCOMPLETO`,
`AUTORIZACION_NO_EMITIDA`, `RECORTE_DESCRIPCION_MOTIVO` y `TRANSPORTISTA_IGNORADO`) son avisos del
sistema, no de SUNAT. Los cuatro primeros, `2570`, `3409`, `4371`, `4372`, `4396` y `4406` existen
desde el 2026-09-15; `4190` y `RECORTE_DESCRIPCION_MOTIVO`, desde el 2026-09-16, cuando la
descripción del motivo empezó a viajar en el XML.

Desde el 2026-09-18 la **guía de transportista** avisa como la remitente: antes callaba porque no
enviaba ni el registro MTC ni ninguna autorización, y lo que llegaba se guardaba y se perdía. Son
de esa fecha `2560`, `2692`, `3345`, `3346`, `3380`, `4392` y `TRANSPORTISTA_IGNORADO`. El panel
de la guía de transportista muestra los mismos avisos al guardar.

Por API, `3357` y `2566` casi no se ven como aviso: con
`indicador_vehiculos_conductores_transportista` en `true`, la emisión ya responde
`MISSING_FIELDS` si falta el conductor o la placa. El aviso cubre lo que llega por otros caminos,
como el panel.

→ [Vehículos y conductores del transportista](./offline/endpoints/13-guia-remision-remitente.md#vehículos-y-conductores-del-transportista)
· [Guía de transportista: materiales o residuos peligrosos](./offline/endpoints/14-guia-remision-transportista.md#materiales-o-residuos-peligrosos)

:::danger El ubigeo de partida se truncaba
Hasta el 11 de septiembre de 2026, el `ubigeo` de `direccion_partida` se cortaba a **un solo
carácter** en 285 de los 1876 distritos del país, y solo por la API. La guía se firmaba con el
ubigeo roto y SUNAT la rechazaba.

Los afectados eran los distritos de **provincias numeradas de la 10 en adelante**. Huari es
`021001` y se emitía `1`. Las provincias `01` a `09` funcionaban por casualidad.

Si tienes guías rechazadas con un ubigeo raro, es esto. Ya está corregido, y desde ahora un
ubigeo que no tenga seis dígitos sale además como aviso `2775` antes de enviar.
:::

## Los motivos aduaneros piden más

Tres motivos de traslado —`08` importación, `09` exportación y `19` traslado de mercancía
extranjera— tienen reglas propias, y en todas ellas **SUNAT rechaza, no observa**. Merece la
pena leerlas antes de integrar, porque los errores llegan al consultar el ticket, no al emitir.

### El documento de aduanas es obligatorio

| Motivo | Documentos que admite | Si falta |
|---|---|---|
| `08` importación | `50` DAM, `52` DS | `3440` |
| `09` exportación | `50` DAM, `52` DS | `3440` |
| `19` mercancía extranjera | `50`, `52`, `91` manifiesto de carga, `92` cita del terminal | `3493` |

Van en `documento_relacionado`, con el código del **Catálogo N.° 61**. Enviar un código que no
esté en la lista de ese motivo también es rechazo, con `3445`.

### El régimen aduanero viaja dentro del número

El número de la DAM y de la DS tiene cuatro partes,
`aduana(3)-año(4)-régimen(2)-correlativo(1..6)`, y **el par del medio no es libre**: SUNAT lo
exige distinto según el motivo. Es el error `3441`, y cuesta de diagnosticar porque el mensaje
solo dice que el formato no cumple.

| Motivo | DAM `50` | DS `52` |
|---|---|---|
| `08` importación | `10` | `18` |
| `09` exportación | `40` | `48` |
| `19` mercancía extranjera | `10`, `20`, `21`, `30`, `36`, `70`, `80` | `18` |

Así que en una exportación `235-2026-40-123456` pasa y `235-2026-10-123456` no.

### El puerto, y dónde tiene que estar

El motivo `19` exige `codigo_de_puerto` y `tipo_de_puerto` (`3483`). En `08` y `09` son
opcionales, pero van en pareja: uno sin el otro se observa con `4413` o `4415`.

El tipo hace falta porque el mismo código puede ser dos sitios distintos. `IQT` es el puerto de
Iquitos y también el aeropuerto Coronel FAP Francisco Secada Vignetta. Lo mismo con `ILO`,
`CHM`, `PIO`, `PCL`, `TYL` y `YMS`.

Y hay una regla que no aparece en la documentación de SUNAT y solo se ve al emitir: **el ubigeo
del puerto tiene que coincidir con el de `direccion_partida`**, o la guía se rechaza con `3364`.
Tiene sentido, porque en un traslado de mercancía extranjera la carga sale del terminal. Con el
puerto del Callao, la partida va en `070101`.

:::warning El motivo 19 todavía no se puede emitir entero
Le faltan reglas por línea de detalle: la unidad de medida (`3446`) y los campos del manifiesto
de carga. Los avisos previos te dirán lo que falta, pero hoy la guía no llega a ser aceptada.
:::

## Corregir una guía rechazada

Cuando SUNAT rechaza una guía, **no hace falta emitir otra**. Se corrige y se reenvía con el
mismo número, por el **mismo endpoint** con el que se emitió: `POST /api/dispatches` o
`POST /api/dispatch-carrier`.

Basta con incluir el `external_id` que recibiste al emitirla, junto con el payload corregido:

```json
{
  "external_id": "229f45f3-3c5f-411e-922b-c800ccbeea75",
  "serie_documento": "V001",
  "...": "resto del payload ya corregido"
}
```

Se conservan la serie, el número y el propio `external_id`. Después hay que volver a llamar al
envío y a la consulta del ticket: corregir no envía nada a SUNAT.

:::tip ¿La emitiste por el lote?
También se corrige por `POST /api/offline/sync-batch`, con el `external_id` dentro de `data`.
Desde el 2026-09-18 vale con el `offline_id` de siempre. En un servidor anterior hace falta uno
**nuevo**: con el de siempre, el lote devuelve `was_duplicate` sin leer el JSON y la guía no
cambia →
[corregir una guía rechazada por el lote](./offline/endpoints/15-sync-batch.md#corregir-una-guía-rechazada-por-el-lote).
:::

**¿Y el error `1032`?** El pliego de SUNAT lo define como *«El comprobante ya esta informado y se
encuentra con estado anulado o rechazado»*, y parecía impedir reenviar con el mismo número. Se
comprobó emitiendo contra SUNAT producción: una guía remitente rechazada con `3443` y una de
transportista rechazada con `2567`, corregidas y reenviadas con su mismo número, **fueron aceptadas
las dos**. Un rechazo por CDR no deja rastro del número; el `1032` se refiere a los rechazos por
evento.

Si no la vas a corregir, también se puede [eliminar](#eliminar-nunca-lo-que-sunat-tiene-y-siempre-preguntando-antes).

:::warning Una guía aceptada no se puede modificar
Si SUNAT ya la aceptó, el sistema responde `DISPATCH_ALREADY_ACCEPTED`. Para deshacerla hay que
darla de baja en el portal de SUNAT, y eso **solo se puede el mismo día**. Después, el estado se
puede reflejar a mano desde el menú de tres puntos del listado.
:::

### Registrar o actualizar: lo decide el `external_id`

El mismo endpoint registra y actualiza, pero **no busca la guía por serie y número**: la reconoce
solo por el `external_id`. Que registre o actualice depende de si lo mandas:

| Lo que envías | Qué hace | Respuesta |
|---|---|---|
| Sin `external_id`, con `numero_documento: "#"` | Registra una guía **nueva** con el siguiente número. La rechazada se queda como estaba | 200, con otro `external_id` |
| Sin `external_id`, con el número de la rechazada | Nada: ese número ya está registrado | 409 `DUPLICATE_DOCUMENT` |
| Con el `external_id` de una guía en cualquier estado salvo Aceptado (`05`) | **Actualiza** esa guía | 200, con el mismo número y el mismo `external_id` |
| Con un `external_id` que no existe | Nada: no registra otra en su lugar | 422 `DISPATCH_NOT_FOUND` |
| Con el `external_id` de una guía aceptada | Nada | 422 `DISPATCH_ALREADY_ACCEPTED` |

Un `external_id` vacío o `null` cuenta como no enviado.

Al actualizar:

- **Manda el JSON completo**, no solo lo que cambia. Reemplaza todo lo que tenía la guía, ítems
  incluidos, y los campos obligatorios se validan igual que al emitir.
- **La serie y el número del JSON no se usan**: mandan los de la guía. Así un descuido no mueve
  el correlativo de un documento que ya pasó por SUNAT.
- La guía **se vuelve a firmar**, se rehace el PDF y queda en **Registrado** (`01`). La respuesta
  trae los `warnings` del JSON nuevo.
- **No se envía a SUNAT.** Hasta que vuelvas a llamar a `send`, consultar el ticket devuelve la
  respuesta del envío anterior: el rechazo.
- Si la empresa tiene activo el envío automático por correo, el cliente **vuelve a recibir** la
  guía.
- Si la corriges otro día, actualiza también `fecha_de_emision`. Con la fecha vieja, SUNAT puede
  rechazarla con `2108` («Presentación fuera de fecha»).

:::warning Actualiza solo guías Registradas o Rechazadas
Hoy el servidor solo frena las **aceptadas**. Una guía **enviada** (`03`), con el ticket todavía en
proceso, se deja sobrescribir: vuelve a Registrado y conserva el ticket anterior. Si después SUNAT
acepta ese primer envío, el sistema se queda con unos datos que SUNAT nunca recibió. Con `98` en el
ticket, espera la respuesta definitiva y decide con ella. Tampoco toques una **anulada** (`11`):
SUNAT ya la tiene.
:::

### El flujo en tu integración

Guarda el `external_id` de cada guía junto a tu propio registro: es la única llave que el sistema
reconoce. Con él, la decisión es esta:

```
¿Tienes el external_id de esa guía?
├─ No → POST sin external_id → registra
└─ Sí → según el último estado que te devolvió la API:
        01 Registrado o 09 Rechazado → POST con external_id → send → status_ticket
        03 Enviado                   → status_ticket; con 98, esperar y volver a consultar
        05 Aceptado                  → nada: la baja va por el portal de SUNAT
```

Si emites por el lote, el «POST con external_id» puede ser una fila de `sync-batch` con el
`external_id` dentro de `data` (desde el 2026-09-18, con el mismo `offline_id`; antes, con uno
nuevo), o la llamada directa a este endpoint
→ [corregir una guía rechazada por el lote](./offline/endpoints/15-sync-batch.md#corregir-una-guía-rechazada-por-el-lote).

:::note Desde el 2026-09-11
En un servidor anterior, el `external_id` del payload no se tiene en cuenta y la llamada se trata
como una guía nueva: con `"#"` gasta un número por intento, y con el número de la rechazada falla
por duplicado. Si no sabes de qué fecha es tu instalación, pregúntale a soporte.
:::

## Prueba de extremo a extremo

Así se probó el ciclo completo contra SUNAT el 16 de septiembre de 2026, con las series de prueba
`T999` y `V999`. Sirve de guion para comprobar una instalación.

| Paso | Llamada | Resultado real |
|---|---|---|
| 1. Emitir la remitente | `POST /api/dispatches` | `T999-90003`, firmada, `warnings: []` |
| 2. Emitir la transportista | `POST /api/dispatch-carrier` | `V999-90002`, firmada, `warnings: []` |
| 3. Enviar las dos | `POST /api/dispatches/send` | Ticket obtenido |
| 4. Consultar el ticket | `POST /api/dispatches/status_ticket` | `V999-90002` **aceptada**; `T999-90003` **rechazada con 3369** |
| 5. Corregir la rechazada | `POST /api/dispatches` con su mismo `external_id` | Mismo número: no se quema correlativo |
| 6. Reenviar y consultar | `send` y `status_ticket` | `T999-90003` **aceptada** |
| 7. Borrar rechazadas antiguas | `DELETE /api/dispatches/{external_id}` | 12 borradas; 2 conservadas con `503 SUNAT_UNREACHABLE` |

**El 3369 lo provocó un ejemplo de este manual:** la llegada iba con
`"codigo_del_domicilio_fiscal": null`. Con destinatario con RUC, el XML declara el RUC asociado al punto
de llegada, y SUNAT exige entonces el código de establecimiento. Desde el 2026-09-16 el sistema trata
`null` y la cadena vacía igual que no mandar la clave, es decir `"0000"`; en una instalación sin esa
actualización, envía `"0000"`.

**Los dos 503 son el comportamiento correcto.** Eran guías de enero de 2025 cuyo ticket ya no dio una
respuesta concluyente, y el sistema no borra lo que SUNAT no confirma.

## Cinco tropiezos que cuestan una tarde

Capturados emitiendo de verdad contra SUNAT. Todos devuelven un rechazo tras consumir el
correlativo, así que conviene conocerlos antes:

| Código | Qué pasa |
|---|---|
| 2560 | El transportista no puede ser el mismo que el remitente |
| 2567 | La placa no admite separadores: `ABC-123` se rechaza, `ABC123` pasa |
| 2775 | En la guía de transportista las direcciones van en `direcciones_proveedores`. Las habituales se aceptan y **se descartan en silencio** |
| 3359 | El documento del conductor se contrasta con el padrón de SUNAT |
| 3443 | El RUC del destinatario, también |

El de las direcciones es el más caro de depurar, porque el sistema acepta el payload sin
quejarse y el rechazo llega después, hablando de un ubigeo vacío que tú sí enviaste.

## Cuando el envío falla: cómo leer el aviso

El envío y la consulta devuelven los errores con el prefijo `Code: … - Message: …`. Lo que
viene después es lo que dijo el servidor, y conviene saber que **no todos hablan igual**:

| Servidor | Forma de la respuesta de error |
|---|---|
| SUNAT producción | `{"error_description":"Error en la autenticacion del usuario.","error":"access_denied"}` |
| Emulador de NubeFact (demo) | `{"cod":"500","msg":"'client_secret' incorrecto"}` |
| Rechazo de negocio del envío | `{"cod":"422","msg":"…","errors":[{"codError":"502","desError":"…"}]}` |

Esa diferencia importaba mucho, porque el sistema solo leía las claves de SUNAT. Contra el
emulador el motivo real se perdía y el aviso salía así, con los dos campos en blanco:

```
Code: 0 - Message: Error al obtener token - error_description:  error:
```

:::tip Ese mensaje vacío era, por sí solo, un diagnóstico
Si ves esa forma antigua en una instalación que aún no tiene la corrección, el tenant está en
**Demo** y fue el emulador quien rechazó la petición. En Producción el mensaje nunca sale
vacío: SUNAT siempre devuelve una descripción.
:::

Desde la corrección, el aviso dice el motivo venga de donde venga, y la respuesta completa
queda registrada en el log del tenant bajo la etiqueta `[GRE]`:

```
Error al obtener token - 'client_secret' incorrecto (codigo 500)
Error al obtener token - RUC incorrecto, debe ser de 11 dígitos (codigo 500)
Error al obtener token - Error en la autenticacion del usuario. (codigo access_denied)
no hubo respuesta del servidor (Operation timed out after 2000 milliseconds)
```

**Quién es el culpable, según el código**

SUNAT valida **primero el usuario** y después el cliente, así que el código reparte la culpa sin
ambigüedad (comprobado el 2026-09-15 repitiendo la petición con un `client_secret` inventado):

| Código | De quién es | Qué revisar |
|---|---|---|
| `access_denied` | Del **usuario SOL** | Que sea un usuario **secundario** con perfil de guía de remisión, escrito como RUC + usuario, con su clave del portal. Que entre al portal no basta: el portal también admite al usuario principal |
| `unauthorized_client` | Del **Client ID o la CLAVE** | Que se hayan copiado bien y pertenezcan a ese RUC |

Desde el panel esto se comprueba sin emitir nada con el botón **Verificar credenciales** de
Configuración → Empresa → Guías electrónicas.

**Las causas más frecuentes**

- **RUC incorrecto, debe ser de 11 dígitos.** En demo el usuario se arma con el RUC de la
  empresa emisora seguido de `MODDATOS`. Si el RUC guardado tiene espacios o caracteres de
  más, el emulador lo rechaza.
- **`client_secret` incorrecto.** En producción, credencial mal copiada o caducada. Ojo con el
  *client id*, que mide más de lo que admitían las columnas antiguas.
- **No hubo respuesta del servidor.** El tiempo de espera hacia SUNAT es de dos segundos, que
  es poco. Un envío que falle así **puede haber llegado igualmente**: antes de reintentar,
  comprueba si la guía ya tiene ticket, o generarás un envío duplicado.

## Fuentes oficiales

El contrato de esta API no lo define el sistema, lo define SUNAT. Estos son los documentos que
mandan:

| Documento | Qué fija |
|---|---|
| [Manual URL – GRE](https://cpe.sunat.gob.pe/sites/default/files/inline-files/Manual%20URL%20%E2%80%93%20GRE.xlsx) | Las tres direcciones, los nombres de cada campo y los códigos de error |
| [Manual de Servicios Web – Nueva GRE](https://cpe.sunat.gob.pe/sites/default/files/inline-files/Manual_Servicios_GRE%20%281%29_0.pdf) | La autenticación y el anexo de errores |
| [Reglas de Validación GRE](https://cpe.sunat.gob.pe/node/116) | Las validaciones de negocio, que cambian con cada resolución |
| [Preguntas frecuentes GRE](https://cpe.sunat.gob.pe/node/122) | La pregunta 18 confirma por escrito que **no hay ambiente de pruebas** |
| [RS 123-2022/SUNAT](https://www.sunat.gob.pe/legislacion/superin/2022/123-2022.pdf) | La norma matriz, y que el QR se genera con lo que SUNAT entrega en el CDR |

:::info El origen exacto del QR no está publicado
La norma dice que el QR se arma *"a partir de la información proporcionada por la SUNAT en el
CDR"*, y es lo que hace el sistema. Pero **en qué campo concreto del CDR viaja esa dirección no
figura en ningún manual público**. Es comportamiento observado, no contrato escrito. Si SUNAT
lo cambiara, no habría aviso previo en la documentación.
:::
