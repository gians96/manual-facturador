---
slug: /v7.2
---
# PRO 7.2 - Octubre

## Introducción

**PRO 7.2** continúa la evolución del Sistema de Facturación Pro 7, enfocándose en la gestión administrativa, mejoras en la experiencia del usuario y automatización de procesos críticos. Esta versión trae importantes actualizaciones en el panel administrador y nuevas funcionalidades para facilitar la gestión de guías de remisión y consignados.

Con acceso 100% al repositorio y soporte completo, PRO 7.2 representa una solución robusta para empresas que buscan eficiencia y control total sobre su sistema de facturación.

---

## 🎯 Características Principales

### Actualizaciones Tecnológicas

- **Laravel 9 + PHP 8**: Manteniendo el framework actualizado para mejor rendimiento
- **Ubuntu 24.04 LTS**: Compatibilidad con la última versión LTS
- **Bootstrap 5**: Framework CSS actualizado con mejoras de diseño
- **Cloudflare SSL Automatizado**: Renovación automática de certificados SSL (Ubuntu 24.04 LTS)

### Nuevas Funcionalidades Core

- **Gestión de Pagos**: Sistema completo para renovaciones del servicio
- **Botón de Soporte Mejorado**: Información personalizada integrada
- **Consignados en Documentos**: Campo adicional para entregas a terceros
- **Validación de Caja**: Control previo antes de generar comprobantes
- **Venta Itinerante**: Nueva modalidad de venta para e-commerce
- **SSL Automático**: Actualización y renovación automática de certificados

---

## 📊 Resumen de Actualizaciones

### ✨ Nuevas Funcionalidades (Features)

| Categoría | Cantidad | Destacados |
|-----------|----------|------------|
| **Panel Administrador** | 11 | Gestión de pagos, accesos personalizados, API de control |
| **UI/UX** | 15 | Login personalizable, nuevo tema, Bootstrap 5 |
| **Panel Clientes** | 9 | Consignados, GRE a terceros, observaciones |
| **E-commerce** | 4 | Venta itinerante, descarga masiva WooCommerce |
| **Reportes** | 2 | Productos en segundo plano, reinicio manual |
| **Facturación** | 4 | Validación de caja, restricción de fechas |
| **Sistema** | 4 | SSL automático, scripts de actualización |

### 🐛 Correcciones (Fixes)

| Categoría | Cantidad | Destacados |
|-----------|----------|------------|
| **PSE** | 5 | CDR SendFact, status en OSE |
| **GRE** | 8 | Código 2566, PSE por API, ubigeo |
| **Backups** | 4 | Process, rutas, merging |
| **Reportes** | 4 | Descarga masiva, PDF A4 |
| **Documentos** | 3 | Fechas en notas de venta |
| **Otros** | 15+ | Múltiples correcciones de estabilidad |

### 🎨 Mejoras de Estilo

- Actualizaciones en panel administrador
- Mejoras visuales en listados y formularios
- Traducción de textos en páginas de error
- Actualización de iconos y espaciados

---

## 🚀 Actualizaciones Destacadas

### 1. Nueva Gestión de Pagos para Renovaciones

Sistema completo para administrar las renovaciones del servicio desde el panel administrador.

#### Características del Módulo

**Control Centralizado**
- 💳 Panel unificado para visualizar todos los pagos
- 📊 Estado de suscripciones y renovaciones
- 🔔 Alertas automáticas de vencimientos próximos
- 📈 Historial completo de transacciones

**Módulo de Pago Cron**
- ⏰ Verificación automática de vencimientos
- 📧 Notificaciones programadas a clientes
- 🔄 Proceso automatizado de renovación
- 📋 Registro detallado de ejecuciones

#### Funcionalidades Adicionales

- **Vista de Detalle**: Información completa de pagos del cliente
- **Órdenes de Pago**: Sistema inteligente que no crea órdenes para clientes sin fecha de finalización establecida
- **Habilitación/Deshabilitación**: Control automático según límite de documentos
- **Mejoras UI**: Interfaz optimizada para una gestión más eficiente

