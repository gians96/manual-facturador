---
title: Instalación de Empresas Demo
description: "Guía para activar y configurar empresas demo en el sistema Pro7"
sidebar_position: 1
---

# Instalación de Empresas Demo

:::info Información
Esta guía te ayudará a configurar las empresas demo preinstaladas en tu servidor Pro7. Las demos incluyen datos preestablecidos como productos, imágenes y configuraciones específicas para cada tipo de negocio.
:::

## Requisitos Previos

- Acceso al panel de administrador
- Permisos de administrador
- Empresas demo preinstaladas en el servidor

## Proceso de Configuración

### 1. Acceso al Panel de Administrador

1. Inicia sesión en el panel de administrador con tus credenciales
2. Navega a la sección de clientes/empresas

![Panel de Administrador](img/instalacion-demo-1.png)

### 2. Creación de Nueva Empresa Demo

1. En el listado de clientes, localiza el botón **Nuevo** en la esquina superior izquierda

![Listado de Clientes](img/instalacion-demo-2.png)

2. Al hacer clic en **Nuevo**, se abrirá el formulario de creación de empresa. Completa los datos obligatorios según la siguiente tabla:

![Formulario de Creación](img/instalacion-demo-3.png)

:::danger Importante
Recuerda que los nombres de subdominio que aparecen en la tabla son obligatorios y deben ser ingresados exactamente como se muestran. Solo debes colocar el nombre del subdominio, por ejemplo: `ferreteria`. El sistema agregará automáticamente el resto del dominio según la configuración de tu servidor. Esto es fundamental para que la demo funcione correctamente y puedas acceder sin inconvenientes.
:::

| Empresa               | Subdominio          | Correo                          | Contraseña |
| --------------------- | ------------------- | ------------------------------- | ---------- |
| Librería              | libreria            | libreria@gmail.com              | 123456     |
| Ferretería            | ferreteria          | ferreteria@gmail.com            | 123456     |
| Juguería              | jugueria            | jugueria@gmail.com              | 123456     |
| Tienda de Abarrotes   | tiendadeabarrotes   | tienda_de_abarrotes@gmail.com   | 123456     |
| Pastelería            | pasteleria          | pasteleria@gmail.com            | 123456     |
| Panadería             | panaderia           | panaderia@gmail.com             | 123456     |
| Fuente de Soda        | fuentedesoda        | fuente_de_soda@gmail.com        | 123456     |
| Carnicería            | carniceria          | carniceria@gmail.com            | 123456     |
| Restaurante Fast Food | restaurantefastfood | restaurante_fast_food@gmail.com | 123456     |
| Pollería              | polleria            | polleria@gmail.com              | 123456     |
| Cevichería            | cevicheria          | cevicheria@gmail.com            | 123456     |
| Heladería             | heladeria           | heladeria@gmail.com             | 123456     |

:::info Más Información
Para más detalles sobre la creación de clientes, consulta la documentación completa en [Crear Cuenta](../../multi-empresa/panel-admin/02-Crear-cuenta.md)
:::

### 3. Configuración de la Demo

Una vez creada la empresa, sigue estos pasos para activar la demo:

1. En el listado de clientes, localiza la empresa demo creada
2. Haz clic en los tres puntos (⋮) al final de la fila
3. Selecciona la opción **Configurar Demo**

![Menú de Configuración](img/instalacion-demo-4.png)

4. En la ventana de configuración:
   - Ubicara la opcion de **Restaurar Demo**
   - Seleccionara la demo correspondiente al tipo de negocio
   - El sistema cargará automáticamente:
     - Productos preestablecidos
     - Imágenes
     - Configuraciones específicas del negocio

![Ventana de Configuración Demo](img/instalacion-demo-5.png)

:::tip Nota
Las demos incluyen datos de ejemplo que puedes modificar según tus necesidades. Se recomienda revisar y ajustar la configuración después de la instalación.
:::

## Verificación de la Instalación

Para verificar que la demo se ha instalado correctamente:

1. Accede a la URL de la empresa demo (ejemplo: `https://libreria.tudominio.pe`)
2. Verifica que puedas iniciar sesión con las credenciales proporcionadas
3. Comprueba que los productos y configuraciones se hayan cargado correctamente
