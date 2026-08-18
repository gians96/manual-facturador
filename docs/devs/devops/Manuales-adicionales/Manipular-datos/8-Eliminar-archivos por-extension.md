# Eliminar Archivos por Extensión en Linux

## Requisitos previos

- Tener acceso a su servidor, VPS, máquina virtual o local vía SSH.
- Tener instalado una versión de SSH en su máquina para conectarse de manera remota (puede utilizar PuTTY, FileZilla o una consola terminal).

En las instalaciones que realizamos para AWS o Google Cloud, hacemos entrega del usuario, la IP del servidor y la clave SSH que puede ser un archivo .ppk o .pem.

## Ejemplo: Eliminar archivos PDF de todos los clientes

1. Acceder vía SSH.
2. Ubicar la ruta de su facturador:
    - Suele estar en `/root/facturadorpro3/`
    - También puede estar ubicado en `/home/usuario/facturadorpro3`
    - Recuerde que el nombre del facturador corresponde al nombre del repositorio, por ejemplo:
      - `facturadorpro3`
      - `multifacturalonew`
      - Entre otros
3. Ingresar a la carpeta del facturador:
    ```bash
    cd /root/facturadorpro3/
    ```
4. Ingresar a la carpeta donde se alojan los archivos de los clientes:
    ```bash
    cd storage/app/tenancy/tenants/
    ```
5. Ejecutar el comando para eliminar archivos PDF:
    ```bash
    find . -name "*.pdf" -type f -delete
    ```
    Este comando busca todos los archivos que terminen en `.pdf` y los eliminará del sistema.

6. Si desea eliminar archivos dentro de una carpeta específica, reemplace el primer `.` (punto) por la ruta. Por ejemplo, para eliminar todos los archivos XML de la carpeta `unsigned`:
    ```bash
    find ./tenancy_*/unsigned/ -name "*.xml" -type f -delete
    ```

7. Puede salir y cerrar la conexión con:
    ```bash
    exit
    ```

## Recomendaciones

- Puede cambiar la extensión `.pdf` por la que requiera eliminar.
- Asegúrese de tener un respaldo si llega a necesitar los archivos posteriormente.

---