---

### 2. Botón de Soporte Mejorado

El botón de soporte ha sido completamente rediseñado para ofrecer información personalizada y acceso rápido a la asistencia.

#### Mejoras Implementadas

**Información Personalizada**
- 📝 Datos del usuario y cuenta pre-cargados
- 🎫 Historial de tickets de soporte
- 📊 Estado actual del sistema
- 🔍 Acceso rápido a documentación relevante

**Panel de Soporte Agregado**
- 💬 Sistema de tickets integrado
- 📎 Adjuntar archivos y capturas
- ⏱️ Seguimiento de tiempo de respuesta
- 🏷️ Categorización de solicitudes

---

### 3. Personalización del Color de Fondo en Login

Mayor flexibilidad visual para adaptar la interfaz a la identidad de tu marca.

#### Características

**Login Personalizado**
- 🎨 El login ahora se adapta completamente a su configuración
- 🖌️ Selector de color intuitivo en configuraciones
- 👀 Vista previa en tiempo real
- 💾 Cambios guardados por cliente

**Aplicación**
- Se aplica tanto en panel administrador como en panel clientes
- Compatible con todos los temas disponibles
- Validaciones de contraste para legibilidad
- Responsive en todos los dispositivos

---

### 4. Endpoint API para Bloquear o Reactivar Cuentas

Nueva API que permite control remoto sobre el estado de las cuentas empresariales.

#### Funcionalidades de la API

**Bloqueo de Cuentas**
```
POST /api/reseller/lockedTenant
- Bloquea el acceso a una empresa específica
```

**Reactivación de Cuentas**
```
POST /api/reseller/lockedTenant
- Reactiva cuentas bloqueadas
```

#### Control de Estado

- 🔒 **Cambio Automático**: El estado se actualiza cuando la cuenta está bloqueada
- 🔐 **Token de Usuario**: Seguridad mejorada con tokens individuales
- 📊 **Registro de Actividad**: Historial completo de cambios de estado
- ⚠️ **Validación Previa**: Evita pasar a producción con documentos pendientes

---

### 5. Mostrar u Ocultar Columnas en Lista de Empresas

Mayor control sobre la visualización de información en el panel administrador.

#### Personalización de Vistas

**Gestión de Columnas**
- ✅ Selecciona qué columnas mostrar u ocultar
- 💾 Configuración guardada por usuario
- 🔄 Restaurar vista por defecto
- 📱 Adaptación automática en móviles

**Mejoras Visuales**
- 🎯 Lista más clara y organizada
- 🔍 Mejor navegación entre empresas
- ⚡ Carga optimizada de datos
- 📊 Información relevante siempre visible

**Filtros Adicionales**
- Filtrado avanzado en listado de clientes
- Búsqueda rápida por múltiples criterios
- Ordenamiento por columnas
- Exportación de datos filtrados

---

### 6. Campo Adicional para "Consignado"

Nueva funcionalidad para gestionar entregas a terceros en guías de remisión y comprobantes.

#### ¿Qué es un Consignado?

El **consignado** es la persona o empresa que recibe la mercancía cuando el destinatario final es diferente al cliente facturado. Esta funcionalidad es esencial para empresas que realizan entregas a múltiples puntos.

#### Implementación Completa

**En Direcciones**
- 📍 Campo adicional para consignado en direcciones de guías
- 🏢 Información del consignado en comprobantes
- 🔍 Filtrado de direcciones con consignado según cliente seleccionado
- 🔄 Sincronización automática con el cliente

**En Documentos**
- 📄 Consignados dentro de nota de venta
- 📋 Consignados en CPE (PDF - default)
- 🚚 Guías de remisión con entrega a terceros (cliente final)
- 📦 Agregar comprador en GRE (Guía de Remisión Electrónica)

