---
sidebar_position: 2
title: "Emisión: items, productos y clientes"
sidebar_label: "Items, productos y clientes"
---

# Emisión desde otra aplicación: items, productos y clientes

Esta guía explica, para una **aplicación externa** que consume el API, qué ocurre con los
**productos (items)** y con el **cliente** cuando emites una factura, boleta, nota o guía de
remisión: cómo se crean en el catálogo del Facturador si no existen, y cómo `codigo_interno` evita
duplicarlos.

:::info Requisito previo
Todas las peticiones van a `https://TU-DOMINIO/api/...` con el encabezado
`Authorization: Bearer <TOKEN>`. Ese token es el **Api Token** de un usuario
(Configuración → Usuarios → botón *Generar Token*, o `POST /api/login`). Revisa la
[Introducción](./introduccion.md) para el detalle completo de autenticación.
:::

## Qué ocurre internamente al emitir

Cuando envías `POST /api/documents` (o `POST /api/dispatches`), **antes** de firmar y mandar el
comprobante a SUNAT, el sistema ejecuta este pipeline:

1. **Autenticación y licencia** — valida el `Bearer` y que la cuenta/emisión no estén bloqueadas.
2. **Traducción** — convierte tus claves en español al formato interno.
3. **Validación y resolución** — valida la serie, **crea o actualiza el cliente**, y **resuelve o
   crea cada producto** del catálogo. 👈 *Aquí es donde tus items entran al catálogo.*
4. **Emisión** — arma el comprobante, firma el XML y lo envía (facturas y NC/ND de factura) o lo
   deja registrado para el resumen diario (boletas), etc.

:::warning Efecto secundario importante
La creación de **productos** y del **cliente** ocurre como *efecto secundario* de emitir, **antes**
de que el comprobante llegue a SUNAT. No necesitas pre-cargar el catálogo: puedes emitir con un
producto que no existe y el Facturador lo crea al vuelo.
:::

## Productos (items): creación y anti-duplicado

La llave con la que el Facturador identifica un producto es **`codigo_interno`** (campo interno
`internal_id`, **máximo 30 caracteres**).

| Situación (según `codigo_interno`) | Comportamiento |
|---|---|
| **Código nuevo** (no existe en el catálogo) | **Crea** un producto nuevo con los datos que enviaste (descripción, unidad, precio, afectación IGV, códigos SUNAT/GS1). Stock inicial **0**. |
| **Código ya existente** | **Reutiliza** ese producto (NO se duplica). Solo actualiza la **descripción** si envías `actualizar_descripcion: true` (valor por defecto). **No** cambia el precio ni los demás datos del catálogo. |
| **Sin `codigo_interno` o vacío** | El código interno queda como cadena vacía `""` → **todos** los productos sin código colapsan en **un único** item de catálogo. ⚠️ Evítalo siempre. |

### Con qué datos se crea el producto nuevo

Al crear un producto por primera vez, el catálogo toma estos campos de la línea:

| Campo del catálogo | Viene de (payload) |
|---|---|
| Código interno | `codigo_interno` |
| Descripción | `descripcion` |
| Nombre | `nombre` |
| Unidad de medida | `unidad_de_medida` |
| Tipo de item | `codigo_tipo_item` (por defecto `01` = producto) |
| Código producto SUNAT | `codigo_producto_sunat` |
| Código GS1 | `codigo_producto_gsl` |
| Precio de venta | `precio_unitario` |
| Afectación IGV (venta y compra) | `codigo_tipo_afectacion_igv` |
| Moneda | `codigo_tipo_moneda` del comprobante |
| Stock inicial | **0** |

:::tip El comprobante siempre usa lo que envías
El catálogo solo sirve para **vincular** la línea con un producto (`item_id`). Los valores que
aparecen en el comprobante (descripción, precio, cantidad, impuestos) son **siempre** los que
mandas en la línea, no los del catálogo. Por eso puedes emitir aunque el producto no exista todavía.
:::

