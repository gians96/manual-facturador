---
sidebar_position: 1
title: Servicios operativos
description: Qué se está ejecutando en producción, cada cuánto, y cómo comprobar que sigue vivo.
---

# Servicios operativos

Registro de lo que corre solo en una instalación en producción. Una tarea programada que
falla no avisa: sigue apareciendo en el código y deja de hacer su trabajo. Esta página existe
para poder **comprobarlo**, no solo para saber que existe.

:::info Cómo se mantiene
Cuando un trabajo deja un servicio corriendo (comando programado, timer de systemd, demonio),
se añade aquí **con su comando de verificación** antes de darlo por cerrado. Está recogido en
el `AGENTS.md` de este repo y en el de `pro-8`.
:::

Los ejemplos usan el prefijo de contenedor `nt-suite_pro`; sustitúyelo por el de tu dominio
(`fpm_<dominio-con-guiones-bajos>`).

## Comprobación rápida

Todo lo programado depende de un solo proceso: el `schedule:run` del contenedor
`scheduling_*`. Si ese contenedor está parado, **nada de la tabla de abajo se ejecuta** y no
hay ningún aviso.

```bash
# ¿Está vivo el scheduler?
docker ps --filter "name=scheduling_nt-suite_pro" --format "{{.Names}} {{.Status}}"

# ¿Qué tiene programado y cuándo toca?
docker exec fpm_nt-suite_pro sh -c "cd /var/www/html && CACHE_DRIVER=file php artisan schedule:list"
```

## Tareas programadas (contenedor `scheduling_*`)

| Servicio | Qué hace | Frecuencia | Cómo verificar que está vivo | Log |
|---|---|---|---|---|
| `tenancy:run tenant:run` | Tareas por tenant: consultas a SUNAT y envíos automáticos. Ejecuta solo las que estén **activas** en la tabla `tasks` del tenant (interruptor de la pantalla *Tareas programadas*) | cada minuto | `docker exec fpm_… php artisan schedule:list \| grep tenant:run` | — |
| `status:server` | Muestra de CPU y RAM para las gráficas de `/information` | cada 5 min | Que aparezcan filas nuevas en `history_resources` | — |
| `storage:scan` | Mide disco, inodes y consumo por tenant para `/information` | cada hora | `stat -c %y storage/app/system/storage-usage.json` (debe ser de hace &lt; 1 h) | `storage_scan.log` |
| `tenants:clean-pdfs --older-than=90` | Libera disco e inodes borrando PDF regenerables de más de 90 días | domingos 04:30 | `tail storage/logs/clean_tenant_pdfs.log` | `clean_tenant_pdfs.log` |
| `telescope:prune --hours=48` | Poda `telescope_entries`, que si no crece sin límite | diaria | `SELECT COUNT(*) FROM telescope_entries` (no debe crecer sin fin) | `telescope_prune.log` |
| `backup:tick` | Decide si toca copia y **encarga** la orden al runner del host | cada 15 min | `tail storage/logs/backup_tick.log` | `backup_tick.log` |
| `backup:watch` | Reconcilia el historial con lo que dejó el runner y **avisa por correo** si falla | cada 15 min | `tail storage/logs/backup_watch.log` | `backup_watch.log` |
| `tenants:usage --flush` | Vuelca el consumo por tenant y refresca tamaños de BD y disco | cada 20 min | `php artisan tenants:usage --days=7` | `tenant_usage.log` |
| `backup:prune-runs --days=180` | Poda el historial de copias | lunes 05:30 | `SELECT COUNT(*) FROM backup_runs` | `backup_prune_runs.log` |
| `tenancy:run print-orders:prune` | Borra órdenes de impresión ya impresas (`pdf_b64` es pesado) | diaria 04:00 | `tail storage/logs/print_orders_prune.log` | `print_orders_prune.log` |
| `order:payments` | Procesa pagos pendientes | cada 2 min | `tail storage/logs/order_create.log` | `order_create.log` |

