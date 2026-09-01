# Manual de Actualización

## Requisitos previos

1. Tener acceso a su servidor, VPS, máquina virtual o local vía SSH. En las instalaciones para AWS o Google Cloud, se entrega el usuario, la IP del servidor y la clave SSH (archivo .ppk o .pem).
2. Tener instalada una versión de SSH en su máquina para conectarse de manera remota. Puede utilizar PuTTY, FileZilla o una consola terminal.
3. Tener los accesos y credenciales de GitLab y de los entornos creados con Docker, usuario MySQL, root, entre otros. Estos son entregados una vez realizada la instalación y pueden encontrarse en los archivos .env y docker-compose.yml.
4. Conocer el nombre del proyecto. En el ejemplo se ha usado `multifacturalo`. Debe tomar en cuenta el proyecto que se le ha compartido en GitLab.

## Pasos

1. Acceder a su instancia vía SSH.
2. Loguearse como superusuario ejecutando `sudo su`.
3. Ejecutar `docker ps` y verificar que estén al menos las siguientes líneas que equivalen a los contenedores de cada servicio iniciado por Docker.

En la lista deberá fijarse en los **NAMES** que contengan **fpm** y **mariadb** ya que en ellos deberá acceder.

- **multifacturalo_fpm2_1**: Equivale al nombre del proyecto donde una vez accedido se encontrará justo en la ruta donde se ha alojado el repositorio y podrá ejecutar comandos `artisan`, `git` o `composer`. Este nombre puede variar un poco, puede llamarse `multifacturalo_fpm1_1`.
- **multifacturalo_mariadb2_1**: Es el contenedor donde podrá acceder a MySQL y utilizar comandos para ello (desde aquí no se ejecutan comandos PHP, artisan, git, entre otros).

4. Una vez ubicado el contenedor a acceder, ejecute el siguiente comando:

  ```bash
  docker exec -ti multifacturalo_fpm1_1 bash
  ```

De esta manera se conectará al contenedor y observará un cambio en el inicio de la terminal.

## Caso FPM

Si ha accedido a **fpm**, entonces se debe encontrar en la ruta `/var/www/html/` donde podrá ejecutar comandos de la siguiente lista (cada comando se ejecuta para situaciones distintas, mayormente no se necesitan ejecutar más de dos comandos en una actualización):

- `git pull origin <rama>` (usar siempre; en Pro 8 la rama es `gians96`, no `master`)
- `git log -5`
- `php artisan migrate` (usar siempre)
- `php artisan tenancy:migrate --path=database/migrations/tenant --force` (usar siempre)
- `php artisan storage:link`
- `php artisan config:cache` (usar siempre)
- `php artisan config:clear`
- `php artisan cache:clear` (usar siempre)
- `composer update`
- `composer install`
- `composer dumpautoload`

Si ha utilizado `git pull origin master`, debe ingresar las credenciales de GitLab, su correo y contraseña de acceso (la contraseña no se muestra en pantalla al ingresarla).

Debe hacer uso de los comandos según sea el caso. Por ejemplo, posterior a un `git pull origin master` que le muestre cambios en migraciones, deberá ejecutar `php artisan migrate --force` y `php artisan tenancy:migrate --path=database/migrations/tenant --force`. De esta manera actualizará los campos de las bases de datos. Básicamente, cada comando cumple una función específica y no todos son usados cada vez que se realiza una actualización.

## MariaDB

Si ha accedido a **mariadb**, podrá hacer uso de comandos MySQL únicamente. Al acceder, deberá utilizar:

```bash
mysql -u root -p
```

Le solicitará la contraseña, la cual se encuentra en el archivo .env dentro del proyecto. También le fue entregada al momento de instalar el proyecto en su servidor. Si ha utilizado los canales de **Slack**, estos están mayormente en las chinchetas del canal.

## Comandos extras

Para detener y restaurar los contenedores (servicios), diríjase a la ruta de su proyecto y ejecute los siguientes comandos:

```bash
docker-compose down
docker-compose up -d
```

Otra manera de detener los contenedores puede ser individualmente con los siguientes comandos:

```bash
docker stop multifacturalo_fpm2_1
docker start multifacturalo_fpm2_1
docker restart multifacturalo_fpm2_1
```

Si desea respaldar o montar un respaldo de una base de datos, puede ejecutar los siguientes comandos:

### Backup

```bash
docker exec CONTAINER /usr/bin/mysqldump -u root --password=root DATABASE > backup.sql
```

### Restore

```bash
cat backup.sql | docker exec -i CONTAINER /usr/bin/mysql -u root --password=root DATABASE
```

Donde `CONTAINER` se refiere al nombre del contenedor `multifacturalo_fpm2_1`.

## Posibles errores

Luego de una actualización donde utilice el comando `composer install`, debe darle permisos a la carpeta en `vendor` del paquete de `mpdf`:

```bash
chmod -R 777 vendor/mpdf/mpdf/tmp
```
