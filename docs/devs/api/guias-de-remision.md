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
