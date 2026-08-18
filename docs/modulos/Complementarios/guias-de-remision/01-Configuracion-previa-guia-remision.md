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