> **Las tareas de cada empresa se ven y se apagan desde el panel del tenant**, en
> *Tareas programadas* (`/tasks`). Lo que se ofrece ahí es una lista blanca
> declarada en `app/Support/TaskCatalog.php`, no un escaneo del directorio de
> comandos: **añadir un comando nuevo al repo ya no lo publica en el panel de
> todas las empresas**; hay que declararlo en el catálogo.
>
> El conjunto recomendado (enviar a SUNAT → resumen diario → bajas → consultar
> resumen → verificar) se crea solo al dar de alta una empresa. Para las que ya
> existen, con `--dry-run` primero:
>
> ```bash
> docker exec fpm_… php artisan tenancy:run tasks:seed-stack --option="dry-run=true"
> docker exec fpm_… php artisan tenancy:run tasks:seed-stack --option="only-empty=true"
> ```
>
> Comprobar que una empresa las tiene y están encendidas:
> `SELECT class, execution_time, active FROM <bd_tenant>.tasks;`
>
> ⚠️ Nada de esto corre si `configurations.cron` está en 0 en ese tenant: los
> comandos salen en la primera línea de su `handle()`.
| `demodb:bktemporary` | Restaura los tenants demo a su snapshot | diaria 03:30 | Que un tenant demo aparezca limpio por la mañana | — |
| `nubetec:refresh-legal` | Versiones legales vigentes de la plataforma | cada hora | `tail storage/logs/nubetec_legal.log` | `nubetec_legal.log` |
| `nubetec:refresh-announcements` | Anuncios que muestra el navbar | cada hora | `tail storage/logs/nubetec_announcements.log` | `nubetec_announcements.log` |
| `tenancy:run nubetec:notify-legal` | Avisa por correo de cambios en los documentos legales | diaria 09:00 | `tail storage/logs/nubetec_legal_notify.log` | `nubetec_legal_notify.log` |
| `nubetec:sync-tenants --limit=200` | Federa empresas hacia la plataforma | diaria 03:30 | `tail storage/logs/nubetec_sync_tenants.log` | `nubetec_sync_tenants.log` |
| `nubetec:seed-subscriptions` | Refleja el plan de cada empresa al día | diaria 03:45 | `tail storage/logs/nubetec_seed_subscriptions.log` | `nubetec_seed_subscriptions.log` |

## Servicios del host (fuera de Docker)

Estos **no** pueden vivir en el contenedor: `restic` está instalado en el host, el volcado
necesita `docker exec` a MariaDB, y la actualización reinicia los propios contenedores PHP —
un proceso que viviera dentro moriría a mitad.

| Servicio | Qué hace | Frecuencia | Cómo verificar que está vivo |
|---|---|---|---|
| `nt-suite-runner.service` / `.timer` | Recoge las órdenes que deja el panel (`/auto-update`, `/backup`) y las ejecuta | cada minuto | `systemctl status nt-suite-runner.timer` — debe decir `active (waiting)` y traer hora en `Trigger:` |
| `logrotate` de `storage/logs/*.log` | Rota los logs del scheduler, que **no** pasan por Monolog y no rotan solos | diaria | `logrotate -d /etc/logrotate.d/nt-suite` |
| `docker system prune` | Libera las capas huérfanas que deja cada despliegue (suelen ser la causa real de quedarse sin inodes) | semanal | `docker system df` |

### Instalar el runner del host

Hay un instalador; no escribas las unidades a mano. Desde la carpeta del proyecto —sea
cual sea— detecta solo la ruta y el prefijo de los contenedores, y crea
`nt-suite-runner.service` y `nt-suite-runner.timer`:

```bash
sudo bash scripts/host-runner-install.sh
```

:::note No le indiques la ruta ni el prefijo
Los deduce: la carpeta, de dónde está el propio script; el prefijo, del primer contenedor
`fpm_*` que encuentre corriendo. Pasarlos a mano es la fuente de error más común —se
escribe el dominio con puntos donde van guiones bajos—. El panel muestra el comando con
la ruta real de tu instalación en el aviso y en su ayuda lateral.
:::

El script toma un `flock`, así que dos disparos solapados no ejecutan dos veces.

