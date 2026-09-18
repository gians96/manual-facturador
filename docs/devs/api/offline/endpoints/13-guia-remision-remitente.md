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
        "codigo_del_domicilio_fiscal": "0000"
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
        "nombres": "PEREZ GARCIA, JUAN",
        "numero_licencia": "Q12345678",
        "telefono": "999888777"
    },
    "vehiculo": {
        "numero_de_placa": "ABC123",
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

:::warning `codigo_del_domicilio_fiscal` de la llegada: no lo mandes en `null`
Hasta el 2026-09-16 este ejemplo lo traía en `null`, y así la guía **sale rechazada con 3369** cuando el
destinatario tiene RUC: el XML declara el RUC asociado al punto de llegada y SUNAT exige entonces el
código de establecimiento. Envía `"0000"` (domicilio fiscal) o no mandes la clave. Desde esa fecha el
sistema trata `null` y `""` como `"0000"`, pero una instalación sin actualizar las sigue rechazando.
:::

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
| `observaciones` | string | No | Viajan a SUNAT en el XML; con más de 250 caracteres SUNAT observa `4186`. **Desde el 2026-09-14 el PDF A4 no las imprime por defecto**: se activan en la [plantilla de la guía](../../../../modulos/configuracion-y-mas/configuracion-globales/Plantillas/Plantillas-pdf-guias.md) |
| `codigo_modo_transporte` | string | **Sí** | `"01"` Transporte público, `"02"` Transporte privado |
| `codigo_motivo_traslado` | string | **Sí** | Ver tabla de motivos |
| `descripcion_motivo_traslado` | string | No | Descripción del motivo. **Obligatoria con el motivo `13`.** Desde el 2026-09-16 viaja a SUNAT en `cbc:HandlingInstructions` con cualquier motivo (antes viajaba siempre el texto del catálogo y esta solo salía en el PDF). Se envía sin saltos de línea ni tabuladores y cortada a 100 caracteres (aviso `RECORTE_DESCRIPCION_MOTIVO`); en el `13`, con menos de 3 letras SUNAT observa y la respuesta avisa `4190`. Sin descripción viaja el texto del catálogo |
| `fecha_de_traslado` | string | **Sí** | Fecha inicio del traslado `YYYY-MM-DD` |
| `fecha_entrega_transporte` | string | No | Solo transporte público (`01`): fecha en que entregas los bienes al transportista, `YYYY-MM-DD`. Si no la envías, viaja `fecha_de_traslado` en su lugar. Anterior a `fecha_de_emision`: aviso `3618` (SUNAT la rechaza, pero la guía se genera y se firma igual) |
| `indicador_de_transbordo` | bool | No | Si hay transbordo. Desde el 2026-09-09 también se acepta como texto (`"true"` / `"false"`); ausente cuenta como `false`. Antes, un `"FALSE"` de texto se rechazaba nombrando una columna interna |
| `unidad_peso_total` | string | **Sí** | Unidad de peso: `"KGM"` (kilos), `"TNE"` (toneladas) |
| `peso_total` | float | **Sí** | Peso total de la carga. Se guarda con **2 decimales**: el tercero se redondea (`34.825` queda y viaja como `34.83`) y la respuesta avisa `REDONDEO_PESO` |
| `numero_de_bultos` | int | No | Cantidad de bultos |
| `numero_de_contenedor` | int\|null | No | Número de contenedor. **Solo admite dígitos:** un código ISO 6346 alfanumérico (`"MSKU1234567"`) se rechaza con `INVALID_NUMERIC_VALUE`. Si no aplica, envía `null` — no `""` |

### `direccion_partida` (origen)

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `ubigeo` | string | **Sí** | Código ubigeo (6 dígitos) |
| `direccion` | string | **Sí** | Dirección completa (máx. 100 caracteres) |
| `codigo_del_domicilio_fiscal` | string\|null | No | Código establecimiento SUNAT. Opcional **de verdad desde el 2026-09-09**: antes, omitir la clave devolvía un 500 aunque aquí figurase como opcional. Si no aplica, omítela o envía `null`; el servidor usa `"0000"`. **En la partida hoy el XML emite siempre `"0000"` con el RUC de tu empresa**, aunque envíes otro código |

### `direccion_llegada` (destino)

Misma estructura que `direccion_partida`. El código de establecimiento de la llegada viaja asociado
al **RUC del destinatario** (solo si el destinatario tiene RUC y el motivo no es `18`): uno
distinto de `"0000"` tiene que estar declarado en SUNAT para ese RUC y con el mismo ubigeo.

:::info La dirección de llegada se guarda en la ficha del destinatario
Desde el **2026-09-17**, la primera guía que use una dirección de llegada la registra en las
direcciones del destinatario, igual que si la hubieras añadido desde el panel. Las siguientes
guías con la misma dirección y el mismo ubigeo **reutilizan** esa ficha, no la duplican, y una
dirección que ya existía no se modifica.

Se guarda para que la guía se pueda abrir y editar en el panel con su dirección de llegada ya
seleccionada. No afecta a lo que ve SUNAT: el XML siempre lleva el ubigeo, la dirección y el
código de establecimiento **tal como los enviaste en esta guía**.

Antes de esa fecha, una guía en modalidad de transporte `01` podía fallar aquí con
`DATABASE_ERROR` (MySQL 1452) sin que hubiera nada mal en el payload, y el reintento no lo
arreglaba.
:::

### `transportista`

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `codigo_tipo_documento_identidad` | string | **Sí** | `"6"` (RUC) para empresas |
| `numero_documento` | string | **Sí** | RUC del transportista |
| `apellidos_y_nombres_o_razon_social` | string | **Sí** | Razón social |
| `numero_mtc` | string | No | Número de registro MTC. Opcional **de verdad desde el 2026-09-09**: antes, omitirlo devolvía un 500 |
| `numero_autorizacion_especial` | string | No | Desde el 2026-09-14. Número de la autorización especial del transportista. Va junto con `codigo_entidad_autorizadora`. De 3 a 50 caracteres, sin tabulaciones ni saltos de línea (admite espacios, guiones y barras); si no, SUNAT observa y avisa `4396`. Viaja con o sin el indicador |
| `codigo_entidad_autorizadora` | string | No | Desde el 2026-09-14. Entidad que otorgó la autorización, catálogo D-37 (tabla más abajo). `"6"` se acepta como `"06"` |

> Solo requerido si `codigo_modo_transporte = "01"` (transporte público) — y desde el
> 2026-09-09 el servidor lo comprueba y lo dice por su nombre. Antes, omitirlo en transporte
> público era un 500.
>
> Con `codigo_modo_transporte = "02"` (transporte privado) el bloque obligatorio es `chofer`,
> por el mismo motivo y con la misma comprobación.
>
> Si el transportista ya existe en el sistema, la guía completa **solo sus datos vacíos**
> (registro MTC y autorización especial). Lo que ya está escrito en el maestro no se pisa.

### `chofer`

En transporte privado (`"02"`) es obligatorio. En transporte público solo se usa con
`indicador_vehiculos_conductores_transportista` (ver más abajo); sin él se descarta.

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `codigo_tipo_documento_identidad` | string | **Sí** | `"1"` (DNI) |
| `numero_documento` | string | **Sí** | DNI del chofer |
| `nombres` | string | **Sí** | Apellidos y nombres en un solo campo, con la forma `"APELLIDOS, NOMBRES"`. La coma separa en el XML los apellidos de los nombres; sin coma, el nombre completo va en los dos |
| `numero_licencia` | string | **Sí** | Número de licencia de conducir |
| `telefono` | string | No | Teléfono del chofer |

`chofer_secundario` es un arreglo opcional con la misma estructura, de máximo 2 conductores.
**No se valida**, así que cada conductor tiene que venir completo. Cuando la guía lleva los
secundarios al XML (transporte privado, o público con el indicador), uno a medias sale con datos
vacíos y avisa `SECUNDARIO_INCOMPLETO`; sin `codigo_tipo_documento_identidad`, SUNAT lo rechaza con
`2570`, que también sale como aviso.

### `vehiculo`

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `numero_de_placa` | string | **Sí** | Placa del vehículo, sin guiones ni espacios |
| `modelo` | string | No | Modelo del vehículo |
| `marca` | string | No | Marca del vehículo |
| `certificado_habilitacion_vehicular` | string\|null | No | Número de la **Constancia de Inscripción Vehicular, Certificado de Habilitación Vehicular o TUC** (física o electrónica) de **este** vehículo; en otros sistemas, «Constancia Insc. MTC» o «TUCE». De 10 a 15 caracteres, solo mayúsculas y números, o SUNAT rechaza con `3355`. Solo viaja al XML en transporte público con el indicador; ahí, sin él, SUNAT observa `4399` |
| `numero_autorizacion_especial` | string | No | Desde el 2026-09-14. Autorización especial del vehículo. Mismo formato que la del transportista (aviso `4406`). **Solo viaja al XML con el indicador**: completa y sin él, se guarda y avisa `AUTORIZACION_NO_EMITIDA` |
| `codigo_entidad_autorizadora` | string | No | Desde el 2026-09-14. Catálogo D-37 |

`vehiculo_secundario` es un arreglo opcional con la misma estructura, de máximo 2 vehículos (desde
el tercero se descartan). **Aquí va el remolque o semirremolque**: ver
[Tracto y remolque](#tracto-y-remolque). Tampoco se valida: un vehículo secundario con TUC o autorización especial pero sin
`numero_de_placa` sale con la placa vacía y avisa `SECUNDARIO_INCOMPLETO`.

### Vehículos y conductores del transportista

:::info Desde el 2026-09-14
Antes esta guía era imposible por API: no había clave para el indicador, y `chofer` y `vehiculo`
se descartaban siempre en transporte público.
:::

Es el transporte público en el que **el remitente declara el vehículo y el conductor de la
empresa de transporte**. SUNAT lo identifica por el indicador
`SUNAT_Envio_IndicadorVehiculoConductoresTransp`. Se activa así:

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `indicador_vehiculos_conductores_transportista` | bool | No | `true` activa el régimen. Solo con `codigo_modo_transporte = "01"`. Acepta también texto (`"true"` / `"false"`); un `"FALSE"` de texto **no** lo activa. Ausente cuenta como `false` |

Con el indicador en `true`:

- **`chofer` completo y `vehiculo.numero_de_placa` son obligatorios.** Sin ellos SUNAT rechaza con
  `3357` o `2566`, así que la guía no se emite: responde `MISSING_FIELDS` con todo lo que falta en
  `errors.faltantes`.
- El XML lleva la fecha de inicio del traslado, el conductor principal y los secundarios, las
  placas, el **TUC de cada vehículo** y sus autorizaciones especiales.
- `fecha_de_traslado` no puede ser anterior a `fecha_entrega_transporte` (`3616`), y la entrega no
  puede ser anterior a la emisión (`3618`). Si no envías `fecha_entrega_transporte`, viaja
  `fecha_de_traslado` como fecha de entrega. SUNAT rechaza los dos casos, pero aquí salen **como
  aviso**: la guía se genera y se firma igual, así que corrígela antes de enviarla.

Ejemplo completo, con datos ficticios, de una venta sujeta a confirmación (`14`) con un conductor
y un vehículo secundarios y la autorización de residuos sólidos del transportista:

```json
{
    "serie_documento": "T001",
    "numero_documento": "#",
    "fecha_de_emision": "2026-09-11",
    "hora_de_emision": "10:00:00",
    "codigo_tipo_documento": "09",
    "datos_del_cliente_o_receptor": {
        "codigo_tipo_documento_identidad": "6",
        "numero_documento": "20000000001",
        "apellidos_y_nombres_o_razon_social": "MINERA DEMO S.A.C.",
        "codigo_pais": "PE",
        "ubigeo": "150101",
        "direccion": "Av. Ejemplo 123 - Lima"
    },
    "observaciones": "Precintos 000123 y 000124",
    "codigo_modo_transporte": "01",
    "codigo_motivo_traslado": "14",
    "descripcion_motivo_traslado": "Venta sujeta a confirmación del comprador",
    "fecha_de_traslado": "2026-09-12",
    "fecha_entrega_transporte": "2026-09-11",
    "indicador_de_transbordo": false,
    "indicador_vehiculos_conductores_transportista": true,
    "unidad_peso_total": "TNE",
    "peso_total": 12.5,
    "numero_de_bultos": 1,
    "direccion_partida": {
        "ubigeo": "150101",
        "direccion": "Av. Almacén 456 - Lima",
        "codigo_del_domicilio_fiscal": "0000"
    },
    "direccion_llegada": {
        "ubigeo": "070101",
        "direccion": "Jr. Destino 789 - Callao",
        "codigo_del_domicilio_fiscal": "0000"
    },
    "transportista": {
        "codigo_tipo_documento_identidad": "6",
        "numero_documento": "20000000002",
        "apellidos_y_nombres_o_razon_social": "TRANSPORTES DEMO S.R.L.",
        "numero_mtc": "1500001CNG",
        "numero_autorizacion_especial": "1500002MRP",
        "codigo_entidad_autorizadora": "06"
    },
    "chofer": {
        "codigo_tipo_documento_identidad": "1",
        "numero_documento": "12345678",
        "nombres": "PEREZ GARCIA, JUAN",
        "numero_licencia": "Q12345678"
    },
    "chofer_secundario": [
        { "codigo_tipo_documento_identidad": "1", "numero_documento": "87654321",
          "nombres": "QUISPE ROJAS, PEDRO", "numero_licencia": "Q87654321" }
    ],
    "vehiculo": {
        "numero_de_placa": "ABC123",
        "certificado_habilitacion_vehicular": "15MRP00000001E",
        "numero_autorizacion_especial": "1500003CNG",
        "codigo_entidad_autorizadora": "06"
    },
    "vehiculo_secundario": [
        { "numero_de_placa": "DEF456", "certificado_habilitacion_vehicular": "15MRP00000002E",
          "numero_autorizacion_especial": "1500004CNG", "codigo_entidad_autorizadora": "06" }
    ],
    "documento_relacionado": [
        { "numero": "1500002MRP", "empresa": "TRANSPORTES DEMO S.R.L.", "ruc": "20000000002",
          "documento": { "id": "76", "descripcion": "Autorización para manejo y recojo de residuos sólidos peligrosos y no peligrosos" } }
    ],
    "items": [
        { "codigo_interno": "P0001", "descripcion": "RESIDUOS SOLIDOS NO PELIGROSOS",
          "unidad_de_medida": "TNE", "cantidad": 12.5 }
    ]
}
```

Qué mirar en este ejemplo:

- `observaciones` viaja a SUNAT, pero el PDF A4 no la imprime salvo que actives el bloque en la
  plantilla de la guía.
- `documento_relacionado[].documento.descripcion` va rellena: sin ella SUNAT observa `4371`.
- La entidad `06` (MTC) de las tres autorizaciones es **de ejemplo**. En cada autorización va el
  código D-37 de la entidad que la otorgó, que no tiene por qué ser el MTC.

:::warning Revisa la entidad de tus autorizaciones
Una autorización especial se emite **solo con número y entidad del catálogo D-37**. No hay
entidad por defecto: el sistema no la inventa. Si falta uno de los dos, o la entidad no está en
el catálogo, la guía se emite **sin** esa autorización y `warnings` lo dice. Una guía de otro
proveedor con `schemeID="76"` en la autorización está mal: `76` es el código del documento
relacionado (catálogo 61), no de la entidad.
:::

**Catálogo D-37 — `codigo_entidad_autorizadora`**

| Código | Entidad | Código | Entidad |
|--------|---------|--------|---------|
| `01` | SUCAMEC | `08` | Ministerio del Ambiente |
| `02` | DIGEMID | `09` | SANIPES |
| `03` | DIGESA | `10` | Municipalidad Metropolitana de Lima |
| `04` | SENASA | `11` | MINSA |
| `05` | SERFOR | `12` | Gobierno Regional |
| `06` | MTC | `13` | OSINERGMIN |
| `07` | PRODUCE | | |

### Tracto y remolque

SUNAT no tiene un campo de semirremolque. Un tracto con remolque o semirremolque se declara como
**dos vehículos**, cada uno con su placa y **su propia** constancia de inscripción:

| En tu sistema | Clave | En el XML | En el PDF |
|---|---|---|---|
| Placa del tracto y su «Constancia Insc. MTC» | `vehiculo.numero_de_placa` + `vehiculo.certificado_habilitacion_vehicular` | `cac:TransportEquipment` | Fila *Principal* |
| Placa del remolque y su «Constancia Insc. MTC. R.» | `vehiculo_secundario[0].numero_de_placa` + `vehiculo_secundario[0].certificado_habilitacion_vehicular` | `cac:AttachedTransportEquipment` | Fila *Secundario* |

Las dos constancias viajan al XML y salen en la columna *TUC / Cert. de habilitación* del PDF, que
es el mismo dato. El campo «N° placa semirremolque» del panel es otra cosa: solo guarda la placa,
solo se imprime y **no viaja a SUNAT**.

### Materiales o residuos peligrosos

La guía **no tiene una marca de «material peligroso»**: el pliego de SUNAT no trae ningún
indicador ni campo para eso. Lo que se declara es el **permiso**, como autorización especial:

| Permiso | Dónde va | Cuándo viaja |
|---|---|---|
| Autorización del transportista | `transportista.numero_autorizacion_especial` + `transportista.codigo_entidad_autorizadora` | Con o sin indicador |
| Autorización de un vehículo | `vehiculo` / `vehiculo_secundario[]`: `numero_autorizacion_especial` + `codigo_entidad_autorizadora` | Solo con el indicador |
| Constancia o TUC de cada vehículo | `certificado_habilitacion_vehicular` | Solo con el indicador |
| El permiso como documento (opcional) | `documento_relacionado[]` con `documento.id` `"76"` (residuos sólidos) y el `ruc` del transportista | Siempre |

La entidad va del catálogo D-37 de arriba (por ejemplo `06` MTC), **no** el `76`. Envía cada
autorización donde corresponde según a quién se otorgó: al transportista, a cada vehículo o a
ambos.

### Ejemplo: retorno a almacén con tracto y remolque (motivo `13`)

Tu empresa devuelve la carga a su almacén después de pesarla en una balanza: es remitente y
destinataria a la vez, lo que SUNAT permite en el motivo `13` (lo prohíbe en `01`, `03`, `05`,
`06`, `09`, `14` y `17`, regla `2555`, y lo exige en `02`, `04`, `07` y `18`, regla `2554`). Datos
ficticios:

```json
{
    "serie_documento": "T001",
    "numero_documento": "#",
    "fecha_de_emision": "2026-09-16",
    "hora_de_emision": "17:57:13",
    "codigo_tipo_documento": "09",
    "datos_del_cliente_o_receptor": {
        "codigo_tipo_documento_identidad": "6",
        "numero_documento": "20000000001",
        "apellidos_y_nombres_o_razon_social": "MI EMPRESA DEMO S.A.C."
    },
    "codigo_motivo_traslado": "13",
    "descripcion_motivo_traslado": "RETORNO A NUESTRO ALMACEN POR PESAJE EN BALANZA",
    "codigo_modo_transporte": "01",
    "fecha_de_traslado": "2026-09-16",
    "fecha_entrega_transporte": "2026-09-16",
    "indicador_de_transbordo": false,
    "indicador_vehiculos_conductores_transportista": true,
    "unidad_peso_total": "TNE",
    "peso_total": 30.35,
    "numero_de_bultos": 297,
    "observaciones": "RETORNO A NUESTRO ALMACEN POR PESAJE EN BALANZA",
    "direccion_partida": { "ubigeo": "040104", "direccion": "Av. Balanza Demo Km 4.5 - Cerro Colorado", "codigo_del_domicilio_fiscal": "0000" },
    "direccion_llegada": { "ubigeo": "040104", "direccion": "Cal. Almacén Demo 13 - Cerro Colorado", "codigo_del_domicilio_fiscal": "0000" },
    "transportista": {
        "codigo_tipo_documento_identidad": "6",
        "numero_documento": "20000000002",
        "apellidos_y_nombres_o_razon_social": "TRANSPORTES DEMO S.R.L.",
        "numero_mtc": "1500001CNG",
        "numero_autorizacion_especial": "1500002MRP",
        "codigo_entidad_autorizadora": "06"
    },
    "chofer": {
        "codigo_tipo_documento_identidad": "1",
        "numero_documento": "12345678",
        "nombres": "PEREZ GARCIA, JUAN",
        "numero_licencia": "Q12345678"
    },
    "vehiculo": { "numero_de_placa": "TRC123", "certificado_habilitacion_vehicular": "15MRP00000001E" },
    "vehiculo_secundario": [
        { "numero_de_placa": "REM456", "certificado_habilitacion_vehicular": "15MRP00000002E" }
    ],
    "documento_relacionado": [
        { "numero": "1500002MRP", "empresa": "TRANSPORTES DEMO S.R.L.", "ruc": "20000000002",
          "documento": { "id": "76", "descripcion": "Autorización para manejo y recojo de residuos sólidos peligrosos y no peligrosos" } }
    ],
    "items": [
        { "codigo_interno": "M0001", "descripcion": "MINERAL MOLIDO", "unidad_de_medida": "TNE", "cantidad": 30.35 }
    ]
}
```

Qué mirar en este ejemplo:

- `descripcion_motivo_traslado` lleva el **motivo real**: es lo que SUNAT recibe en el `13`. Un
  texto genérico como «Otros» no explica el traslado.
- El remolque (`REM456`) va en `vehiculo_secundario` con **su** constancia, no la del tracto.
- Los vehículos no llevan autorización propia: el permiso para residuos peligrosos es del
  transportista, y además se cita como documento `76`.
- El destinatario no lleva `direccion`: el PDF no imprime la línea vacía.

### `documento_relacionado`: quién lo emitió

| Campo | Qué hace |
|-------|----------|
| `numero` | Número del documento |
| `documento.id` | Código del Catálogo N.° 61 |
| `documento.descripcion` | **Recomendada.** Sin ella el XML sale con `cbc:DocumentType` vacío y SUNAT observa `4371`. Hasta 120 caracteres, sin saltos de línea ni tabuladores, o SUNAT observa `4372` |
| `ruc` | RUC de quien emitió el documento. Ver abajo |
| `empresa` | Razón social de quien lo emitió. **Solo sale en el PDF**: no viaja en el XML |

Desde el 2026-09-14 el RUC emisor del documento en el XML (`IssuerParty`) depende del código:

- `01`, `03`, `04`, `09`, `12` y `48`: siempre la empresa que emite la guía (regla 3381).
- Cualquier otro, por ejemplo `76`: el `ruc` de la fila si tiene 11 dígitos; si no, la empresa.
  En ese caso el documento viaja **como emitido por tu empresa**, y la respuesta lo avisa con
  `3409`.

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
| `13` | Otros no comprendidos en ningún código del presente catálogo. Exige `descripcion_motivo_traslado` |
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
| `cantidad` | number | **Sí** | Mayor que 0. Es el `<cbc:DeliveredQuantity>` del XML. Se guarda con 4 decimales: si envías más, se redondea y avisa `REDONDEO_CANTIDAD` |
| `descripcion` | string | Condicional | Solo si el `codigo_interno` **no existe todavía** y hay que crear el producto |
| `unidad_de_medida` | string | Condicional | Obligatoria al crear el producto. **Si la envías, es la que viaja en el XML de esa línea aunque el producto ya exista** con otra unidad; si no, se usa la del producto. Catálogo 03 de SUNAT (`NIU`, `KGM`, `TNE`…). En el motivo `09` la línea viaja siempre con `U` |
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
        "external_id": "abc-def-123",
        "warnings": []
    }
}
```

`warnings` trae los avisos previos: lo que SUNAT va a observar o rechazar y lo que el sistema va a
guardar distinto de como lo enviaste. No bloquean. →
[Avisos antes de emitir](../../guias-de-remision.md#avisos-antes-de-emitir)

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
- Para corregir por el lote una guía rechazada, mándala con un `offline_id` nuevo y su `external_id`: con el mismo `offline_id` la corrección no se aplica → [15 — Corregir una guía rechazada por el lote](15-sync-batch.md#corregir-una-guía-rechazada-por-el-lote).
