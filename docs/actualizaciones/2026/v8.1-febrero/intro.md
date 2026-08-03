---
slug: /v8.1
---

# PRO 8.1 - Febrero

## Introducción

**PRO 8.1** marca un hito importante en la evolución del Facturador, enfocándose en optimización de inventarios, mejoras en la gestión de productos y cumplimiento normativo actualizado. Esta versión introduce funcionalidades clave como traslados masivos por Excel, mejoras sustanciales en el sistema de presentaciones de productos y actualización del IGV para sectores específicos según normativa SUNAT.

Con un enfoque en la eficiencia operativa y la experiencia del usuario, PRO 8.1 representa una solución integral para empresas que requieren mayor control sobre sus inventarios y operaciones comerciales.

---

## 🎯 Características Principales Destacadas

### 1. **Traslados Masivos mediante Excel**

Sistema revolucionario para gestionar traslados de inventario en grandes volúmenes, optimizando operaciones logísticas.

### 2. **Mejoras en Presentaciones de Productos**

Rediseño completo del sistema de unidades, factores y presentaciones para mayor flexibilidad y precisión.

### 3. **Actualización IGV Hoteles y Restaurantes**

Implementación del cambio de IGV al 10.5% según normativa SUNAT para sectores específicos.

### 4. **Sistema de Etiquetas de Precio Mejorado**

Nueva gestión de etiquetas personalizables con soporte API completo.

### 5. **Optimizaciones en POS y Restaurante**

Mejoras significativas en el punto de venta y módulo de restaurante con nuevas funcionalidades.

---

## 📊 Resumen de Actualizaciones

### ✨ Nuevas Funcionalidades (Features)

| Categoría           | Cantidad | Destacados                                         |
| ------------------- | -------- | -------------------------------------------------- |
| **Inventarios**     | 8        | Traslados masivos Excel, gestión de lotes mejorada |
| **Productos**       | 12       | Presentaciones rediseñadas, campos personalizados  |
| **Etiquetas**       | 5        | API de etiquetas, diseño customizable              |
| **POS/Restaurante** | 7        | Impresión automática, SSE para cocina              |
| **UI/UX**           | 18       | Temas mejorados, responsive mobile                 |
| **Reportes**        | 4        | Consulta de documentos con totales USD             |
| **Configuraciones** | 6        | Campos personalizados, afectaciones IGV            |

### 🐛 Correcciones Críticas (Fixes)

| Categoría             | Cantidad | Destacados                                     |
| --------------------- | -------- | ---------------------------------------------- |
| **Precios**           | 6        | Decimales, cambios rápidos, valores originales |
| **Documentos**        | 8        | Cliente "Varios", filtros, conversiones        |
| **Órdenes de Compra** | 3        | Productos, direcciones proveedores             |
| **Lotes**             | 2        | Validación regeneración items                  |
| **Stock**             | 3        | Costo ponderado, presentaciones                |
| **Restaurante**       | 4        | Productos con receta, insumos                  |

### 🎨 Mejoras de Interfaz (UI/Style)

| Categoría       | Mejoras                                          |
| --------------- | ------------------------------------------------ |
| **Temas**       | Light, Dark, Modern, Black con colores dinámicos |
| **Responsive**  | Optimización tablets y móviles                   |
| **Componentes** | Sidebar, dialogs, formularios mejorados          |
| **Dashboard**   | Panel de bienvenida rediseñado                   |

---

## 🚀 Funcionalidades Destacadas en Detalle

### 1. 📦 Traslados Masivos mediante Excel

Gestión eficiente de grandes volúmenes de traslados de inventario utilizando archivos Excel.

#### Características Principales

**Importación Masiva**

- 📋 Carga de múltiples traslados desde archivo Excel
- ✅ Validación automática de datos
- 🔍 Verificación de stock disponible
- 📊 Reporte de errores y advertencias

**Diseño de Plantilla Excel**

- 📝 Plantilla estandarizada con campos obligatorios
- 🎨 Diseño mejorado y más intuitivo
- 📥 Descarga de plantilla desde el sistema
- 💡 Ejemplos incluidos para facilitar uso

#### Funcionalidades del Módulo

**Proceso de Traslado**

