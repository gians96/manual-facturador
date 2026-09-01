# Actualización

Para tener la última versión del facturador con nuevos módulos y corrección de fixtures, se debe realizar el proceso de actualización. Recuerda realizar este proceso de manera periódica, siguiendo estos pasos:

:::info Puedes cerrar la página sin miedo
La actualización la ejecuta el servidor, no el navegador. Si recargas o cierras la pestaña y
vuelves, **la barra sigue donde iba**. Y mientras una está en curso no se puede lanzar otra
encima: el botón se bloquea.

Durante el proceso el sitio puede quedar unos segundos sin responder, porque se reinician los
servicios. Es normal y necesario: sin ese reinicio el código nuevo no llega a aplicarse.
:::

:::info Antes de la primera vez hay que preparar el servidor
El botón no funciona en una instalación recién hecha: hacen falta dos cosas, una sola vez.

1. **El ejecutor**, que es quien recoge lo que encargas desde el panel.
2. **Las credenciales de git para `root`**, que es el usuario que ejecuta la actualización —no
   el tuyo. Que a ti te funcione un `git pull` a mano no significa que funcione desde aquí.

El botón **Ayuda** de esta pantalla abre un panel lateral con los comandos exactos, ya con la
ruta de tu instalación, y con pestañas para **Local** y **Producción**. El detalle técnico
está en [Servicios operativos](/devs/operacion/servicios-operativos).
:::

:::note No hace falta hacer `git pull` a mano antes
El proceso descarga los cambios por sí mismo. Hacerlo antes solo significa teclear el token
dos veces.
:::

:::warning Se hace una copia antes de empezar
El proceso guarda un respaldo completo de la base de datos antes de tocar nada, por si hubiera
que volver atrás. Se conservan los últimos; los antiguos se borran solos para no llenar el
disco.
:::

## Secciones actualización

Iniciamos entrando a nuestro sistema Administrador donde visualizaremos el módulo de Actualización.

Están disponibles las siguientes funcionalidades:

1. Pulsa **Iniciar actualización**. Verás una **barra de progreso** con el paso en el que va
   (descarga, dependencias, migraciones, reinicio de servicios…).
2. Antes de decidir, **Ver qué va a entrar** lista los cambios pendientes.

3. En la sección **Changelog** se observará los cambios y mejoras realizadas en cada actualización.

![Alt text](img/actualizacion-1.png)
