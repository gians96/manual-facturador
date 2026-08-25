#!/bin/bash
#
# 02-install-dev.sh — Facturador Pro-8: Instalacion de desarrollo en WSL2
#
# Fase 2 del proceso de instalacion en Windows Server/Desktop.
# Ejecutar DENTRO de WSL despues de completar 01-setup-wsl.ps1
#
# Uso:
#   curl -O https://raw.githubusercontent.com/gians96/codeplant/master/facturador-pro/install/windows-server/02-install-dev.sh
#   chmod +x 02-install-dev.sh
#   ./02-install-dev.sh
#
# Clona el repo y ejecuta local-setup.sh.
# Sin proxy, sin SSL, puertos dev (8080, 3308).
#

set -e

# ─── Instalar siempre en el HOME del usuario real ───────────
# PROJECT_DEST cuelga de $HOME. Bajo sudo, $HOME es /root y el proyecto
# termina en /root/proyectos/pro-8: la extension WSL de VS Code se conecta
# como tu usuario normal y no puede abrir esa ruta, y el bind mount queda
# con owner root. En vez de abortar, se reejecuta como el usuario real.
if [ "$(id -u)" -eq 0 ]; then
    TARGET_USER="${SUDO_USER:-}"
    # Sesion root directa (ej: 'wsl -u root'): no hay SUDO_USER, asi que se
    # usa el primer usuario real de la distro (uid 1000, el default de WSL).
    if [ -z "$TARGET_USER" ] || [ "$TARGET_USER" = "root" ]; then
        TARGET_USER="$(getent passwd 1000 2>/dev/null | cut -d: -f1)"
    fi
    if [ -z "$TARGET_USER" ]; then
        echo "ERROR: corriendo como root y no hay usuario normal al que cambiar."
        echo "  Crea uno:  adduser tuusuario && usermod -aG sudo tuusuario"
        exit 1
    fi

    # Si el script se descargo con sudo vive en /root y TARGET_USER no puede
    # leerlo. Se copia a /tmp antes de bajar de privilegios.
    SELF_TMP="$(mktemp /tmp/02-install-dev.XXXXXX)"
    cat "$(cd "$(dirname "$0")" && pwd)/$(basename "$0")" > "$SELF_TMP"
    chmod 0755 "$SELF_TMP"

    echo "Detectado root: el proyecto debe vivir en el HOME de tu usuario."
    echo "Reejecutando como '$TARGET_USER' ..."
    echo ""
    if command -v sudo >/dev/null 2>&1; then
        exec sudo -u "$TARGET_USER" -H bash "$SELF_TMP" "$@"
    else
        exec su - "$TARGET_USER" -c "bash '$SELF_TMP' $*"
    fi
fi

REPO_URL="https://gitlab.com/gians96/pro-8.git"
BRANCH="gians96"
PROJECT_DEST="$HOME/proyectos/pro-8"

persist_bun_path() {
    for shell_file in "$HOME/.profile" "$HOME/.bashrc"; do
        if [ -f "$shell_file" ] && ! grep -q 'BUN_INSTALL=.*/.bun' "$shell_file"; then
            {
                echo ""
                echo "# Bun runtime/bundler"
                echo "export BUN_INSTALL=\"\$HOME/.bun\""
                echo "export PATH=\"\$BUN_INSTALL/bin:\$PATH\""
            } >> "$shell_file"
        fi
    done
}

ensure_bun() {
    export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
    case ":$PATH:" in
        *":$BUN_INSTALL/bin:"*) ;;
        *) export PATH="$BUN_INSTALL/bin:$PATH" ;;
    esac

    if command -v bun >/dev/null 2>&1; then
        echo "Bun OK: $(bun --version)"
        return 0
    fi

    if [ -x "$BUN_INSTALL/bin/bun" ]; then
        echo "Bun OK: $($BUN_INSTALL/bin/bun --version)"
        return 0
    fi

    echo "Instalando Bun..."
    if ! command -v unzip >/dev/null 2>&1; then
        sudo apt-get update -qq && sudo apt-get install -y unzip >/dev/null
    fi
    if ! command -v curl >/dev/null 2>&1; then
        sudo apt-get update -qq && sudo apt-get install -y curl ca-certificates >/dev/null
    fi
    curl -fsSL https://bun.sh/install | bash >/dev/null
    export PATH="$BUN_INSTALL/bin:$PATH"
    hash -r 2>/dev/null || true

    persist_bun_path

    echo "Bun instalado: $(bun --version)"
}

