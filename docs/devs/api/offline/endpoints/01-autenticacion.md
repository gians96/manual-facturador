# 01 — Autenticación

> `POST /api/login`  
> **Controller:** `Tenant\Api\MobileController@login`  
> **Auth:** No requerida  
> **Uso offline:** Primera llamada. Obtiene token, datos de empresa, configuración de la app y el `establishment_id` del usuario.

---

## Request

### Headers

```
Content-Type: application/json
Accept: application/json
```

### Payload

```json
{
    "email": "demo@nt-suite.pro",
    "password": "123456",
    "domain": "demo.nt-suite.pro",
    "ssl": "https://"
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `email` | string | Sí | Email del usuario |
| `password` | string | Sí | Contraseña |
| `domain` | string | Sí | Dominio del tenant (sin protocolo) |
| `ssl` | string | Sí | Protocolo: `"https://"` o `"http://"` |

---

## Response (200 OK)

```json
{
    "success": true,
    "name": "Administrador",
    "email": "demo@nt-suite.pro",
    "establishment_id": 1,
    "seriedefault": null,
    "token": "TOKEN_DEMO_reemplazar_por_el_real",
    "restaurant_role_id": 3,
    "restaurant_role_code": "ADM",
    "ruc": "20123456789",
    "app_logo": null,
    "app_logo_base64": "",
    "company": {
        "name": "EMPRESA DEMO S.A.C.",
        "address": "LIMA, Lima, Lima, -",
        "phone": "-",
        "email": "demo@nt-suite.pro",
        "enable_list_product": false,
        "qr_api_enable_ws": false,
        "qr_api_url_ws": null,
        "qr_api_key_ws": null,
        "url_logo": "",
        "logo_base64": "",
        "is_business_turn_tap": 0
    },
    "app_configuration": {
        "id": 1,
        "show_image_item": true,
        "print_format_pdf": "ticket",
        "theme_color": "blue",
        "card_color": "multicolored",
        "header_waves": 0,
        "app_mode": "default",
        "direct_print": false,
        "has_igv_31556": false,
        "igv_31556_percentage": "0.105",
        "direct_send_documents_whatsapp": false,
        "restrict_receipt_date": true,
        "shipping_time_days": 4,
        "auto_send_pdf_email": false
    },
    "permission_edit_item_prices": true,
    "sellerId": 1
}
```

### Campos clave para Flutter

| Campo | Tipo | Uso offline |
|-------|------|-------------|
| `token` | string | **Guardar.** Se usa como `Bearer {token}` en todos los demás endpoints |
| `establishment_id` | int | **Guardar.** Identifica la sucursal. Items y series se filtran por este ID |
| `sellerId` | int | **Guardar.** ID del vendedor para enviar en `codigo_vendedor` / `seller_id` |
| `company.name` | string | Razón social para mostrar en la app |
| `ruc` | string | RUC de la empresa para generar filenames |
| `restaurant_role_id` | int | Rol del usuario (1=Cajero, 2=Mesero, 3=Admin) |
| `restaurant_role_code` | string | Código del rol: `CAJ`, `MSR`, `ADM` |
| `app_configuration` | object | Configuración visual y de comportamiento de la app |
| `app_configuration.restrict_receipt_date` | bool | **Guardar.** Si es `false`, no se valida la fecha de emisión |
| `app_configuration.shipping_time_days` | int | **Guardar.** Margen de días para la fecha de emisión (default `4`) |
| `app_configuration.auto_send_pdf_email` | bool | Si el backend envía el comprobante al correo del cliente al emitir |
| `seriedefault` | string\|null | Serie por defecto del usuario (puede ser null si tiene múltiples) |

---

## Response de Error (401)

```json
{
    "success": false,
    "message": "Usuario o contraseña incorrecta"
}
```

---

## Notas para Offline

- Este endpoint **requiere conexión a internet** siempre.
- El token obtenido debe almacenarse en SQLite/SharedPreferences local.
- El `establishment_id` determina qué items, series y warehouse descargará la app.
- El `sellerId` se envía en cada comprobante como `codigo_vendedor` (documentos) o `seller_id` (notas de venta).
- Si `seriedefault` es `null`, se debe consultar `GET /api/offline/series-numbering` para obtener las series asignadas al usuario.
- **`restrict_receipt_date` y `shipping_time_days` se usan para validar la fecha de emisión
  antes de encolar una venta.** Sin ellos, un comprobante fuera de plazo se acepta en el
  dispositivo y solo se descubre rechazado al sincronizar. Disponibles en `app_configuration`
  desde 2026-09-02; si el backend es anterior no vendrán, así que asume el default
  (`true` / `4`). Regla completa en [35 — Plazo de la Fecha de Emisión](35-plazo-fecha-emision.md).
- **`auto_send_pdf_email` es informativo.** El envío del comprobante por correo lo hace el
  backend en la propia emisión; la app no debe lanzar ninguna llamada extra. Sirve para
  reflejarlo en la interfaz y avisar cuando el cliente elegido no tiene correo registrado.
  Regla completa en [36 — Envío Automático por Correo](36-envio-automatico-por-correo.md).
