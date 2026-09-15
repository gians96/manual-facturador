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

## Diseño del PDF de la guía (A4)

El PDF A4 de las guías de remisión se arma con **plantillas por bloques**. El orden de las secciones, los datos opcionales (vendedor, teléfonos, serie o lote de los productos, términos…) y el formato se eligen en **Configuración → Plantillas PDF → PDF - Guías de remisión**, con un usuario administrador. Cada empresa puede tener varias plantillas, usar una en toda la empresa y otra en un establecimiento concreto.

Conoce cómo hacerlo paso a paso en el artículo **[Plantillas PDF - Guías de remisión](../../configuracion-y-mas/configuracion-globales/Plantillas/Plantillas-pdf-guias.md)**.

:::info ¿Dónde quedaron los interruptores de «Datos opcionales»?
Estaban en **Configuración → Empresa → Avanzado → pestaña Extra**, tarjeta **Guías de Remisión**. Lo que tenías elegido **se conserva**: ahora son los valores de la plantilla **Predeterminada** de tu empresa, y si la duplicas la copia sale igual. En esa tarjeta queda solo el botón **Editar plantillas de guía**, que lleva al editor.
:::

:::warning Las observaciones ya no se imprimen por defecto
Desde el 14 de septiembre de 2026 el PDF A4 no imprime las **observaciones** de la guía, aunque siguen viajando a SUNAT. Si las necesitas en el papel, duplica la Predeterminada, enciende el bloque **Observaciones** y asigna esa plantilla.
:::

:::warning Si usas la plantilla «Plantilla personalizable»
En **Configuración → Plantillas PDF → PDF**, la plantilla personalizable permite **Configurar columnas del documento** por establecimiento. Ese ajuste **ya no se aplica a las guías de remisión**: sus columnas se eligen en el bloque **Bienes** de la plantilla de guía. Facturas, boletas y demás documentos de esa plantilla siguen igual.
:::
