---
sidebar_position: 2
title: Configurar las copias a Google Drive
description: Paso a paso, desde cero, para que las copias empiecen a subirse solas.
---

# Configurar las copias a Google Drive

Guía completa. Al terminar, las copias se harán solas y podrás entrar a tu Drive, ver las
carpetas por fecha y descargarte un volcado sin ninguna herramienta.

:::info Antes de empezar: por qué hacen falta dos piezas
El panel **no hace** las copias: las **encarga**. Deja una orden y un servicio del servidor la
recoge y la ejecuta. Es necesario porque el volcado necesita hablar con el contenedor de
MariaDB y `rclone` vive en el servidor, dos cosas que la aplicación PHP no puede hacer.

**Si ves una copia «En cola» que no avanza, es que falta ese servicio.** Es el paso 3.
:::

## Paso 1 · Instalar rclone en el servidor

Por SSH, en el servidor:

```bash
sudo apt update && sudo apt install -y rclone
rclone version
```

Si tu distribución trae una versión antigua (menor que 1.60), instala la oficial:

```bash
curl https://rclone.org/install.sh | sudo bash
```

## Paso 2 · Autorizar Google Drive

:::note Dónde se ejecuta cada cosa
El **paso 1** va en el servidor (Linux, por SSH). El **paso 2** va en **tu ordenador**, porque
el servidor no tiene navegador y no puede completar el consentimiento de Google. Los pasos 3 a
6 vuelven al servidor o al panel.
:::

Tu servidor no tiene navegador, así que la autorización se hace **en tu ordenador** y se pega
el resultado. Es el paso que más se atasca, y solo tiene un truco: hay que decirle a rclone
que **no** intente abrir el navegador.

