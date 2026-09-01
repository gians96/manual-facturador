# Información

Si deseas conocer el consumo de recursos con el sistema de facturación, puedes consultar esta área:

Iniciamos entrando a nuestro sistema **Administrador** donde visualizaremos el **módulo de Información**.

En la sección **Datos de PHP** se ven los límites con los que corre la aplicación: memoria,
tiempo máximo de ejecución y tamaño de subida.

## Recursos del servidor

Al lado están los gráficos de **procesador, memoria y disco**, con las cifras de ahora mismo
encima: cuánta RAM se usa de la que hay, y cuánto disco queda libre. Se toma una muestra cada
5 minutos.

Puedes mirar hacia atrás con los botones de **24 h · 7 días · 30 días**, o elegir un rango
propio con el calendario. En rangos largos se muestra la media por hora o por día, porque
mandar al navegador una muestra de cada 5 minutos de tres meses son decenas de miles de
puntos y el gráfico se vuelve ilegible; los picos siguen viéndose.

:::note Por qué el disco importa más que los otros dos
El procesador y la memoria se recuperan solos: suben y al rato bajan. El disco no — solo
crece, y cuando se llena el sistema deja de poder emitir. Es la única de las tres cuya
**tendencia** hay que mirar, y por eso ahora se guarda.
:::

El histórico se conserva **90 días**, que es el rango más largo que se puede consultar.


## Almacenamiento

Debajo encontrarás **cuánto ocupa el sistema y quién lo ocupa**:

- **Disco** e **inodes**, con un color que avisa antes de que haya que leer el número. Los
  inodes van aparte porque se agotan antes que el disco cuando hay muchos archivos pequeños:
  el servidor deja de poder crear archivos aunque queden gigabytes libres.
- **Espacio por cliente**, ordenado de mayor a menor, con el desglose por carpeta y una marca
  de cuál se regenera sola y cuál está protegida.
- **Fuera de los clientes**: respaldos previos a cada actualización, registros y cachés. Suele
  ser lo que más pesa y lo que nadie mira.

Las cifras se calculan **cada hora**, no al abrir la página: recorrer todo el almacenamiento
lleva su tiempo y no debe hacerte esperar. Verás cuándo se midieron, y puedes forzar un
recálculo con **Recalcular**.

### Liberar espacio

Cada cliente tiene un botón para borrar sus PDF antiguos. Funciona en dos pasos: primero
calcula **en seco** y te dice cuánto se liberaría, y solo entonces pide confirmación.

Los PDF se vuelven a generar cuando alguien los pide, así que borrarlos no pierde nada. **Los
XML firmados, los CDR, los certificados y los adjuntos no se tocan nunca**: esos no se pueden
regenerar.

Por defecto solo borra los de más de 90 días. Purgar también los recientes cambiaría espacio en
disco por tiempo de proceso cada vez que alguien reimprima.

## Consumo por cliente

La pestaña **Consumo por tenant** responde a «¿qué plan le corresponde a este cliente?» con
datos en vez de intuición: peticiones, tiempo de proceso, tamaño de su base y de sus archivos,
resumidos en un **índice comparable**.

:::note Qué se mide y qué no
Todos los clientes comparten los mismos procesos y la misma base de datos, así que la memoria y
el procesador **no se pueden medir por cliente**. Lo que se hace es **atribuir**: medir cada
petición y sumarla al cliente que la provocó.
:::

La columna **«pesa por»** es la que orienta la conversación: no es lo mismo un cliente que
consume por *tráfico* —muchos usuarios trabajando— que uno que solo *acumula datos*.

![Alt text](img/informacion_editado.png)
