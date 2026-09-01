# FACTURADOR — Scripts de Instalación

## Estructura

```
facturador-pro/
├── install/
│   ├── linux/                    ← Servidor Linux (VPS/dedicado)
│   │   ├── install.sh            ← Instalador interactivo
│   │   └── updateSSL.sh          ← Renovar certificado SSL
│   └── windows-server/           ← Windows Server con WSL2
│       ├── 01-setup-wsl.ps1      ← Fase 1: WSL2 + Docker (PowerShell Admin)
│       ├── 02-install-prod.sh    ← Fase 2: Producción (proxy, SSL, multi-proyecto)
│       ├── 02-install-dev.sh     ← Fase 2: Desarrollo (sin proxy ni SSL)
│       └── README.md             ← Documentación detallada
├── README.MD                     ← Este archivo
├── TROUBLESHOOTING.md
└── troubleshooting/              ← Guías puntuales de errores recurrentes
```

> **Troubleshooting de producción:** los runbooks de errores recurrentes (tenant local en 500,
> reportes atascados, etc.) son internos y no se publican. Viven en el repo del facturador, en
> `docs/09-operacion/troubleshooting/`.

---

## Instalación en Linux (VPS / Servidor dedicado)

```sh
cd /var/
curl -O https://manual-facturador.nube-tec.com/install-scripts/linux/install.sh
chmod +x install.sh
sudo ./install.sh
```

El script pide dominio y número de servicio de forma interactiva.

Para realtime de restaurante, el instalador publica Soketi en el subdominio reservado `ws.<dominio>` usando el mismo contenedor Soketi y el mismo proxy. No crees tenants llamados `ws`; los tenants reales siguen usando sus subdominios normales.

Para agregar otro proyecto (multi-proyecto):

```sh
sudo ./install.sh
# Ingresar dominio y service number 2, 3, etc.
```

### Renovar SSL

```sh
cd /var/
curl -O https://manual-facturador.nube-tec.com/install-scripts/linux/updateSSL.sh
chmod +x updateSSL.sh
./updateSSL.sh mi-dominio.com
```

---

## Instalación en Windows Server (WSL2)

Ver la [guía completa de instalación en Windows Server](windows-server/).

Resumen rápido:

```powershell
# Fase 1 — PowerShell como Administrador
Invoke-WebRequest -Uri "https://manual-facturador.nube-tec.com/install-scripts/windows-server/01-setup-wsl.ps1" -OutFile "01-setup-wsl.ps1"
powershell -ExecutionPolicy Bypass -File 01-setup-wsl.ps1

# Fase 2 — Dentro de WSL
wsl
curl -O https://manual-facturador.nube-tec.com/install-scripts/windows-server/02-install-prod.sh
chmod +x 02-install-prod.sh
sudo ./02-install-prod.sh
```

---

## Entorno local de desarrollo (Windows + WSL2)

Para una **máquina de desarrollo** (no un servidor): preparar WSL2, instalar Ubuntu 24.04
con su usuario y contraseña, verificar las dependencias de desarrollo (git, Docker, Bun) y
correr el instalador inicial del proyecto.

Ver la [guía de entorno local de desarrollo](local-dev/).

Resumen rápido:

```bash
# Dentro de WSL (Ubuntu 24.04), con Docker ya funcionando
git clone -b gians96 https://gitlab.com/gians96/pro-8.git ~/proyectos/pro-8
cd ~/proyectos/pro-8
bash scripts/local-setup.sh
```

Resultado: `http://localhost:8080` (panel) y MySQL en `localhost:3308`.

---

## Actualización del proyecto

:::tip Lo recomendado es el script, no los comandos a mano
Usa `update.sh` (o `scripts/prod-update.sh` en el repo). Hace el **backup previo**, aplica el
`--path` de las migraciones de tenant y —lo más importante— **reinicia los contenedores**, que
es lo que hace que el código nuevo entre de verdad. Los comandos de abajo son para
diagnosticar o para casos en los que el script no aplique.
:::

:::danger Sin reiniciar, el código nuevo NO se aplica
Los contenedores PHP corren con `opcache.validate_timestamps=0`: cada proceso sirve **para
siempre** el bytecode que cargó al arrancar, aunque el archivo cambie en disco. Y hay **tres**
procesos PHP con su propia caché (`fpm`, `supervisor`, `scheduling`), no uno.

Un `git pull` seguido de `cache:clear` deja el sitio **exactamente igual que antes**. Hay que
reiniciar los tres, más `nginx` (que resuelve `fastcgi_pass` una sola vez al arrancar y puede
quedarse apuntando a la IP vieja de `fpm`). Ver el paso 5.
:::

1) Agregar llave ssh al gitlab, que se crea al momento de instalar el sistema en el sevidor, buscar en el archivo `[proyecto].txt`

2) Ingresamos al terminal del docker que ejecuta el fpm para el servicio web.

```sh
docker exec -it $(docker ps -qf "name=fpm1_1") bash
```

3) Traemos cambios del repositorio

```sh
git pull origin [rama]
```

4) Ejecutamos los siguientes comandos, para actualizar cambios en la aplicación