:::danger Instalar no es lo mismo que estar corriendo
El instalador puede terminar sin errores y el temporizador quedarse **caído**. Si eso
pasa, las órdenes del panel se acumulan en «En cola» y nada lo explica: el panel las
encargó y nadie las recoge. Comprueba **siempre** las dos cosas:

```bash
sudo bash scripts/host-runner-install.sh --status
systemctl status nt-suite-runner.timer
```

Tiene que decir `Active: active (waiting)` y una hora en `Trigger:`.
:::

#### `Failed to queue unit startup job: Unit docker.service not found`

El temporizador arranca y muere en el acto. Ocurre cuando **Docker no es un servicio de
systemd**: Docker Desktop con integración WSL, docker rootless (es una unidad de
usuario, no del sistema) o un `DOCKER_HOST` remoto.

Las versiones anteriores del instalador escribían `Requires=docker.service`, que es una
dependencia *dura*: si esa unidad no existe, systemd se niega a encolar el trabajo y
tumba el temporizador entero. Reinstalar lo arregla — ahora comprueba si
`docker.service` existe de verdad y solo lo referencia entonces, dejando la verificación
de que Docker responde al propio script, que da un error legible.

```bash
sudo bash scripts/host-runner-install.sh
```

**Desde 2026-08-31 esto se arregla solo al actualizar.** `prod-update.sh` ejecuta
`host-runner-install.sh --refresh` como último paso, que reescribe la unidad **solo si ya
estaba instalada** y sale sin error si no lo está o si falta permiso. Así un arreglo en la
plantilla llega a todos los servidores con el despliegue, en vez de tener que ir máquina
por máquina. La actualización **no** instala el ejecutor por su cuenta: montar un servicio
del sistema es decisión de quien administra el servidor.

## Copias de seguridad

La programación se edita desde `/backup` en el panel; las **credenciales del destino** viven
en el servidor y nunca en la aplicación.

### Dos modos

| | **Archivos normales** (`plain`) | **Cifrado** (`restic`) |
|---|---|---|
| ¿Se ven en el Drive? | **Sí**: carpetas por fecha, descargas un `.sql.gz` y ya | No: hace falta `restic` y la contraseña |
| Espacio | Cada copia ocupa entera (los volcados van con `gzip`) | Muchas copias apenas cuestan más que una |
| Retención | Borra carpetas con más de `KEEP_DAYS` días | `restic forget --keep-*` |
| Si el destino se compromete | Los datos son legibles | Los datos no se pueden leer |

**`plain` es el modo por defecto** y es lo razonable cuando el Drive es tuyo y quieres poder
entrar y descargarte un volcado sin herramientas.

Un dato medido, para dimensionar: una base de **567 MB en disco baja a 15 MB** comprimida
(ratio ~37×). Un servidor con 16 GB de bases cabe en unos **450 MB por copia completa**, así
que 30 días de copias diarias son ~14 GB.

### Destinos y trabajos

Se gestionan **desde el panel**, en `/backup`, con el mismo modelo que Dokploy:

- **Destinos**: el catálogo de sitios donde dejar copias (Google Drive, S3/B2/R2, SFTP, disco
  montado). Se crean una vez y los comparten todos los trabajos. Sus credenciales se guardan
  **cifradas** con la `APP_KEY`, y hay un botón **Probar** que escribe un archivo y lo lee de
  vuelta: comprobar solo que la carpeta existe dejaría pasar un token de solo lectura, que
  fallaría en la primera copia real.
- **Trabajos**: N tareas independientes, cada una con su destino, alcance (todo / bases /
  archivos / una base concreta), horario, carpeta y retención. Se activan por separado y se
  pueden lanzar a mano sin tocar su horario.

Así se pueden tener a la vez «bases cada 6 h al Drive» y «todo completo, semanal, a otro
proveedor», que es lo que una sola programación no permitía.

:::tip Un destino que el panel no deba conocer
Quien administre el panel puede usar las credenciales guardadas ahí. Para un destino que deba
quedar fuera de su alcance, defínelo en el servidor con `scripts/backup-setup.sh`: el panel lo
lista como *solo lectura* y nunca ve sus claves.
:::