```
1. Descarga plantilla Excel
2. Completa información de productos y cantidades
3. Selecciona almacenes origen y destino
4. Carga archivo al sistema
5. Valida y procesa traslados
```

**Validaciones Implementadas**

- ✅ Verificación de códigos de productos
- ✅ Control de stock suficiente
- ✅ Validación de almacenes válidos
- ✅ Verificación de lotes (si aplica)
- ✅ Control de unidades de medida

**Nueva Vista de Traslados**

- 🔄 Cambio de vistas entre traslados individuales y masivos
- 📊 Visualización mejorada de operaciones
- 🔍 Filtros avanzados por fecha, almacén, usuario
- 📈 Estadísticas de traslados realizados

#### Beneficios

- ⚡ Reducción de tiempo en traslados de inventario
- 📉 Minimización de errores humanos
- 📊 Trazabilidad completa de operaciones
- 💼 Ideal para empresas con múltiples sucursales

:::tip Casos de Uso Recomendados

**Traslados Masivos Excel son ideales para:**

- Redistribución de inventario entre sucursales
- Consolidación de stock al final del mes
- Traslados programados de productos de temporada
- Ajustes de inventario en múltiples almacenes
- Apertura de nuevas sucursales

:::

---

### 2. 🏷️ Mejoras en el Sistema de Presentaciones de Productos

Rediseño completo del módulo de presentaciones para mayor flexibilidad y control sobre unidades y factores de conversión.

#### Actualización del Flujo de Presentaciones

**Nueva Gestión de Precios**

- 🔄 Flujo completamente rediseñado
- 📊 Tabla de gestión de precios en lugar de listado simple
- 🎨 Labels customizables para cada nivel de precio
- ⚙️ Mayor control sobre factores de conversión

**Campos Editables Mejorados**

- ✏️ Edición de unidad, descripción y factor
- 🔢 Validación automática de factores
- 📝 Descripciones personalizables por presentación
- ✅ Control de integridad de datos

#### Sistema de Unidades y Factores

**Factores de Conversión**

- 🔢 Factor personalizable para cada presentación
- 📐 Cálculo automático de equivalencias
- 🔄 Conversión bidireccional entre unidades
- ✅ Validaciones para evitar inconsistencias

**Unidades de Medida**

- 📏 Unidad base configurable
- 📦 Unidades de presentación flexibles
- 🔀 Conversión automática en documentos
- 📊 Reportes considerando factores

#### Labels Personalizados para Precios

**Configuración Flexible**

- 🏷️ Labels personalizados agregados
- 🎨 Nombres customizables (Precio 1, Precio 2, Precio Mayorista, etc.)
- 💾 Guardado por configuración del sistema
- 🔄 Aplicación inmediata en todo el sistema

**Aplicación en Módulos**

- 🛒 POS muestra labels personalizados
- 📄 Documentos reflejan nomenclatura configurada
- 📊 Reportes con etiquetas personalizadas
- 🔍 Búsqueda por nombre de precio

#### Correcciones de Presentaciones

- ✅ Error en label de presentación en vista de stocks corregido
- ✅ Validación de factores en edición
- ✅ Sincronización correcta con inventario
- ✅ Cálculo preciso en conversiones

:::info Ejemplo de Uso

**Producto: Aceite de Cocina**

Presentación Base:

- Unidad: Litro (L)
- Precio Base: S/ 10.00

Presentaciones Adicionales:

- Caja x 12 L (Factor 12) → Precio: S/ 115.00 (5% descuento)
- Pallet x 48 cajas (Factor 576) → Precio: S/ 5,200.00 (10% descuento)

Con labels personalizados:

- Precio al por Menor
- Precio Distribuidor
- Precio Mayorista
  :::

---

### 3. 📊 Actualización IGV 10.5% para Hoteles y Restaurantes

Implementación del cambio de IGV según normativa SUNAT para sectores específicos.

#### Normativa SUNAT

**Cambio Regulatorio**

- 📜 Ley que establece IGV reducido al 10.5%
- 🏨 Aplicable a servicios de hospedaje
- 🍽️ Aplicable a servicios de restaurante
- 📅 Vigencia según calendario tributario

#### Implementación en el Sistema

