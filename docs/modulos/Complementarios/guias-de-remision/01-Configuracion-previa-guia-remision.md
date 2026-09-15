# Configuración previa - Guía de remisión

Ingresa al módulo **Configuración y más** y en el submodulo **Configuraciones Globales** .

Debera elegir la submodulo **Empresa**, en la subcategoria **Empresa**

![Alt text](img/nuevaguia3.jpg)

Deberá completar los siguientes campos:

## Guias Electronicas

![Alt text](img/nuevaguia4.jpg)

* **SOAP Usuario:** Para completar este campo, coloque el usuario secundario creado al configurar su cuenta por primera vez.
* **SOAP Password:**  Para completar este campo,  coloque la contraseña del usuario secundario creado al configurar su cuenta por primera vez.

:::danger importante

Para llenar **Client ID** y **Client Secret (Clave)** debe ingresar a la plataforma SUNAT con la clave **SOL**.

:::

Al ingresar a SUNAT, seleccionamos **Credenciales de API SUNAT/ Credenciales de API SUNAT/ Credenciales de API SUNAT** y por último **Gestión Credenciales de API SUNAT**.

![Alt text](img/nuevaguia5.jpg)

Para registrar la aplicación, tendrá que completar:

![Alt text](img/nuevaguia8.jpg)

* **Nombre de su aplicación:** Ingresa el nombre de su aplicación. Por ejemplo: Factura fácil.
* **URL de su aplicación:** Ingresa la URL de su aplicación. Por ejemplo: https://tudominio.pe
* **Casillas de selección:** Selecciona la casilla GREE Emision de Comprobantes/v1/contribuyente/gem.
* **Alcance:** Selecciona la casilla Desktop.
Después selecciona el botón **Guardar**, se generará un token en los campos **ID** y **CLAVE**.

![Alt text](img/nuevaguia10.jpg)

Copiamos esos accesos y lo pegamos en:

* **SOAP Usuario:** Para completar este campo, coloque el usuario secundario creado al configurar su cuenta por primera vez.
* **SOAP Password:**  Para completar este campo,  coloque la contraseña del usuario secundario creado al configurar su cuenta por primera vez.
* **ID -> Client ID**
* **CLAVE -> Client Secret (Clave)**

![Alt text](img/nuevaguia.jpg)

Selecciona el botón **Guardar** y ya puede generar su guía. Conoce como en el siguiente **[artículo](./05-Generar-guias-de-remision.md)**.

## Datos opcionales del PDF de la guía (A4)

Cada empresa decide qué datos **internos** salen en el PDF A4 de sus guías de remisión. Ingresa al módulo **Configuración**, subcategoría **Empresa**, selecciona **Avanzado** y abre la pestaña **Extra**. En la tarjeta **Guías de Remisión** está el bloque **Datos opcionales del PDF de la guía (A4)**, con un interruptor por dato. Se guarda al cambiarlo.

| Interruptor | Encendido de fábrica |
|---|---|
| Vendedor | Sí |
| Teléfono del destinatario | Sí |
| Serie de los productos | Sí |
| Modelo de los productos | Sí |
| Marca de los productos | Sí |
| Lote de los productos | Sí |
| Vencimiento de los productos | Sí |
| Referencias internas | Sí |
| Campos personalizados | Sí |
| Términos y condiciones | Sí |
| Marca y modelo del vehículo | No |
| Teléfono del conductor | No |

Los valores de fábrica reproducen el PDF de siempre. Una columna de productos solo aparece si está encendida **y** algún producto de la guía tiene ese dato.

:::info Lo que viaja a SUNAT siempre se imprime
Solo se pueden ocultar datos que no forman parte de la guía enviada a SUNAT. El destinatario, el transportista con su registro MTC y su autorización especial, los vehículos con su TUC, los conductores y los documentos relacionados salen siempre.

Vendedor, teléfono del destinatario, referencias internas y campos personalizados solo aplican a la guía remitente: la guía de transportista nunca los imprimió. Los tickets no cambian.
:::

:::warning Si usas la plantilla «Plantilla personalizable»
En **Configuración → Plantillas PDF → PDF**, la plantilla personalizable permite **Configurar columnas del documento** por establecimiento. Ese ajuste **ya no se aplica a las guías de remisión**: las guías de todas las plantillas usan el mismo diseño y se gobiernan con los interruptores de esta tarjeta, que son por empresa. Facturas, boletas y demás documentos de esa plantilla siguen igual.
:::