### Configurarlo desde el servidor

```bash
sudo bash scripts/backup-setup.sh          # asistente: pregunta el modo y guía Drive
sudo bash scripts/backup-setup.sh --check  # comprobar lo ya configurado
```

Como el servidor no tiene navegador, la autorización de Drive se hace en tu ordenador
(`rclone authorize "drive"`) y se pega el token en el asistente. Responde **`n`** a «usar el
navegador para autenticar»: es lo que corresponde en una máquina sin escritorio.

El perfil queda en `/etc/nt-suite/backup.d/<perfil>.env` con permisos `600` de root, y junto a
él un `.info` con permisos `644` que contiene **solo lo que no es secreto** (modo y destino).
El panel lee ese `.info` para saber cómo tratar el destino; el `.env` con las claves no lo
puede leer, porque corre como `www-data`.

```bash
# /etc/nt-suite/backup.d/gdrive.env   (600, root)
BACKUP_MODE=plain
REMOTE_PATH=gdrive:backup/mi-servidor
```

:::note Ya no lleva `KEEP_DAYS`
La retención vive **solo en el trabajo**, y se cuenta en copias, no en días. Tenerla en los
dos sitios obligaba a rellenar dos campos «Conservar» sin que se supiera cuál mandaba.
:::

:::warning El .env del servidor viaja en la copia
Se respalda a propósito: de su `APP_KEY` derivan las contraseñas de base de datos de cada
tenant, así que sin él los volcados no bastan para recuperar el acceso. Pero eso significa
que, en modo `plain`, **cualquiera que entre a esa cuenta de Drive tiene las claves de la
instalación y los datos fiscales de todos los clientes**. Protege esa cuenta con verificación
en dos pasos y no la compartas.
:::

### Cómo queda organizado en el destino (modo `plain`)

```
backup/mi-servidor/          <- carpeta base del destino
  copia-diaria/              <- una carpeta POR TRABAJO: es lo que los aísla
    2026-08-31_020000/       <- una carpeta POR EJECUCIÓN, con hora
      db/*.sql.gz            <- un volcado por empresa
      config/                <- .env, docker-compose.yml, supervisor.conf
      COMO-RESTAURAR.txt
    2026-08-31_060000/       <- copiar varias veces al día ya no se pisa
    files/                   <- espejo, sólo sube lo que cambió
    files-versiones/         <- lo que se borró o cambió, por ejecución
```

Cada trabajo tiene **su propia carpeta**, así dos trabajos sobre el mismo destino nunca se
sobrescriben ni se borran la retención entre ellos. Y cada ejecución tiene la suya, de modo
que copiar varias veces al día conserva todas.

`files/` se sincroniza, no se duplica: los XML firmados y los CDR ya subidos no se vuelven a
transferir. Restaurar un cliente es descargar su `.sql.gz` y su carpeta de `files/`.

Verificación:

```bash
# Estado del destino, sea cual sea el modo
sudo bash scripts/backup-setup.sh --check

# Modo archivos normales
rclone lsf gdrive:backup/mi-servidor --dirs-only          # trabajos
rclone lsf gdrive:backup/mi-servidor/copia-diaria --dirs-only | tail -5
rclone size gdrive:backup/mi-servidor

# Modo cifrado
restic snapshots --tag db | tail -5
restic check                      # integridad, semanal
restic stats --mode raw-data      # lo que ocupa de verdad, ya deduplicado
```

## Consumo por tenant (para revisar planes)

```bash
docker exec fpm_nt-suite_pro sh -c "cd /var/www/html && CACHE_DRIVER=file php artisan tenants:usage --days=30"
```

También en el panel: **Información → Consumo por tenant**.

:::info Qué se mide y qué no
No hay aislamiento por tenant: todos comparten los mismos procesos PHP y la misma
instancia de MariaDB, así que el sistema operativo ve procesos, no clientes. «Cuánta RAM
usa el tenant X» **no tiene respuesta directa**.

