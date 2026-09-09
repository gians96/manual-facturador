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

## Credenciales: son otras, no las de facturación

El token de la API GRE **no** se obtiene con el usuario y clave SOL que ya usas para
facturar. Hace falta registrar en SUNAT un *cliente API SOL*, que entrega:

- `client_id` y `client_secret`
- un **usuario SOL secundario** con permiso sobre guías

Con esos cuatro datos el sistema pide el token (`grant_type=password`) y lo reutiliza durante
una hora antes de renovarlo. Si las guías fallan con error de autenticación y las facturas
siguen saliendo bien, casi siempre es que faltan o caducaron estas credenciales — no las de
facturación.

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

Cuando hay CDR, se descarga, se guarda y de ahí sale la URL del QR. Igual que en producción.

:::warning Lo que el modo demo NO prueba
- **El CDR de demo no tiene valor fiscal.** La guía no queda registrada en SUNAT ni aparece en
  SUNAT SOL.
- **El emulador no consulta los padrones reales**: RUC del destinatario, series autorizadas, estado
  del contribuyente. Una guía aceptada en demo puede ser rechazada en producción.
- **Los correlativos avanzan igual.** Lo emitido en demo consume numeración de la serie. Revísala
  antes de pasar a producción.
- **Es un servicio de terceros.** Si está caído, el modo demo falla aunque el sistema esté bien.
:::

## Cómo probar una guía en demo

### Lo que no hace falta

- **La credencial GRE de SUNAT SOL.** En demo el sistema **descarta** el usuario secundario y el
  *client id* / *client secret* que estén configurados, y usa los de prueba. Esos campos pueden
  quedar vacíos.
- **Un certificado digital propio.** En demo se firma con un certificado de prueba que viene
  incluido. El certificado propio solo se exige en Producción.

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

### Pasos

1. Poner **SOAP Tipo** en **Demo**.
2. Tener registrada la serie de guías del establecimiento.
3. Emitir la guía. Recordar que la `09` va por `POST /api/dispatches` y la `31` por
   `POST /api/dispatch-carrier`.
4. Enviarla y consultar el ticket hasta que deje de responder `98`.

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