### Recomendaciones para integradores

- **Manda siempre un `codigo_interno` estable y único por producto** (tu propio SKU). Es la única
  forma de que no se dupliquen los productos entre emisiones. Máximo 30 caracteres.
- **No hay índice único en base de datos** sobre `codigo_interno`: el anti-duplicado es a nivel de
  aplicación (*buscar → si no existe, crear*). Consecuencias:
  - Usa códigos deterministas (no aleatorios por emisión).
  - Evita crear el **mismo código nuevo** en dos peticiones **concurrentes** (podría generar 2
    productos por condición de carrera).
- **El precio del catálogo se fija con el primer `precio_unitario`** visto para ese código; las
  emisiones posteriores con el mismo código **no** actualizan el precio del catálogo (el
  comprobante sí usa el precio que envías). Si tú administras los precios, esto no te afecta.
- Si administras las descripciones en tu sistema y **no** quieres que el catálogo del Facturador cambie,
  envía **`actualizar_descripcion: false`** en la línea.

### Ejemplo de línea de item

```json
{
  "items": [
    {
      "codigo_interno": "SKU-000123",
      "descripcion": "Polo algodón talla M",
      "unidad_de_medida": "NIU",
      "codigo_tipo_afectacion_igv": "10",
      "cantidad": 2,
      "valor_unitario": 50.00,
      "precio_unitario": 59.00,
      "actualizar_descripcion": false
    }
  ]
}
```

## Guías de remisión: misma llave, distinto stock inicial

En `POST /api/dispatches` los items también se resuelven/crean por `codigo_interno`, con una
diferencia: al **crear** un producto nuevo, el stock inicial se fija en la **cantidad** enviada
(no en 0). El anti-duplicado por `codigo_interno` funciona igual que en los comprobantes.

## Cliente / receptor: también se crea o actualiza

El bloque `datos_del_cliente_o_receptor` hace **upsert** del cliente en el módulo Clientes. La
llave es **tipo de documento de identidad + número**:

- Si el cliente **no existe**, se crea.
- Si **ya existe**, se **actualiza** con los datos enviados: razón social/nombre, dirección,
  ubigeo, correo, teléfono, etc.

:::note
Reemitir al mismo RUC/DNI con datos distintos **actualiza** ese cliente en el Facturador. En la guía de
transportista (tipo `31`) no se procesa cliente.
:::

## Idempotencia: evita comprobantes duplicados con `offline_id`

Si tu integración puede **reintentar** una emisión (timeout de red, reintento automático), envía un
**`offline_id`** único por cada emisión lógica:

- Si ya existe un comprobante con ese `offline_id`, el API **no crea otro**: devuelve el existente
  con **`was_duplicate: true`** en la respuesta.
- Sin `offline_id`, cada `POST /api/documents` intenta crear un comprobante nuevo.

```json
{
  "offline_id": "APP-2026-000045",
  "serie_documento": "F001",
  "numero_documento": "#",
  "...": "resto del comprobante"
}
```

:::tip Patrón recomendado
Genera el `offline_id` en tu sistema **antes** de llamar al API y reutilízalo en los reintentos de
esa misma venta. Así, aunque envíes la petición 2 o 3 veces, obtendrás siempre el mismo comprobante.
:::

## Checklist para integrar desde otra aplicación

- Obtén el **token** del usuario (Configuración → Usuarios) y envíalo como `Authorization: Bearer`.
- Usa `numero_documento: "#"` para que el correlativo sea automático.
- Asigna un **`codigo_interno` estable y único (≤30 caracteres)** a cada producto.
- Decide `actualizar_descripcion` (`true`/`false`) según si administras las descripciones.
- Envía un **`offline_id`** único por emisión y reutilízalo en los reintentos.
- Guarda el **`external_id`** de la respuesta: identifica al comprobante en anulaciones, notas y
  consultas de estado.
- Para **boletas**, recuerda declararlas por **resumen diario** (`POST /api/summaries`).
