# 11 — Nota de Débito Electrónica

> `POST /api/documents`  
> **Controller:** `Tenant\Api\DocumentController@store`  
> **Middleware:** `input.request:document,api`  
> **Auth:** `Bearer {token}`  
> **Código tipo:** `"08"`

---

## Descripción

La nota de débito **incrementa** el importe de una factura o boleta ya emitida: intereses por mora, penalidades, gastos adicionales. Mismo endpoint que factura/boleta, con `codigo_tipo_documento: "08"`.

> 📘 **Estructura común:** cliente, items, totales, idempotencia, `acciones` y forma de la respuesta son **idénticos** a los de factura/boleta. Ver [09-boleta-factura.md](09-boleta-factura.md).
>
> 📕 **Estructura de nota:** `documento_afectado`, herencia del grupo de envío, ruta a SUNAT y errores son **idénticos** a los de la nota de crédito. Ver [10-nota-credito.md](10-nota-credito.md). Aquí va solo lo que difiere.

---

## Payload

```json
{
    "serie_documento": "FD01",
    "numero_documento": "#",
    "fecha_de_emision": "2026-04-18",
    "hora_de_emision": "15:30:00",
    "codigo_tipo_documento": "08",
    "codigo_tipo_moneda": "PEN",
    "codigo_tipo_nota": "01",
    "motivo_o_sustento_de_nota": "Intereses por mora",
    "documento_afectado": {
        "external_id": "90a15d6f-7043-432e-9d06-9f52c0d0af6a"
    },
    "codigo_vendedor": 1,
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
    "items": [
        {
            "codigo_interno": "-",
            "descripcion": "Intereses por mora - Factura F001-10",
            "codigo_producto_sunat": null,
            "unidad_de_medida": "ZZ",
            "cantidad": 1,
            "valor_unitario": 50.847457627118,
            "precio_unitario": 60.00,
            "codigo_tipo_precio": "01",
            "codigo_tipo_afectacion_igv": "10",
            "total_base_igv": 50.847457627118,
            "porcentaje_igv": 18,
            "total_igv": 9.152542372881,
            "total_impuestos": 9.152542372881,
            "total_valor_item": 50.847457627118,
            "total_item": 60.00
        }
    ],
    "totales": {
        "total_exportacion": 0,
        "total_operaciones_gravadas": 50.847457627118,
        "total_operaciones_inafectas": 0,
        "total_operaciones_exoneradas": 0,
        "total_operaciones_gratuitas": 0,
        "total_igv": 9.152542372881,
        "total_impuestos": 9.152542372881,
        "total_valor": 50.847457627118,
        "total_venta": 60.00
    }
}
```

Los items y totales son **el importe adicional a cobrar**, no el total del documento original.

---

