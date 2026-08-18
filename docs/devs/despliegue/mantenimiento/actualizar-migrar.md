---
title: Actualizar o Migrar el Sistema
description: "Guía para actualizar el sistema Facturador o migrar desde versiones anteriores."
sidebar_position: 5
---

# Guía para Actualizar o Migrar el Sistema

## ⚠️ Nuevo Contenedor Redis

Se ha añadido un nuevo contenedor Redis. **Tener cuidado al momento de actualizar**, ya que debe verificarse que el contenedor se haya creado correctamente y realizar configuraciones adicionales en el archivo `.env`.

---

## ❌ IMPORTANTE - Migración desde Pro 7

Si estás actualizando desde **Pro 7 (rama main)** a **Facturador**, **es obligatorio seguir primero el manual de migración**.

👉 **[Manual de Upgrade Pro 7 a Facturador](https://pro8.jczap.net/devs/instalacion/Upgrade-Docs)**

### Cambios Importantes

Al actualizar debes tener en cuenta:

- **Dependencias del proyecto** - Necesarias para Facturador
- **Estructura de archivos y carpetas** - Cambios en la organización
- **Configuraciones del sistema** - Nuevos parámetros requeridos

**Nota:** Puedes actualizar directamente, pero se recomienda seguir el manual oficial para evitar problemas durante la migración.

---

## 📋 Pre Requisitos

Antes de comenzar, asegúrate de tener:

- ✅ Acceso SSH al servidor
- ✅ Credenciales válidas de GitLab (usuario y token)
- ✅ Permisos para ejecutar comandos Docker
- ✅ Una suscripción activa para migrar desde versiones anteriores

---

## Guías Disponibles

| Guía                        | Descripción                                                                                        |
| --------------------------- | -------------------------------------------------------------------------------------------------- |
| **Actualización Estándar**  | Para usuarios que ya tienen Facturador y solo necesitan actualizar a la última versión.                 |
| **Migración Pro 7 → Facturador** | Para clientes que desean migrar desde Pro 7 a la nueva versión Facturador. Requiere suscripción activa. |
| **Solución de Problemas**   | Ayuda para resolver errores comunes durante el proceso de actualización.                           |

---

## 1. Conexión al Servidor

### 1.1 Acceso por SSH

```bash
ssh [usuario]@[ip]
```

### 1.2 Verificar contenedores activos

```bash
docker ps
```

### 1.3 Acceder al contenedor FPM

```bash
docker exec -it [nombre_contenedor_fpm] /bin/bash
```

---

## 2. Preparación del Entorno

> **💡 Tip:** Antes de actualizar, siempre revisa si tienes cambios locales para evitar conflictos.

### 2.1 Verificar estado del repositorio

```bash
git status
```

### 2.2 Guardar cambios locales (si los hay)

```bash
git stash
```

### 2.3 Verificar la URL del repositorio remoto

```bash
git remote -v
```

Si la URL no es correcta, actualízala:

```bash
git remote set-url origin https://gitlab.com/gians96/pro-8.git
```

---

## 3. Actualización Estándar

Para usuarios que ya tienen Facturador instalado.

### 3.1 Descargar cambios

```bash
git pull origin main
```

> **ℹ️ Nota:** Si se solicitan credenciales, ingresa tu usuario y token de GitLab.

### 3.2 Recuperar cambios guardados (si aplicaste stash)

```bash
git stash apply
```

### 3.3 Aplicar migraciones y optimizaciones

Puedes ejecutar los comandos individualmente:

```bash
php artisan migrate
php artisan tenancy:migrate
php artisan config:cache
php artisan cache:clear
php artisan optimize:clear
```

O ejecutarlos en una sola línea:

```bash
php artisan migrate && php artisan tenancy:migrate && php artisan config:cache && php artisan cache:clear && php artisan optimize:clear
```

---

## 4. Migración de Pro 7 a Facturador

> **⚠️ Importante:** Debes tener una **suscripción activa** para realizar esta migración. Si tu suscripción no está vigente, contacta al área comercial antes de continuar.

### ❗ ATENCIÓN - Pasos Obligatorios

**Antes de migrar de Pro 7 a Facturador, es obligatorio seguir el manual oficial de upgrade:**

👉 **[Manual de Upgrade Pro 7 a Facturador](https://pro8.jczap.net/devs/instalacion/Upgrade-Docs)**

Este manual incluye:

- Actualización de dependencias
- Cambios en la estructura del proyecto
- Configuraciones específicas necesarias
- Scripts de migración de base de datos

**⛔ No omitas este paso** o podrías experimentar errores críticos en el sistema.

### 4.1 Cambiar repositorio remoto

```bash
git remote set-url origin https://gitlab.com/gians96/pro-8.git
```

### 4.2 Verificar configuración

```bash
git remote -v
```

### 4.3 Proceso de migración completa

```bash
git status
git add .
git stash
git pull origin main
git reset --hard origin/main
git stash apply
```

### 4.4 Verificación post-migración

Después de completar la migración:

- ✅ Confirma que todos los datos se migraron correctamente
- ✅ Verifica el funcionamiento de las principales funcionalidades
- ✅ Revisa y ajusta configuraciones según tus necesidades
- ✅ Comprueba que las nuevas dependencias de Facturador estén instaladas

---

## 5. Actualización después del 20 de Febrero

### 5.1 Descargar últimos cambios

```bash
git pull origin main
```

Ingresar usuario y token cuando se solicite.

### 5.2 Limpiar dependencias

Ejecutar:

```bash
rm -rf vendor node_modules composer.lock package-lock.json
```

### 5.3 Instalar dependencias

```bash
composer install
```

### 5.4 Salir del contenedor FPM

```bash
exit
```

### 5.5 Entrar a la carpeta del facturador

Desde el servidor (generalmente está con el nombre de tu dominio):

```bash
cd /ruta/del/facturador
```

### 5.6 Configurar Redis en docker-compose.yml

1. Abrir el archivo `docker-compose.yml`
2. Copiar la configuración del servicio **Redis**
3. Guardar los cambios

### 5.7 Actualizar variables de entorno (.env)

En el archivo `.env`, cambiar:

```env
# Cambiar REDIS_HOST según lo que está en docker-compose.yml
REDIS_HOST=redis

# Cambiar CACHE_DRIVER de 'file' a 'redis'
CACHE_DRIVER=redis
```

### 5.8 Reiniciar los contenedores

```bash
docker compose down
docker compose up -d
```

### 5.9 Ingresar al contenedor FPM y ejecutar los siguientes comandos:

```bash
docker exec -it [nombre_contenedor_fpm] /bin/bash
```

```bash

php artisan migrate
php artisan tenancy:migrate
php artisan config:cache
php artisan cache:clear
php artisan optimize:clear
```
