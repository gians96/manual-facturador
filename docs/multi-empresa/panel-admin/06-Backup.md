# Backups

Las copias de seguridad se configuran una vez y a partir de ahí se hacen solas, subiéndose
fuera del servidor. Se administran desde **Administrador → Backup**.

:::info Cómo funciona
El panel no hace las copias: las **encarga**. Un servicio del servidor las recoge y las
ejecuta, porque el volcado necesita hablar con la base de datos y las herramientas de subida
viven en el servidor.

Si ves una copia **«En cola» que no avanza**, es que ese servicio no está recogiendo las
órdenes: o no se instaló, o se instaló y no llegó a arrancar. El propio panel te lo dirá
pasados unos minutos, con el comando. El detalle está en
[Configurar las copias](/devs/operacion/configurar-copias-drive#si-algo-no-va).
:::

## Los dos conceptos

**Destinos** — dónde se guardan las copias: Google Drive, un bucket S3 (Backblaze, Cloudflare
R2, AWS), otro servidor por SFTP o un disco montado. Se configura **una vez** y lo comparten
todos los trabajos.

**Trabajos** — qué se copia, cada cuánto y cuántas copias conservar. Puedes tener varios a la
vez: por ejemplo «bases de datos cada 6 h al Drive» y «todo completo, semanal, a otro
proveedor».

Se separan porque autorizar un destino cuesta (hay que pedir permiso a Google, pegar un token)
y no tendría sentido repetirlo en cada trabajo ni cambiarlo en varios sitios cuando caduque.

## Crear un destino

**Destinos → Añadir**. Según el tipo te pedirá unas credenciales u otras; cada campo tiene un
**?** que abre la guía de ese proveedor.

| Campo | Qué es |
|---|---|
| **Nombre** | Cómo lo llamarás. Es el que eligen los trabajos. |
| **Tipo** | Google Drive, S3 compatible, SFTP o disco del servidor. |
| **Carpeta base** | Dónde dejar las copias. Puedes anidar: `backup/mi-empresa.com`. |
| **Formato** | *Archivos normales* (los ves y descargas desde el destino) o *cifrado*. |

Al guardar, pulsa **Probar**: escribe un archivo y lo lee de vuelta. Comprobar solo que la
carpeta existe dejaría pasar una credencial de solo lectura, que fallaría en la primera copia
real y de madrugada.

:::warning Las credenciales no salen del servidor
Se guardan cifradas y nunca se muestran de vuelta. Un destino que el panel no deba conocer
puede definirse directamente en el servidor; el panel lo listará como *solo lectura*.
:::

## Crear un trabajo

**Trabajos de copia → Crear**.

| Campo | Qué es |
|---|---|
| **Nombre** | «Copia diaria», «Cliente X»… También da nombre a su carpeta en el destino. |
| **Destino** | Uno de los que hayas creado. |
| **Qué copiar** | Todo · Bases de datos · Archivos · Un cliente completo. |
| **Cuándo** | Desde cada hora hasta semanal, o una expresión cron propia. |
| **Subcarpeta** | Opcional, para separar proyectos dentro del mismo destino. |
| **Conservar las últimas** | Cuántas copias guardar. 0 = todas. |

El formulario muestra **la ruta final** donde acabarán las copias, para que no tengas que
imaginártela.

:::note Activar un trabajo no dispara una copia inmediata
La primera será a la siguiente hora programada. Para una ahora mismo, usa el botón de
ejecutar de su fila.
:::

## Los cuatro tipos de copia

| Tipo | Qué incluye |
|---|---|
| **Todo** | Bases + archivos + configuración |
| **Bases de datos** | Los volcados + configuración |
| **Archivos** | XML firmados, CDR, certificados, logos + configuración |
| **Un cliente completo** | La base de un cliente **y** sus archivos |

*Un cliente completo* es el que sirve para «un cliente se va y quiere sus datos» o para
restaurar solo a uno.

**Los PDF no se copian**: el sistema los vuelve a generar cuando alguien los pide, así que
guardarlos sería pagar espacio por algo reconstruible.

:::note La configuración va siempre
Aunque el tipo diga «bases de datos», el archivo de configuración se copia igual. Contiene la
clave de la que dependen las contraseñas de base de datos de cada cliente: sin ella, los
volcados no se pueden abrir. Ocupa unos pocos KB.
:::

## Cómo queda organizado

```
backup/mi-empresa.com/       ← Carpeta base del destino
  copia-diaria/              ← el trabajo
    2026-08-31_020000/       ← una carpeta por cada copia
      db/*.sql.gz
      config/
      COMO-RESTAURAR.txt
    2026-08-31_060000/
    files/                   ← archivos: solo sube lo que cambió
```

Cada trabajo tiene **su propia carpeta**, así dos trabajos nunca se mezclan las copias ni se
borran entre sí. Y cada copia tiene la suya, de modo que copiar varias veces al día conserva
todas.

## Historial y avisos

El **historial** muestra cada ejecución con su resultado: exitosa, parcial (por ejemplo, 54 de
56 bases), fallida o en curso. Si algo falla, al desplegar la fila verás **el motivo real**, no
un mensaje genérico.

Y puedes pedir que **te avise por correo** cuando una copia falle o cuando pasen demasiadas
horas sin una correcta. Se envía una vez por incidencia, no en cada comprobación.

## Archivos en este servidor

Aparte, el panel lista lo que ocupa disco **en el propio servidor**: los respaldos previos a
cada actualización y los volcados del sistema antiguo. Puedes borrarlos desde ahí.

:::warning Son dos cosas distintas
Borrar archivos locales **no** elimina las copias del destino remoto, y la retención remota
tampoco borra nada de aquí.
:::

## Restaurar

Cada copia lleva dentro un `COMO-RESTAURAR.txt` con las instrucciones. El procedimiento completo
está en [Configurar las copias](/devs/operacion/configurar-copias-drive).

:::danger Lo que más se falla al restaurar
Hay que usar el archivo de configuración **de la copia**. Si se instala el sistema nuevo y se
deja su clave recién generada, los volcados se importan bien pero el sistema no puede abrir
ninguna base de cliente. El script de restauración lo comprueba y se niega a seguir si no
coincide.
:::
