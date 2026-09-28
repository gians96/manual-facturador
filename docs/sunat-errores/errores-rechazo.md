---
title: Errores que generan Rechazo SUNAT
description: "Listado de errores que generan rechazo (códigos 2000-3999) en comprobantes electrónicos SUNAT Perú."
sidebar_position: 2
---

# ❌ Errores que generan Rechazo SUNAT (2000-3999)

:::danger Importante
Estos errores **invalidan el comprobante electrónico**. 
- El documento es rechazado por SUNAT
- La numeración se considera ya utilizada
- No se puede reutilizar el número
- Se debe generar nuevo documento con nueva numeración
:::

## 📑 Categorías Principales

### 📝 Validación de Emisor y Receptor (2010-2022)

| Código | Descripción |
|--------|-------------|
| 2010 | Contribuyente no está activo |
| 2011 | Contribuyente no está habido |
| 2012 | No autorizado para emitir comprobantes electrónicos |
| 2013 | No cumple tipo de empresa/tributos requeridos |
| 2014 | Falta CustomerAssignedAccountID del receptor |
| 2015 | Falta AdditionalAccountID del receptor |
| 2016 | AdditionalAccountID - Tipo documento receptor no cumple estándar |
| 2017 | CustomerAssignedAccountID - Receptor debe ser RUC |
| 2018 | CustomerAssignedAccountID - Dato no cumple formato |
| 2019 | Falta RegistrationName del emisor |
| 2020 | RegistrationName del emisor no cumple estándar |
| 2021 | Falta RegistrationName del receptor |
| 2022 | RegistrationName del receptor no cumple estándar |

### 📦 Validación de Detalle de Ítems (2023-2070)

| Código | Descripción |
|--------|-------------|
| 2023 | Número de orden de ítem con formato incorrecto |
| 2024 | Falta tag InvoicedQuantity en ítems |
| 2025 | InvoicedQuantity no cumple estándar |
| 2026 | Falta descripción (cbc:Description) en ítems |
| 2027 | Falta información en descripción del ítem |
| 2028 | Falta tag cac:AlternativeConditionPrice con PriceTypeCode=01 |
| 2029 | PriceTypeCode no cumple estándar |
| 2030 | Falta tag cbc:PriceTypeCode |
| 2031 | LineExtensionAmount no cumple estándar |
| 2032 | Falta tag LineExtensionAmount en ítems |
| 2033 | TaxAmount no cumple formato |
| 2034 | TaxAmount es obligatorio |
| 2035 | TaxScheme ID no cumple estándar |
| 2036 | Código de tributo inválido |
| 2037 | Falta tag TaxScheme ID del ítem |
| 2038 | TaxScheme Name no cumple estándar |
| 2039 | Falta tag TaxScheme Name del ítem |
| 2040 | Tipo de afectación IGV incorrecto |
| 2041 | Sistema de cálculo ISC incorrecto |
| 2042 | IGV es obligatorio |

### 💸 Validación de Impuestos y Totales (2071-2150)

| Código | Descripción |
|--------|-------------|
| 2070 | Falta DocumentCurrencyCode |
| 2071 | Moneda inconsistente en documento |
| 2072 | CustomizationID - Versión incorrecta |
| 2073 | Falta tag CustomizationID |
| 2074 | UBLVersionID - Versión incorrecta |
| 2075 | Falta tag UBLVersionID |
| 2102 | Error al procesar factura |
| 2103 | Serie inválida |
| 2104 | RUC emisor no existe |
| 2105 | Factura a dar de baja no registrada |
| 2106 | Factura ya está en baja |
| 2108 | Presentación fuera de fecha |
| 2116 | Nota Crédito debe modificar Factura/Ticket |
| 2122 | PayableAmount inválido |
| 2146 | Nombre internacional IGV debe ser VAT |

### 🖋️ Validación de Firma y Comunicación (2151-2399)

| Código | Descripción |
|--------|-------------|
| 2151 | Falta ID de firma |
| 2152 | ID de firma debe contener información |
| 2153 | ID de firma debe ser igual al RUC emisor |
| 2220 | ID no coincide con nombre archivo |
| 2221 | RUC no coincide con nombre archivo |
| 2222 | No autorizado para emitir electrónicos |
| 2230 | Formato fecha IssueDate incorrecto |
| 2334 | Documento electrónico alterado |
| 2336 | Error en validación de firma digital |
| 2345 | Serie no corresponde al tipo de comprobante |
| 2352 | Debe tener solo un TaxTotal para IGV |
| 2373 | ISC sin sistema de cálculo especificado |
| 2401 | Error al leer XML |
| 2403 | Numeración/nombre duplicado |

### 💰 Operaciones Especiales (2400-2752)

| Código | Descripción |
|--------|-------------|
| 2500 | Falta descripción/valor en anticipos |
| 2501 | Valor de venta debe ser > 0 |
| 2600 | Comprobante fuera de plazo |
| 2601 | No es Agente de Percepción |
| 2605 | RUC cliente no existe |
| 2617 | No es Agente de Retención |
| 2620 | Proveedor = Emisor en retención |
| 2635 | Falta DocumentTypeCode=99 en NC |
| 2642 | Exportación requiere TipoAfectación=40 |
| 2657 | Número documento duplicado en CPE |
| 2665 | No autorizado para emitir Tickets |
| 2670 | Razón Social ≠ RUC |
| 2752 | Ítem duplicado |

### 🗑️ Comunicación de baja (anulaciones)

:::info Lo rechazado es la anulación, no el comprobante
Cuando SUNAT rechaza una comunicación de baja o un resumen de anulación, el comprobante **sigue vigente**. El sistema deja la anulación en **RECHAZADO** y el comprobante vuelve a **ACEPTADO**, salvo que SUNAT diga que ya está de baja: entonces queda **POR ANULAR**. Ver [Anular comprobantes](../guias-adicionales/tipos-de-comprobantes/anular-comprobantes.md).
:::

| Código | Descripción | Qué hacer |
|--------|-------------|-----------|
| 2105 | Comprobante a dar de baja no registrado en SUNAT | Revisarlo en el Validador de documentos: SUNAT no lo tiene |
| 2106 | Factura ya está en baja | El comprobante queda Por anular: verificarlo en el Validador de documentos |
| 2323 | Documento ya informado en otra comunicación de baja | Igual que 2106 |
| 2324 | El archivo de la comunicación de baja ya se presentó | Igual que 2106 |
| 2957 | Baja fuera de plazo, contado desde la emisión | Emitir una nota de crédito (tipo 01) |
| 2958 | Baja fuera de plazo, contado desde la recepción | Emitir una nota de crédito (tipo 01) |

---

### Características:
1. **Cobertura selectiva**: Errores más comunes y críticos
2. **Agrupación temática**: 5 categorías principales
3. **Legibilidad mejorada**: Formato claro y conciso
4. **Priorización visual**: Iconos y colores para alertas
5. **Sistema de navegación**: Links integrados entre documentos