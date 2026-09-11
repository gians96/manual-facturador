# 13 — Guía de Remisión Remitente

> `POST /api/dispatches`  
> **Controller:** `Tenant\Api\DispatchController@store`  
> **Middleware:** `input.request:dispatch,api` (transforma campos español → inglés)  
> **Auth:** `Bearer {token}`  
> **Código tipo:** `"09"`

---

## Descripción

La guía de remisión del remitente documenta el **traslado de bienes** desde un punto de partida hasta un destino. Se emite cuando la empresa es quien envía la mercadería.

### Diferencia con Guía del Transportista

| Aspecto | Guía Remitente (**este doc**) | Guía Transportista ([14](14-guia-remision-transportista.md)) |
|---------|-------------------------------|--------------------------------------------------------------|
| Código tipo SUNAT | `09` | `31` |
| Endpoint | `POST /api/dispatches` | `POST /api/dispatch-carrier` |
| Emite | La empresa que **envía** la mercadería | La empresa de **transporte** contratada |
| Serie típica | `T001` | `V001` |
| Cliente / receptor | Destinatario final | Destinatario final (el remitente original va como dato extra) |
| Vehículos secundarios | No requeridos | Sí, puede llevar varios |
| Motivo traslado | Venta, compra, traslado entre almacenes, etc. | Traslado por encargo de terceros |

---

## Payload

```json
{
    "serie_documento": "T001",
    "numero_documento": "#",
    "fecha_de_emision": "2026-04-18",
    "hora_de_emision": "08:00:00",
    "codigo_tipo_documento": "09",
    "datos_del_emisor": {
        "codigo_del_domicilio_fiscal": "0000"
    },
    "datos_del_cliente_o_receptor": {
        "codigo_tipo_documento_identidad": "6",
        "numero_documento": "20123456789",
        "apellidos_y_nombres_o_razon_social": "EMPRESA DEMO S.A.C.",
        "codigo_pais": "PE",
        "ubigeo": "150101",
        "direccion": "PJ. JORGE BASADRE NRO. 158",
        "correo_electronico": null,
        "telefono": null
    },
    "observaciones": "Traslado de mercadería por venta",
    "codigo_modo_transporte": "01",
    "codigo_motivo_traslado": "01",
    "descripcion_motivo_traslado": "Venta",
    "fecha_de_traslado": "2026-04-19",
    "indicador_de_transbordo": false,
    "unidad_peso_total": "KGM",
    "peso_total": 25.5,
    "numero_de_bultos": 3,
    "numero_de_contenedor": null,
    "direccion_partida": {
        "ubigeo": "150101",
        "direccion": "Av. Principal 123, Lima",
        "codigo_del_domicilio_fiscal": "0000"
    },
    "direccion_llegada": {
        "ubigeo": "150132",
        "direccion": "Jr. Los Olivos 456, San Juan de Lurigancho",
        "codigo_del_domicilio_fiscal": null
    },
    "transportista": {
        "codigo_tipo_documento_identidad": "6",
        "numero_documento": "20123456789",
        "apellidos_y_nombres_o_razon_social": "TRANSPORTES LIMA S.A.C.",
        "numero_mtc": "123456"
    },
    "chofer": {
        "codigo_tipo_documento_identidad": "1",
        "numero_documento": "12345678",
        "nombres": "JUAN PEREZ GARCIA",
        "numero_licencia": "Q12345678",
        "telefono": "999888777"
    },
    "vehiculo": {
        "numero_de_placa": "ABC-123",
        "modelo": "HINO 500",
        "marca": "HINO",
        "certificado_habilitacion_vehicular": null
    },
    "items": [
        {
            "codigo_interno": "ASD",
            "descripcion": "Mercadería trasladada",
            "unidad_de_medida": "NIU",
            "cantidad": 10
        }
    ]
}
```

---

## Campos del Payload

