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
Las empresas nuevas ya traen estas dos tareas. Si a la tuya le faltan, en *Tareas programadas* pulsa **Aplicar configuración recomendada**: las crea con su hora. Solo son necesarias si la empresa tiene apagado el envío individual de boletas; la anulación de boletas no la hace ninguna tarea.
:::