**Configuración de Afectación**

- ⚙️ Listado de afectaciones para items en configuraciones
- 🔧 Selector de tipo de afectación por producto
- ✅ Aplicación automática del 10.5% cuando corresponde
- 📋 Configuración por defecto para nuevos productos

**Afectación "Sujeta al IGV"**

- 🔄 Cambio a 10.5% implementado
- ✅ Validaciones adicionales
- 🔍 Control de errores en direcciones de proveedor

#### Aplicación por Sector

**Hoteles**

- 🏨 IGV 10.5% en servicios de alojamiento
- 🛏️ Aplicable a habitaciones y servicios relacionados
- 📊 Cálculos automáticos en facturación
- 📄 Comprobantes con tasa correcta

**Restaurantes**

- 🍽️ IGV 10.5% en consumos
- 🍕 Aplicación en POS de restaurante
- 📱 Comandas con impuesto correcto
- 🧾 Tickets con desglose adecuado

#### Configuración por Defecto

**Descuento Global**

- ⚙️ Configuración que afecta la base como default
- 💰 Descuentos aplicados antes del IGV
- 📊 Cálculo correcto de base imponible
- ✅ Validación de configuraciones

:::warning Importante - Configuración IGV

El sistema permite configurar diferentes tasas de IGV:

- **18%**: Tasa general (por defecto)
- **10.5%**: Hoteles y restaurantes (configurable por producto)
- **Exonerado**: Productos sin IGV
- **Inafecto**: Operaciones no gravadas

Asegúrate de configurar correctamente la afectación de cada producto según tu sector y la normativa vigente.
:::

---

### 4. 🏷️ Sistema de Etiquetas de Precio Mejorado

Gestión completa de etiquetas de precio con personalización avanzada y soporte API.

#### Nueva API de Etiquetas

**Endpoint de Listado**

```
GET /api/price-labels
- Retorna todas las etiquetas de precio configuradas
- Incluye información de productos y precios
- Filtrado por categorías y almacenes
```

**Funcionalidades API**

- 📋 Listado completo de etiquetas
- 🔍 Filtrado avanzado por múltiples criterios
- 📊 Información detallada de cada producto
- 🔄 Sincronización en tiempo real

#### Mejoras en la Interfaz

**Exportación Mejorada**

- 📥 Actualización en exportar archivo de etiquetas
- 📄 Múltiples formatos disponibles (PDF, Excel)
- 🎨 Diseños personalizables
- 📦 Exportación masiva optimizada

**Diseño de Etiquetas**

- 🎨 Plantillas customizables
- 🖼️ Soporte para logos e imágenes
- 📐 Tamaños estándar y personalizados
- 🖨️ Optimización para impresión

#### Correcciones Implementadas

- ✅ Error al generar etiquetas corregido
- ✅ Parseo de símbolos extraños solucionado
- ✅ URL correcta para imágenes
- ✅ Datos del sistema integrados

:::tip Uso de Etiquetas de Precio

**Casos de uso recomendados:**

- Impresión de etiquetas para góndolas
- Etiquetas con códigos de barras
- Precios de ofertas y promociones
- Etiquetas para inventario físico
- Señalización de punto de venta
  :::

---

### 5. 🍽️ Optimizaciones en POS y Módulo de Restaurante

Mejoras significativas en el punto de venta y funcionalidades específicas para restaurantes.

#### Restaurante - Impresión Automática

**Servicio de Impresión Configurable**

- 🖨️ Impresión automática de PDF en comandas
- ⚙️ Configuración para habilitar/deshabilitar
- 📄 Plantillas personalizables por tipo de documento
- 🔄 Proceso automático al confirmar pedido

**Configuraciones de Impresión**

- ✅ Activar/desactivar impresión automática
- 📱 Impresión directa a cocina
- 🧾 Tickets de consumo automáticos
- 📋 Comandas con formato optimizado

#### SSE para Cocina

**Server-Sent Events**

- 🔔 Notificaciones en tiempo real a cocina
- 📡 Actualización automática de pedidos
- ⚡ Sin necesidad de recargar página
- 🔄 Sincronización entre estaciones

**Requerimientos Técnicos**

