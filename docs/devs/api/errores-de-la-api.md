---
sidebar_position: 2.1
title: "Errores de la API: qué significa cada respuesta"
sidebar_label: "Errores de la API"
---

# Errores de la API: qué significa cada respuesta

Aplica a `POST /api/documents` (facturas, boletas y notas).

## Antes que nada: la cabecera

```
Content-Type: application/json
```

**Es obligatoria.** Sin ella el servidor trata el cuerpo como un formulario y descarta el
comprobante. Es, con diferencia, la causa número uno de consultas sobre esta API: como el
JSON nunca llega a leerse, la respuesta acusaba la falta de campos que **sí** venían en el
envío, y la depuración salía disparada en la dirección equivocada.

Hoy el error lo dice de frente:

```json
{
  "success": false,
  "message": "No se pudo interpretar el cuerpo como JSON. Envía la cabecera 'Content-Type: application/json'; sin ella el servidor lo trata como formulario y descarta el comprobante. Recibido: application/x-www-form-urlencoded.",
  "error_code": "MISSING_CONTENT_TYPE"
}
```

## Forma de la respuesta

El sobre no cambia nunca: `success` y `message` están siempre.

```json
{
  "success": false,
  "message": "Texto accionable en español",
  "error_code": "MISSING_FIELDS",
  "errors": { "faltantes": ["totales", "items"] }
}
```

`error_code` y `errors` son **añadidos y opcionales**: aparecen en los errores de entrada y
sirven para ramificar en tu código sin tener que leer el texto del mensaje. Si tu integración
ya funciona leyendo solo `success` y `message`, sigue funcionando igual.

## Códigos de estado

| Código | Significa |
|---|---|
| `200` | Comprobante emitido |
| `400` | El cuerpo no se pudo interpretar |
| `401` | Token ausente o inválido |
| `403` | Emisión bloqueada por licencia |
| `422` | Falta un campo, un catálogo no es válido o una regla de negocio no se cumple |
| `500` | Fallo real del servidor |

Un dato mal enviado **nunca** devuelve 500. Si recibes un 500, no es culpa de tu payload.

> **Cambio de comportamiento (2026-09-02).** Los errores de negocio —serie incorrecta,
> ubigeo, fecha fuera de plazo— antes salían con **500**. Ahora salen con **422**, que es lo
> que son. El `message` es el mismo de siempre.

## 400 · el cuerpo no llegó

| `error_code` | Qué revisar |
|---|---|
| `MISSING_CONTENT_TYPE` | Falta la cabecera. El mensaje te dice qué `Content-Type` llegó |
| `INVALID_JSON` | Sintaxis rota. El mensaje incluye el motivo exacto: comillas, comas, llaves |
| `EMPTY_BODY` | No llegó cuerpo. Si tu cliente anunció tamaño y no llegó nada, puede haberse excedido el límite del servidor |
| `BODY_IS_LIST` | Enviaste `[{...}]`. Este endpoint procesa **un comprobante por petición** |

## 422 · el comprobante no es válido

### `MISSING_FIELDS`

Se informan **todos los que faltan de una vez**, no de uno en uno:

```
Faltan campos obligatorios: totales, items.
```

Obligatorios: `serie_documento`, `numero_documento`, `codigo_tipo_documento`,
`codigo_tipo_moneda`, `datos_del_cliente_o_receptor` (con
`codigo_tipo_documento_identidad`, `numero_documento` y
`apellidos_y_nombres_o_razon_social`), `totales` (con `total_venta`) e `items`.

En listas, el mensaje **numera la línea** — con ocho ítems iguales, «falta descripcion» no
diría cuál corregir:

```
Ítem #2: falta 'descripcion'.
Pago #1: falta 'codigo_destino_pago'. Si no aplica, envíalo como null.
Para notas de crédito y débito es obligatorio 'documento_afectado'.
```

### `INVALID_UNIT_TYPE`

```
La unidad de medida 'TON' no existe en el catálogo 03 de SUNAT.
Para ese caso el código correcto suele ser 'TNE'.
```

Los códigos del catálogo 03 no siempre son los intuitivos. Los que más se confunden:

| Enviado | Correcto | |
|---|---|---|
| `TON`, `TM`, `TN` | `TNE` | Toneladas |
| `KG` | `KGM` | Kilogramos |
| `UND`, `UNI`, `U` | `NIU` | Unidad |
| `LT`, `L` | `LTR` | Litros |
| `MT`, `M` | `MTR` | Metros |
| `CAJA` | `BX` | Caja |
| `SERVICIO` | `ZZ` | Servicio |

### `TOTALS_MISMATCH`

```
'totales.total_operaciones_gravadas' (5000.00) no coincide con la suma de
'total_valor_item' de los ítems (100.00).
```

Solo salta ante un descuadre real. Las diferencias de céntimos por redondeo **pasan sin
problema**, y la comprobación se omite por completo en comprobantes con cargos, descuentos,
anticipos, ISC, operaciones gratuitas o afectaciones mixtas.

### Reglas de negocio

Mismos mensajes de siempre, ahora con 422:

- `La serie ingresada F001, es incorrecta.`
- `La fecha de emisión no puede ser menor a {N} día(s).`
- `El código ubigeo debe contener 6 dígitos` · `El código ubigeo es incorrecto`
- `El tipo doc. identidad {X} del cliente no es válido.`

## Cosas que conviene saber

- **Los decimales no se rechazan.** Los importes se almacenan con dos decimales y se redondean
  solos. Enviar `151724.376` no da error.
- **Un comprobante duplicado sigue devolviendo 500** con el mensaje
  `El documento: 01 F001-00005242 ya se encuentra registrado.` Está pendiente de cambiarse
  a 409.
- **Las guías de remisión no siguen este flujo.** Tienen su propio proceso de tres pasos:
  ver [Guías de remisión: cómo funcionan](./guias-de-remision.md).
