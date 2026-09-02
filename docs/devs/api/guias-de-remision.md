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

## Modo de pruebas

En modo demo las guías no se envían a SUNAT sino a un entorno de pruebas, con credenciales de
prueba ya incorporadas. Sirve para validar la estructura del XML y el flujo completo sin
emitir nada real.
