---
sidebar_position: 3
title: Monitoreo de disponibilidad
description: GET /health y UptimeRobot con aviso por Telegram, para enterarse de una caída antes que los clientes.
---

# Monitoreo de disponibilidad

Si el Facturador deja de responder, hoy te enteras cuando llama un cliente. Esta página deja un
vigilante externo que consulta el servidor cada 5 minutos y te avisa por Telegram cuando algo no
responde. Se configura una sola vez y no instala nada en el servidor.

## Qué se vigila: `GET /health`

Cada instalación responde en `https://<tu-dominio>/health`, sin iniciar sesión:

| Código | Significa |
|---|---|
| `200` | La aplicación responde y llega a la base de datos |
| `503` | La base de datos no responde: el sitio está caído para todos |
| `500` | El sitio está en modo mantenimiento (`artisan down`): la aplicación responde así a todas las rutas, `/health` incluida |
| Sin respuesta o `502` | PHP o nginx no atienden: servidor saturado, contenedores caídos |

El cuerpo trae además el detalle, sin datos internos (ni hosts, ni versiones, ni mensajes de
error):

```json
{"status":"ok","checks":{"database":true,"scheduler":true,"dependencies":true}}
```

- `database`: la base de datos del sistema contesta. **Es lo único que decide el código HTTP.**
- `scheduler`: el resultado de `system:check` tiene menos de 15 minutos, así que el scheduler
  sigue vivo. Si se para, las tareas programadas dejan de correr sin avisar.
- `dependencies`: en esa última comprobación, Laravel llegó a Redis y al WebSocket.

`scheduler` y `dependencies` no cambian el código a propósito: un Redis caído no impide facturar,
y marcar la caída ahí despertaría a alguien por algo que puede esperar a la mañana.

Compruébalo desde cualquier equipo:

```bash
curl -s -o /dev/null -w '%{http_code}\n' https://<tu-dominio>/health   # 200
curl -s https://<tu-dominio>/health                                    # el detalle
```

La ruta responde igual en el dominio principal y en los subdominios de cada empresa; vigila el
dominio principal.

## UptimeRobot con aviso por Telegram

UptimeRobot tiene un plan gratuito que alcanza: monitores cada 5 minutos y avisos por Telegram.
El panel cambia de aspecto con el tiempo, así que los nombres de los menús pueden variar un
poco; los pasos son estos.

### 1. Crear el contacto de Telegram

1. Entra a tu cuenta de UptimeRobot y busca las **integraciones** (en paneles antiguos, *My
   Settings → Alert Contacts → Add Alert Contact*).
2. Elige **Telegram**. UptimeRobot muestra un enlace (o un código QR) a su bot.
3. Ábrelo en Telegram y pulsa **Iniciar** (*Start*). Para avisar a un **grupo**, agrega el bot al
   grupo y envía ahí el comando que te indica UptimeRobot.
4. Vuelve a UptimeRobot: el contacto aparece como activo. Si ofrece enviar una notificación de
   prueba, úsala y confirma que llega.

### 2. Crear el monitor

1. **New monitor** (o *Add New Monitor*).
2. Tipo: **HTTP(s)**.
3. URL: `https://<tu-dominio>/health`.
4. Intervalo: **5 minutos**.
5. En *Alert contacts* / *Notifications*, marca el contacto de Telegram.
6. Guarda. En unos minutos el monitor pasa a **Up**.

UptimeRobot da la alerta cuando la respuesta es un error (un `503`, un `502`, un `404`) o cuando no
contesta, y vuelve a avisar cuando se recupera.

### 3. Opcional: avisar también si se para el scheduler

Un segundo monitor, de tipo **Keyword**, sobre la misma URL:

- Palabra clave: `"scheduler":true`
- Alerta cuando la palabra clave **no existe** (*Keyword not exists*).

Avisa cuando el sitio responde pero las tareas programadas llevan más de 15 minutos sin correr
(el contenedor `scheduling_*` caído, por ejemplo). No es tan urgente como el primero: usa el
mismo contacto o uno aparte.

### 4. Probar que el aviso llega

No hace falta tumbar nada. Crea un monitor temporal apuntando a una ruta que no existe, por
ejemplo `https://<tu-dominio>/health-prueba-alerta` (compruébalo antes con `curl`: debe responder
`404`). UptimeRobot lo marca caído y el aviso llega a Telegram. Después **bórralo**.

## Si hay un proxy o CDN delante

Si el dominio pasa por un servicio con protección contra bots, puede responder con un desafío a
UptimeRobot y el monitor marcará caídas falsas. Excluye la ruta `/health` de esa protección. La
respuesta ya lleva `Cache-Control: no-store`, así que no se sirve desde caché.

## Cuando llega un aviso

1. Abre el sitio y `https://<tu-dominio>/health` para ver qué falla.
2. **Antes de reiniciar nada**, guarda la evidencia: `sudo bash scripts/prod-evidencia.sh` desde la
   carpeta del proyecto. Un reinicio borra lo único que dice qué petición o qué consulta saturó el
   servidor (ver [Servicios operativos](./servicios-operativos.md#monitor-externo-y-evidencia-antes-de-reiniciar)).
3. Con la evidencia guardada, revisa contenedores (`docker ps`), el log de acceso y el slow log
   como se explica en [Capacidad y visibilidad del stack](./servicios-operativos.md#capacidad-y-visibilidad-del-stack).
