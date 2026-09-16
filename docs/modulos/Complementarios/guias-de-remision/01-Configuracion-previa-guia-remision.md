# Configuración previa - Guía de remisión

Ingresa al módulo **Configuración y más** y en el submodulo **Configuraciones Globales** .

Debera elegir la submodulo **Empresa**, en la subcategoria **Empresa**

![Alt text](img/nuevaguia3.jpg)

Deberá completar los siguientes campos:

## Guias Electronicas

![Alt text](img/nuevaguia4.jpg)

* **SOAP Usuario:** el **RUC seguido del usuario secundario**, sin espacios ni guiones. Por ejemplo, si el RUC es `20123456789` y el usuario secundario es `MIUSUARIO`, aquí va `20123456789MIUSUARIO`. SUNAT lo exige así: con el usuario solo, el envío falla con «Error en la autenticación del usuario».
* **SOAP Password:** la clave SOL de ese usuario secundario.

:::warning Tiene que ser un usuario SECUNDARIO con permiso de guías
Que un usuario **entre al portal de SUNAT no garantiza que sirva** para enviar guías, y SUNAT responde con el mismo error que ante una clave equivocada. Caso comprobado en septiembre de 2026: con un usuario que sí entraba al portal, SUNAT contestaba «Error en la autenticación del usuario»; con un usuario secundario nuevo, creado con permisos de guías, entregó el token al instante con el mismo Client ID y la misma CLAVE.

Para crearlo:

1. Entra al portal SOL con el **usuario principal** del RUC y abre la administración de usuarios secundarios.
2. Crea el usuario y asígnale las opciones de **Guía de Remisión Electrónica**.
3. Entra una vez al portal con ese usuario: SUNAT pide cambiar la clave inicial.
4. Escríbelo aquí como RUC + usuario, con su clave nueva, y pulsa **Verificar**.
:::

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

## Comprobar las credenciales antes de emitir

En esa misma tarjeta, junto al botón **Guardar**, hay un botón **Verificar**. Pide el token a SUNAT y te
dice si lo acepta: **no emite ninguna guía** ni guarda nada, así que se puede usar mientras configuras.
Prueba lo que está escrito en pantalla, y lo que dejes vacío lo toma de lo ya guardado.

El propio botón indica el estado con su color —gris sin comprobar, verde conectado, rojo o ámbar si
falla— y, al pasar el ratón, muestra el resultado en una palabra. El icono de información de al lado
guarda la explicación y el detalle de la última comprobación. Si cambias una credencial, el botón
vuelve a gris: lo comprobado antes ya no vale.

Qué significa cada respuesta:

| Respuesta | Qué revisar |
|---|---|
| «SUNAT aceptó las credenciales» | Nada: ya puedes emitir |
| Error del **usuario SOL** | El usuario secundario: que exista, que tenga permiso de guías y que esté escrito como RUC + usuario |
| Error del **Client ID o la CLAVE** | Vuelve a copiarlos de *Credenciales de API SUNAT* |
| «No se llegó a SUNAT» | La salida a internet del servidor (proxy o cortafuegos) |

:::warning No lo repitas a ciegas
Varios intentos fallidos seguidos pueden hacer que SUNAT bloquee el usuario SOL. Corrige el dato antes de volver a probar.
:::

:::info Si tu empresa está en Demo
En Demo el sistema no habla con SUNAT, sino con un emulador de pruebas, y el botón lo indica. Ahí
comprueba que el servidor llega al emulador y que el RUC esté bien escrito, pero **no** valida tus
credenciales reales. Para eso, marca la casilla **«probar también las de producción»**: hace la consulta
contra SUNAT sin cambiar el entorno de tu empresa.
:::

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