Lo que sí se puede es **atribuir**: un middleware mide cada petición —en `terminate()`, con
la respuesta ya enviada, para no añadir latencia— y la suma al tenant que la provocó. Eso,
cruzado con el tamaño exacto de su base de datos (`information_schema`) y sus archivos en
disco, da un **índice de consumo** comparable entre clientes.
:::

El informe también dice **por qué** pesa cada uno (proceso, tráfico, base de datos o
archivos) y en qué proporción. No es lo mismo un cliente que consume por tráfico —muchos
usuarios trabajando— que uno que solo acumula datos: la conversación sobre su plan es
distinta, y esa columna es la que la orienta.

## Configurar el destino de las copias

Hay un asistente que instala `restic` y `rclone`, guía la autorización de Google Drive,
crea el perfil con permisos correctos e inicializa el repositorio:

```bash
sudo bash scripts/backup-setup.sh                 # asistente (Google Drive)
sudo bash scripts/backup-setup.sh --check         # comprobar lo ya configurado
```

Como el servidor no tiene navegador, la autorización de Drive se hace en tu ordenador
(`rclone authorize "drive"`) y se pega el token en el asistente. Éste responde `n` a
«usar el navegador para autenticar», que es lo que corresponde en una máquina sin escritorio.

## Restaurar en otro servidor

Cada copia lleva dentro un `COMO-RESTAURAR.txt` con sus propias instrucciones, para no tener
que buscar documentación el día peor.

```bash
# 1. Ver qué copias hay (una carpeta por ejecución)
rclone lsf gdrive:backup/mi-servidor/copia-diaria --dirs-only

# 2. Descargar una ejecución concreta, más los archivos
rclone copy gdrive:backup/mi-servidor/copia-diaria/2026-08-31_020000 ./restore
rclone copy gdrive:backup/mi-servidor/copia-diaria/files ./restore/files

# 3. Ver qué haría, sin tocar nada
bash scripts/backup-restore.sh --from ./restore --dry-run

# 4. Restaurar
bash scripts/backup-restore.sh --from ./restore
```

:::note El prefijo de los contenedores se detecta solo
Ya no hay que pasar `--prefix`: los scripts lo deducen del primer contenedor
`fpm_*` que encuentren. Si restauras donde todavía no corren, indícalo con
`--container-prefix <nombre>`.
:::

:::danger El error que más se comete al restaurar
De la `APP_KEY` del `.env` derivan las contraseñas de base de datos de **cada tenant**. Si se
instala el sistema nuevo y se deja su `APP_KEY` recién generada, los volcados se importan bien
pero el sistema **no puede abrir ninguna base de tenant**: da «Access denied» y parece que el
backup estaba mal. No lo estaba.

El script comprueba la `APP_KEY` antes de tocar nada y se niega a seguir si no coincide,
ofreciendo las dos salidas: usar el `.env` de la copia, o conservar la clave del servidor y
ejecutar después `php artisan tenancy:key:update`.
:::

El script además verifica cada `.sql.gz` con `gzip -t` **antes** de empezar: un volcado
truncado se detecta ahí y no a mitad de la importación.

**Verificado** en una restauración real: 329 tablas, mismos recuentos de documentos, ítems,
personas y usuarios, y `CHECKSUM TABLE` idéntico entre origen y destino.

:::info Qué queda fuera de la copia, y por qué
Solo los PDF y las bandejas de descarga, porque el sistema los regenera. **Las bases de
datos van completas**: ninguna tabla, ninguna fila y ninguna columna se omiten, de modo que
la comparación por `CHECKSUM TABLE` de arriba sigue siendo posible.
:::

## Telescope: la tabla que se come el disco

`telescope_entries` guarda una fila por petición, consulta, evento y acceso a caché. Sin
frenarla llega a cifras que sorprenden: en una instalación medida ocupaba **40,5 GB de
fichero conteniendo 169 MB de datos**, y generaba **3.477 filas por minuto** (≈5 millones al
día).

El desglose explica dónde está el ruido:

| Tipo de entrada | Filas en 41 min |
|---|---|
| `cache` | 72.089 |
| `event` | 63.042 |
| `query` | 5.167 |

**El 95 % es caché y eventos**, que no sirven para diagnosticar nada. Ningún código de
negocio consulta esas tablas.

