---
sidebar_position: 2.3
title: "Documentos relacionados: enlazar guías y comprobantes"
sidebar_label: "Documentos relacionados"
---

# Documentos relacionados: enlazar guías y comprobantes

Hay **siete claves** en la API para decir «este documento tiene que ver con aquel otro».
Se llaman parecido, viven en dos endpoints distintos y acaban en cuatro sitios distintos.
Equivocarse no da error: da un comprobante que parece correcto y al que le falta algo.

Esta página es el mapa. Si solo vas a leer una cosa, que sea la tabla siguiente.

## La tabla que resuelve casi todo

| Clave | Endpoint | Dónde acaba | ¿La ve SUNAT? | ¿Enlaza los registros? |
|---|---|---|---|---|
| `guias[]` | `/api/documents` | `documents.guides` | Sí, `cac:DespatchDocumentReference` | **No** |
| `relacionados[]` | `/api/documents` | `documents.related` | Sí, `cac:AdditionalDocumentReference` | **No** |
| `anticipos[]` | `/api/documents` | `documents.prepayments` | Sí, como anticipo deducido | **No** |
| `documento_relacionado[]` | `/api/dispatches`<br/>`/api/dispatch-carrier` | `dispatches.reference_documents` | Sí, `cac:AdditionalDocumentReference` (catálogo 61) | **No** |
| `documento_afectado` | `/api/dispatches`<br/>`/api/dispatch-carrier` | `dispatches.data_affected_document` | **No** — solo el PDF | **No** |
| **`comprobante_de_referencia`** | `/api/dispatches`<br/>`/api/dispatch-carrier` | `dispatches.reference_document_id` | Sí — deriva `documento_relacionado` si no lo mandas | **Sí** |
| **`guia_de_origen`** | `/api/documents` | `documents.dispatch_id` | No | **Sí** |
| **`guias_relacionadas[]`** | `/api/documents` | `reference_document_id` de cada guía | No | **Sí** |

Las tres en negrita son nuevas desde el **2026-09-08**. Antes de esa fecha **la API no
podía enlazar nada**: solo se podía mandar el texto que va al XML.

## Texto y enlace no son lo mismo

Son dos cosas independientes, y casi siempre quieres las dos.

**El texto** es lo que SUNAT lee en el XML. Es lo que cumple la obligación formal de
declarar qué guía sustenta la factura, o qué factura sustenta el traslado.

**El enlace** es lo que el sistema sabe. Es lo que hace que:

- la guía deje de aparecer en «Generar comprobante desde múltiples guías», de modo que
  nadie la facture dos veces;
- el listado de guías muestre el **N.º de comprobante** en su columna;
- el PDF de la guía imprima el comprobante que la sustenta;
- los reportes que cruzan guías con comprobantes las encuentren.

Puedes tener uno sin el otro. Mandar solo `guias[]` deja un XML impecable y una guía que
sigue figurando como pendiente de facturar. Mandar solo `guia_de_origen` deja el sistema
cuadrado y a SUNAT sin enterarse. Para la mayoría de integraciones, lo correcto es mandar
las dos cosas — salvo en `comprobante_de_referencia`, que se encarga solo (ver más abajo).

:::warning Esto mueve el stock
Los enlaces no son etiquetas: cambian quién descuenta las existencias.

- **`comprobante_de_referencia`** → la guía **no** descuenta stock. Es lo correcto: ya lo
  descontó el comprobante que la origina.
- **`guia_de_origen`** → el comprobante **no** descuenta stock. También es lo correcto: ya
  lo descontó la guía.
- **`guias_relacionadas`** → no cambia nada; el comprobante descuenta con normalidad.

Ese último caso tiene un límite conocido: si las guías ya descontaron existencias y
facturas con `guias_relacionadas`, **el stock se descuenta dos veces**. Le pasa igual al
flujo web equivalente y está pendiente de arreglo. Mientras tanto, si tus guías descuentan
stock, usa `guia_de_origen` para el enlace.
:::

## Las tres formas de nombrar un documento

`comprobante_de_referencia`, `guia_de_origen` y cada elemento de `guias_relacionadas`
aceptan la misma gramática. Elige una:

```json
{ "external_id": "46c6ce9d-aaae-4b8d-8e94-a6f94c964b47" }
```

```json
{ "serie_documento": "F001", "numero_documento": "190", "codigo_tipo_documento": "01" }
```

```json
{ "codigo": 1234 }
```

- **`external_id`** es la recomendada: es lo que te devolvió la API al emitir ese
  documento, y no depende de nada más.
- La **terna** es cómoda si guardas serie y número. `codigo_tipo_documento` es opcional;
  mándalo si una misma serie-número pudiera existir en dos tipos distintos. El correlativo
  admite ceros a la izquierda (`"190"` y `"00000190"` encuentran la misma fila), y también
  se acepta la forma combinada `"F001-190"` en `numero_documento`.
- **`codigo`** es el id interno del registro. Sirve como último recurso.

## Recetas

Todas las llamadas llevan `Authorization: Bearer <TU_TOKEN>` y
`Content-Type: application/json`. Ver [Errores de la API](./errores-de-la-api.md) si algo
no sale.

### Facturo primero y luego emito la guía

Lo más habitual: la venta genera la factura, y el traslado de la mercadería genera la guía.

```json
// POST /api/dispatches
{
  "serie_documento": "T001",
  "numero_documento": "#",
  "codigo_tipo_documento": "09",
  "comprobante_de_referencia": { "external_id": "46c6ce9d-…" },
  "...": "resto del payload de la guía"
}
```