**En API**
- ⚙️ Endpoint `has_consigned` al buscar cliente por API
- 🔧 Corrección de errores de consignado y vendedor
- ✅ Validación automática de datos del consignado

---

### 7. Soporte para Guías de Remisión con Entrega a Terceros

Gestión completa de GRE cuando el destinatario final es diferente al cliente.

#### Funcionalidades de GRE Mejoradas

**Comprador en GRE**
- 👤 Agregar información completa del comprador
- 🔢 Número del comprador incluido (migración corregida)
- 📝 Productos opcionales en GRE transportista
- ✅ Validación del key `is_transport_m1l` dentro de DispatchInput

**Información de Transporte**
- 🚛 MTC en información de compañía y PDF A4 de transportista
- 👨‍✈️ Conductor y transportista cuando la opción está habilitada
- 🗺️ Ubigeo corregido en PDF de GRE
- ❌ Validación de transportista eliminada en transporte público para M1

**Observaciones Extendidas**
- 📏 Mayor longitud para observaciones en guías
- 🔄 Observaciones de nota de venta hacia guías
- 💬 Información de observación desde cotización a nota de venta
- 📌 Direcciones de envío corregidas en PDF default

#### Correcciones de GRE

- ✅ Error código 2566 solucionado
- ✅ PSE por API habilitado en GRE transportista
- ✅ Error al establecer comprador corregido
- ✅ Quitar validación conflictiva de transportista en M1

---

### 8. Validación de Caja Antes de Generar Comprobantes

Control previo que garantiza que existe una caja abierta antes de generar documentos.

#### Características

**Validación Automática**
- ⚠️ Mensaje de aviso para abrir caja
- 🔒 Bloqueo de generación sin caja abierta
- 🔓 Apertura automática al ingresar al módulo venta
- ✅ Verificación en tiempo real del estado de caja

**Beneficios**
- Previene errores en el flujo de facturación
- Asegura trazabilidad de todas las operaciones
- Facilita el control de ingresos diarios
- Mejora la auditoría de documentos

**Mejoras en Cajas**
- Pagos generales mejorados en cajas
- Cambios en la descripción de caja para mayor claridad
- Reporte general de caja para PDF A4 corregido
- Formato HTML para impresión de reportes

---

### 9. Actualización Automática del SSL con Cloudflare

Sistema automatizado para renovación de certificados SSL utilizando Cloudflare.

#### Características Principales

**Renovación Automática**
- 🔐 Actualización automática de certificados SSL
- ⏰ Verificación programada de vencimientos
- 🔄 Renovación sin intervención manual
- ✅ Confirmación de instalación exitosa

#### Requisitos y Compatibilidad

**Requisitos Previos**
- 🌐 Dominio registrado en Cloudflare
- 🔑 API Token de Cloudflare configurado
- 📧 Email de cuenta Cloudflare
- ✅ DNS configurado correctamente

:::danger Compatibilidad de Sistema Operativo

**Ubuntu 24.04 LTS** - ✅ MÉTODO RECOMENDADO
- Soporte completo y automatizado
- Instalación más estable y confiable
- Script optimizado para esta versión
- Todas las funcionalidades garantizadas

**Ubuntu 22.04 LTS** - ⚠️ MÉTODO NO RECOMENDADO
- Funciona pero requiere configuración adicional
- Posibles conflictos con dependencias
- Mayor mantenimiento manual

**Ubuntu 20.04 LTS** - ⚠️ MÉTODO NO RECOMENDADO
- Compatible pero no optimizado
- Requiere ajustes manuales
- Recomendamos migrar a 24.04 LTS

:::

:::info Requisito de Cloudflare

Para utilizar la actualización automática del SSL, **es obligatorio tener tu dominio configurado en Cloudflare**. El sistema utiliza la API de Cloudflare para gestionar y renovar automáticamente los certificados SSL.