### Cómo dejarla pequeña

**1 · Vaciarla.** Devuelve el espacio al instante, siempre que `innodb_file_per_table` esté
activo (lo está por defecto). Una clave foránea obliga a desactivar la comprobación un
momento:

```bash
docker exec mariadb_<prefijo> sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "
SET FOREIGN_KEY_CHECKS=0;
TRUNCATE TABLE <base>.telescope_entries_tags;
TRUNCATE TABLE <base>.telescope_entries;
SET FOREIGN_KEY_CHECKS=1;"'
```

**2 · Callar los vigilantes ruidosos**, en el `.env`. No hace falta publicar la
configuración: el paquete lee una variable por vigilante.

```bash
TELESCOPE_CACHE_WATCHER=false
TELESCOPE_EVENT_WATCHER=false
```

Se conserva lo útil: excepciones, consultas, peticiones, correos, trabajos y comandos.

**3 · Podar más a menudo.** `telescope:prune --hours=12` cada 6 horas, no 48 h una vez al día.
Ya está en `app/Console/Kernel.php`.

:::danger Podar NO devuelve el espacio al disco
InnoDB no entrega al sistema de ficheros las páginas que libera un `DELETE`: quedan
reutilizables dentro de la tabla, pero el `.ibd` **solo crece**. Por eso una poda de 29
millones de filas dejó el fichero igual de grande, y hubo que vaciar la tabla.

Si algún día hay que recuperar espacio conservando el contenido, es `OPTIMIZE TABLE`, que
bloquea la tabla mientras reconstruye el fichero.
:::

:::note En producción, valora apagarlo del todo
`.env.example` trae `TELESCOPE_ENABLED=false`. Telescope es una herramienta de desarrollo; en
un servidor con tráfico real su coste es constante y su uso, ocasional.
:::

## El histórico de recursos: cuánto ocupa y cómo se limpia

Es la otra tabla que crece sola, pero **no tiene nada que ver con Telescope en escala**:

| | `history_resources` | `telescope_entries` sin frenar |
|---|---|---|
| Por fila | 154 bytes | ~600 bytes |
| Al día | ~168 muestras | ~5.000.000 filas |
| **Con la retención puesta** | **~2 MB (90 días)** | 40.960 MB |

Una muestra cada ~4 minutos, y **una sola fila por muestra pase lo que pase**: no crece con el
número de clientes, así que 2 MB son 2 MB con 5 tenants o con 55.

### Se poda sola, igual que Telescope

```bash
# Semanal, desde app/Console/Kernel.php
php artisan history:prune --days=90
```

90 días es el defecto porque es **el rango más largo que la pantalla permite consultar**:
guardar más es guardar lo que no se puede mirar. Se ajusta sin tocar código:

```bash
# .env
HISTORY_KEEP_DAYS=30
```

### Limpiarlo desde el panel

**Información → Almacenamiento → pestaña Mantenimiento**. Lista las tablas de diagnóstico con
su tamaño y filas reales, y ofrece las dos operaciones:

- **Podar** — borra las filas más antiguas del plazo que elijas. Pide confirmación.
- **Vaciar del todo** — recrea el fichero. Pide **escribir `VACIAR`**, porque se pierde todo
  el histórico y no se deshace.

Solo el administrador maestro puede usarlo: no basta con tener el módulo `information`
marcado, que es una casilla que un reseller puede activar desde su panel.

:::note Por qué dos botones y no uno
Podar y vaciar no son lo mismo, y ofrecer solo uno deja sin salida en la mitad de los casos.
Medido en esta instalación: podar 11.185 filas liberó **0 bytes** en el disco (InnoDB conserva
el fichero y reutiliza el hueco); vaciar Telescope liberó **13,59 MB** al instante.

El panel avisa cuando el hueco interno ya supera a los datos: ahí podar no va a devolver nada.
:::

### O a mano

```bash
docker exec fpm_<prefijo> php artisan history:prune --days=30
```

Cualquier valor sirve; `--days=1` deja solo el último día. El borrado va **por lotes de 5.000
filas** para no bloquear la tabla mientras `status:server` intenta escribir la muestra de ese
minuto.

