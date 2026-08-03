# Manual de Usuario - Facturador

Este repositorio contiene la documentación oficial y el manual de usuario del **Facturador** (sistema de facturación electrónica). El sitio está construido con [Docusaurus](https://docusaurus.io/).

## 🌐 Sitio En Vivo

Puedes acceder al manual desplegado en: [https://manual.pro8.uio.la](https://manual.pro8.uio.la)

---

## 🛠️ Desarrollo Local

### Instalación

Se recomienda el uso de **npm** para la gestión de dependencias:

```bash
npm install
```

### Ejecutar servidor de desarrollo

```bash
npm run start
```

Este comando inicia un servidor local en `http://localhost:3000`. La mayoría de los cambios se reflejan en tiempo real.

---

## 🏗️ Construcción y Despliegue

### Build

Genera el contenido estático en la carpeta `build/`:

```bash
npm run build
```

### Deploy (GitHub Pages)

Para desplegar la versión más reciente en la rama `gh-pages`:

```bash
npm run deploy
```
