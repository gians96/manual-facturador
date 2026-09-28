---
sidebar_position: 6
title: Anulación de Comprobantes Automática
---

# Anulación de Comprobantes Automática

Cuando se presenta la necesidad de anular un comprobante, es esencial contar con un proceso sencillo y efectivo que permita llevar a cabo esta tarea de manera precisa.

:::info IMPORTANTE
Solos los comprobantes con el estado de **Aceptado** se puede anular.
:::

Si desea anular un comprobante lo que debe hacer es dirigirse a los 3 puntos del lado derecho y dar clic en anular, completar el motivo y clic en **ANULAR**.

![Alt text](img/anular_comprobante_new_1.png)


Con estos pasos el sistema envía la anulación a SUNAT, que responde con un ticket. Mientras ese ticket no se consulte, el comprobante se visualiza con el estado **POR ANULAR**.

![alt text](img/anular_comprobante_new_2.png)

Para completar la anulación, ingresa a **Comprobantes pendientes → Anulaciones** (o usa el enlace **Ir a anulaciones**) y selecciona **Enviar Baja** en la fila de la anulación. Cuando SUNAT la acepta, el comprobante queda **ANULADO**. Es el mismo paso para facturas, boletas y notas; está explicado con capturas en [Anular notas de crédito y débito](anular-notas-de-credito-y-debito.md#completar).

Si SUNAT **rechaza** la anulación, la fila pasa a **RECHAZADO** y el comprobante vuelve a **ACEPTADO**: para SUNAT sigue vigente. El mensaje de **Enviar Baja** dice el motivo con su código:

- **2957 o 2958, fuera de plazo.** Se pidió la baja después del plazo. El comprobante no se puede anular: para dejarlo sin efecto, emite una **nota de crédito** (tipo 01, *Anulación de la operación*).
- **2106, 2323 o 2324, ya está de baja.** SUNAT dice que ese comprobante ya se dio de baja o ya se informó en otra comunicación. El comprobante queda **POR ANULAR**, no Aceptado: compruébalo en **Reportes → Validador de documentos** y regularízalo con lo que diga SUNAT.

Así funciona también con un PSE, que a veces devuelve el rechazo sin CDR: la fila queda en **RECHAZADO** sin botón **CDR**.

También puedes sincronizar el estado con el de SUNAT en **Reportes → Validador de documentos**: coloca el comprobante a actualizar y haz clic en **Regularizar documentos**.

Las notas de crédito y débito se anulan igual, desde su propia fila del listado: [Anular notas de crédito y débito](anular-notas-de-credito-y-debito.md).

:::danger IMPORTANTE:
Recuerde que estas anulaciones solo se pueden realizar dentro de los primeros 7 días después de la emisión del comprobante, pasado el tiempo debe emitir una nota de crédito.

Si se envía fuera de plazo, SUNAT la rechaza con el código 2957 y el comprobante vuelve a **ACEPTADO**. Para que el sistema no deje enviarla, activa **Restringir envío de comunicación de baja (RA)** en la configuración avanzada, con 7 días.

:::
