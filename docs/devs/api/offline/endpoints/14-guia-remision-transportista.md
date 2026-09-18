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
    "direcciones_proveedores": {
        "remitente": {
            "ubigeo": "150101",
            "direccion": "Av. Principal 123, Lima"
        },
        "destinatario": {
            "ubigeo": "040101",
            "direccion": "Jr. Mercaderes 456, Arequipa"
        }
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
        "numero_de_placa": "ABC123",
        "modelo": "HINO 500",
        "marca": "HINO",
        "certificado_habilitacion_vehicular": "15M24000001E"
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

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `codigo_del_domicilio_fiscal` | string | No | Código del establecimiento emisor |
| `numero_autorizacion_especial` | string\|null | No | Desde el 2026-09-18. Autorización especial de **tu empresa** como transportista **en esta guía**. De 3 a 50 caracteres, sin tabulaciones ni saltos de línea (aviso `4396`) |
| `codigo_entidad_autorizadora` | string\|null | No | Desde el 2026-09-18. Entidad que la otorgó, catálogo D-37 (ver [13 — Catálogo D-37](13-guia-remision-remitente.md#vehículos-y-conductores-del-transportista)). `"6"` se acepta como `"06"` |

En la guía de transportista **el transportista es tu empresa**. Su **registro MTC** y su
**autorización especial** viajan a SUNAT en el XML (`CarrierParty`), y salen de la ficha de la
empresa (**Empresa → Registro MTC** y **Autorización especial**). Con las dos claves de arriba
se cambia la autorización **solo en esta guía**:

| Lo que envías | Lo que viaja |
|---|---|
| Ninguna de las dos claves | La autorización de la ficha de la empresa |
| Las dos con valor | Esa autorización, en lugar de la de la ficha |
| Las dos en `null` | Ninguna autorización en esta guía |
| Solo una | Se guarda, pero **no se emite**: la respuesta avisa `4394` o `4397` |

El registro MTC no se cambia por guía: sale siempre de la ficha. Sin él, SUNAT acepta la guía
pero la observa con `4391` (hasta el 2026-09-18 **toda** guía de transportista salía así,
porque el XML no lo enviaba), y la respuesta lo avisa en el campo `empresa.registro_mtc`.

### `datos_destinatario` — Quien recibe la mercadería

Misma estructura que `datos_remitente`.

### `vehiculo` y `vehiculo_secundario[]` (máx. 2)

`vehiculo_secundario` tiene la misma estructura que `vehiculo`. Es para los vehículos
adicionales (semirremolques, carretas).

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `numero_de_placa` | string | **Sí** en `vehiculo` | Sin guiones ni espacios (`2567`). Sin la del principal, SUNAT rechaza con `2566` |
| `modelo` · `marca` | string | No | Solo para el PDF |
| `certificado_habilitacion_vehicular` | string\|null | No | TUC o constancia de **este** vehículo, de 10 a 15 mayúsculas y números (`3355`). En la guía de transportista viaja siempre; sin él, SUNAT observa `4399` y la respuesta lo avisa |
| `numero_autorizacion_especial` | string | No | Autorización especial de **este** vehículo. En la guía de transportista **viaja siempre** desde el 2026-09-18; antes se guardaba y no llegaba al XML, sin ningún aviso |
| `codigo_entidad_autorizadora` | string | No | Catálogo D-37. Va junto con el número: con uno solo no se emite y se avisa `4403` o `4405` |

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
| `transportista` | **Sí** (empresa de transporte) | No: es la propia empresa. Si lo envías se descarta y la respuesta avisa `TRANSPORTISTA_IGNORADO` |
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

## Materiales o residuos peligrosos

Igual que en la [guía remitente](13-guia-remision-remitente.md#materiales-o-residuos-peligrosos), la
guía **no tiene una marca de «material peligroso»**. Lo que se declara es el **permiso**: la
autorización especial, con la entidad que la otorgó (catálogo D-37). En la guía de transportista
todo viaja **siempre**, sin ningún indicador:

| Permiso | Dónde va |
|---|---|
| Autorización de tu empresa | Ficha de la empresa, o `datos_del_emisor.numero_autorizacion_especial` + `codigo_entidad_autorizadora` para esta guía |
| Autorización de un vehículo | `vehiculo` / `vehiculo_secundario[]`: `numero_autorizacion_especial` + `codigo_entidad_autorizadora` |
| TUC o constancia de cada vehículo | `certificado_habilitacion_vehicular` |
| El permiso como documento (opcional) | `documento_relacionado[]` con `documento.id` `"67"` (permiso MATPEL del MTC) o `"65"` (circulación MATPEL en el Callao) |

:::danger El `76` no vale en la guía de transportista
La autorización de residuos sólidos (`76`) que cita la guía remitente es, según el catálogo 61 de
SUNAT, **solo del remitente**. En una guía de transportista SUNAT la **rechaza** con `2692`
(comprobado contra producción el 2026-09-18), y la respuesta lo avisa antes de enviar. Los
permisos del transportista son el `65`, `66`, `67`, `68`, `69` y `82`.
:::

Reglas del documento relacionado en esta guía:

- **Cuántos caben:** con un permiso (`65` a `69`) o una guía de transportista (`31`), hasta **2**
  (`3345`); sin ninguno, **1**, salvo que uno sea una guía remitente electrónica (`3346`). Citar la
  guía remitente y el permiso MATPEL es justo el caso de dos.
- **Quién lo emitió (`ruc`):** una guía remitente electrónica (`09`) viaja con el RUC del
  **remitente de esta guía**, aunque la fila traiga otro (regla `3381`); un permiso sin `ruc`, con
  el de tu empresa. Una factura o boleta sin RUC válido sale sin emisor y SUNAT la rechaza (`3380`,
  se avisa antes).
- **La guía remitente tiene que existir** en SUNAT para ese remitente (`3433`).

:::warning El remitente no puede ser tu empresa
En esta guía tu empresa es el transportista, y SUNAT rechaza una guía cuyo remitente es el propio
transportista (`2560`). Si trasladas tu propia carga, emite una
[guía remitente](13-guia-remision-remitente.md) en transporte privado. La respuesta lo avisa y el
panel no la deja emitir.
:::

Ejemplo con datos ficticios: un permiso MATPEL relacionado y dos vehículos con su TUC y su
autorización. La autorización de la empresa sale de su ficha (no se envía `datos_del_emisor`):

```json
{
    "serie_documento": "V001",
    "numero_documento": "#",
    "fecha_de_emision": "2026-09-18",
    "hora_de_emision": "10:00:00",
    "codigo_tipo_documento": "31",
    "fecha_de_traslado": "2026-09-18",
    "unidad_peso_total": "TNE",
    "peso_total": 28.5,
    "direcciones_proveedores": {
        "remitente": { "ubigeo": "150101", "direccion": "Av. Almacén 456 - Lima" },
        "destinatario": { "ubigeo": "070101", "direccion": "Jr. Destino 789 - Callao" }
    },
    "datos_remitente": {
        "codigo_tipo_documento_identidad": "6",
        "numero_documento": "20000000001",
        "apellidos_y_nombres_o_razon_social": "QUIMICA DEMO S.A.C."
    },
    "datos_destinatario": {
        "codigo_tipo_documento_identidad": "6",
        "numero_documento": "20000000003",
        "apellidos_y_nombres_o_razon_social": "INDUSTRIAS DEMO S.A.C."
    },
    "chofer": {
        "codigo_tipo_documento_identidad": "1",
        "numero_documento": "12345678",
        "nombres": "PEREZ GARCIA, JUAN",
        "numero_licencia": "Q12345678"
    },
    "vehiculo": {
        "numero_de_placa": "TRC123",
        "certificado_habilitacion_vehicular": "15MRP00000001E",
        "numero_autorizacion_especial": "1500003CNG",
        "codigo_entidad_autorizadora": "06"
    },
    "vehiculo_secundario": [
        { "numero_de_placa": "REM456", "certificado_habilitacion_vehicular": "15MRP00000002E",
          "numero_autorizacion_especial": "1500004CNG", "codigo_entidad_autorizadora": "06" }
    ],
    "pagador_flete": {
        "indicador_pagador_flete": "Remitente",
        "codigo_tipo_documento_identidad": "6",
        "numero": "20000000001",
        "nombres": "QUIMICA DEMO S.A.C."
    },
    "documento_relacionado": [
        { "numero": "1500005MRP",
          "documento": { "id": "67", "descripcion": "Permiso de Operación Especial para el servicio de transporte de MATPEL - MTC" } }
    ],
    "items": [
        { "codigo_interno": "Q0001", "descripcion": "ACIDO SULFURICO", "unidad_de_medida": "TNE", "cantidad": 28.5 }
    ]
}
```

Para usar otra autorización de tu empresa solo en esta guía, añade:

```json
"datos_del_emisor": {
    "numero_autorizacion_especial": "MATPEL-2026-001",
    "codigo_entidad_autorizadora": "13"
}
```

:::info Probado contra SUNAT producción (2026-09-18)
Guías aceptadas con la autorización de la empresa y de cada vehículo, el TUC de cada vehículo y el
permiso `67` relacionado, por la API y por el panel. La entidad `06` (MTC) de los ejemplos es solo
eso, un ejemplo: en cada autorización va el código D-37 de la entidad que la otorgó.
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
- Para corregir por el lote una guía rechazada, mándala con un `offline_id` nuevo y su `external_id`: con el mismo `offline_id` la corrección no se aplica → [15 — Corregir una guía rechazada por el lote](15-sync-batch.md#corregir-una-guía-rechazada-por-el-lote).
- Los datos de remitente y destinatario se pueden llenar offline usando el catálogo de clientes descargado.
- Los vehículos secundarios son opcionales (para semirremolques).