## Campos propios de la nota

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `codigo_tipo_documento` | string | **Sí** | `"08"` |
| `codigo_tipo_nota` | string | **Sí** | Catálogo 10 de SUNAT. Sale en `<cbc:ResponseCode>` |
| `motivo_o_sustento_de_nota` | string | **Sí** | Texto libre. Sale en `<cbc:Description>` |
| `documento_afectado` | object | **Sí** | Misma estructura y mismas dos formas que en [nota de crédito](10-nota-credito.md#documento-afectado) |

Los tres se comprueban **antes de emitir** y, si falta más de uno, se informan juntos en un solo `MISSING_FIELDS`. Detalle y ejemplo de respuesta en [10-nota-credito.md](10-nota-credito.md#campos-propios-de-la-nota).

:::info Cambio de comportamiento (2026-09-07)

Hasta esa fecha cada uno fallaba distinto y ninguno de forma útil: `MISSING_FIELDS` solo para `documento_afectado`, **HTTP 500** con SQL crudo para el motivo, y **ningún error** para el tipo — la nota se emitía con `<cbc:ResponseCode>` vacío y la rechazaba SUNAT, con el correlativo consumido.

:::

### Tipos de nota de débito (`codigo_tipo_nota`)

| Código | Descripción |
|--------|-------------|
| `01` | Intereses por mora |
| `02` | Aumento en el valor |
| `03` | Penalidades / otros conceptos |
| `10` | Ajustes de operaciones de exportación |
| `11` | Ajustes afectos al IVAP |

Igual que en la NC, un código inexistente se rechaza con `INVALID_REFERENCE` (HTTP 422) y el mensaje enumera los valores válidos de tu tenant, leídos de su tabla `cat_note_debit_types`. Antes del 2026-09-07 esto salía como HTTP 500 con el SQL crudo.

### Serie

| Documento afectado | Serie ND habitual |
|-------------------|----------|
| Factura (`F001`) | `FD01` |
| Boleta (`B001`) | `BD01` |

Debe existir para el tipo `08` en el establecimiento del token, o se rechaza con `INVALID_SERIES`.

---

## Diferencias reales con la nota de crédito

Más allá del código de tipo y del catálogo de motivos, son tres:

| | Nota de crédito (`07`) | Nota de débito (`08`) |
|---|---|---|
| Efecto | Reduce o anula | Incrementa |
| `cuotas[]` | Se guardan; se emiten en el XML solo en la [nota tipo `13`](10-nota-credito.md#nota-tipo-13) | **Se descartan al crear el documento**, a propósito: el XML de nota de débito no tiene dónde representar un calendario de pago. No es un error y no va a serlo — mandarlas emite un comprobante válido |
| `FormaPago` en el XML | Solo en la nota tipo `13` con `codigo_condicion_de_pago: "02"` | Nunca |

Todo lo demás —`pagos[]` descartado, `codigo_tipo_operacion` y `fecha_de_vencimiento` ignorados, herencia del grupo, correo automático, idempotencia por `offline_id`— se comporta exactamente igual.

---

## Cómo llega la nota a SUNAT

Idéntico a la nota de crédito, y conviene no darlo por supuesto: **la ruta la fija el documento afectado, no la serie de la nota**.

| Documento afectado | `group_id` | Ruta |
|---|---|---|
| Factura (`01`) | `01` | Individual al emitir, si `send_auto` está activo. Si no, `POST /api/documents/send` |
| Boleta (`03`) | `02` | Individual solo si además está activo el envío individual de boletas **y** la boleta afectada se envió así. Si no, **resumen diario** vía `POST /api/summaries` |

`POST /api/documents/send` **rechaza** las notas de boleta: solo acepta el grupo `01`. El desarrollo completo, con los interruptores y sus combinaciones, está en [10-nota-credito.md § Cómo llega la nota a SUNAT](10-nota-credito.md#como-llega-a-sunat) y en [37-envio-automatico-a-sunat.md](37-envio-automatico-a-sunat.md).

---

## Response (200 OK)

```json
{
    "success": true,
    "data": {
        "number": "FD01-1",
        "filename": "20123456789-08-FD01-1",
        "external_id": "uuid-nd",
        "state_type_id": "05",
        "state_type_description": "Aceptado",
        "id": 789,
        "print_ticket": "https://demo.nt-suite.pro/print/document/uuid-nd/ticket"
    },
    "links": {
        "xml": "https://…",
        "pdf": "https://…",
        "cdr": "https://…"
    },
    "response": {
        "code": "0",
        "description": "La Nota de Débito numero FD01-1, ha sido aceptada"
    }
}
```

Si la nota no se remitió en el acto, `state_type_id` llega como `"01"` (Registrado), `links.cdr` vacío y `response` como `[]` (arreglo vacío, no objeto). Es una emisión correcta pendiente de envío, no un error.

---

## Notas para offline

- Misma restricción que la NC: **el documento afectado tiene que estar sincronizado** para disponer de su `external_id`.
- Las notas de débito son poco frecuentes en alta rotación, pero comparten pipeline: no necesitan tratamiento especial en el cliente offline más allá de encolarlas detrás de su documento original.
- No mandes `cuotas[]` en una ND aunque el original fuera a crédito: se descartan sin aviso. Para corregir un calendario de pagos, el instrumento es la [nota de crédito tipo `13`](10-nota-credito.md#nota-tipo-13).
