# Facturador — Entorno local de desarrollo (Windows + WSL2 Ubuntu 24.04)

Guía **de cero a andando** para un equipo de desarrollo con Windows 10/11: preparar
WSL2, instalar Ubuntu 24.04, verificar las dependencias de desarrollo y ejecutar el
script de instalación inicial del proyecto (`scripts/local-setup.sh`).

> **Esto no es producción.** Sin proxy reverso, sin SSL, sin dominio: la app queda en
> `http://localhost:8080` y MySQL en `localhost:3308`.
> Para servidores ver [Linux (VPS / dedicado)](../linux/), [On-premise](../onpremise/)
> o [Windows Server](../windows-server/).

---

## Índice

1. [Requisitos de la máquina](#1-requisitos-de-la-máquina)
2. [Fase 0 — Preparar WSL2 en Windows](#2-fase-0--preparar-wsl2-en-windows)
3. [Fase 1 — Dependencias dentro de Ubuntu](#3-fase-1--dependencias-dentro-de-ubuntu)
4. [Fase 2 — Instalación del proyecto](#4-fase-2--instalación-del-proyecto)
5. [Qué hace local-setup.sh](#5-qué-hace-local-setupsh)
6. [Verificación post-instalación](#6-verificación-post-instalación)
7. [Editar código (VS Code / Cursor)](#7-editar-código-vs-code--cursor)
8. [Uso diario](#8-uso-diario)
9. [Troubleshooting](#9-troubleshooting)

---

## 1. Requisitos de la máquina

| Requisito | Mínimo | Recomendado |
|-----------|--------|-------------|
| **OS** | Windows 10 22H2 / Windows 11 | Windows 11 |
| **Virtualización** | VT-x / AMD-V (SVM) habilitada en BIOS | — |
| **RAM** | 8 GB | 16 GB |
| **Disco** | SSD 30 GB libres | SSD 60 GB libres |
| **Puertos libres** | `8080` (app), `3308` (MySQL), `6001` (Soketi) | — |

Si la virtualización está deshabilitada, WSL2 no arranca: reiniciar → BIOS (DEL/F2/F10)
→ *Intel VT-x* / *AMD-V* / *SVM Mode* → **Enabled**.

> **El código vive en ext4, dentro de WSL** (`~/proyectos/pro-8`), **nunca** en `C:\`
> ni `/mnt/c/...`. PHP lee miles de archivos por request y sobre NTFS vía 9P el TTFB
> pasa de menos de 1 s a 4-8 s.

---

## 2. Fase 0 — Preparar WSL2 en Windows

Todo este bloque va en **PowerShell como Administrador**.

### 2.1 Actualizar WSL y fijar la versión 2

```powershell
wsl --update
wsl --set-default-version 2
```

Si `wsl` todavía no existe (Windows sin la característica instalada):

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

Reiniciar Windows y volver a `wsl --update`.

### 2.2 Instalar Ubuntu 24.04

```powershell
wsl --install -d Ubuntu-24.04
```

La primera vez que la distro arranca pide:

- **`Enter new UNIX username`** → usuario de Linux (ej. `pro8admin`, o el que prefieras).
- **`New password`** / **`Retype new password`** → contraseña de **sudo dentro de Ubuntu**.
  No es la contraseña de Windows y **no se ve mientras se escribe**. Anótala: sin ella
  no se puede instalar Docker ni arrancar servicios.

Si la ventana se cerró antes de completar ese diálogo, abrir *Ubuntu 24.04* desde el
menú Inicio o ejecutar `wsl -d Ubuntu-24.04`.

### 2.3 Verificar

```powershell
wsl -l -v
```

Debe mostrar `Ubuntu-24.04` y **VERSION 2**. Si sale `VERSION 1`:

```powershell
wsl --set-version Ubuntu-24.04 2
```

Dejarla como distro por defecto (opcional, evita pasar `-d` siempre):

```powershell
wsl --set-default Ubuntu-24.04
```

---

## 3. Fase 1 — Dependencias dentro de Ubuntu

Entrar a la distro (`wsl -d Ubuntu-24.04`) y trabajar **siempre desde `$HOME`**.

### 3.1 Base del sistema

```bash
sudo apt-get update
sudo apt-get install -y git curl unzip ca-certificates
```

### 3.2 Docker

Dos opciones válidas; elegir **una**:

| Opción | Cómo | Notas |
|--------|------|-------|
| **Docker Engine nativo en WSL** (recomendado) | `curl -fsSL https://get.docker.com \| sudo sh` y después `sudo usermod -aG docker $USER` | Sin dependencias de Windows. Arranca con `sudo service docker start`. |
| **Docker Desktop** | Instalar en Windows y activar *Settings → Resources → WSL Integration → Ubuntu-24.04* | Si el CLI falla con `protocol not available`, ejecutar `docker context use default`. |

Tras `usermod -aG docker $USER` hay que **cerrar y volver a abrir la sesión de WSL**
(o ejecutar `newgrp docker`) para que el grupo aplique.

> **No mezclar las dos.** Docker Desktop y Docker Engine nativo compiten por el mismo
> socket; si conviven, desinstalar Docker Desktop o desactivar su integración con WSL.

### 3.3 Bun

Bun es el runtime/bundler JS del proyecto (compila los assets con Vite). **No hace falta
instalarlo a mano**: `scripts/local-setup.sh` y `scripts/local-update.sh` cargan
`scripts/ensure-bun.sh`, que lo instala si falta y persiste el `PATH` en `~/.bashrc` y
`~/.profile`. Para adelantarlo:

```bash
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc
```

### 3.4 Lo que **no** se instala en el host

PHP, Composer, Node/npm y MySQL **viven dentro de los contenedores**. Instalarlos en
Ubuntu no aporta nada y suele confundir: `php artisan` desde el host falla por permisos
de `storage/logs`. Siempre vía contenedor (ver [Uso diario](#8-uso-diario)).

### 3.5 Checklist de verificación

```bash
git --version           # 2.x
docker --version        # 27.x o superior
docker info             # sin "Cannot connect to the Docker daemon"
docker compose version  # v2.x (plugin, no docker-compose v1)
bun --version           # 1.x (o se instalará solo durante el setup)
free -h                 # RAM disponible para la VM de WSL
pwd                     # debe empezar en /home/... nunca en /mnt/c
```

Si `docker info` falla: `sudo service docker start` (Engine nativo) o revisar la
integración WSL de Docker Desktop.

---

## 4. Fase 2 — Instalación del proyecto

### Opción A — Scripts de instalación (automático)

Es el mismo par de scripts de Windows Server y sirve igual en un equipo de desarrollo.
La Fase 1 automatiza todo el capítulo anterior (virtualización, WSL2, Ubuntu 24.04,
usuario + contraseña, Docker Engine, firewall) y deja las credenciales en
`data-config.txt`.

```powershell
# PowerShell como Administrador
Invoke-WebRequest -Uri "https://manual-facturador.nube-tec.com/install-scripts/windows-server/01-setup-wsl.ps1" -OutFile "01-setup-wsl.ps1"
powershell -ExecutionPolicy Bypass -File 01-setup-wsl.ps1
```

```bash
# Dentro de WSL
wsl -d Ubuntu-24.04
curl -O https://manual-facturador.nube-tec.com/install-scripts/windows-server/02-install-dev.sh
chmod +x 02-install-dev.sh
./02-install-dev.sh        # SIN sudo
```

`02-install-dev.sh` verifica Docker, instala Bun, pregunta la rama (default `gians96`),
clona el repo en `~/proyectos/pro-8`, ejecuta `scripts/local-setup.sh`, compila los
assets, corrige permisos de `storage/` y guarda las credenciales en
`~/proyectos/pro-8-dev.txt`.

Detalle completo en [Windows Server (WSL2)](../windows-server/).

### Opción B — Manual (si ya tienes el repo o quieres controlar cada paso)

```bash
mkdir -p ~/proyectos
git clone -b gians96 https://gitlab.com/gians96/pro-8.git ~/proyectos/pro-8
cd ~/proyectos/pro-8
bash scripts/local-setup.sh        # SIN sudo; pide sudo solo para el autoarranque
```

> **Equivalente en Linux nativo** (sin Windows): el instalador `install-local.sh` de
> [Linux (VPS / dedicado)](../linux/) hace lo mismo y termina en este mismo
> `scripts/local-setup.sh`.

---

## 5. Qué hace local-setup.sh

Es el instalador inicial del entorno local. Es **idempotente**: se puede volver a
ejecutar sobre una instalación existente.

1. Carga `scripts/ensure-bun.sh` (instala Bun si falta).
2. Verifica que el directorio sea un checkout completo (`composer.json` + `artisan`) y
   que **Docker pueda montarlo** (monta una imagen de prueba contra el proyecto).
3. Genera `docker-compose.local.yml`, `docker/nginx/default`, `supervisor.conf` y el
   `.env` (desde `.env.example` si no existe), forzando `APP_URL_BASE=localhost` y
   `APP_URL=http://localhost:8080`.
4. Levanta **7 contenedores** y espera a MariaDB y Redis.
5. `composer install` + `composer dump-autoload --classmap-authoritative` dentro de FPM.
6. `migrate --seed`, `tenancy:key:update` y `tenancy:migrate`.
7. Corrige permisos de `storage/` y `bootstrap/cache` (owner `www-data`).
8. Arranca Supervisor y verifica que haya workers `RUNNING` y el scheduler activo.
9. `bun install --ignore-scripts` + `bun run build` (assets de Vite).
10. En WSL instala el alias **`pro8up`** en `~/.bashrc` y el servicio
    **`pro8-autostart.service`**, que recrea el stack tras reiniciar Windows.

### Contenedores

| Contenedor | Función |
|------------|---------|
| `nginx_pro8_local` | Entrada HTTP (puerto 8080) |
| `fpm_pro8_local` | PHP-FPM con Laravel en `/var/www/html` |
| `mariadb_pro8_local` | Base de datos (puerto 3308) |
| `redis_pro8_local` | Caché y colas |
| `soketi_pro8_local` | WebSocket / Broadcasting (puerto 6001) |
| `scheduling_pro8_local` | Scheduler de Laravel (cron) |
| `supervisor_pro8_local` | Colas y workers |

### Accesos que quedan

| Recurso | Valor |
|---------|-------|
| Panel administrativo | `http://localhost:8080/login` |
| Usuario admin (seed) | `admin@gmail.com` / `123456` |
| Tenants | `http://TENANT.localhost:8080` (ej. `demo.localhost:8080`) |
| MySQL | `localhost:3308` — usuario `root`, contraseña `secret` |
| Redis | `redis_pro8_local:6379`, sin password |

> El seed solo crea el usuario administrador del panel y el plan *Ilimitado*. Los
> tenants (empresas) se crean desde el panel administrativo; su subdominio
> `TENANT.localhost` resuelve solo en los navegadores modernos. Si el tuyo no lo
> resuelve, agrega la entrada en `C:\Windows\System32\drivers\etc\hosts`.

---

## 6. Verificación post-instalación

```bash
# 1. Los 7 contenedores arriba
docker ps --format "table {{.Names}}\t{{.Status}}"

# 2. FPM ve el proyecto (bind mount OK)
docker exec fpm_pro8_local sh -c "ls /var/www/html/artisan"

# 3. La app responde (302 al login es correcto)
curl -I http://localhost:8080

# 4. Los workers corren
docker exec supervisor_pro8_local supervisorctl status

# 5. Assets compilados
ls public/build/manifest.json
```

Desde Windows, abrir `http://localhost:8080/login` y entrar con `admin@gmail.com` /
`123456`.

---

## 7. Editar código (VS Code / Cursor)

El proyecto está en ext4 dentro de WSL, así que hay que abrirlo **en modo remoto**, no
como unidad de red:

```bash
# desde WSL, dentro del proyecto
cd ~/proyectos/pro-8
code .
```

```powershell
# o desde Windows
code --remote wsl+Ubuntu-24.04 /home/TU_USUARIO/proyectos/pro-8
```

Requiere la extensión *WSL* de VS Code. Navegar por `\\wsl.localhost\Ubuntu-24.04\...`
desde el Explorador sirve para ver archivos, pero es lento para trabajar.

---

## 8. Uso diario

```bash
wsl -d Ubuntu-24.04
cd ~/proyectos/pro-8

sudo service docker start            # solo si Docker no arrancó solo

pro8up                               # recrea el stack (alias de scripts/pro8-restart.sh)

docker compose -f docker-compose.local.yml logs -f
docker compose -f docker-compose.local.yml down
docker compose -f docker-compose.local.yml up -d

docker exec -it fpm_pro8_local bash  # shell dentro de PHP
```

### Actualizar el entorno

```bash
cd ~/proyectos/pro-8
bash scripts/local-update.sh          # git pull + composer + bun + migraciones + cachés
bash scripts/local-update.sh mi-rama  # actualizar desde otra rama
```

### Empezar de cero

```bash
bash scripts/local-clean.sh   # borra contenedores, volúmenes y archivos generados
bash scripts/local-setup.sh
```

> `local-clean.sh` **borra la base de datos local**. Para solo apagar el stack usa
> `docker compose -f docker-compose.local.yml down`, **sin `-v`**.

### Comandos artisan

Siempre dentro del contenedor y con `CACHE_DRIVER=file` (evita el bug del driver
`redis_tenancy` en CLI):

```bash
docker exec fpm_pro8_local sh -c "CACHE_DRIVER=file php artisan migrate"
docker exec fpm_pro8_local sh -c "CACHE_DRIVER=file php artisan config:clear"
```

---

## 9. Troubleshooting

| Problema | Causa | Solución |
|----------|-------|----------|
| `wsl --install` falla o WSL no arranca | Virtualización deshabilitada | Habilitar VT-x / AMD-V / SVM en BIOS |
| Distro en `VERSION 1` | WSL1 por defecto | `wsl --set-version Ubuntu-24.04 2` |
| Olvidaste la contraseña de Ubuntu | — | En PowerShell: `wsl -d Ubuntu-24.04 -u root` y dentro `passwd TU_USUARIO` |
| `Cannot connect to the Docker daemon` | Servicio parado | `sudo service docker start` |
| `Failed to initialize: protocol not available` | El CLI heredó el contexto `desktop-linux` | `docker context use default` |
| `permission denied` en `/var/run/docker.sock` | Falta el grupo `docker` | `sudo usermod -aG docker $USER` y reabrir WSL |
| TTFB de varios segundos | El código está en `/mnt/c/...` | Mover el proyecto a `~/proyectos/` (ext4) |
| Composer no encuentra `composer.json` en `/var/www/html` | Docker levantó antes de que WSL montara `$HOME` | `pro8up` o `bash scripts/local-update.sh` (nunca `down -v`) |
| `Access denied for user 'tenancy_demo'` en `TENANT.localhost` | `APP_KEY` cambió y la password derivada por Hyn quedó desincronizada | `docker exec fpm_pro8_local sh -c "cd /var/www/html && CACHE_DRIVER=file php artisan tenancy:key:update"` y después `config:cache` |
| Puerto 8080 / 3308 ocupado | Otro servicio en Windows | Editar `APP_PORT` / `MYSQL_PORT_HOST` en `scripts/local-setup.sh`, luego `local-clean.sh` + `local-setup.sh` |
| `Unable to create directory` en tenancy | Permisos de `storage/` | `docker exec -u root fpm_pro8_local sh -c "mkdir -p /var/www/html/storage/app/tenancy/tenants && chown -R www-data:www-data /var/www/html/storage && chmod -R ug+rwX /var/www/html/storage"` |
| El stack no vuelve tras reiniciar Windows | `pro8-autostart` recién instalado | Una vez en PowerShell: `wsl --shutdown`. Diagnóstico: `tail -f /var/log/pro8-autostart.log` |
| Pantalla sin estilos | Assets no compilados | `bun install --ignore-scripts && bun run build` |