Con eso basta: además de escribir el enlace, **rellena `documento_relacionado` por ti** con
la factura, de modo que el `cac:AdditionalDocumentReference` sale en el XML igual que si la
hubieras emitido desde el formulario web. Si mandas `documento_relacionado` a mano, se
respeta el tuyo y no se toca.

Comprueba que funcionó: la guía debe mostrar el número de la factura en la columna
**N.º Comprobante** del listado, y ya no debe ofrecer «Generar comprobante».

### Traslado primero, factura después

```json
// POST /api/documents
{
  "serie_documento": "F001",
  "numero_documento": "#",
  "codigo_tipo_documento": "01",
  "guia_de_origen": { "serie_documento": "T001", "numero_documento": "4", "codigo_tipo_documento": "09" },
  "guias": [ { "codigo_tipo_documento": "09", "numero": "T001-4" } ],
  "...": "resto del payload de la factura"
}
```

Aquí sí hacen falta las dos claves: `guia_de_origen` crea el enlace, `guias` pone la
referencia en el XML que ve SUNAT.

### Una factura que cierra varias guías

```json
// POST /api/documents
{
  "guias_relacionadas": [
    { "serie_documento": "T001", "numero_documento": "5", "codigo_tipo_documento": "09" },
    { "external_id": "9f3e…" },
    { "codigo": 44 }
  ],
  "guias": [
    { "codigo_tipo_documento": "09", "numero": "T001-5" },
    { "codigo_tipo_documento": "09", "numero": "T001-6" },
    { "codigo_tipo_documento": "09", "numero": "T001-7" }
  ],
  "...": "resto del payload de la factura"
}
```

Las tres guías quedan apuntando a esta factura y sus PDF se regeneran para imprimirla.

### Solo quiero que la guía salga en el XML, sin enlazar nada

Manda únicamente `guias[]`. Es lo que hacía todo el mundo antes del 2026-09-08 y sigue
siendo válido.

## Una guía no se factura dos veces

Si una de las guías que mandas en `guias_relacionadas` o en `guia_de_origen` ya está
facturada, la petición se rechaza:

```json
{
  "success": false,
  "message": "Guías ya facturadas en 'guias_relacionadas': T001-5 (ya facturada por F001-190). Si el comprobante anterior fue anulado, la guía vuelve a estar disponible.",
  "error_code": "DISPATCH_ALREADY_LINKED"
}
```

Si el comprobante anterior está **anulado**, la guía vuelve a quedar libre y se puede
facturar de nuevo: anular y reemitir es un flujo normal.

## `documento_afectado` no enlaza nada

Es la clave que más confusión genera, porque su nombre y su descripción sugerían un enlace
que nunca ocurría.

`documento_afectado` guarda serie, número y tipo del comprobante que sustenta el traslado y
**los imprime en el PDF de la guía**. Eso es todo: no viaja en el XML y no relaciona los
registros. Si lo que quieres es el enlace, la clave es `comprobante_de_referencia`; si lo
que quieres es que SUNAT lo vea, es `documento_relacionado`.

:::info Corregido el 2026-09-08
Hasta esa fecha, `documento_afectado` con `external_id` **se descartaba en silencio**: la
guía se emitía sin ningún dato del comprobante y sin ningún aviso. Ahora se resuelve y se
imprime, igual que la forma con serie/número/tipo.
:::

## La guía de transportista (31) en la factura

:::danger Hoy no llega a SUNAT
Si mandas `guias: [{ "codigo_tipo_documento": "31", … }]` en una factura, el sistema la
guarda y la imprime en el PDF, pero **la omite del XML**. SUNAT no la ve.

No es una regla de SUNAT: las notas de crédito y débito sí la emiten, y la guía oficial de
elaboración del XML habla de guías «remitente **o transportista**, según corresponda». Es
una divergencia del sistema, pendiente de comprobar en el entorno de pruebas antes de
cambiarla — un XML mal formado tumba la factura entera.

Mientras tanto: con el tipo `31` no hay forma de que SUNAT vea la referencia por esta vía.
:::

## Errores

Todos son **422**, con la forma habitual (`success`, `message`, `error_code`) descrita en
[Errores de la API](./errores-de-la-api.md).

| `error_code` | Cuándo |
|---|---|
| `REFERENCE_NOT_FOUND` | La serie-número, el `external_id` o el `codigo` no corresponden a ningún documento del sistema |
| `MISSING_FIELDS` | Falta `serie_documento`/`numero_documento`, o falta `numero` o `monto` en `guias`/`anticipos`/`relacionados` |
| `MALFORMED_REFERENCE` | La referencia no es un objeto, o el elemento de la lista no lo es. Distinto de `INVALID_REFERENCE`, que es un código inexistente en su catálogo |
| `AMBIGUOUS_REFERENCE` | La serie-número encaja con más de un documento. Añade `codigo_tipo_documento` |
| `INVALID_DOCUMENT_TYPE` | El `codigo_tipo_documento` de una guía no existe en el catálogo. En guías se usa `"09"` o `"31"` |
| `DISPATCH_ALREADY_LINKED` | Una de las guías ya está facturada por un comprobante vigente |

:::tip El nombre del correlativo
En `guias[]`, `anticipos[]` y `relacionados[]` la clave es **`numero`**, no
`numero_documento`. Desde el 2026-09-08 se acepta también `numero_documento` como alias,
porque es como se llama esa clave en el resto del payload y confundirse era lo natural —
antes daba un HTTP 500.
:::

## Ver también

- [Guías de remisión: cómo funcionan por dentro](./guias-de-remision.md) — por qué una guía
  necesita tres llamadas y credenciales aparte.
- [Emisión: items, productos y clientes](./emision-items-y-catalogo.md) — cómo se crean o
  reutilizan los productos al emitir.
- [Errores de la API](./errores-de-la-api.md).