echo ""
echo "============================================"
echo "  FACTURADOR PRO-8 — Instalacion Desarrollo"
echo "  (WSL2)"
echo "============================================"
echo ""

# ─── Verificar Docker ─────────────────────────────────────────
# En WSL2 con Docker Desktop, el cliente puede heredar el contexto
# 'desktop-linux' (endpoint npipe de Windows), que rompe dentro de Linux
# con: "Failed to initialize: protocol not available" o panic del CLI.
# Fix: forzar contexto 'default' que apunta a unix:///var/run/docker.sock.
# Nota: se captura stderr SOLO si el comando falla. 'docker info' escribe
# warnings en stderr incluso cuando funciona, asi que no sirve basarse en
# "hay texto en stderr" para decidir si hubo error.
if ! DOCKER_ERR="$(docker info 2>&1 >/dev/null)"; then
    # Caso 1: el socket existe pero tu usuario no esta en el grupo 'docker'.
    # Este es el error que empuja a reintentar con sudo, y con sudo el
    # proyecto termina en /root. Se corrige anadiendo el grupo y
    # reejecutando con 'sg docker', que lo aplica en esta misma sesion sin
    # tener que cerrar WSL.
    if echo "$DOCKER_ERR" | grep -qi "permission denied"; then
        if ! id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then
            echo "Tu usuario no pertenece al grupo 'docker'. Anadiendo..."
            sudo usermod -aG docker "$USER"
        else
            echo "Usuario en grupo 'docker' pero la sesion actual no lo tiene activo."
        fi
        echo "Reejecutando con 'sg docker' ..."
        exec sg docker -c "bash '$0' $*"
    fi

    # Caso 2: contexto heredado de Docker Desktop.
    echo "Docker no responde. Probando arreglo de contexto WSL..."
    docker context use default >/dev/null 2>&1 || true
    sleep 1
    if ! docker info >/dev/null 2>&1; then
        echo "Docker no esta corriendo. Intentando iniciar servicio nativo..."
        sudo service docker start 2>/dev/null || true
        sleep 3
        if ! docker info >/dev/null 2>&1; then
            echo "ERROR: No se pudo conectar con Docker."
            echo "  - Si usas Docker Desktop: activa WSL Integration para Ubuntu-24.04"
            echo "    (Settings > Resources > WSL Integration) y reinicia Docker Desktop."
            echo "  - Si usas Docker Engine nativo: sudo service docker start"
            echo "  - Luego en WSL: docker context use default"
            echo "  - Si el error es 'permission denied' en docker.sock:"
            echo "      sudo usermod -aG docker \$USER   (y reabrir WSL)"
            echo "    NO uses sudo con este script: instalaria en /root."
            exit 1
        fi
    fi
fi
echo "Docker OK (contexto: $(docker context show 2>/dev/null || echo default))"

# ─── Instalar Bun (runtime/bundler JS) ────────────────────────
# Se usa para compilar assets con Vite y ejecutar socket-server.js.
persist_bun_path
ensure_bun

# ─── Rama (opcional) ──────────────────────────────────────────
read -p "Rama a clonar [$BRANCH]: " input_branch
if [ ! -z "$input_branch" ]; then
    BRANCH="$input_branch"
fi

# ─── Clonar o actualizar ─────────────────────────────────────
if [ -f "$PROJECT_DEST/artisan" ]; then
    echo "El proyecto ya existe en $PROJECT_DEST"
    read -p "Actualizar con git pull? [S/n]: " do_pull
    if [ "$do_pull" != "n" ] && [ "$do_pull" != "N" ]; then
        cd "$PROJECT_DEST"
        git pull origin $BRANCH
        echo "Proyecto actualizado"
    fi