### Cabecera

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `serie_documento` | string | **Sí** | Serie de guía: `"T001"` |
| `numero_documento` | string | **Sí** | `"#"` auto-numerar o número concreto |
| `fecha_de_emision` | string | **Sí** | `YYYY-MM-DD` |
| `hora_de_emision` | string | **Sí** | `HH:mm:ss` |
| `codigo_tipo_documento` | string | **Sí** | `"09"` Guía Remitente |
| `datos_del_emisor` | object | No | Solo `codigo_del_domicilio_fiscal`. **Si no lo envías se usa el establecimiento del usuario del token**, igual que en `POST /api/documents`. Si lo envías con un código que no existe, `INVALID_ESTABLISHMENT` |
| `datos_del_cliente_o_receptor.codigo_pais` | string | No | Opcional **desde el 2026-09-09**: si no lo envías se asume `"PE"`, igual que el panel y la API de notas de venta. Si el cliente ya existe con otro país, se conserva el suyo. Antes, omitirlo devolvía `NULL_NOT_ALLOWED` |
| `hora_de_emision` | string | **Sí** | `HH:mm:ss`. `dispatches.time_of_issue` no admite null |
| `observaciones` | string | No | Observaciones |
| `codigo_modo_transporte` | string | **Sí** | `"01"` Transporte público, `"02"` Transporte privado |
| `codigo_motivo_traslado` | string | **Sí** | Ver tabla de motivos |
| `descripcion_motivo_traslado` | string | No | Descripción del motivo |
| `fecha_de_traslado` | string | **Sí** | Fecha inicio del traslado `YYYY-MM-DD` |
| `indicador_de_transbordo` | bool | No | Si hay transbordo. Desde el 2026-09-09 también se acepta como texto (`"true"` / `"false"`); ausente cuenta como `false`. Antes, un `"FALSE"` de texto se rechazaba nombrando una columna interna |
| `unidad_peso_total` | string | **Sí** | Unidad de peso: `"KGM"` (kilos), `"TNE"` (toneladas) |
| `peso_total` | float | **Sí** | Peso total de la carga |
| `numero_de_bultos` | int | No | Cantidad de bultos |
| `numero_de_contenedor` | int\|null | No | Número de contenedor. **Solo admite dígitos:** un código ISO 6346 alfanumérico (`"MSKU1234567"`) se rechaza con `INVALID_NUMERIC_VALUE`. Si no aplica, envía `null` — no `""` |

### `direccion_partida` (origen)

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `ubigeo` | string | **Sí** | Código ubigeo (6 dígitos) |
| `direccion` | string | **Sí** | Dirección completa (máx. 100 caracteres) |
| `codigo_del_domicilio_fiscal` | string\|null | No | Código establecimiento SUNAT. Opcional **de verdad desde el 2026-09-09**: antes, omitir la clave devolvía un 500 aunque aquí figurase como opcional. Si no aplica, omítela o envía `null`; el servidor usa `"0000"` |

### `direccion_llegada` (destino)

Misma estructura que `direccion_partida`.

### `transportista`

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `codigo_tipo_documento_identidad` | string | **Sí** | `"6"` (RUC) para empresas |
| `numero_documento` | string | **Sí** | RUC del transportista |
| `apellidos_y_nombres_o_razon_social` | string | **Sí** | Razón social |
| `numero_mtc` | string | No | Número de registro MTC. Opcional **de verdad desde el 2026-09-09**: antes, omitirlo devolvía un 500 |

> Solo requerido si `codigo_modo_transporte = "01"` (transporte público) — y desde el
> 2026-09-09 el servidor lo comprueba y lo dice por su nombre. Antes, omitirlo en transporte
> público era un 500.
>
> Con `codigo_modo_transporte = "02"` (transporte privado) el bloque obligatorio es `chofer`,
> por el mismo motivo y con la misma comprobación.

### `chofer`

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `codigo_tipo_documento_identidad` | string | **Sí** | `"1"` (DNI) |
| `numero_documento` | string | **Sí** | DNI del chofer |
| `nombres` | string | **Sí** | Nombre completo |
| `numero_licencia` | string | **Sí** | Número de licencia de conducir |
| `telefono` | string | No | Teléfono del chofer |

### `vehiculo`

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `numero_de_placa` | string | **Sí** | Placa del vehículo |
| `modelo` | string | No | Modelo del vehículo |
| `marca` | string | No | Marca del vehículo |
| `certificado_habilitacion_vehicular` | string\|null | No | TUC |

### Motivos de Traslado (`codigo_motivo_traslado`)

El catálogo vigente es el de la **Resolución de Superintendencia 000240-2024**, que sustituye al
anterior. Son catorce códigos:

| Código | Descripción |
|--------|-------------|
| `01` | Venta |
| `02` | Compra |
| `03` | Venta con entrega a terceros |
| `04` | Traslado entre establecimientos de la misma empresa |
| `05` | Consignación |
| `06` | Devolución |
| `07` | Recojo de bienes transformados |
| `08` | Importación |
| `09` | Exportación |
| `13` | Otros no comprendidos en ningún código del presente catálogo |
| `14` | Venta sujeta a confirmación del comprador |
| `17` | Traslado de bienes para transformación |
| `18` | Traslado por emisor itinerante de comprobantes de pago |
| `19` | Traslado de mercancía extranjera |

