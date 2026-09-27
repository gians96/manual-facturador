# Migración de Servidor con Docker
---
- [Recomendado: migrar con el sistema de copias](#recomendado-migrar-con-el-sistema-de-copias)
- [Método manual anterior](#método-manual-anterior)
  - [Propósito](#propósito)
  - [Requisitos](#requisitos)
  - [Servidor A](#servidor-a)
  - [Servidor B](#servidor-b)
  - [Envío de Data](#envío-de-data)
  - [Despliegue](#despliegue)

## Recomendado: migrar con el sistema de copias

Desde 2026-09-27 se migra con las copias del panel (`/backup`). La misma herramienta que protege
el servidor hace el traslado, así que la migración también demuestra que las copias se restauran.
Se ensayó de punta a punta en un servidor aislado: los datos, los usuarios de base de datos de cada
empresa y los archivos llegaron idénticos.

:::warning Antes de nada: el `.env` de la copia
De la `APP_KEY` del `.env` salen las contraseñas de base de datos de cada empresa y lo cifrado en el
panel. El servidor nuevo se instala **con el `.env` de la copia** (`config/.env` dentro de cada copia)
**antes de iniciar MariaDB por primera vez**. Si la `APP_KEY` no coincide, el panel se niega a
restaurar y explica por qué.
:::

### 1. Preparar el servidor nuevo

1. Instala el stack con el instalador del manual, usando el `.env` de una copia reciente.
2. Revisa en ese `.env` lo que depende del servidor: `DB_HOST`, `REDIS_HOST`, `PUSHER_HOST`,
   `EVOLUTION_*` (los nombres de los contenedores llevan el prefijo de la instalación) y
   `APP_URL_BASE` si cambia el dominio.
3. Instala el ejecutor del host (`sudo bash scripts/host-runner-install.sh`). rclone lo instala la
   actualización. Comprueba en `/backup` que la lista de revisión marca el ejecutor y rclone en verde.

### 2. Ensayo, sin cortar nada

1. En el servidor viejo, pasa al nuevo la carpeta del trabajo con la copia de la noche anterior:
   ```bash
   rsync -a --info=progress2 /var/backups/<dominio>/<trabajo>/ root@IP-DEL-NUEVO:/var/backups/importar/<dominio>/
   ```
   Así, además, los archivos (XML y CDR, que casi no cambian) quedan ya en el nuevo: la noche del
   cambio solo viaja la diferencia.
2. En el nuevo: **Backup → Restaurar / importar → Una carpeta del servidor** →
   `/var/backups/importar/<dominio>` → **Revisar la copia** → **Todo** → escribe `RESTAURAR`.
3. Comprueba que entra a una empresa, que abre el PDF de un comprobante antiguo y que emite uno de prueba.
   El tiempo que tardó la restauración es el que tendrá el corte.

### 3. La noche del cambio

1. En el viejo, **mantenimiento antes de la copia final**, para que nadie emita algo que no llegue al
   nuevo:
   ```bash
   docker exec fpm_<prefijo> php artisan down
   ```
2. La copia final, **desde la terminal** (con el sistema en mantenimiento el panel responde 503):
   ```bash
   sudo bash /ruta/del/proyecto/scripts/backup-run.sh --profile <destino> --job-slug <trabajo>
   ```
3. Repite el `rsync` del ensayo: solo viaja lo que cambió.
4. En el nuevo, **Restaurar / importar** otra vez con la copia más reciente. Pone el sistema en
   mantenimiento mientras importa, guarda antes lo que sobrescribe en
   `storage/app/backups/pre-restore/` y recrea los usuarios de base de datos de cada empresa.
5. Cambia en Cloudflare la IP de origen del dominio a la del servidor nuevo. Con el proxy activo, el
   cambio es inmediato.
6. Levanta el resto de servicios (scheduler, supervisor, Redis, Soketi) y comprueba `/health`: los tres
   valores en `true`.

**Tiempo de corte estimado** para un servidor de unas 60 empresas (24 GB de datos, 3 GB de archivos):
unos **40 minutos**, entre 35 y 50, con los archivos ya sembrados en el ensayo. Lo que más pesa es
importar las bases, y depende del disco del servidor nuevo: el ensayo te da la cifra exacta.

:::tip Descargar una copia
En **Trabajos → Copias guardadas** se puede descargar un ZIP con las bases, con todo o con un solo
cliente. Sirve para guardarla fuera del servidor, pero para migrar es mejor el `rsync`: una descarga
grande por el navegador se corta pasada una hora.
:::

## Método manual anterior

El procedimiento de antes, a mano con `zip` y `scp`. Sigue valiendo si el servidor viejo no tiene el
sistema de copias.

### Propósito
Migrar todos los datos del facturador de un servidor A a un servidor B.

### Requisitos
- Acceso SSH a ambos servidores.
- Misma versión de sistemas operativos en ambos servidores.
- Si posee un archivo SSH como clave en formato .ppk, convertir a formato .pem.

### Servidor A
* Ingresar al servidor e instalar `zip`: 
  ```bash
  apt-get install zip unzip
  ```
* Crear una carpeta `scp`: 
  ```bash
  mkdir scp
  ```
* Copiar el contenido de las carpetas `proxy` y `certs`: 
  ```bash
  cp -r proxy/ scp/
  cp -r certs/ scp/
  ```
* Verificar el tamaño del directorio del facturador: 
  ```bash
  du -sh facturador/
  ```
  * Si el tamaño es inferior a 5GB, se recomienda usar:
    ```bash
    zip -r facturador.zip facturador/
    ```
  * Si es mayor, usar:
    ```bash
    tar -cvf facturador.tar facturador/
    ```
* Mover el archivo comprimido a `scp`: 
  ```bash
  mv facturador.zip scp/
  ```
* Ir a la carpeta de volúmenes de Docker: 
  ```bash
  cd /var/lib/docker/volumes/
  ```
* Verificar el tamaño del volumen de base de datos: 
  ```bash
  du -sh facturador1_mysqldata_1
  ```
  * Si el tamaño es inferior a 5GB, se recomienda usar:
    ```bash
    zip -r mysql.zip facturador1_mysqldata_1/
    ```
  * Si es mayor, usar:
    ```bash
    tar -cvf mysql.tar facturador1_mysqldata_1/
    ```
* Mover el archivo comprimido a `scp`: 
  ```bash
  mv mysql.zip /ruta/scp/
  ```

> **Advertencia:** Si la instalación es muy antigua (versión PRO3 que ha venido actualizando), verificar la versión de MySQL directamente en el contenedor de MariaDB:
> ```bash
> docker exec -ti CONTENEDOR_MYSQL mysql --version
> ```
> Dicha versión debe asignarse en el archivo `docker-compose.yml` dentro del facturador.

### Servidor B
* Ingresar al servidor e instalar `zip`: 
  ```bash
  apt-get install zip unzip
  ```
* Instalar las dependencias en el servidor:
  ```bash
  apt-get -y update
  apt-get -y install git-core
  apt-get -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  apt-get -y update
  apt-get -y install docker-ce
  systemctl start docker
  systemctl enable docker
  curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  apt-get -y install letsencrypt
  docker network create proxynet
  ```

### Envío de Data
#### Desde el Servidor A hacia el Servidor B
* Enviar la carpeta `scp` completa hacia el servidor B.
* Si el servidor B usa archivo de clave (.pem) para conectarse, debe cargarlo previamente:
  ```bash
  # Sintaxis
  # scp -r -i [clave] [carpeta_local] [USUARIO]@[IP]:[/ruta/destino]
  # Ejemplo
  scp -r -i clave.pem scp/ root@192.196.138.123:/root/
  ```
* Si el servidor B no usa archivo de clave:
  ```bash
  # Sintaxis
  # scp -r [carpeta_local] [USUARIO]@[IP]:[/ruta/destino]
  # Ejemplo
  scp -r scp/ root@192.196.138.123:/root/
  ```

### Despliegue
* Ingresar a la carpeta `scp` y descomprimir los archivos: 
  ```bash
  cd scp
  ```
* Si son archivos `.zip`, usar: 
  ```bash
  unzip facturador.zip
  unzip mysql.zip
  ```
* Si son archivos `.tar`, usar: 
  ```bash
  tar -xvf facturador.tar
  ```
* Mover las carpetas a la ruta destino (suele ser `/root` o `/home/usuario`): 
  ```bash
  mv proxy /ruta_destino/
  mv facturador /ruta_destino/
  mv certs /ruta_destino/
  ```
* Mover la carpeta de MySQL a la ruta de volúmenes de Docker: 
  ```bash
  mv facturador1_mysqldata_1/ /var/lib/docker/volumes/
  ```
* Ingresar a la carpeta del facturador y levantar los servicios: 
  ```bash
  cd /ruta_destino/facturador/
  docker-compose up -d
  ```
* Ingresar a la carpeta del proxy y levantar los servicios: 
  ```bash
  cd /ruta_destino/proxy/
  docker-compose up -d
  ```

Si todo está correcto, solo quedará cambiar la IP a la que apunta el dominio.