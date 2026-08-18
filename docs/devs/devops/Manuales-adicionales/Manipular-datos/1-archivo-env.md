# DOCUMENTACIÓN .ENV

## PRO 3 | PRO 4 | PRO 5

### Factúralo Perú 2020

## PARÁMETROS DEL ARCHIVO .ENV

Descripción de los parámetros utilizados por el sistema

| PARÁMETRO | DESCRIPCIÓN | DEFAULT |
|-----------|-------------|---------|
| APP_DEBUG | usado para mostrar detalles de error en desarrollo. Dejar en false para proyectos en producción | false |
| APP_URL_BASE | dominio de la aplicación (link sin los prefijos http y www) | |
| DB_CONNECTION | conexión a la base de datos. Para conexiones a un servidor externo debe modificar el DB_HOST y DB_PORT en caso de que use un puerto distinto de 3306 | system |
| DB_HOST | | 127.0.0.1 |
| DB_PORT | | 3306 |
| DB_DATABASE | | |
| DB_USERNAME | | |
| DB_PASSWORD | | |
| MAIL_DRIVER | conexión al servidor de correos, por defecto está preparado para conectarse con google. Recuerde habilitar el acceso de apps menos seguras. Para conexiones a un servidor distinto, debe solicitar o ubicar el resto de parámetros | smtp |
| MAIL_HOST | | smtp.gmail.com |
| MAIL_PORT | | 465 |
| MAIL_USERNAME | | |
| MAIL_PASSWORD | | |
| MAIL_ENCRYPTION | | ssl |
| LIMIT_UUID_LENGTH_32 | | |
| TENANCY_DATABASE_AUTO_DELETE | al eliminar un cliente se eliminarán tanto el usuario como la base de datos que le enlazan | true |
| TENANCY_DATABASE_AUTO_DELETE_USER | | |
| ITEMS_PER_PAGE | cantidad de campos por paginación de tablas | 20 |
| ITEMS_PER_PAGE_SIMPLE_D_TABLE | cantidad de campos por paginación de tablas | 5 |
| PASSWORD_CHANGE | permitir cambiar la clave del administrador | true |
| PREFIX_DATABASE | prefijo de las bases de datos de los clientes | |
| SIGNATURE_NOTE_OSE | valor agregado a los XML | FACTURALO |
| SIGNATURE_URI_OSE | valor agregado a los XML | |
| FORCE_HTTPS | si es una instalación con SSL este valor cambia a true | false |
| DOCUMENT_TYPE_03_FILTER | filtrar documentos tipo DNI en documentos tipo factura | false |
| RECREATE_DOCUMENT | recrear documentos | false |
| IMPORT_DOCUMENTS | permite importar documentos desde la vista de listado de documentos. Se debe seguir un formato específico. Por ahora permite 2 items por documento | false |
| PDF_TEMPLATE | carpeta contenedora de las plantillas para generar el formato de los archivos pdf. La ruta de las plantillas es app/CoreFacturalo/Templates/pdf | default |
| PDF_TEMPLATE_FOOTER | añadir pie de pagina al formato de los pdf | true |
| PDF_NAME_REGULAR | los pdf contienen dos fuentes, puede añadir el nombre de alguna fuente añadida a la carpeta de plantillas. La ruta de la carpeta de fuentes para los pdf es app/CoreFacturalo/Templates/pdf/[TEMPLATE]/font | false |
| PDF_NAME_BOLD | | |
| ENABLED_TEMPLATE_TICKET_80 | habilitar un tamaño de ticket de impresión para 80mm | false |
| ENABLED_DISCOUNT_GLOBAL | | false |
| CHANGE_TO_REGISTERED_STATUS | | false |
| API_SERVICE_URL | url de la API para consultar documentos a seniat y reniec, RUC y DNI respectivamente | https://apiperu.dev |
| API_SERVICE_TOKEN | token asignada al usuario previamente registrado en apiperu | 3cf2365976ecb83ca2fd422ddc76fdc39804480a041f3edc43619ced59bd6938 |
| SUNAT_ALTERNATE_SERVER | url alternativa de sunat para recibir documentos | true |
| ADMIN_DELETE_CLIENT | permiso para eliminar clientes desde el administrador | true |
| NUMBER_ITEMS | cantidad de productos a mostrar al inicio | 20 |
| NUMBER_SEARCH_ITEMS | cantidad de productos a mostrar al buscar | 250 |

## Actualización

Luego de editar parámetros del archivo .env debe ejecutarse el comando:

```bash
php artisan config:cache
```

Este debe ejecutarse en la raíz del proyecto, que puede estar instalado en una de las siguientes rutas dependiendo del modo de instalación:

- `/var/www/html/[facturador]`
- `/home/[usuario]/[facturador]`
- `/root/[facturador]`

Si la instalación es realizada con docker debe acceder al contenedor fpm, los pasos puede verlos en el siguiente manual:

[Manual de instalación con Docker](https://docs.google.com/document/d/11PI1a9yjCPfH9CCuWmJSrdj1V8IEUffqurqvdkw29co/edit?usp=sharing)