:::warning Esta tabla estaba mal hasta el 2026-09-11
Faltaban tres códigos (`05`, `06` y `07`) y las descripciones estaban corridas una fila: el `17`
mostraba lo del `18`, el `18` lo que antes era el `19`, y el `19` mostraba *«Compra con entrega a
terceros»*, que **no existe en ningún catálogo de SUNAT**.

Ojo con el `19`, porque no cambió de nombre sino de identidad: en el catálogo de 2012 era
*«Traslado a zona primaria»*, luego desapareció, y volvió el 14 de noviembre de 2024 con un
significado distinto. Si encuentras la descripción antigua en algún sitio, está desactualizada.
:::

### `items[]`

:::tip Una guía de remisión NO lleva precios
Es la duda más frecuente al integrar guías desde un ERP, porque esta página remitía a la
estructura de una factura. La tabla `dispatch_items` **no tiene columna de importe** y el XML
`DespatchAdvice` solo emite tres cosas por línea: cantidad, descripción y código de producto.
Si tu sistema solo conoce la cantidad atendida, con eso basta.
:::

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `codigo_interno` | string | **Sí** | Debe coincidir exactamente con el del producto. Sin él, todas las líneas se agrupan en un mismo producto y la guía sale con un solo detalle |
| `cantidad` | number | **Sí** | Mayor que 0. Es el `<cbc:DeliveredQuantity>` del XML |
| `descripcion` | string | Condicional | Solo si el `codigo_interno` **no existe todavía** y hay que crear el producto |
| `unidad_de_medida` | string | Condicional | Igual: solo al crear. Catálogo 03 de SUNAT (`NIU`, `KGM`, `TNE`…) |
| `valor_unitario` | number | No | Opcional incluso al crear: el producto nace con precio 0, visible en el panel para corregirlo |

Ejemplo completo de un ítem de guía:

```json
{ "codigo_interno": "200020001", "descripcion": "CONCENTRADO DE COBRE",
  "unidad_de_medida": "TNE", "cantidad": 9.57 }
```

`precio_unitario`, `total_item`, `porcentaje_igv`, `total_base_igv`, `total_impuestos` y el
resto del bloque de una factura **se aceptan por compatibilidad y se descartan**: no llegan al
XML ni se guardan como importe.

:::note La descripción del XML sale del producto, no de la línea
`<cbc:Description>` se toma de la ficha del producto (`items.description`), no de la
`descripcion` que mandas en el ítem. La de la línea sí aparece en el PDF. Si necesitas texto
que cambia por viaje —precintos, lotes— tenlo en cuenta al revisar el XML firmado.
:::

---

## Response (200 OK)

```json
{
    "success": true,
    "data": {
        "number": "T001-12",
        "filename": "20123456789-09-T001-12",
        "external_id": "abc-def-123"
    }
}
```

---

## Endpoints Adicionales

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `POST` | `/api/dispatches/send` | Enviar guía a SUNAT por `external_id` |
| `POST` | `/api/dispatches/status_ticket` | Consultar estado del ticket en SUNAT |
| `GET` | `/api/dispatches/tables` | Tablas auxiliares (modos transporte, motivos, etc.) |
| `GET` | `/api/dispatches/records` | Listar guías emitidas (paginado) |

Descarga de los archivos. Son rutas **públicas**: no piden token, las protege solo el
`external_id`.

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/downloads/dispatch/pdf/{external_id}/{formato?}` | PDF. Se regenera con el QR si la guía ya tiene CDR |
| `GET` | `/downloads/dispatch/xml/{external_id}` | XML firmado |
| `GET` | `/downloads/dispatch/cdr/{external_id}` | CDR, solo cuando SUNAT ya respondió |

:::warning El PDF del paso 1 no lleva QR
Se puede descargar desde que la guía se registra, pero el QR lo entrega SUNAT dentro del CDR:
aparece recién al consultar el ticket con resultado aceptado. Vuelve a pedir el PDF después de
ese paso.

→ [El QR y el PDF: cuándo aparecen](../../guias-de-remision.md#el-qr-y-el-pdf-cuándo-aparecen)
:::

---

## Notas para Offline

- **La guía requiere firma digital y envío a SUNAT (GRE 2.0).** Al crear offline, se almacena localmente y se procesa al sincronizar.
- Las direcciones de partida/llegada usan ubigeo del catálogo descargado (ver [05-ubigeo.md](05-ubigeo.md)).
- Validaciones estrictas del backend: `direccion_llegada.direccion` y `direccion_partida.direccion` son **requeridos** y máx. 100 caracteres. (Hasta el 2026-09-09 el error los nombraba como `delivery.address` y `origin.address`, que son los nombres internos y no existen en tu payload.)
- Para offline, enviar `numero_documento` con número concreto basado en `series-numbering`.