**En tu PC** (con rclone instalado, [descárgalo aquí](https://rclone.org/downloads/)):

```bash
rclone authorize "drive"
```

:::warning El token da acceso permanente
Ese JSON permite leer, subir y **borrar** tu Drive entero, incluidas las copias. No lo pegues
en correos, chats ni capturas: solo en el panel. Si se te escapa, revócalo en
[los permisos de tu cuenta de Google](https://myaccount.google.com/permissions) —borrar el
mensaje donde lo pegaste **no lo invalida**— y vuelve a autorizar.
:::

:::warning En Windows hay que escribir `.\` delante
Si descargaste el ZIP y ejecutas desde esa carpeta, PowerShell responde
*«El término 'rclone' no se reconoce…»*. No es que falte: **PowerShell no ejecuta programas de
la carpeta actual** salvo que se lo digas. Antepón `.\`:

```powershell
cd C:\Users\TU_USUARIO\Downloads\rclone-v1.75.0-windows-amd64
.\rclone authorize "drive"
```

Si lo vas a usar más veces, cópialo a una carpeta del PATH (por ejemplo
`C:\Windows\System32`) o añade su carpeta al PATH, y entonces sí funcionará como `rclone`
a secas desde cualquier sitio.
:::

Se abrirá el navegador, entras con tu cuenta de Google y aceptas. Al volver a la terminal,
rclone imprime algo así:

```
Paste the following into your remote machine --->
{"access_token":"ya29.a0Ad…","token_type":"Bearer","refresh_token":"1//09…","expiry":"2026-…"}
<---End paste
```

**Copia el JSON completo**, desde la primera `{` hasta la última `}` — sin las líneas
`Paste the following…` ni `<---End paste`.

:::tip Copiar bien desde PowerShell
Selecciona el texto con el ratón y pulsa **Enter** (así copia en la consola de Windows), o
usa botón derecho → *Marcar*. Si al pegar en el panel ves saltos de línea en medio del JSON,
no pasa nada: el sistema los quita antes de usarlo.
:::

:::danger Crea tu propio Client ID: el compartido se retira en 2026
rclone avisa desde su propia documentación:

> *«The shared client_id **is being retired and will stop working during 2026**, so creating
> your own is now strongly recommended.»*

Es decir: si dejas *Client ID* y *Client Secret* vacíos, las copias funcionarán hasta que
Google corte esa cuota compartida — **y entonces empezarán a fallar sin que nadie haya tocado
nada**. No es un campo opcional por mucho tiempo.

Crearlos, resumido:

1. Entra en [console.cloud.google.com](https://console.cloud.google.com) y crea un proyecto.
2. Activa la **Google Drive API**.
3. En *Credenciales*, crea un *ID de cliente de OAuth* de tipo **Aplicación de escritorio**.
4. Copia el *Client ID* y el *Client Secret* en el panel.

Guía completa: [rclone — making your own client id](https://rclone.org/drive/#making-your-own-client-id).

Si cambias el Client ID, **vuelve a ejecutar `rclone authorize`**: el token anterior pertenece
a la aplicación antigua. Con credenciales propias, además, las subidas grandes van bastante
más rápidas.
:::

## Paso 3 · Instalar el ejecutor

Es la pieza que recoge lo que encarga el panel. **Sin ella las copias se quedan en cola.**

```bash
cd /ruta/del/proyecto
sudo bash scripts/host-runner-install.sh
```

:::tip El panel te da el comando con tu ruta
No hace falta que la busques: cuando una orden se queda en cola, el aviso de la pantalla
de copias muestra el comando con la ruta real de tu instalación, listo para pegar. También
está en la ayuda lateral, pestaña *Desde cero*.

El instalador deduce la carpeta y el prefijo de los contenedores; no le pases ninguno.
:::

Detecta solo el prefijo de tus contenedores, crea el servicio systemd y lo arranca. Para
comprobar que está vivo:

```bash
sudo bash scripts/host-runner-install.sh --status
```

Debe decir `OK instalado` y mostrar cuándo se disparará. Si dice `NO instalado`, las órdenes
del panel no las ejecutará nadie.

## Paso 4 · Crear el destino en el panel

En **Backup → Destinos → Añadir**:

| Campo | Qué poner |
|---|---|
| **Nombre interno** | `gdrive` — minúsculas, sin espacios. Es el que eligen los trabajos. |
| **Descripción** | «Drive de la empresa», para reconocerlo. |
| **Tipo** | Google Drive |
| **Ruta en el destino** | Puedes anidar carpetas: `backup/nt-suite.pro`. Se crean solas, y así un mismo Drive aloja varios servidores sin mezclarse. |
| **Formato** | *Archivos normales* si quieres poder abrirlos desde Drive. |
| **Conservar copias** | 30 días es un buen punto de partida. |
| **Token de autorización** | El JSON completo del paso 2. |
| **Client ID / Secret** | Muy recomendable (ver el aviso de arriba). |

Guarda y pulsa **Probar**. La prueba escribe un archivo y lo lee de vuelta: comprobar solo
que la carpeta existe dejaría pasar un token de solo lectura, que fallaría en la primera copia
real y de madrugada.

## Paso 5 · Crear el trabajo

En **Backup → Trabajos de copia → Crear**:

| Campo | Qué poner |
|---|---|
| **Nombre** | «Copia diaria» |
| **Destino** | `gdrive` |
| **Qué copiar** | *Todo* (bases + archivos + configuración) |
| **Cuándo** | *Diario (02:00)* |
| **Carpeta** | vacío, salvo que compartas el destino entre proyectos |
| **Conservar las últimas** | 14 copias |
| **Activo** | sí |

Puedes crear **varios trabajos** con destinos y horarios distintos: por ejemplo «bases cada
6 h al Drive» y «todo completo, semanal, a otro proveedor».

Pulsa el botón de **ejecutar** de la fila para lanzar la primera sin esperar al horario.

:::note Activar un trabajo no dispara una copia inmediata
La primera será a la siguiente hora programada. Para una ahora mismo, usa el botón de
ejecutar.
:::

## Cómo queda organizado en el destino

```
backup/nt-suite.pro/        ← «Carpeta base», del destino
  produccion/               ← «Subcarpeta», del trabajo (opcional)
    copia-diaria/           ← el trabajo, automático
      2026-08-31_020000/    ← una carpeta por EJECUCIÓN
        db/*.sql.gz
        config/.env, docker-compose.yml
        COMO-RESTAURAR.txt
      2026-08-31_060000/
      files/                ← espejo: solo sube lo que cambió
      files-versiones/2026-08-31_060000/
```

Dos cosas importantes de esta estructura:

**Cada trabajo escribe en su propia carpeta.** Es lo que impide que dos trabajos sobre el mismo
destino se mezclen las copias y —lo que de verdad duele— que la retención de uno borre las
carpetas del otro.

**Cada ejecución tiene la suya.** Por eso copiar varias veces al día conserva las copias de
verdad, en lugar de que la de las 06:00 sobrescriba la de las 02:00.

:::tip «Conservar las últimas N» cuenta copias, no días
Con 6 copias diarias, «7 días» serían 42 carpetas y el espacio se dispara sin verlo venir.
Contando copias, lo que configuras es lo que ocupa.
:::

## Los cuatro tipos de copia

| Tipo | Qué incluye |
|---|---|
| **Todo** | Bases + archivos + configuración |
| **Bases de datos** | Los volcados + configuración |
| **Archivos** | XML firmados, CDR, certificados, logos + configuración |
| **Un cliente completo** | La base de un cliente **y** sus archivos |

*Un cliente completo* es el que sirve para «un cliente se va y quiere sus datos» o para
restaurar solo a uno: con «bases de datos» de un cliente se quedaban fuera sus XML firmados.

:::note La configuración va siempre
Aunque el tipo diga «bases de datos», el `.env` se copia igual. Sin la `APP_KEY` que contiene,
los volcados no abren las bases de los clientes — son unos pocos KB que evitan que una copia
quede inservible.
:::

## Paso 6 · Comprobar que ha subido

En el panel, la fila aparecerá en el **historial** con su resultado. Y desde el servidor:

```bash
rclone lsf gdrive:nt-suite-backup/db --dirs-only
rclone size gdrive:nt-suite-backup
```

O simplemente entra a tu Drive: verás `nt-suite-backup/db/<fecha>/` con un `.sql.gz` por
empresa y un `COMO-RESTAURAR.txt` con las instrucciones dentro.

:::tip Ayuda dentro del propio panel
Cada campo del formulario tiene un **?** que abre un panel lateral con los pasos de ese
proveedor. El botón **Ayuda** de la cabecera abre el flujo completo desde cero.
:::

## Si algo no va

| Síntoma | Causa y solución |
|---|---|
| **«En cola» y no avanza** | Falta el ejecutor, **o está instalado y no arrancó**. Comprueba las dos cosas: `sudo bash scripts/host-runner-install.sh --status` y `systemctl status nt-suite-runner.timer`. Ver el recuadro de abajo. |
| Temporizador `failed`: «Unit docker.service not found» | Docker no es un servicio de systemd (Docker Desktop + WSL, rootless, o `DOCKER_HOST` remoto). Reinstala: `sudo bash scripts/host-runner-install.sh`. |
| «rclone no esta instalado» | Paso 1. En el servidor, no en tu PC. |
| PowerShell: «El término 'rclone' no se reconoce» | Estás en la carpeta del ZIP: escribe `.\rclone authorize "drive"`. Ver el aviso del paso 2. |
| «No se pudo acceder a…» | El token caducó o no tiene permisos de escritura. Repite el paso 2 y pulsa **Probar**. |
| «copia PARCIAL» | Alguna base o carpeta falló. El detalle está en el historial, desplegando la fila. |
| «MYSQL_ROOT_PASSWORD no esta en .env» | El script se ejecutó desde una carpeta que no es la del proyecto. Usa `--project-dir`. |
| Todo correcto pero el Drive se llena | Baja «Conservar copias» o espacia el horario. Sin cifrado no hay deduplicación: cada copia ocupa entera. |
| `FALLO al sincronizar tenants (revisa permisos de lectura)` | Una carpeta que el ejecutor no puede leer. El temporizador corre como `root`, así que esto suele salir solo al lanzar el script a mano con otro usuario. |

:::danger Que el instalador termine bien no significa que esté corriendo
Es la avería que más cuesta reconocer, porque **no da ningún error**: el panel encarga la
copia, la escribe en `storage/app/system/jobs/` y se queda esperando a un proceso que no
existe. La pantalla dice «En cola» y no pasa nada más.

```bash
systemctl status nt-suite-runner.timer
```

Debe decir `Active: active (waiting)` y una hora en `Trigger:`. Si dice `failed`, la fila
de arriba tiene el motivo más habitual.

Para ver qué pasó en el último intento:

```bash
journalctl -u nt-suite-runner.service -n 50 --no-pager
```
:::

:::note Una copia «Parcial» no es una copia fallida
La copia **está subida**; lo que ocurre es que alguna base o carpeta quedó fuera, y el
historial dice cuál. No dispara el aviso de fallo por correo, y aparece como *Parcial* en
el historial. Tratarla como fallo escondería que 7 de 7 bases sí entraron.
:::

## Cuánto va a tardar (y qué lo hace lento)

Cada paso del registro dice cuánto tardó el anterior, así que esto no hay que adivinarlo.
Medido en una instalación con 7 bases:

| Paso | Tiempo |
|---|---|
| Cargar perfil y verificar destino | 6 s |
| Configuración | 55 s |
| Bases de datos | 99 s |
| Archivos | 14 s |

:::tip Lo que casi nunca es el problema son los archivos
La intuición dice que lo lento es subir miles de XML y CDR uno por uno. Pero `rclone sync`
es **incremental**: un XML firmado se sube una vez y nunca más, porque no cambia. En
régimen normal el paso de archivos es el más corto de todos —14 s arriba—; lo que sí puede
tardar es la **primera** copia, que sube todo el histórico.

Comprimirlo todo en un `.tar.gz` y subir un solo archivo parece más rápido, y para la
primera vez lo es. Pero elimina el incremental: **cada** copia volvería a subir el
histórico entero. Con 16 GB de archivos y 4 copias al día son 64 GB diarios de subida en
lugar de casi nada. Y para recuperar un solo XML habría que descargar el paquete completo.
:::

### Lo que sí cuesta: las bases

Los volcados se suben **enteros en cada copia** —una base hay que volcarla completa para
que sea consistente—, así que su tamaño manda sobre el tiempo total.

De ahí que la copia excluya el **contenido** de las tablas efímeras, conservando su
estructura para que la restauración funcione:

```
telescope_entries · telescope_entries_tags · telescope_monitoring
sessions · failed_jobs · jobs
```

Son datos de depuración y de cola: nadie los restaura. En la instalación medida,
`telescope_entries` pesaba **7,6 GB con 5,4 millones de filas**, mientras que todo lo demás
de la base del sistema —clientes, planes, licencias— sumaba menos de 2 MB. El efecto:

| | Antes | Después |
|---|---|---|
| Volcado del sistema | 297,8 MB | **0,22 MB** |
| Total de la copia | 316,7 MB | **19,1 MB** |

Podar Telescope **no sustituye** a esto: `telescope:prune --hours=48` deja las últimas 48 h,
que en un servidor con tráfico siguen siendo cientos de MB en cada copia.

### Ajustar la subida

Para proveedores con muchos ficheros pequeños, `rclone` va afinado con `--fast-list`
(pide el árbol remoto de una vez en lugar de carpeta por carpeta), 8 transferencias y 16
comprobadores. Se puede subir por variable de entorno en el perfil del destino:

```bash
RCLONE_TRANSFERS=16
RCLONE_CHECKERS=32
```

:::warning Más no siempre es más rápido
Pasarse provoca respuestas 403 de límite de tasa del proveedor; rclone reintenta y la copia
acaba tardando **más**. Sube de dos en dos y compara los tiempos del registro.
:::

## Cuánto va a ocupar

Los volcados se comprimen: una base de **567 MB pasa a 15 MB** (medido). Un servidor con
16 GB de bases ocupa unos **450 MB por copia completa**, así que 30 días de copias diarias son
~14 GB.

Los **archivos** no se duplican: se sincronizan, así que solo sube lo que cambió desde la
última vez. Lo que se borra o se modifica queda en `files-versiones/<fecha>`.
