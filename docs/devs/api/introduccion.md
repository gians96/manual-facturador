---
sidebar_position: 1
---

# API Documentation

Bienvenido a la documentación de la API del Facturador Pro 8.

## Introducción

Esta sección contiene toda la documentación necesaria para integrar tu aplicación con nuestro sistema de facturación electrónica.

:::tip ¿Integras desde otra aplicación?
Además de esta página, revisa **[Items, productos y clientes](./emision-items-y-catalogo.md)**:
explica en detalle cómo el Pro 8 **crea o reutiliza los productos** del catálogo al emitir (con la
llave `codigo_interno`), cómo hace **upsert del cliente**, y cómo **evitar comprobantes duplicados**
con `offline_id`.
:::

Todos los endpoints del API viven bajo el **dominio de tu empresa** (tenant), con prefijo `/api`:

```
https://<dominio-de-tu-empresa>/api/...
```

Por ejemplo, si tu empresa está en `empresa.pro8.uio.la`, la emisión de comprobantes es
`POST https://empresa.pro8.uio.la/api/documents`.

## Características principales

- **Facturación electrónica**: Genera facturas, boletas y otros comprobantes electrónicos
- **Gestión de productos**: Administra tu catálogo de productos y servicios
- **Clientes**: Gestiona la información de tus clientes
- **Inventario**: Controla el stock de tus productos
- **Reportes**: Obtén información detallada de tus ventas

## Autenticación

Todas las peticiones (excepto el login) requieren un **token de acceso** enviado en el encabezado
`Authorization` como *Bearer token*, junto con `Accept: application/json`:

```bash
curl -X POST https://tu-dominio.com/api/documents \
  -H "Authorization: Bearer <TU_TOKEN>" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d @factura.json
```

:::tip ¿De dónde saco el token?

El token pertenece a cada **usuario** del sistema y se puede obtener de dos formas:

**1. Desde la web (recomendado):** ingresa al sistema y ve a **Configuración → Usuarios**.
El listado muestra la columna **"Api Token"** de cada usuario (enmascarado); usa el botón de
*ver token* para abrir el modal y **copiar el token completo**. Al editar un usuario, el
formulario también muestra el campo *Api Token* y el botón **"Generar Token"** para regenerarlo
(solo un administrador puede regenerarlo; al hacerlo, el token anterior deja de funcionar).

**2. Por API (login):** envía las credenciales del usuario y toma el campo `token` de la respuesta:

```bash
curl -X POST https://tu-dominio.com/api/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"email":"usuario@correo.com","password":"******"}'
```

Respuesta (resumida):

```json
{
  "success": true,
  "name": "Administrador",
  "email": "usuario@correo.com",
  "establishment_id": 1,
  "token": "aB3xK9mPqR5tW7yZ1cD4fG6hJ8kL0nQ2sU...",
  "company": { "name": "MI EMPRESA", "...": "..." }
}
```

Si las credenciales son inválidas, el login responde HTTP 200 con
`{"success": false, "message": "No Autorizado"}`.

:::

**Detalles del token:**

- El token **no expira**; solo cambia si un administrador lo regenera.
- Se crea automáticamente al crear cada usuario.
- Las peticiones sin token (o con token inválido) responden **HTTP 401**:
  `{"success": false, "message": "No se encuentra autenticado"}` — siempre que se envíe el
  encabezado `Accept: application/json` (sin él, el API redirige a la pantalla de login).

**Bloqueos por licencia (HTTP 403):**

| `message_code` | Significado |
|---|---|
| `LICENSE_TENANT_BLOCKED` | La cuenta (tenant) está suspendida por licencia: se bloquea todo el API. |
| `LICENSE_EMISSION_BLOCKED` | La emisión de comprobantes está bloqueada por licencia (`POST /api/documents`). |

## Formato de errores

| Código HTTP | Cuándo | Cuerpo |
|---|---|---|
| 200 | Operación exitosa | `{"success": true, ...}` |
| 401 | Token ausente o inválido | `{"success": false, "message": "No se encuentra autenticado"}` |
| 403 | Bloqueo por licencia | `{"success": false, "message": "...", "message_code": "LICENSE_..."}` |
| 422 | Error de validación | `{"success": false, "message": {"campo": ["errores"]}}` |
| 500 | Error de negocio (serie incorrecta, documento no encontrado, etc.) | `{"success": false, "message": "La serie ingresada F001, es incorrecta."}` |

## Endpoints disponibles

### Administración
- [Gestión de Tenants](admin/api-spec/get-reseller-detail.api.mdx)
- [Bloqueo de Administrador](admin/locked-admin/locked-admin.api.mdx)
- [Bloqueo de Tenants](admin/locked-tenant/locked-tenant.api.mdx)

### Facturación
- [Facturas](tenant/Generar-factura/introduccion.info.mdx)
- [Boletas](tenant/Generar-boleta/introduccion.info.mdx)
- [Notas de Crédito y Débito](tenant/Generar-notas/introduccion.info.mdx)
- [Resúmenes diarios](tenant/Generar-resumenes/introduccion.info.mdx)
- [Anulación de Facturas](tenant/Anulacion-facturas/introduccion.info.mdx)
- [Anulación de Boletas](tenant/Anulacion-boleta/introduccion.info.mdx)

### Productos y Clientes
- [Productos](tenant/Productos/introduccion.info.mdx)
- [Clientes](tenant/Clientes/introduccion.info.mdx)

### Inventario
- [Gestión de Inventario](tenant/Inventario/introduccion.info.mdx)

### Otros
- [Cotizaciones](tenant/Generar-cotizacion/introduccion.info.mdx)
- [Guías de Remisión](tenant/Guia-remision/introduccion.info.mdx)
- [Retenciones](tenant/Retencion/introduccion.info.mdx)

## Flujo típico de integración

1. **Obtener el token** (una sola vez, desde Configuración → Usuarios o vía `POST /api/login`).
2. **Emitir el comprobante** con `POST /api/documents` (factura/boleta/nota). Guarda el
   `external_id` de la respuesta: identifica al comprobante en todas las demás operaciones.
   👉 Cómo se crean/deduplican los productos y el cliente al emitir (llave `codigo_interno`) y cómo
   evitar duplicados con `offline_id`: ver [Items, productos y clientes](./emision-items-y-catalogo.md).
3. **Facturas y notas de factura**: se envían a SUNAT al emitirse (o con `POST /api/documents/send`
   si se emitió con `acciones.enviar_xml_firmado: false`).
4. **Boletas y notas de boleta**: se declaran con el **resumen diario** (`POST /api/summaries`) y
   se consulta el ticket con `POST /api/summaries/status`.
5. **Anulaciones**: facturas con `POST /api/voided` (+ `voided/status`); boletas con resumen de
   tipo `3` (`POST /api/summaries`).
6. **Guías de remisión**: `POST /api/dispatches` → `POST /api/dispatches/send` →
   `POST /api/dispatches/status_ticket`. ⚠️ Las guías **no tienen ambiente de pruebas de SUNAT**:
   el envío requiere credenciales del API GRE de producción configuradas en la empresa.
7. **Descargas**: usa los `links` (`xml`, `pdf`, `cdr`) que devuelve cada operación.

## Soporte

Si tienes alguna pregunta o necesitas ayuda, no dudes en contactarnos a través de nuestro sistema de soporte.
