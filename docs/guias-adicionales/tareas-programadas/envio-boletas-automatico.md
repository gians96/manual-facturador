# Envio de Boletas automatico

:::info

Esta es una guía para programar el envío de boletas a SUNAT.

:::

## ¿Qué es el envío de Boletas automatico?

El envío de boletas automatico es una funcionalidad que permite enviar boletas a SUNAT de forma automática.

## ¿Cómo programar el envío de Boletas automatico?

1. Ir a **Configuración** -> **Configuración Globales** -> **Avanzado** -> **Tareas Programadas**

![alt text](img/envio-boletas-automatico-1.png)

2. Hacer clic en **Agregar**
3. Seleccionar **Enviar el resumen diario de boletas** (en versiones anteriores se llamaba *Envío de resúmenes a SUNAT*)

![alt text](img/envio-boletas-automatico-2.png)

4. Configurar los parámetros (Tarea y hora)
5. Hacer clic en **Guardar**

6. Configurar **Consultar el resultado del resumen diario** (antes *Consulta de Resumenes*), unas dos horas después del envío

![alt text](img/envio-boletas-automatico-3.png)

7. Configurar los parámetros (Tarea y hora)
8. Hacer clic en **Guardar**

:::warning

**Nota:** Se recomienda programar el envío de boletas en horarios fuera de pico para evitar errores, se recomienda que sea en horarios de madrugada 12 am a 5am.

:::

:::tip Configuración recomendada
Las empresas nuevas ya traen estas dos tareas. Si a la tuya le faltan, en *Tareas programadas* pulsa **Aplicar configuración recomendada**: las crea con su hora. Solo son necesarias si la empresa tiene apagado el envío individual de boletas. La anulación de una boleta se pide a mano desde el listado; su resultado lo consulta la tarea **Consultar las anulaciones**.
:::

## Si SUNAT rechaza el resumen

El resumen queda **Rechazado** con el motivo de SUNAT, y sus boletas vuelven a **Registrado**: la noche siguiente la tarea las declara otra vez en un resumen nuevo. Dos casos no vuelven con las demás:

- **La boleta que SUNAT señala como causa del rechazo** (por ejemplo, una boleta emitida con una serie de nota de venta, `NV01`, que SUNAT nunca acepta) queda **Rechazada** con el motivo, y las demás se declaran sin ella. Esa venta hay que emitirla otra vez con una serie de boleta. Desde esta versión el sistema ya no deja emitir una boleta con una serie que no empiece con **B**.
- **La boleta que SUNAT dice que ya tiene** (*Existe documento ya informado anteriormente*) queda **Aceptada** cuando el sistema puede confirmarlo: porque un resumen anterior suyo fue aceptado, o con la consulta integrada de SUNAT si la empresa la tiene configurada.

Antes, un resumen rechazado por una sola boleta se volvía a armar igual cada noche y SUNAT lo rechazaba otra vez.
