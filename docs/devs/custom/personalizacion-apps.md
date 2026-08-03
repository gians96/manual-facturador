---
title: Personalización de Apps
sidebar_position: 1
---

import DocsCard from '/src/components/global/DocsCard';
import DocsCards from '/src/components/global/DocsCards';

# Personalización de Mozo y VendeYA

:::info En Construcción
Información técnica para la personalización de las aplicaciones web de Mozo y VendeYA para revendedores y desarrolladores.
:::

## Introducción

Esta guía detalla el proceso de personalización de las aplicaciones web de Mozo y VendeYA para revendedores y desarrolladores.

---

## Personalización del Logo

### Requisitos Previos

- Carpeta comprimida de Mozo o VendeYA (proporcionada al obtener el repositorio compilado)
- Logos en formato **SVG** (recomendado) o PNG de alta resolución
- Versiones del logo:
  - **Light mode**: Logo para fondos claros
  - **Dark mode**: Logo para fondos oscuros

### Estructura de Archivos

Al descomprimir la carpeta de Mozo o VendeYA, encontrarás la siguiente estructura:

```
compilado/
├── imagenes/
│   └── logos/
│       ├── logo-light.svg
│       ├── logo-dark.svg
│       ├── logo-light-old.svg (backup) <--- Logo original
│       └── logo-dark-old.svg (backup) <--- Logo original
```

### Pasos para Cambiar el Logo

1. **Descomprimir la carpeta**
   - Extrae el contenido de la carpeta comprimida que recibiste

2. **Navegar a la ubicación de los logos**

```
   carpeta-app/ → imagenes/ → logos/
```

3. **Respaldar logos originales** (opcional pero recomendado)
   - Renombra los logos existentes agregando un sufijo:
     - `logo-light.svg` → `logo-light-old.svg`
     - `logo-dark.svg` → `logo-dark-old.svg`

4. **Reemplazar con tus nuevos logos**
   - Coloca tus logos personalizados con los nombres exactos:
     - `logo-light.svg` (para modo claro)
     - `logo-dark.svg` (para modo oscuro)

5. **Verificar formato**
   - Asegúrate de que los logos estén en formato **SVG** para mejor calidad
   - Si usas PNG, utiliza resoluciones altas (mínimo 300x300 px)

### Subir a cPanel

Una vez realizados los cambios:

1. Comprime nuevamente la carpeta
2. Accede a tu cPanel
3. Sube los archivos al directorio correspondiente
4. Completa el proceso de instalación siguiendo la guía correspondiente:

<DocsCards>
  <DocsCard 
    header="Guía Instalación Mozo" 
    href="/devs/despliegue/plataformas/mozo-cpanel"
  >
    <p>Manual completo para desplegar Mozo en cPanel.</p>
  </DocsCard>

<DocsCard
header="Guía Instalación VendeYA"
href="/devs/despliegue/plataformas/vendeya-cpanel"

>

    <p>Manual completo para desplegar VendeYA en cPanel.</p>

  </DocsCard>
</DocsCards>

### Resultado

Los nuevos logos se mostrarán en:

- **Pantalla de login**: Versión light/dark según el tema del navegador
- **Panel principal**: Header y navegación del sistema
- **Versión móvil**: Todas las vistas de la aplicación

## Notas Importantes

- Los logos deben mantener proporciones adecuadas (se recomienda formato horizontal)
- El formato SVG garantiza mejor calidad en cualquier resolución
- Ambas versiones (light/dark) son obligatorias para una experiencia visual óptima
- Los cambios se reflejan inmediatamente después de la instalación