- ⚙️ Configuración de servidor SSE
- 🔧 Endpoints dedicados para eventos
- 📊 Panel de monitoreo de conexiones
- ✅ Fallback para conexiones inestables

#### Mejoras en Flujo de Pedidos

**Optimización de Eventos**

- 🔄 Ajuste para no perder el primer evento
- ✅ Validación por cambio de campo
- 📊 Mejor control de estados
- ⚡ Respuesta más rápida

#### Productos con Receta e Insumos

**Sistema de Recetas**

- 🍳 Checkbox para productos con receta
- 📝 Gestión de insumos asociados
- ⚙️ Habilitación/deshabilitación de insumos
- 🔒 Validaciones específicas

**Correcciones Implementadas**

- ✅ Ocultar checkbox en productos compuestos
- ✅ Ocultar input de unidad en recetas
- ✅ Validaciones corregidas para recetas
- ✅ Flujo optimizado de creación

**Reestructuración del Formulario**

- 🎨 Formulario rediseñado para productos con insumos
- 📋 Campos organizados de forma lógica
- ✅ Validaciones mejoradas
- 💡 Mejor experiencia de usuario

#### POS General

**Historial y Edición**

- 📊 Historial de ventas por producto
- ✏️ Edición de productos desde POS
- 🏷️ Etiquetas de precios integradas (feature)
- 🔍 Búsqueda rápida mejorada

**Tiempo en Comanda**

- ⏰ Permitir enviar tiempo de creación
- 📊 Control de tiempos de preparación
- 🔔 Alertas por demora
- 📈 Reportes de eficiencia

:::info Configuración Recomendada para Restaurantes

**Para máximo rendimiento:**

1. Habilitar SSE para notificaciones en tiempo real
2. Configurar impresión automática de comandas
3. Utilizar productos con receta para control de insumos
4. Activar historial de ventas para análisis

**Beneficios:**

- ⚡ Servicio más rápido
- 📊 Mejor control de inventario
- 🔍 Trazabilidad completa
- 💰 Reducción de mermas
  :::

---

### 6. 🎨 Mejoras Masivas en UI/UX

Rediseño significativo de la interfaz con múltiples temas y optimización responsive.

#### Temas Mejorados

**Tema Light**

- ☀️ Mejoras visuales completas
- 🎨 Paleta de colores optimizada
- 📱 Mejor contraste y legibilidad
- ✅ Consistencia en todos los módulos

**Tema Modern**

- ✨ Actualizaciones estéticas
- 🎯 Diseño más limpio y moderno
- 📊 Mejor organización visual
- 🔄 Transiciones suaves

**Tema Black con Colores Dinámicos**

- 🌙 Colores dinámicos configurables
- 🎨 Paleta de colores personalizable
- ⚡ Mejor experiencia en modo oscuro
- ✅ Restauración de colores originales cuando sea necesario

#### Sidebar Optimizado

**Modos de Sidebar**

- 🎨 Sidebar modo light y dark agregado
- 📏 Selector de margen configurable
- 🏢 Selector de sucursal opcional integrado
- 🔧 Personalización completa

**Mejoras de Estilo**

- ✨ Mejoras en modo dark del selector de sucursal
- 🎯 Mejor visibilidad de opciones
- 📱 Adaptación responsive
- ✅ Corrección de colores en temas light y modern

#### Responsive Mobile y Tablets

**Optimización Móvil**

- 📱 Mejoras para tablets y móviles
- 🔧 Dialogs y formularios responsive
- 📊 Adaptación de tablas y listados
- ✅ Experiencia touch optimizada

**Componentes Adaptados**

- 📋 Formularios más accesibles
- 🔍 Búsquedas optimizadas
- 📊 Gráficos responsive
- 🎯 Navegación mejorada

#### Dashboard y Panel de Bienvenida

**Panel de Bienvenida Rediseñado**

- 🎨 Mejoras en UI del dashboard
- 📊 Información más clara y organizada
- 🎯 Accesos rápidos optimizados
- 📈 Gráficos interactivos mejorados

:::tip Personalización de Interfaz

**Recomendaciones por tipo de uso:**

**Oficina / Día:**