```sh
composer install
php artisan migrate --force
php artisan tenancy:migrate --path=database/migrations/tenant --force
composer dump-autoload -o
php artisan view:clear
php artisan route:clear
php artisan config:clear
php artisan cache:clear
php artisan config:cache
chmod -R 777 vendor/mpdf/mpdf
```

5) **Reiniciar los contenedores** (fuera del contenedor, en el host). Sin este paso el código
nuevo no se aplica:

```sh
docker restart fpm_<dominio> supervisor_<dominio> scheduling_<dominio>
docker restart nginx_<dominio>

# Y limpiar la caché OTRA VEZ, ya con los procesos nuevos: la limpieza anterior
# corrió mientras los viejos seguían atendiendo, y cualquier petición de esa
# ventana la repobló con el código anterior.
docker exec fpm_<dominio> sh -c "cd /var/www/html && CACHE_DRIVER=file php artisan cache:clear"
```

6) Comprobar que el código nuevo está activo (no basta con un 200):

```sh
curl -sk https://<dominio>/login | grep -c "<algo-que-cambio>"
```

## Migración de tenants - clientes (backup)
Primero realizamos el backup en el sistema, lo descargamos:
1) Creamos en el panel de admnistrador de usuarios (clientes), al momento de terminar todo el proceso de creacion del nuevo inquilino (Cliente), eliminamos y creamos otra vez en blanco la base de datos

```sh
drop DATABASE [BaseDatos];
CREATE DATABASE [BaseDatos];
```
2) Restauramos la base de datos que anteriormente le sacamos backup.

Si es local, en el ssh del servidor

```sh
mysql -u [user] -p [database_name] < [filename].sql
```

si es remoto

```sh
mysql -h [host] -u [user] -p [database_name] < [filename].sql
```

3) Aplicamos cambios al nuevo sistema, con las migraciones del inquilino:

```sh
docker exec [identificadordeldocker] composer install
docker exec [identificadordeldocker] php artisan migrate
docker exec [identificadordeldocker] php artisan tenancy:migrate --path=database/migrations/tenant --force --path=database/migrations/tenant --force
docker exec [identificadordeldocker] php artisan cache:clear
docker exec [identificadordeldocker] php artisan config:cache
docker exec [identificadordeldocker] chmod -R 777 vendor/mpdf/mpdf
```

4) Con acceso a SFTP, la carpeta `tenancy_cliente.zip`, lo descomprimimos y copiamos las carpetas a su respectiva ruta de archivos `[proyecto]/storage/app/tenancy/tenants/[inquilino]`


```sh
mv /[rutabackup]/tenancy/cdr [proyecto]/storage/app/tenancy/tenants/[inquilino]/cdr/
mv /[rutabackup]/tenancy/pdf [proyecto]/storage/app/tenancy/tenants/[inquilino]/pdf/
mv /[rutabackup]/tenancy/quotation [proyecto]/storage/app/tenancy/tenants/[inquilino]/quotation/
mv /[rutabackup]/tenancy/sale_note [proyecto]/storage/app/tenancy/tenants/[inquilino]/sale_note/
mv /[rutabackup]/tenancy/signed [proyecto]/storage/app/tenancy/tenants/[inquilino]/signed/
mv /[rutabackup]/tenancy/unsigned [proyecto]/storage/app/tenancy/tenants/[inquilino]/unsigned/
```
5) Luego tenemos que asignarles los siguientes permisos

```sh
sudo chown -R www-data:www-data [proyecto]/storage/app/tenancy/tenants/[inquilino]/cdr/
sudo chown -R www-data:www-data [proyecto]/storage/app/tenancy/tenants/[inquilino]/pdf/
sudo chown -R www-data:www-data [proyecto]/storage/app/tenancy/tenants/[inquilino]/quotation/
sudo chown -R www-data:www-data [proyecto]/storage/app/tenancy/tenants/[inquilino]/sale_note/
sudo chown -R www-data:www-data [proyecto]/storage/app/tenancy/tenants/[inquilino]/signed/
sudo chown -R www-data:www-data [proyecto]/storage/app/tenancy/tenants/[inquilino]/unsigned/
```
## Errores comunes:
1) Error de permiso
```
 Unable to retrieve the file_size for file at location: download_tray_xlsx/ventas_report_general_items_20251231140251-1.xlsx. {"userId":1,"exception":"[object] (League\Flysystem\UnableToRetrieveMetadata(code: 0): Unable to retrieve the file_size for file at location: download_tray_xlsx/ventas_report_general_items_20251231140251-1.xlsx. at /var/www/html/vendor/league/flysystem/src/UnableToRetrieveMetadata.php:49)
```
Comando para dar permiso necesario
```sh
# Dar el propietario correcto, no 777: `chmod 777` deja storage escribible por
# cualquier proceso del servidor, y no arregla la causa (el propietario).
chown -R www-data:www-data /var/nt-suite.pro/storage /var/nt-suite.pro/bootstrap/cache
chmod -R ug+rwX /var/nt-suite.pro/storage /var/nt-suite.pro/bootstrap/cache
```
