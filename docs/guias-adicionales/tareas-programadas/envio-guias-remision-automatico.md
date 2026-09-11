# Envio de Guías de Remisión automatico

:::info

Esta es una guía para programar el envío de guías de remisión a SUNAT.

:::

## ¿Qué es el envío de Guías de Remisión automatico?

El envío de guías de remisión automatico es una funcionalidad que permite enviar guías de remisión a SUNAT de forma automática.

## ¿Cómo programar el envío de Guías de Remisión automatico?

1. Ir a **Configuración** -> **Configuración Globales** -> **Avanzado** -> **Tareas Programadas**

![alt text](img/envio-guias-remision-automatico-1.png)

2. Hacer clic en **Agregar**
3. Seleccionar **Envio de Guías de Remisión automatico**

![alt text](img/envio-guias-remision-automatico-2.png)

4. Configurar los parámetros (Tarea y hora)
5. Hacer clic en **Guardar**

:::warning

**Nota:** Se recomienda programar el envío de guías de remisión en horarios fuera de pico para evitar errores.

:::

## Falta la segunda tarea: consultar el resultado

Enviar no cierra el proceso. SUNAT no responde en el momento: acepta la guía y devuelve un
número de ticket. La aceptación, y con ella el **código QR**, llegan en una segunda consulta.

Son **dos tareas distintas** y hay que programar las dos:

| Tarea | Qué hace |
|---|---|
| **Enviar guías de remisión a SUNAT** | Envía las guías pendientes y obtiene su ticket. La guía queda en *Enviado*. |
| **Consultar el resultado de las guías de remisión** | Recoge la respuesta de SUNAT. La guía pasa a *Aceptada* y obtiene el QR. |

Prográmalas en ese orden y deja **al menos una hora** entre una y otra. SUNAT puede tardar en
procesar el envío, y una consulta demasiado pronto solo responde que la guía sigue en proceso.

:::danger Con solo la primera tarea, ninguna guía llega a tener QR
Si programas el envío pero no la consulta, las guías se quedan en estado *Enviado* de forma
indefinida. El PDF nunca muestra el código QR, que es lo que un fiscalizador escanea en
carretera.

→ [El QR y el PDF: cuándo aparecen](../../devs/api/guias-de-remision.md#el-qr-y-el-pdf-cuándo-aparecen)
:::

## ¿Y el PDF que ya descargué?

El PDF se puede descargar desde que la guía se registra, pero hasta que SUNAT la acepta **no
lleva QR**: ese código lo genera SUNAT, no el Facturador. Una vez que la guía figura como
*Aceptada*, vuelve a descargar el PDF desde el listado de guías y saldrá con el QR impreso.