else
    echo "Clonando $REPO_URL (rama: $BRANCH)..."
    mkdir -p "$(dirname $PROJECT_DEST)"
    git clone -b $BRANCH "$REPO_URL" "$PROJECT_DEST"
    echo "Proyecto clonado en $PROJECT_DEST"
fi

# ─── Preparar directorios de storage (ANTES de local-setup) ──
# local-setup.sh ejecuta 'composer install' dentro de FPM, y su hook
# post-autoload-dump lanza 'artisan package:discover'. config/view.php
# resuelve la ruta con realpath(storage_path('framework/views')): si esa
# carpeta no existe, realpath() devuelve false, el cache path queda vacio y
# artisan aborta con "Please provide a valid cache path.", tumbando toda la
# instalacion por el 'set -e' de arriba.
# git no versiona directorios vacios, asi que en un clon nuevo esa carpeta
# NO viene en el repo: hay que crearla en el host antes de que Docker monte
# el proyecto en /var/www/html.
echo ""
echo "Preparando directorios de storage..."
mkdir -p "$PROJECT_DEST/storage/framework/views" \
         "$PROJECT_DEST/storage/framework/cache/data" \
         "$PROJECT_DEST/storage/framework/sessions" \
         "$PROJECT_DEST/storage/framework/testing" \
         "$PROJECT_DEST/storage/framework/laravel-excel" \
         "$PROJECT_DEST/storage/app/public" \
         "$PROJECT_DEST/storage/app/tenancy/tenants" \
         "$PROJECT_DEST/storage/logs" \
         "$PROJECT_DEST/storage/debugbar" \
         "$PROJECT_DEST/bootstrap/cache"
# Si un intento previo alcanzo a cachear la config con la ruta invalida
# horneada dentro, Laravel lee ese archivo entero en vez de config/view.php
# y seguiria fallando aunque la carpeta ya exista. Se regenera solo despues.
rm -f "$PROJECT_DEST/bootstrap/cache/config.php"

# ─── Ejecutar local-setup.sh ─────────────────────────────────
echo ""
echo "Ejecutando local-setup.sh (levanta 7 containers)..."
echo ""
cd "$PROJECT_DEST"
bash scripts/local-setup.sh

# ─── Compilar assets con Bun (Vite) ──────────────────────────
# canvas (dependencia transitiva) necesita libs nativas para compilar.
# Para evitar fallos en entornos sin build-tools, se usa --ignore-scripts.
# Luego 'bun run build' genera public/build/* requerido por el layout.
echo ""
echo "Instalando dependencias JS con Bun (--ignore-scripts)..."
cd "$PROJECT_DEST"
bun install --ignore-scripts

echo "Compilando assets (vite build)..."
bun run build || echo "ADVERTENCIA: falló el build de assets; revisa errores arriba"

# ─── Corregir permisos de storage y bootstrap/cache ──────────
# El repo NO trae toda la estructura: git no versiona directorios vacios y
# storage/framework/views llega sin .gitignore, por eso se crea mas arriba
# antes de local-setup.sh. Aqui solo se corrige el owner.
# El problema es que al ejecutar comandos artisan dentro del contenedor como
# root, Laravel puede crear subdirectorios (ej: storage/framework/cache/data)
# con owner root y permisos 700, pero el worker php-fpm corre como www-data
# y no puede escribir ahi. Sintomas:
#   - "file_put_contents(.../storage/framework/views/XXX.php): Permission denied"
#   - "Unable to create a directory at /var/www/html/storage/app/tenancy/tenants"
# Fix: forzar ownership a www-data y modo 775 en todo storage y bootstrap/cache.
echo ""
echo "Corrigiendo permisos de storage y bootstrap/cache..."
if docker ps --format '{{.Names}}' | grep -q '^fpm_pro8_local$'; then
    docker exec fpm_pro8_local bash -c '
        chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache &&
        chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache &&
        find /var/www/html/storage/framework/views -type f -delete 2>/dev/null || true
    ' && echo "Permisos OK" || echo "ADVERTENCIA: no se pudo ajustar permisos"
