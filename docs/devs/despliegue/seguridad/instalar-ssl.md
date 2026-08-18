---
sidebar_position: 1
---

# Instalar - Actualizar el SSL

Si al instalar el Facturador elegiste la opción de no descargar el certificado SSL, o si el
certificado ya está próximo a vencer, con estos pasos podrás emitirlo o renovarlo en tu dominio.

:::info DURACIÓN REAL DEL CERTIFICADO
Los certificados gratuitos de **Let's Encrypt duran 90 días** (no 30). No esperes al último día:
renueva con **15 a 30 días de margen**. Al terminar, el script imprime la **fecha sugerida de la
próxima renovación** (unos 75 días después de la emisión) — agéndala en tu calendario.

La renovación es **manual** porque el reto se resuelve creando un registro TXT en el DNS de tu
registrador, y la mayoría de registradores no ofrece API. Si tu dominio está en Cloudflare, puedes
automatizarla: ver [SSL Automático](./ssl-cloudflare.md).
:::

## ¿Qué script me toca?

| Tu instalación | Script a usar | Dónde |
|---|---|---|
| Servidor Linux con Docker (instalado con `install.sh`) | `updateSSL.sh` | [Sección A](#a-servidor-linux-con-docker) |
| On-premise multi-dominio (instalado con `install.sh` de on-premise) | `ssl.sh` | [Sección B](#b-instalación-on-premise-multi-dominio) |
| Dominio administrado en Cloudflare (con API token) | `certbot-dns-cloudflare` | [SSL Automático](./ssl-cloudflare.md) |
| Servidor LAMP (Apache, sin Docker) | `certbot` | [Actualizar SSL en instalación LAMP](./ssl-instalacion-lamp.md) |

:::danger LOS ENLACES ANTIGUOS DE `git.buho.la` YA NO SE USAN
Versiones anteriores de esta guía descargaban `newSSL.sh` y `updateSSL.sh` desde snippets de
`git.buho.la`. Esos scripts quedaron **obsoletos**: copian `cert.pem` (sin la cadena intermedia,
lo que rompe la validación en varios clientes), escriben en `/root/certs` y reinician un contenedor
con nombre fijo (`proxy_proxy_1`).

Usa los scripts publicados en **este manual**
(`https://manual-facturador.nube-tec.com/install-scripts/…`): detectan el contenedor del proxy y su
volumen real de certificados, copian `fullchain.pem` y validan el resultado.
:::

---

## A. Servidor Linux con Docker

### A.1 Descargar el script

Ingresa a tu VPS y conviértete en superusuario:

```bash
sudo su
```

Ubícate en la **raíz donde vive la carpeta de tu dominio** (por ejemplo `/var/`, donde existe
`/var/tudominio.pe/`) y descarga el script:

```bash
cd /var/
curl -fSL -o updateSSL.sh https://manual-facturador.nube-tec.com/install-scripts/linux/updateSSL.sh
chmod +x updateSSL.sh
```

:::tip
El script encuentra el proyecto solo: acepta ejecutarse desde la raíz que contiene `tudominio.pe/`,
desde dentro de la carpeta del proyecto, o si el proyecto está en `/var/tudominio.pe`.
:::

### A.2 Emitir o renovar el certificado

```bash
sudo ./updateSSL.sh tudominio.pe
```

El script hace, en un solo paso:

1. Pide a Let's Encrypt el certificado **wildcard** `*.tudominio.pe` + `tudominio.pe` (reto DNS-01).
2. Copia `fullchain.pem` / `privkey.pem` al volumen real de certificados del proxy, también para
   `ws.tudominio.pe` (el subdominio de realtime).
3. Repara en `docker-compose.yml` las variables del proxy (`VIRTUAL_HOST`, `VIRTUAL_PORT`,
   `VIRTUAL_PROTO`, `CERT_NAME`) y agrega el redirect `www.tudominio.pe` → `tudominio.pe`.
4. Reconstruye el `nginx_N` del proyecto, reinicia el proxy y valida HTTP y HTTPS contra
   `127.0.0.1`.

### A.3 El reto DNS: crear el registro TXT

1. La primera vez, certbot pedirá un **correo de contacto** (solo si el servidor aún no tiene
   cuenta registrada en Let's Encrypt).

   ![Dominio para el SSL](img/dominio-ssl.png)

2. Certbot mostrará **uno o dos registros TXT** que debes crear en el panel DNS de tu registrador.
   El nombre del registro es **`_acme-challenge.tudominio.pe`** y el valor es la cadena que muestra
   la pantalla.

   ![Registro TXT](img/registro-txt-ssl.png)

:::danger ANTES DE PRESIONAR ENTER
Verifica que los TXT ya se hayan propagado. Puedes usar **https://www.whatsmydns.net/** o, desde el
servidor:

```bash
dig TXT _acme-challenge.tudominio.pe @8.8.8.8 +short
```

La propagación toma entre 5 y 30 minutos. **No uses `Ctrl+C`**: cancela el proceso y hay que
empezar de nuevo.
:::

![Propagación DNS](img/dns-ssl.png)

3. Cuando los TXT ya respondan, presiona **Enter**. Si todo está bien, verás la confirmación:

   ![Verificado](img/verificado-ssl.png)

### A.4 Activar HTTPS en la aplicación (solo la primera vez)

`updateSSL.sh` **instala el certificado y repara el proxy, pero no modifica el `.env`**. La primera
vez que activas HTTPS hay que apuntar la aplicación a `https://`:

1. Edita `.env` en la carpeta del proyecto y deja:

   ```env
   APP_URL=https://${APP_URL_BASE}
   FORCE_HTTPS=true
   ```

2. Recompila la configuración **dentro del contenedor de PHP** (el nombre es tu dominio con los
   puntos cambiados por guiones bajos):

   ```bash
   docker exec fpm_tudominio_pe php artisan config:cache
   docker exec fpm_tudominio_pe php artisan cache:clear
   ```

3. Reinicia los tres contenedores de PHP para que tomen la nueva configuración (con OPcache en
   producción, los workers siguen sirviendo la config vieja hasta reiniciarse):

   ```bash
   docker restart fpm_tudominio_pe scheduling_tudominio_pe supervisor_tudominio_pe
   ```

El detalle de estos parámetros está en [Gestión externa de SSL](./gestion-externa-ssl.md).

### A.5 Reparar el proxy sin renovar el certificado

Si el certificado sigue vigente pero el sitio no carga por HTTPS (por ejemplo Cloudflare muestra
`522`, o `www` cae como tenant en vez del panel), no hace falta pedir un certificado nuevo:

```bash
sudo ./updateSSL.sh tudominio.pe --repair-proxy
```

Este modo **no llama a certbot ni pide TXT**: reutiliza el certificado existente, repara
`docker-compose.yml` y `nginx`, reconstruye el nginx del proyecto y valida el resultado. No toca
volúmenes ni base de datos.

---

## B. Instalación on-premise multi-dominio

En las instalaciones on-premise (varios dominios bajo una misma raíz, normalmente
`/opt/proyectos`) el ciclo completo de SSL lo cubre un solo script, `ssl.sh`:

```bash
cd /opt/proyectos
curl -fSL -o ssl.sh https://manual-facturador.nube-tec.com/install-scripts/onpremise/ssl.sh
chmod +x ssl.sh
```

```bash
sudo ./ssl.sh                                    # muestra un menú con los dominios instalados
sudo ./ssl.sh --domain fe.tudominio.org          # directo a un dominio
sudo ./ssl.sh --domain fe.tudominio.org --repair-proxy
```

El script **detecta solo el modo**:

| Situación | Modo | Qué hace |
|---|---|---|
| El dominio aún no tiene certificado | **emitir** | Pide el wildcard, y además activa HTTPS en el `.env` (`APP_URL`, `FORCE_HTTPS`, Pusher por 443), recompila la config y reinicia `fpm`, `scheduling` y `supervisor`. |
| El dominio ya tiene certificado | **renovar** | Renueva con `--force-renewal` y verifica que el certificado realmente cambió. |
| Se pasa `--repair-proxy` | **reparar** | No pide TXT ni renueva: solo repara compose/nginx, reinicia el proxy y valida. |

Un único certificado `*.fe.tudominio.org` cubre **todas las empresas** de ese dominio base
(`empresa.fe.tudominio.org`). Cada dominio base instalado lleva su propio wildcard: ejecuta `ssl.sh`
una vez por dominio.

:::info
Emitir o renovar **no requiere IP pública ni NAT**: el reto DNS-01 solo necesita crear el TXT en el
DNS público del registrador. Guía completa del entorno on-premise:
[Instalación on-premise](../instalacion-scripts/onpremise/index.md).
:::

---

## C. Cómo saber cuándo vence

Desde el navegador: [¿Cómo saber cuándo se vence mi certificado SSL?](../../../guias-adicionales/certificados/como-saber-cuando-vence-mi-ssl.md)

Desde el servidor:

```bash
sudo certbot certificates
```

```bash
echo | openssl s_client -servername tudominio.pe -connect tudominio.pe:443 2>/dev/null \
  | openssl x509 -noout -dates
```

`notAfter` es la fecha de vencimiento. Si faltan menos de 30 días, renueva.

---

## D. Problemas frecuentes

| Síntoma | Causa probable | Qué hacer |
|---|---|---|
| Certbot dice que no encuentra el TXT | El registro no se propagó todavía | Espera y confirma con `dig TXT _acme-challenge.tudominio.pe @8.8.8.8` antes de presionar Enter |
| Cloudflare muestra `522` pero el servidor responde en local | El proxy no está publicando 443 correctamente | `sudo ./updateSSL.sh tudominio.pe --repair-proxy` |
| El navegador sigue mostrando el certificado viejo tras renovar | El proxy no recargó los certificados | Reinicia el contenedor del proxy (el script ya lo hace; verifica con `docker ps`) |
| Renovaste pero la app sigue enlazando a `http://` | Falta el paso [A.4](#a4-activar-https-en-la-aplicación-solo-la-primera-vez) | Ajusta `.env`, `config:cache` y reinicia `fpm`, `scheduling` y `supervisor` |
| `too many certificates already issued` | Límite de Let's Encrypt (5 certificados duplicados por semana) | Espera a que pase la ventana; no repitas la emisión en bucle |
