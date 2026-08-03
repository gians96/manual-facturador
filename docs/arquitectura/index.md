---
title: Arquitectura del ecosistema
description: "Cómo encajan las piezas del Facturador: portal de suscripción, sistema web/ERP, app de ventas (POS) y la plataforma de suscripciones."
sidebar_position: 0
---

# Arquitectura del ecosistema

El **Facturador** no es una sola aplicación: es una familia de piezas que trabajan juntas.
Esta página da el mapa general para entender cómo se relacionan, útil tanto para quien
**usa** el sistema como para quien **integra** con la API.

## Componentes

| Pieza | Qué hace |
|------|----------|
| **Portal de suscripción** | Web pública donde un cliente elige un plan y crea su empresa. Es la puerta de entrada. |
| **Facturador (web / ERP)** | El corazón: facturación electrónica, ventas, inventario, caja, reportes y administración. Emite los comprobantes a **SUNAT** y expone la **API**. |
| **App de ventas (POS)** | Aplicación multiplataforma para vender en el punto de venta (restaurante, minimarket, farmacia, etc.), ver reportes de caja y emitir comprobantes. **Funciona offline** y sincroniza contra la API del Facturador. |
| **Plataforma de suscripciones** | Gestiona los planes y las empresas: aprovisiona cada empresa en el Facturador y habilita las capacidades según el plan contratado. |

## Cómo fluye

```
   Cliente
     │  1. elige un plan
     ▼
 ┌─────────────────────┐      2. aprovisiona la empresa      ┌───────────────────────────┐
 │  Portal de           │ ─────────────────────────────────▶ │  Plataforma de            │
 │  suscripción         │                                     │  suscripciones            │
 └─────────────────────┘                                     └────────────┬──────────────┘
                                                    3. crea el tenant y     │
                                                    habilita capacidades    ▼
                                                              ┌───────────────────────────┐
                                                              │  Facturador (web / ERP)   │
                                                              │  · emite a SUNAT          │
                                                              │  · expone la API          │
                                                              └──────┬─────────────┬──────┘
                                              4a. venta desde la web │             │ 4b. venta desde el POS
                                                                     ▼             ▼
                                                              Comprobantes    ┌───────────────────┐
                                                              electrónicos ──▶│  App de ventas    │
                                                              (SUNAT)         │  (POS, offline)   │
                                                                              └───────────────────┘
```

1. El cliente **elige un plan** en el portal de suscripción.
2. Se **aprovisiona su empresa** (su *tenant*) en el Facturador.
3. El **plan contratado** define qué puede hacer la empresa (emitir comprobantes, número de
   usuarios, etc.).
4. La empresa **vende** desde la web del Facturador **o** desde la app de ventas (POS), y los
   comprobantes electrónicos se envían a **SUNAT**.

## Por dónde seguir

- **[API del Facturador](../devs/api/introduccion.md)** — para integrar tu propio sistema.
- **[API Offline (app de ventas)](../devs/api/offline/index.md)** — el contrato que usa la app POS.
- **[Instalación](../devs/despliegue/instalacion-scripts/index.md)** — desplegar el Facturador en tu servidor.