else
    echo "ADVERTENCIA: contenedor fpm_pro8_local no esta corriendo, omito fix de permisos"
fi

# ─── Verificar alias/autostart instalados por local-setup.sh ──
# local-setup.sh deja listo el reinicio seguro de WSL: alias pro8up y
# pro8-autostart.service. No descargamos scripts extra desde este instalador.
BASHRC="${HOME}/.bashrc"
RESTART_SCRIPT="${PROJECT_DEST}/scripts/pro8-restart.sh"
if [ -f "$RESTART_SCRIPT" ]; then
    chmod +x "$RESTART_SCRIPT" 2>/dev/null || true
    if [ -f "$BASHRC" ] && ! grep -q "alias pro8up=" "$BASHRC"; then
        {
            echo ""
            echo "# pro-8: reinicio seguro del stack tras reboot (WSL2 + Docker Desktop)"
            echo "alias pro8up='bash ${RESTART_SCRIPT}'"
        } >> "$BASHRC"
        echo "Alias 'pro8up' instalado en ~/.bashrc"
    fi
fi

if [ ! -f /etc/systemd/system/pro8-autostart.service ]; then
    echo "ADVERTENCIA: auto-start no quedo instalado. Re-ejecuta: bash scripts/local-setup.sh"
else
    echo "✓ Arranque automatico ya configurado (pro8-autostart.service)"
fi

# ─── Generar data-config.txt fuera del proyecto ──────────────
DATA_CONFIG="$(dirname $PROJECT_DEST)/pro-8-dev.txt"
cat << EOF > $DATA_CONFIG
============================================
DATOS DE INSTALACION (DEV) - pro-8
Generado: $(date '+%Y-%m-%d %H:%M')
============================================
Ruta del proyecto: $PROJECT_DEST
Rama: $BRANCH
URL: http://localhost:8080
----------------------------------------------
Acceso remoto a MySQL
Puerto: 3308
Host: localhost
Usuario: root
Contrasena root: secret
----------------------------------------------
Redis
Host: pro8_local_redis
Puerto: 6379
Password: null
----------------------------------------------
Contenedor FPM: pro8_local_fpm
Contenedor MariaDB: pro8_local_mariadb
Contenedor Redis: pro8_local_redis
============================================

Para entrar al proyecto:
  wsl -d Ubuntu-24.04
  cd $PROJECT_DEST

Para levantar/reiniciar:
  cd $PROJECT_DEST
  docker compose -f docker-compose.local.yml up -d
EOF
echo "Credenciales guardadas en: $DATA_CONFIG"

# Append a data-config.txt de Fase 1 si existe
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PHASE1_CONFIG="$SCRIPT_DIR/data-config.txt"
if [ -f "$PHASE1_CONFIG" ]; then
    cat << EOF >> $PHASE1_CONFIG

# ============================================
# FASE 2 — Desarrollo
# Instalado: $(date '+%Y-%m-%d %H:%M')
# ============================================
Ruta: $PROJECT_DEST
Rama: $BRANCH
URL: http://localhost:8080
MySQL: localhost:3308 (root / secret)
Credenciales completas: $DATA_CONFIG
EOF
    echo "data-config.txt (Fase 1) actualizado"
fi

echo ""
echo "============================================"
echo "  INSTALACION DEV COMPLETADA"
echo "============================================"
echo ""
echo "  Proyecto: $PROJECT_DEST"
echo "  App:      http://localhost:8080"
echo "  MySQL:    localhost:3308 (root / secret)"
echo ""
echo "  Credenciales: $DATA_CONFIG"
echo ""
echo "  Para entrar al proyecto:"
echo "    wsl"
echo "    cd $PROJECT_DEST"
echo ""
echo "  Tras reiniciar Windows, el stack se recrea automaticamente con pro8-autostart."
echo "  Si systemd se activo por primera vez, ejecuta una vez en PowerShell: wsl --shutdown"
echo "  Diagnostico: tail -f /var/log/pro8-autostart.log"
echo ""
