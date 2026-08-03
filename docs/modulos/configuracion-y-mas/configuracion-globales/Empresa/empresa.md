---
sidebar_position: 1
---

# Empresa

En este artículo te enseñaremos los pasos para configurar tu plataforma de facturación, conectarte a SUNAT y empezar a facturar:

Ingresa al módulo de **Configuración** y luego en la subcategoría **Empresa**, selecciona **Empresa**.

![Alt text](img/empresaa1.jpg)

Aparecerá lo siguiente:

## 1. Datos de la Empresa

Completa los siguientes campos:

![Datos de la Empresa](img/datosempresaa2.jpg)

- **Número:** Indica el número de identificación de tu empresa.
- **Nombre:** Ingresa el nombre de la empresa. Este campo es obligatorio.
- **Nombre Comercial:** Especifica el nombre comercial que se utilizará.
- **N° Cuenta de Detraction:** Inserta el número de cuenta de detracción si lo deseas.
- **Logo:** Puedes subir el logo de la empresa seleccionando el botón azul. Se recomienda una resolución de 700x300 píxeles.
- **Rúbrica (Firma Digital):** Sube tu firma digital usando el botón azul. Se recomienda una resolución de 700x300 píxeles.
- **Favicon (Icono Web):** Sube el favicon, que es la imagen que aparecerá en la pestaña de navegación. Se recomienda que sea una imagen con fondo transparente y cuadrada en formato PNG.
- **Título (Nombre Web):** Define el nombre que aparecerá en la pestaña del navegador al acceder a la plataforma.
- **Logo APP:** Sube un logo específico para la aplicación, utilizando el botón azul. Se recomienda un color de fondo blanco.

**Entorno del Sistema**

- **SOAP Tipo:** Cambia este valor de "Demo" a "Producción" para habilitar tu sistema.
- **SOAP Envío:** Selecciona el SOAP de envío a SUNAT.
- **SOAP Usuario y Contraseña:** Ingresa el usuario y contraseña del **usuario secundario** creado previamente.

Recuerda que al ingresar el usuario, debes agregar también el RUC como se indica en la imagen.

Después de completar todos los campos, selecciona el botón **Guardar** para aplicar los cambios.

![Alt text](img/datosempresaa3.jpg)

:::danger importante

- Al crear un usuario secundario no utilizar palabras que contengan parte de nombre
  de la empresa.

  - Ejemplo:
    - Nombre de la Empresa: Constructora Juan.
    - Usuario Secundario: CONSJUAN (Error).
    - **Usuario Secundario: C6NSJU4N (Correcto)**.

- Al generar la contraseña secundario asegúrese de usar contraseñas que
  contengan números y letras con mayúsculas, y que no usen palabras de la
  empresa. Para generarla puede utilizar herramientas externas como: **[https://www.clavesegura.org/es/](https://www.clavesegura.org/es/)**
  :::

## 2. Certificado

![Alt text](img/reportecertificado.jpg)

- Para completar la conexión con SUNAT es necesario subir el certificado digital. En esta sección adjuntamos el archivo **.pfx** que nos brinda SUNAT.

## 3. Certificado QZ-Tray

![Alt text](img/Certificado_QZ.jpg)

- Para realizar impresiónes directamente desde aplicaciones web hacia impresoras conectadas localmente.
- Esta funcionalidad elimina la necesidad de cuadros de diálogo y configuraciones adicionales, facilitando la impresión automatizada de tickets, etiquetas y otros documentos.
- Como realizar la configuracion **[Aquí](/devs/custom/impresion-automatica)**.

## 4. Servicio PSE

En caso de migrar a nuestro facturador y usar un proveedor **PSE**, coloca los accesos **aquí**.

![Alt text](img/datosempresaa5.jpg)

## 5. Consulta integrada de CPE- Validador de documentos

Se requiere configurar el validador de documentos para que ante cualquier eventualidad con SUNAT se puedan regularizar el estado de sus comprobantes. Agrega los token como en la imagen mostrada.

![Alt text](img/datosempresaa4.jpg)

## 6. Configuración de pagos

Configuración para generar el link de pago para Yape y Mercado Pago.

**Yape:** Podrá habilitar yape, seleccionando el interruptor, al activar le aparecerán los siguientes campos:

![Alt text](img/datosempresaa66.jpg)

- **Número de teléfono:** Inserta el número de teléfono que tiene registrado en yape.
- **Nombres y Apellidos:** Inserta los nombres y apellidos que están registrados en yape.
- **Adjuntar código QR (Imagen):** Inserta la imagen del código QR que te registra en yape.

Seguido, selecciona el botón **Guardar**.

- **Mercado de Pago:** Podrá habilitar Mercado Pago, seleccionando el interruptor, al activar le aparecerán los siguientes campos:

![Alt text](img/mercadolibre.jpg)

Los tokens se copiaran en su cuenta de mercado pago

Seguido, selecciona el botón **Guardar**.

## 7. Envio de mensajes a través de QR Api

Esta opción permite enviar los comprobantes generados en formato PDF utilizando un servicio de mensajería que integra QR API. Para activar esta funcionalidad, es necesario:

Habilitar la opción seleccionando "Sí".

- **A continuación, te mostramos los pasos necesarios para activar y configurar correctamente el envío de mensajes a través de QR API:**

  - 1. Inicia sesión en QR API: Ingrese su correo electrónico y su contraseña en la pantalla de inicio de sesión.

  - 2. Dashboard: Una vez dentro, podrás ver todos tus dispositivos registrados y el estado de cada uno.

  - 3. Agregar Dispositivo: Haz clic en "Nuevo" e ingresa el nombre del dispositivo y el número de teléfono móvil que deseas vincular.

  - 4. Escanea el Código QR: Sigue las instrucciones en la pantalla para escanear el código QR con la aplicación de WhatsApp en tu móvil.

  - 5. Ver detalles del dispositivo: Luego de escanear el código QR, tendrás que redirigirte a la página de detalles del dispositivo, donde podrás ver la información del número registrado, su estado, y el API Token necesario para integrarlo, esto se hace dándole clik a tu numero.

  - 6. Utiliza el API Token: Copia el API Token mostrado en la pantalla. Este será necesario para realizar las integraciones de mensajería con tu sistema.

  - 7. Ingresa la URL de la página del servicio, que será proporcionada por QR API al registrarte. La URL es la dirección web específica donde se llevará a cabo la integración.

- **Posterior a los pasos antes mencionados**

  Ingresar la URL del Cliente y el API Key proporcionados por el servicio QR API.

![Alt text](img/datosempresaa33.jpg)

:::danger importante

Recuerde que debe registrarse en el servicio antes de usar esta opción para obtener las credenciales necesarias.
:::
