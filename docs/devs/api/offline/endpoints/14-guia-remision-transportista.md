# 14 — Guía de Remisión Transportista

> `POST /api/dispatch-carrier`  
> **Controller:** `Modules\Dispatch\Http\Controllers\Api\DispatchCarrierController@store`  
> **Middleware:** `input.request:dispatch,api`  
> **Auth:** `Bearer {token}`  
> **Código tipo:** `"31"`

---

## Descripción

La guía de remisión del transportista la emite la **empresa de transporte** que traslada los bienes. A diferencia de la guía del remitente, incluye datos del remitente y destinatario como terceros, y puede tener vehículos secundarios.

> 📘 Ver tabla comparativa con guía remitente en [13-guia-remision-remitente.md](13-guia-remision-remitente.md#diferencia-con-guía-del-transportista).

---

## Payload

```json
{
    "serie_documento": "V001",
    "numero_documento": "#",
    "fecha_de_emision": "2026-04-18",
    "hora_de_emision": "07:00:00",
    "codigo_tipo_documento": "31",
    "observaciones": "Traslado de mercadería",
    "codigo_modo_transporte": "01",
    "codigo_motivo_traslado": "01",
    "descripcion_motivo_traslado": "Venta",
    "fecha_de_traslado": "2026-04-19",
    "indicador_de_transbordo": false,
    "unidad_peso_total": "KGM",
    "peso_total": 50.0,
    "numero_de_bultos": 5,
    "direccion_partida": {
        "ubigeo": "150101",
        "direccion": "Av. Principal 123, Lima",
        "codigo_del_domicilio_fiscal": "0000"
    },
    "direccion_llegada": {
        "ubigeo": "040101",
        "direccion": "Jr. Mercaderes 456, Arequipa",
        "codigo_del_domicilio_fiscal": null
    },
    "datos_remitente": {
        "codigo_tipo_documento_identidad": "6",
        "descripcion_tipo_documento_identidad": "RUC",
        "numero_documento": "20123456789",
        "apellidos_y_nombres_o_razon_social": "EMPRESA DEMO S.A.C."
    },
    "datos_destinatario": {
        "codigo_tipo_documento_identidad": "6",
        "descripcion_tipo_documento_identidad": "RUC",
        "numero_documento": "20123456789",
        "apellidos_y_nombres_o_razon_social": "EMPRESA DEMO S.A.C."
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
        "certificado_habilitacion_vehicular": "HAB-001"
    },
    "vehiculo_secundario": [
        {
            "numero_de_placa": "DEF-456",
            "modelo": "Carreta",
            "marca": "FACCHINI",
            "certificado_habilitacion_vehicular": null
        }
    ],
    "chofer_secundario": [
        {
            "codigo_tipo_documento_identidad": "1",
            "numero_documento": "87654321",
            "nombres": "PEDRO GOMEZ RUIZ",
            "numero_licencia": "Q87654321",
            "telefono": "999777666"
        }
    ],
    "pagador_flete": {
        "indicador_pagador_flete": "Remitente",
        "codigo_tipo_documento_identidad": "6",
        "descripcion_tipo_documento_identidad": "RUC",
        "numero": "20123456789",
        "nombres": "EMPRESA DEMO S.A.C."
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

## Campos Específicos del Transportista (diferentes a Remitente)

### `datos_remitente` — Quien envía la mercadería

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `codigo_tipo_documento_identidad` | string | **Sí** | `"6"` RUC, `"1"` DNI |
| `descripcion_tipo_documento_identidad` | string | No | `"RUC"`, `"DNI"`. Opcional **de verdad desde el 2026-09-09**: antes, omitirlo devolvía un 500 aunque aquí figurase como opcional |
| `numero_documento` | string | **Sí** | Número de documento |
| `apellidos_y_nombres_o_razon_social` | string | **Sí** | Razón social |

El bloque entero es **obligatorio** en el `31`, igual que `datos_destinatario` y `chofer`. Sin
ellos la guía se emitía igual y SUNAT la rechazaba, con el correlativo ya consumido; desde el
2026-09-09 se rechaza antes de emitir, nombrando el bloque que falta.

### `items[]`

:::tip Una guía de remisión NO lleva precios
`dispatch_items` no tiene columna de importe y el XML `DespatchAdvice` solo emite cantidad,
descripción y código de producto. Mismo criterio que la guía remitente: ver
[13 — `items[]`](13-guia-remision-remitente.md#items).
:::

| Campo | Requerido |
|---|---|
| `codigo_interno` | **Sí**. Sin él todas las líneas se agrupan en un mismo producto |
| `cantidad` | **Sí**, mayor que 0 |
| `descripcion` · `unidad_de_medida` | Solo si el `codigo_interno` no existe todavía y hay que crear el producto |

### `datos_del_emisor`

Opcional. Si no lo envías se usa el establecimiento del usuario del token, igual que en
`POST /api/documents`.

### `datos_destinatario` — Quien recibe la mercadería

Misma estructura que `datos_remitente`.

### `vehiculo_secundario[]` (máx. 2)

Misma estructura que `vehiculo`. Para vehículos adicionales (semirremolques, carretas).

### `chofer_secundario[]` (máx. 2)

Misma estructura que `chofer`. Para choferes adicionales.

### `pagador_flete` — Quien paga el transporte

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `indicador_pagador_flete` | string | `"Remitente"`, `"Destinatario"`, `"Tercero"` |
| `codigo_tipo_documento_identidad` | string | Tipo doc del pagador |
| `descripcion_tipo_documento_identidad` | string | Descripción tipo doc |
| `numero` | string | Número de documento |
| `nombres` | string | Razón social / nombre |

### Diferencias con Guía Remitente

| Aspecto | Remitente (09) | Transportista (31) |
|---------|---------------|-------------------|
| Serie | T001 | V001 |
| `datos_del_cliente_o_receptor` | **Sí** (el destinatario) | No (usa `datos_destinatario`) |
| `transportista` | **Sí** (empresa de transporte) | No (es la propia empresa) |
| `datos_remitente` | No | **Sí** (quien envía) |
| `datos_destinatario` | No | **Sí** (quien recibe) |
| `vehiculo_secundario` | No | **Sí** (máx. 2) |
| `chofer_secundario` | No | **Sí** (máx. 2) |
| `pagador_flete` | No | **Sí** |
| `chofer` | Según modalidad | **Sí, siempre** |
| `direccion_partida` / `direccion_llegada` | **Sí** | Se aceptan y **se descartan** |

:::warning Las direcciones del `31` no van donde parece
`direccion_partida` y `direccion_llegada` solo se leen en la guía remitente (`09`). En el `31`
el servidor las acepta sin quejarse y **las descarta**: las direcciones de este tipo viajan en
`direcciones_proveedores` (con `remitente` y `destinatario`, cada uno con `ubigeo` y
`direccion`) o, si ya están registradas, en `direccion_remitente_id` /
`direccion_destinatario_id`.
:::

---

## Response (200 OK)

```json
{
    "success": true,
    "data": {
        "number": "V001-5",
        "filename": "20123456789-31-V001-5",
        "external_id": "uuid-guia-transportista"
    }
}
```

---

## Endpoints Adicionales

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/api/dispatch-carrier/records` | Listar guías de transportista (paginado) |

El envío a SUNAT y la consulta del ticket **no tienen ruta propia de transportista**: se hacen
con los mismos endpoints que la remitente, que buscan la guía por `external_id` sin importar si
es `09` o `31`.

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `POST` | `/api/dispatches/send` | Enviar la guía a SUNAT por `external_id` |
| `POST` | `/api/dispatches/status_ticket` | Consultar el ticket y recoger el CDR |
| `GET` | `/downloads/dispatch/pdf/{external_id}/{formato?}` | PDF |
| `GET` | `/downloads/dispatch/xml/{external_id}` | XML firmado |
| `GET` | `/downloads/dispatch/cdr/{external_id}` | CDR, solo cuando SUNAT ya respondió |

:::warning El PDF de la `31` no se rehace solo al descargarlo
La regeneración automática del PDF en la descarga hoy cubre únicamente la guía remitente
(`09`). Para que una guía de transportista muestre el QR, consulta el ticket por API, que sí
rehace el archivo, o pídela por la ruta de impresión `/print/dispatch/{external_id}/{formato}`,
que la regenera siempre.

→ [El QR y el PDF: cuándo aparecen](../../guias-de-remision.md#el-qr-y-el-pdf-cuándo-aparecen)
:::

---

## Notas para Offline

- Mismas consideraciones que la guía remitente: firma digital y envío SUNAT se procesan al sincronizar.
- Por lote (`sync-batch`) funciona igual que el `09`: ver [15 — Guías de remisión por lote](15-sync-batch.md#guías-de-remisión-por-lote--09-y-31).
- Los datos de remitente y destinatario se pueden llenar offline usando el catálogo de clientes descargado.
- Los vehículos secundarios son opcionales (para semirremolques).