Si no tienes tu dominio en Cloudflare:
1. Crea una cuenta gratuita en [Cloudflare](https://cloudflare.com)
2. Añade tu dominio a Cloudflare
3. Cambia los nameservers de tu dominio
4. Obtén tu API Token desde el panel de Cloudflare
5. Configura el API Token en el sistema PRO 7.2

:::

**Documentación Disponible**
- Manual de actualización incluido
- Script de actualización automatizado
- Guía para entorno local con Laragon
- Documentación del proceso de upgrade

---

### 10. Restricción de Fechas en Generación de CPE

Control estricto sobre las fechas permitidas al generar comprobantes de pago electrónicos.

#### Restricciones Implementadas

**Fechas Futuras**
- 🚫 No permite seleccionar fechas futuras
- ⚠️ Mensaje de validación claro
- 📅 Fecha máxima: fecha actual
- ✅ Previene errores de facturación

**Fechas Anteriores**
- ⏮️ Restricción de fechas muy antiguas (según configuración)
- 🔒 Control de períodos contables cerrados
- 📊 Consistencia en reportes fiscales
- ✅ Corrección de error que no generaba comprobantes desde nota de venta por fechas

**Validaciones Adicionales**
- Evita pasar a producción con documentos pendientes o en proceso
- Verificación del estado del documento antes de cambios
- Validación de usuario que creó el documento (mantiene creador original)

---

### 11. Nueva Opción de Venta Itinerante

Modalidad especial de venta para negocios que operan en múltiples ubicaciones.

#### Características

**¿Qué es Venta Itinerante?**
Permite gestionar ventas realizadas por vendedores que se desplazan a diferentes puntos de venta o directamente a clientes en sus ubicaciones.

**Funcionalidades**
- 📍 Registro de ubicación de venta
- 👤 Asignación de vendedor específico
- 🚗 Trazabilidad de rutas
- 📊 Reportes por zona o vendedor

**Integración E-commerce**
- Descarga de todos los productos existentes (WooCommerce & Listado)
- Mejor redirección en pedidos y ecommerce
- Término "precio" cambiado por "total" en documentos de tienda virtual
- Corrección de items repetidos en paginados

---

### 12. Mayor Claridad en Tareas Programadas

Mejoras significativas en la visualización y gestión de tareas automáticas del sistema.

#### Mejoras Implementadas

**Visualización Mejorada**
- 📋 Descripciones amigables en selector de tareas
- ⏰ Estado de ejecución en tiempo real
- 📊 Historial de ejecuciones
- ⚠️ Alertas de tareas fallidas

**Gestión de Tareas**
- 🔄 Reinicio manual de reportes en cola
- 📈 Reporte en segundo plano de productos generales
- ⏯️ Pausar y reanudar tareas
- 📝 Logs detallados de cada ejecución

---

## 🔄 Otras Mejoras Significativas

### Panel Administrador

**Accesos y Permisos**
- Accesos personalizados agregados
- Selector de temas en panel administrador
- Token de usuario añadido para mayor seguridad
- Pequeñas mejoras en configuraciones del admin

**Redes Sociales**
- TikTok agregado en configuraciones
- Sincronización de título del navegador con módulo y empresa
- Validaciones mejoradas en el login

### UI/UX General

**Bootstrap 5**
- Actualización completa de clases Bootstrap 5
- Mejoras en iconos y espaciados
- Inputs, header y sidebar mejorados
- Actualizaciones en filtros del dashboard

**Temas**
- Nuevo tema agregado al sistema
- Mejoras en UI del tema default
- Soluciones de estilos en tema black
- Dropdowns mejorados

**Listados y Formularios**
- Sidebar actualizado
- Listados más claros y organizados
- Formularios con mejor orden en configuraciones
- Actualización de estilos en listado de clientes

---

## 🛠️ Correcciones Técnicas Importantes

### PSE y Facturación Electrónica

- ✅ Error al decodificar CDR en PSE SendFact corregido
- ✅ Servicio PSE por API implementado
- ✅ Cambio de status en OSE SendFact mejorado
- ✅ Captura correcta de status rechazado antes de cambiar a anulado
- ✅ Nueva respuesta al obtener CDR desde SUNAT

### Backups y Sistema

- ✅ Ejecuciones con Process actualizadas
- ✅ Solución a error dentro de backups
- ✅ Error de rutas repetidas corregido
- ✅ Error de merging solucionado
- ✅ Consideración de actualización añadida

### Reportes

- ✅ Búsqueda para reportes de detracción (error #46)
- ✅ Descarga masiva en cola corregida
- ✅ Formato HTML para impresión de reporte
- ✅ Columna de cobros fuera de fecha y total de comisiones

### Clientes y Consignados

- ✅ Filtrado correcto en direcciones con consignado
- ✅ Validación de vendedor respecto al usuario autenticado
- ✅ Corrección de errores en selección de consignado

### Otros

- ✅ Componente QR API en configuración
- ✅ Precios unitarios respecto al valor del almacén
- ✅ Rango de valores para fecha de notificación
- ✅ Comisión fuera de rango corregida
- ✅ Error en función `close` del zip solucionado
- ✅ Referencias en archivos JS corregidas
- ✅ ChangePass.php editado para comando passwords

---

## 📦 Mejoras de Arquitectura

### Código y Estructura

- **Script de Actualización**: Actualización automática de dependencias
- **Documentación**: Manual completo de upgrade y actualización
- **Entorno Local**: Manual de actualización Laragon incluido
- **Reverse app.js**: Optimización de archivos JavaScript

### Sistema

- **Cloudflare SSL**: Automatización completa del proceso
- **Validaciones**: Mayor control sobre operaciones críticas
- **Seguridad**: Tokens de usuario y accesos mejorados

---

## 💡 Recomendaciones de Uso

### Para Administradores

1. Configura el módulo de gestión de pagos desde el inicio
2. Personaliza el botón de soporte con tu información
3. Define los colores del login según tu marca
4. Implementa el SSL automático (Ubuntu 24.04 LTS recomendado)
5. Configura accesos personalizados para tu equipo

### Para Usuarios Finales

1. Familiarízate con el campo de consignados
2. Aprovecha las validaciones de caja
3. Utiliza las restricciones de fechas para evitar errores
4. Explora la nueva opción de venta itinerante
5. Revisa las tareas programadas regularmente

### Para Desarrolladores

1. Revisa la documentación de actualización
2. Utiliza el script automatizado para dependencias
3. Implementa el endpoint API de bloqueo de cuentas
4. Configura el entorno local con Laragon
5. Consulta los manuales de upgrade

---

## 📞 Soporte y Asistencia

¿Necesitas ayuda con la actualización o tienes preguntas sobre las nuevas funcionalidades?

Nuestro equipo de soporte mejorado está disponible para asistirte en:
- Migración desde PRO 7.1 a PRO 7.2
- Configuración del módulo de gestión de pagos
- Implementación de SSL automático con Cloudflare
- Configuración de consignados y GRE
- Capacitación sobre nuevas funcionalidades
- Personalización del sistema

---

## 📚 Documentación Adicional

Para más información sobre funcionalidades específicas, consulta nuestra documentación completa:

- **Manual de Actualización**: [Proceso paso a paso desde 7.0 a 7.1 o 7.2](../../../devs/despliegue/mantenimiento/06-Upgrade-Docs.md)
- **Guía de Gestión de Pagos**: Configuración del módulo completo
- **Tutorial de SSL Automático**: [Configuración con Cloudflare](../../../devs/despliegue/seguridad/ssl-cloudflare.md)
- **Documentación de Consignados**: Uso en GRE y comprobantes
- **API Documentation**: [Endpoint de control de cuentas](../../../devs/api/admin/locked-tenant/locked-tenant.api.mdx)