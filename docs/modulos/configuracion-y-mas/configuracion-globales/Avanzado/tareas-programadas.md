---
sidebar_position: 1
---

# ¿Qué son las Tareas Programadas?

Las tareas programadas son procesos automatizados que se ejecutan en horarios específicos para mantener y optimizar tu sistema sin intervención manual. Permiten automatizar tareas repetitivas y críticas como respaldos, envíos a SUNAT, y mantenimiento de datos.

---

::alert{type="info"}

Si quieres saber como programar envio de Facturas, Boletas y Guías de Remisión, puedes hacer clic \*\*\*\*.

::

## 📋 Tareas de Gestión de Datos

### Rellenar datos para Información de libro de cuentas

Genera automáticamente la información contable del libro de cuentas según los comprobantes registrados en el período.

### Backup de la base de datos

Crea copias de seguridad de tu base de datos de forma individual por empresa o completa para proteger toda tu información.

### Obtener archivos generados en ZIP

Comprime y descarga los archivos generados en el sistema (reportes, comprobantes, etc.) de forma individual o completa.

### Restaurar base de datos demo desde archivo SQL

Restaura la base de datos de demostración a partir de un archivo SQL previamente guardado.

### Actualización de filtros de los productos

Recalcula y actualiza automáticamente los filtros de búsqueda y categorización de productos en el sistema.

### Regularizar costo ponderado de los productos

Recalcula el costo ponderado de inventario según las transacciones de compra y venta registradas.

---

## 🔐 Tareas de Seguridad y Administración

### Cambiar contraseñas de los tenants

Modifica las contraseñas de acceso de los usuarios del sistema de forma masiva o individual.

### Validación de certificado digital

Verifica que los certificados digitales (firma electrónica) sean válidos y estén vigentes.

### Guardar data respecto a datos del servidor

Registra y almacena información de configuración y datos del servidor para auditoría.

---

## 📊 Tareas de Reportes y Cambios

### Generar changelog

Crea un registro detallado de todos los cambios realizados en el sistema para auditoría e historial.

### Consultar todos los documentos anulados

Obtiene un listado de todos los comprobantes que han sido anulados en el período especificado.

### Consultar el estado de los documentos

Verifica el estado actual de todos los documentos (emitidos, pendientes, rechazados, etc.).

---

## 🛠️ Tareas de Operación

### Recrear nota de ventas con recurrencia

Genera automáticamente notas de venta periódicas basadas en patrones recurrentes configurados.

### InsertStartBillingCycleForClient

Inicia un nuevo ciclo de facturación para clientes con suscripciones o planes mensuales.

### PaymentOrderCommand

Procesa órdenes de pago pendientes y actualiza estados de transacciones.

### Consultar documentos a otro URL en modo offline

Obtiene documentos desde un servidor alterno cuando el modo offline está activado.

### Enviar los documentos hacia el servidor offline

Sincroniza los comprobantes hacia el servidor de respaldo para garantizar disponibilidad sin internet.

---

## 🗂️ Tareas de Guías

### Consultar guías

Obtiene el listado de guías de remisión registradas en el sistema.

### Enviar guías a SUNAT

Transmite automáticamente las guías de remisión electrónicas hacia la plataforma SUNAT para validación oficial.

---

## 📤 Tareas de Envío a SUNAT

### Para enviar facturas a SUNAT

Envía automáticamente las facturas electrónicas al sistema de SUNAT para su validación y registro oficial. Solo envía las que siguen dentro de los **Días de plazo de envío**: las vencidas quedan registradas para que SUNAT no las rechace. Además, el servidor reintenta cada 2 horas las que fallaron porque SUNAT no respondió ([más detalle](../../../../guias-adicionales/tareas-programadas/envio-facturas-automatico.md)).

> **Nota:** Configura los horarios preferentes para evitar picos de envío. SUNAT recomienda usar horarios fuera de punta.

### Para enviar boletas a SUNAT

Transmite automáticamente las boletas electrónicas hacia SUNAT garantizando su correcto registro en el sistema tributario.

> **Nota:** Las boletas se envían en lotes. Asegúrate de que no haya errores de validación antes de programar esta tarea.

### Consulta de resúmenes a SUNAT

Verifica el estado de los resúmenes diarios de boletas y facturas que fueron enviados a SUNAT.

### Envío de resúmenes a SUNAT

Transmite automáticamente los resúmenes diarios consolidados de documentos hacia la plataforma de SUNAT.

### Enviar a SUNAT con el servidor offline

Sincroniza y envía documentos a SUNAT incluso cuando el servidor está en modo offline, usando el servidor de respaldo.

---

## 💾 Tareas de Respaldo y Recuperación

### Backup de la demo

Crea un respaldo completo del entorno de demostración para proteger la configuración de pruebas.

### Restaurar los datos de la demo

Recupera la base de datos de demostración a su estado anterior desde un backup guardado.

### Restaurar backup temporal de demo

Restaura un backup temporal de la demo creado en un período reciente.

---

## 🔍 Tareas de Búsqueda y Consulta

### SearchMostUsedAffectationIgvTypes

Identifica automáticamente los tipos de afectación IGV más utilizados en tus documentos para optimizar configuraciones.

---

## ⚙️ Recomendaciones de Configuración

- **Horarios recomendados:** Configura tareas críticas (backups, SUNAT) en horarios fuera de pico (madrugada/fin de semana)
- **Frecuencia:** Establece backups diarios para máxima protección de datos
- **Monitoreo:** Revisa regularmente el estado de las tareas programadas en el registro de ejecución
- **Respaldo offline:** Activa respaldos automáticos en servidor alterno para continuidad de negocio

## Anexo: ¿Cómo programar el envío de Facturas, Boletas y Guías de Remisión?

Enviar Facturas : **Para enviar facturas a SUNAT** seguir el siguiente manual **[Envío automático de facturas](../../../../guias-adicionales/tareas-programadas/envio-facturas-automatico.md)**

Enviar Boletas : **Para enviar boletas a SUNAT** seguir el siguiente manual **[Envio de Boletas automatico](../../../../guias-adicionales/tareas-programadas/envio-boletas-automatico.md)**

Enviar Guías de Remisión : **Para enviar guías de remisión a SUNAT** seguir el siguiente manual **[Envio de Guías de Remisión automatico](../../../../guias-adicionales/tareas-programadas/envio-guias-remision-automatico.md)**