:::note Podar no reduce el fichero, y aquí da igual
Como con Telescope, InnoDB no devuelve al disco las páginas liberadas: el `.ibd` mantiene su
tamaño y reutiliza el hueco. En una tabla que se estabiliza en 2 MB eso no es un problema —
justamente por eso aquí basta con podar, y en Telescope hubo que vaciar.
:::

## Actualizar: cómo se autentica y por qué el script se protege

### Un solo `git pull`, y lo hace el script

`prod-update.sh` hace **su propio** `git pull`. Hacerlo antes a mano no adelanta nada: git
contacta con el remoto siempre, así que el token se acaba tecleando dos veces.

### Las credenciales son del usuario que EJECUTA, no del que instala

Intervienen tres usuarios distintos y es fácil confundirlos:

| Quién | Qué hace |
|---|---|
| Tu usuario | El `git pull` a mano, en la terminal |
| **`root`** | Ejecuta la actualización (la unidad systemd no lleva `User=`) |
| **`www-data`** | El «Ver qué va a entrar» del panel |

Que funcione al ejecutarlo tú **no significa** que funcione desde el panel. Y bajo systemd no
hay terminal, así que git no puede preguntar: o falla, o se cuelga esperando.

```bash
sudo git config --global credential.helper store
sudo sh -c 'printf "https://%s:%s@gitlab.com\n" USUARIO TOKEN > /root/.git-credentials'
sudo chmod 600 /root/.git-credentials
```

:::warning Usa un Deploy Token, no tu token personal
*Settings → Repository → Deploy tokens*, permiso `read_repository`. Es de solo lectura, está
atado a ese proyecto y se revoca sin tocar tu cuenta. Si el servidor se ve comprometido, con
él no se puede empujar ni acceder a otros repositorios.
:::

Comprobar que ya no pide nada:

```bash
sudo GIT_TERMINAL_PROMPT=0 git -C /ruta/del/proyecto ls-remote origin
```

El script hace esa misma comprobación **antes** del respaldo: si faltan credenciales, avisa y
para, en vez de descubrirlo después de volcar toda la base.

### Por qué todo el script vive dentro de `main()`

Bash lee un script **por posición de byte a medida que lo ejecuta**. Como el script hace
`git pull` sobre el repositorio donde él mismo vive, se reescribe en marcha: todo lo posterior
se lee de un fichero que ya cambió debajo, y muere con `unexpected EOF` **después** del
respaldo y **antes** de migrar.

La solución es el idioma clásico de bash:

```bash
main() {
    ...todo el cuerpo...
}

main "$@"
exit $?
```

Dentro de una función, bash analiza el cuerpo entero antes de ejecutar nada.

:::danger El `exit $?` no es adorno
Sin él, bash sigue leyendo tras la llamada, choca con la cola del fichero nuevo y **termina
con código 2 aunque el trabajo haya salido bien** — y el panel lo marca como actualización
fallida. Medido: sin `exit`, código 2; con `exit`, código 0.
:::

Afecta a los scripts **versionados dentro del repositorio que actualizan**:
`prod-update.sh`, `local-update.sh` y `onprem-update.sh`. Los instaladores del manual se
descargan aparte, así que el `git pull` no los toca.

Además, si el `pull` trae una versión nueva del propio script, se relanza con ella una sola
vez (sin repetir la descarga), para que un arreglo del proceso de actualización surta efecto
en **esa** actualización y no en la siguiente. Lo compartido vive en
`scripts/lib/update-common.sh`.

## Qué NO está automatizado (y debería revisarse a mano)

- **La restauración.** Un backup sin restauración probada no es un backup. Una vez al mes:
  restaurar un tenant en un entorno aparte y abrirlo.
- **`APP_DEBUG` y `DEBUGBAR_ENABLED`.** Con Debugbar activo se escribe un archivo JSON por
  cada petición en `storage/debugbar/`, para siempre. Suele agotar los inodes antes que
  cualquier otra cosa. En producción ambos deben estar en `false`.
