---
sidebar_position: 4
title: Seguridad del servidor y registro fuera de la máquina
description: Qué deja la actualización por su cuenta, qué se instala a mano (journald, sshd, vigilante) y cómo sacar el registro de seguridad a otra máquina donde nadie lo pueda borrar.
---

# Seguridad del servidor y registro fuera de la máquina

Después de un incidente hay que poder responder **quién entró, desde dónde, cómo y qué cambió**, aunque
el servidor esté tomado. Quien controla un servidor controla también lo que está guardado en él. Por eso
la evidencia tiene que salir a **otra máquina**, que la recoge sin que el servidor tenga cómo borrarla.

El diseño completo está en `pro-8/docs/04-arquitectura/registro-de-eventos-de-seguridad.md`. Qué hacer en un
incidente: `pro-8/docs/09-operacion/incidente-de-seguridad.md`.

## Lo que deja la actualización sola

`prod-update.sh`, `onprem-update.sh` y los `update.sh` de este manual aplican, sin preguntar, todo lo
que no cambia nada visible:

| Qué | Para qué |
|---|---|
| PHP de la imagen del proyecto (`scripts/stack/php`), en la versión parcheada que fija el repo | Ningún servidor queda en un PHP con fallos conocidos: ver [PHP: versión y parches](#php-versión-y-parches) |
| nginx con `real_ip`, confiando **solo** en la IP exacta del proxy y en Cloudflare | La IP registrada es la del cliente y no se puede falsificar escribiendo un `X-Forwarded-For` |
| `TRUSTED_PROXIES` en `.env` (bajo la marca `# pro8-sec`) | La app usa los mismos saltos de confianza que nginx |
| Log `pro8sec` de nginx en `/var/log/pro8/<prefijo>/nginx/`, fuera del proyecto | Una webshell (que escribe como www-data) no lo puede tocar |
| Workers de supervisor y scheduler como `www-data`, `vendor` sin 777 | Ningún proceso root carga código que www-data pueda cambiar |
| Si ya está instalado: `security-install.sh --refresh` | Mantiene al día las copias y las unidades del host |

:::warning Recrear nginx, después de guardar sus logs
Para montar `/var/log/pro8/<prefijo>/nginx` hay que recrear el contenedor nginx una vez, y recrearlo borra sus
`docker logs`, que pueden ser evidencia. La actualización **no** lo hace por su cuenta: imprime los pasos. Guarda
antes los logs (paso 1 del runbook de incidente) o pon `SECURITY_LOGGING_RECREATE_NGINX=true` en `.env`, que los
guarda en `/var/log/pro8/<prefijo>/evidence` antes de recrear.
:::

## PHP: versión y parches

Los contenedores `fpm`, `scheduling` y `supervisor` usan una imagen que se construye con el Dockerfile
del proyecto, `scripts/stack/php/Dockerfile`. La versión de PHP es una línea de ese archivo
(`ARG PHP_VERSION`). Cuando sale un parche, se cambia esa línea en el repo, y la siguiente
actualización lo lleva a cada servidor.

Hasta octubre de 2026 se usaban imágenes de un tercero (`rash07/php-fpm:8.2` y compañía). Tenían
PHP 8.2.5 y no se actualizaban desde 2023, así que quedaron expuestas a **php2shell**
(CVE-2026-109618 y CVE-2026-109619, corregidas en la 8.2.35): una sola petición sin autenticar
ejecutaba código en el servidor.

**Qué hace la actualización** (`ensure_php_runtime`, en el paso «Reiniciando contenedores PHP y
nginx»):

1. Si los contenedores ya corren la imagen del Dockerfile actual, no hace nada.
2. Si no, la **construye**. La primera vez tarda unos minutos y necesita unos 3 GB libres.
3. La **prueba** antes de usarla:
   - la versión de PHP;
   - que no pierda ningún módulo de los que hay hoy;
   - que `upload_progress` esté apagado;
   - que lea un certificado .pfx antiguo;
   - la configuración de php-fpm;
   - que `artisan` arranque.
4. Guarda una **foto** de cada contenedor en `/var/log/pro8-evidencia`: archivos agregados, `/tmp`,
   procesos y logs. Recrear un contenedor borra todo eso, y puede ser evidencia.
5. Cambia la imagen en el `docker-compose.yml`, con un respaldo
   `docker-compose.yml.backup-before-php-<versión>-<fecha>`.
6. Recrea los tres contenedores. Si fpm no arranca, vuelve al compose y a la imagen anteriores.

El corte de servicio es de unos segundos por contenedor.

**Comprobar** la versión que corre cada contenedor y que el sitio no la anuncie:

```bash
docker exec fpm_<prefijo> php -v | head -1
```

```bash
curl -sI https://<dominio>/login | grep -i x-powered-by || echo "sin X-Powered-By"
```

**Si la actualización termina en rojo** con «PHP sigue VULNERABLE», el código nuevo quedó
desplegado pero PHP no se cambió. El motivo está en la línea `-> PHP` de la salida. Los casos
habituales:
- **falta espacio:** libera con `docker image prune` y `docker builder prune` y vuelve a actualizar;
- **no se pudo descargar la base:** sin salida a Docker Hub, GitHub o getcomposer.org;
- **la imagen no pasó una prueba:** la salida dice cuál.

Para no aplicarlo en un servidor concreto, pon `PHP_RUNTIME_ENSURE=false` en su `.env`. Mientras PHP
siga por debajo de la versión del Dockerfile, la actualización seguirá terminando en rojo.

**Volver atrás** (las imágenes anteriores no se borran): copia el respaldo sobre el compose y
recrea los tres.

```bash
cp docker-compose.yml.backup-before-php-<versión>-<fecha> docker-compose.yml
```

```bash
docker compose up -d --no-deps --no-build fpm_1 scheduling_1 supervisor_1 && docker compose restart nginx_1
```

**Mitigar mientras tanto** en un servidor que todavía no se puede actualizar: copia un `.ini` dentro
de cada `fpm_*` y recarga php-fpm sin recrearlo. Así no se pierde evidencia y no se toca el repo.
Corta durante un segundo las peticiones en curso, y se pierde si el contenedor se recrea:

```bash
printf 'session.upload_progress.enabled = 0\nexpose_php = Off\n' > /root/zz-php2shell.ini
```

```bash
for c in $(docker ps --format '{{.Names}}' | grep '^fpm_'); do docker cp /root/zz-php2shell.ini "$c":/usr/local/etc/php/conf.d/zz-php2shell.ini && docker exec "$c" sh -c 'php-fpm -t 2>&1' | grep -q 'test is successful' && docker kill -s USR2 "$c"; done
```

Desde octubre de 2026, el pool de php-fpm del proyecto (`scripts/stack/php-fpm/zz-pool.conf`)
también apaga `upload_progress` y la cabecera `X-Powered-By`. Eso llega con cualquier
actualización, aunque la imagen nueva no se haya podido construir.

:::warning PHP 8.2 se queda sin parches el 31-12-2026
Después de esa fecha hay que pasar a la 8.3 o posterior. No es solo subir el `ARG`: Laravel 9
soporta PHP hasta la 8.2, y el cambio se prueba antes en local.
:::

## Lo que se instala a mano: `security-install.sh`

Toca servicios del sistema, así que lo decide quien administra el servidor: una actualización no lo instala
por su cuenta. Se corre como root desde la carpeta del proyecto. En WSL o sin systemd se salta con un aviso.

```bash
sudo bash scripts/security-install.sh --dry-run    # qué haría, sin tocar nada
sudo bash scripts/security-install.sh              # instalar
sudo bash scripts/security-install.sh --status     # cómo quedó
```

| Qué instala | Detalle |
|---|---|
| journald persistente | `/etc/systemd/journald.conf.d/50-pro8.conf`: `Storage=persistent`, 2 GB, 180 días. Solo las claves que el administrador no haya puesto |
| sshd `LogLevel VERBOSE` | `/etc/ssh/sshd_config.d/50-pro8-logging.conf`, validado con `sshd -t` (si falla, se deshace). Deja la huella de la clave con la que se entró |
| Hora | Si el reloj no está sincronizado y no hay chrony ni ntpd, `timedatectl set-ntp true`. **No** toca `LocalRTC` |
| `pro8-security-watch` (cada 5 min) | Avisa de un `.php` nuevo en `storage/` o `public/`, de código cambiado después de la última actualización y de cada login SSH aceptado |
| `pro8-seclog-collect` (cada 5 min) | Junta el registro de seguridad de la app, el log `pro8sec` de nginx y el journal de ssh, sudo y el ejecutor en trozos que ya no cambian, en `/var/log/pro8-sec/outbox/` |

- **Dónde corren:** desde copias de root en `/usr/local/lib/nt-suite/`, nunca desde el proyecto.
- **Cómo leen `storage/`:** con los permisos de su dueño, sin seguir enlaces.

**Avisos del vigilante.** Se configuran aparte de los de la app, para que quien tome la app no pueda
silenciarlos:

```bash
sudo nano /etc/nt-suite/security.env          # TELEGRAM_TOKEN y TELEGRAM_CHAT_ID (root 0600)
sudo bash scripts/security-install.sh --test-alert
```

## La máquina recolectora

Es otra máquina Linux con systemd: el servidor de la plataforma, un VPS barato o cualquier equipo que esté
siempre encendido. **Ella va a buscar** los trozos cada 5 minutos por SSH. El servidor no tiene ninguna
credencial hacia ella, así que quien lo tome no puede borrar lo ya recogido.

**1. En la recolectora** (como root, con una copia del repo o de `scripts/seclog-pull*.sh`):

```bash
sudo apt-get install -y rsync openssh-client
sudo bash scripts/seclog-pull-install.sh --host <IP del servidor> --name <alias>
```

Crea el usuario sin privilegios `pro8-seclog` y su clave, y el timer `pro8-seclog-pull@<alias>`. Al terminar
imprime la clave pública y el comando para el servidor.

**2. En el servidor**, autoriza esa clave **solo para leer** el outbox:

```bash
sudo apt-get install -y rsync
sudo bash scripts/security-install.sh --pull-key '<clave impresa>' --pull-from <IP pública de la recolectora>
```

Crea el usuario `seclog-pull`, con `authorized_keys` en `restrict,command="rrsync -ro /var/log/pro8-sec/outbox/"`.
Con esa clave solo se puede leer: borrar, subir o escribir se rechaza. Si sshd usa `AllowUsers`, agrega
`seclog-pull`.

**3. Comprueba:**

```bash
# en la recolectora
sudo systemctl start pro8-seclog-pull@<alias>.service
journalctl -u pro8-seclog-pull@<alias> -n 20
sudo bash scripts/seclog-pull-install.sh --status
```

La copia queda en `/srv/pro8-seclog/<alias>/`:
- `chunks/`: los trozos, en solo lectura;
- `LEDGER`: el sha256 de cada trozo y su encadenado;
- `EVENTS.txt`: los avisos.

Se guarda **365 días**.

**La recolectora avisa por Telegram** (`/etc/nt-suite/seclog-pull.env`) si:
- la recogida falla;
- falta un trozo, porque se borró antes de recogerlo;
- el sha256 o la cadena no cuadran, porque alguien reescribió algo ya recogido;
- un servidor no trae nada nuevo en 30 minutos, porque alguien paró el envío;
- la secuencia vuelve a empezar, por una reinstalación o un borrado del estado.

### Comprobar que borrar desde el servidor no alcanza la copia

Con la clave de la recolectora, todo esto se rechaza:

```bash
sudo -u pro8-seclog ssh -i /var/lib/pro8-seclog/.ssh/id_ed25519 seclog-pull@<servidor> 'rm -rf /var/log/pro8-sec/outbox/*'
# rrsync error: SSH_ORIGINAL_COMMAND does not run rsync
```

Borra o cambia en el servidor un trozo ya recogido. La copia no cambia, porque la recogida nunca
sobrescribe ni borra. Una línea del `MANIFEST` reescrita da el aviso «líneas ya recogidas reescritas».

### Verificar la base contra la copia

```bash
docker cp /srv/pro8-seclog/<alias> fpm_<prefijo>:/tmp/copia      # o llévala por otra vía
docker exec -u www-data fpm_<prefijo> php artisan security:verify --against /tmp/copia
```

Detecta filas de `security_events` modificadas, borradas o metidas a mano después de recogidas. Sin
`--against` el comando dice «SIN ANCLA»: comparar el servidor consigo mismo no prueba nada.

Si el servidor se reinstala, en la recolectora:

```bash
sudo -u pro8-seclog bash /usr/local/lib/nt-suite/seclog-pull.sh --name <alias> --reanchor
```

El `LEDGER` anterior se conserva.

## Avisos de la app

Los avisos de la app (logins sospechosos, cambios de empresa o logo, subidas peligrosas, nuevos admins) son
otros, distintos de los del vigilante. Se encienden en el `.env` del proyecto con:
- `SECURITY_ALERT_TELEGRAM_TOKEN`
- `SECURITY_ALERT_TELEGRAM_CHAT_ID`
- `SECURITY_ALERT_EMAIL`

Ver [Servicios operativos → Registro de seguridad](./servicios-operativos.md#registro-de-seguridad).

## Lo que conviene hacer a mano

Son cambios que pueden dejarte fuera, así que no los automatiza nada:

- **La base no se publica a internet.** En el compose, `"127.0.0.1:${MYSQL_PORT_HOST}:3306"`, y se entra por
  túnel SSH ([Ingreso a la base de datos](../devops/ingreso-a-la-db.md)). `ufw` no la protege: Docker se lo salta.
- **SSH sin contraseña y sin root**, cuando ya entres con clave. Copia tu clave
  (`ssh-copy-id`) y comprueba que entras con ella. Después pon `PasswordAuthentication no` y
  `PermitRootLogin prohibit-password`, valida con `sshd -t` y recarga.
- **fail2ban** con la jaula `sshd`. Ojo con una NAT de oficina compartida: puede banear a todos.