- Tema Light o Modern
- Sidebar modo light
- Colores suaves para reducir fatiga visual

**Trabajo Nocturno:**

- Tema Black
- Colores dinámicos personalizados
- Reducción de brillo en elementos

**Dispositivos Móviles:**

- Sidebar con margen reducido
- Selector de sucursal compacto
- Formularios optimizados para touch
  :::

---

## 🔧 Otras Mejoras Importantes

### Gestión de Documentos

**Cliente "Varios" Mejorado**

- ✅ Filtro para seleccionar tipo de documento
- ✅ Error al establecer cliente corregido
- ✅ Validación mejorada de datos

**Conversión de Documentos**

- ✏️ Botón de editar en oportunidades de venta y pedidos
- 💰 Condición de pago al contado por defecto en notas de venta
- 🔄 Notas rechazadas pueden regenerarse con anulación de operación

**Reportes de Documentos**

- 💵 Cálculo de totales en dólares en consulta de documentos
- ✅ Errores corregidos en reportes de guías

### Gestión de Precios

**Correcciones de Precios**

- ✅ Valores decimales en listado de precios corregidos
- ✅ Error en cambio rápido de precios solucionado
- 🎨 Interfaz de listado mejorada

### Optimizaciones de Inventario

**Costo Ponderado**

- ✅ Error cuando stock no existe para item nuevo corregido
- ✅ Cálculo de stock anterior siempre en positivo

**Gestión de Lotes**

- ✅ Validación mejorada al regenerar items
- 🔄 Conversión de nota de venta a factura preserva lotes

**Información de Stock**

- 📊 API incluye información de stock en almacenes
- 🏢 Visualización por ubicación

### Configuraciones Avanzadas

**Campos Personalizados**

- ⚙️ Módulo de campos personalizados en configuración avanzada
- 📝 Creación de campos custom aplicables a documentos y POS

**Atributos Extra**

- 📝 Campo "Atributo extra" visible en cotizaciones plantilla A4

### Gestión de Usuarios

**Multiusuario**

- 🔧 Middleware del módulo optimizado
- ⏰ Aumento de tiempo de vida del cache de auto login

### Órdenes de Compra

- ✅ Error al editar productos en órdenes corregido
- ✅ Direcciones de proveedor actualizadas correctamente

### E-commerce

- ✅ Registro de invitados mejorado
- ✅ Modal de inicio de sesión corregido

### Plantillas y PDFs

**Plantillas Oficiales**

- 📄 Plantillas default y marca de agua
- ✅ Fallback para plantillas no reconocidas
- ✅ Comando para generar plantillas tenant

---

## 💡 Recomendaciones de Implementación

### Para Administradores

**Configuración Inicial**

1. ✅ Configurar traslados masivos y descargar plantilla Excel
2. ✅ Revisar y ajustar sistema de presentaciones de productos
3. ✅ Verificar configuración de IGV (10.5% para hoteles/restaurantes)
4. ✅ Personalizar labels de precios según necesidad
5. ✅ Configurar etiquetas de precio y plantillas

**Módulo Restaurante**

1. ✅ Habilitar SSE para notificaciones en tiempo real
2. ✅ Configurar impresión automática de comandas
3. ✅ Configurar productos con receta e insumos
4. ✅ Activar tiempo de creación en comandas

**Personalización UI**

1. ✅ Seleccionar tema según preferencia (Light/Dark/Modern/Black)
2. ✅ Configurar sidebar y margen
3. ✅ Activar selector de sucursal si se requiere
4. ✅ Ajustar colores dinámicos en tema Black

### Para Usuarios Finales

**Operaciones Diarias**

1. ✅ Utilizar traslados masivos para operaciones grandes
2. ✅ Aprovechar labels personalizados de precios
3. ✅ Verificar afectación IGV en productos
4. ✅ Usar cliente "Varios" correctamente
5. ✅ Generar etiquetas de precio cuando sea necesario

### Para Desarrolladores

**Integraciones API**

1. ✅ Implementar API de etiquetas de precio
2. ✅ Utilizar endpoint de información de stock
3. ✅ Integrar búsqueda de productos con datos completos
4. ✅ Aprovechar campos personalizados
5. ✅ Implementar SSE para tiempo real
