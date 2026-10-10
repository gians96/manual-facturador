# Agregar usuarios a mi sistema

En esta área te ayudaremos a crear usuarios para que puedan ingresar al sistema. Sigue estos pasos para realizarlo:

Ingresa al módulo de **Configuración y más** luego selecciona la subcategoría **Usuarios**. En la parte superior derecha selecciona el botón **Nuevo**.

![alt text](img/usuario1.jpg)

:::danger importante

Selecciona la opción recrear documentos si deseas permitir que tu usuario tenga la posibilidad de recrear un documento que aún este con el estado registrado.

:::

## Nuevo usuario

Aparecerá el formulario para llenar los datos del **Nuevo usuario**.

![alt text](img/usuario2.jpg)

Se completarán los siguientes datos:

* **1. Nombre:** Ingresa el nombre del nuevo usuario.
* **2. Correo electrónico:** Ingresa el correo electrónico del usuario.
* **3. Establecimiento:**  Selecciona el establecimiento en el que el usuario estará asignado.
* **4. Contraseña:**  Crea una contraseña para el usuario.
* **5. Confirmar contraseña:**  Ingresa nuevamente la contraseña para confirmarla.
* **6. Perfil:**  Selecciona el perfil del usuario.

## Permisos

En esta sección se selecciona los módulos a los que tendrá acceso el usuario creado.

![alt text](img/usuario3.jpg)

### Eliminar boletas y facturas registradas

Más abajo, en la misma pestaña **Permisos**, la sección **Comprobantes** tiene dos casillas:

* **Eliminar boletas registradas**
* **Eliminar facturas registradas**

Son independientes: puedes dejar que un usuario elimine boletas sin darle las facturas, como en
la imagen. Las dos vienen **desmarcadas para todos los usuarios**, incluido el administrador:
márcalas solo a quien deba poder borrar comprobantes.

![Sección Comprobantes: Eliminar boletas registradas marcada y Eliminar facturas registradas sin marcar](img/permisos-eliminar-comprobantes.png)

Con la casilla marcada, ese usuario ve la opción **Eliminar** en los comprobantes de ese tipo que
están en estado **Registrado**; en las boletas, además, solo si todavía no van en ningún resumen
diario ([Lista de comprobantes](../../esenciales/ventas/2-lista-de-comprobantes.md#eliminar-una-boleta-o-factura-registrada)).
Si la empresa trabaja por API, los permisos valen también para el usuario dueño del token
([Eliminar - Boleta o factura registrada](../../../devs/api/tenant/Generar-boleta/eliminar-boleta.api.mdx)).

Al guardar, el cambio se aplica de inmediato en el listado de comprobantes.

## Datos personales

En esta sección se completa con los datos personales del nuevo usuario. (Opcional)

![alt text](img/usuario4.jpg)

## Config. Documentos

En esta sección se habilita al nuevo usuario que tipo de documentos va a poder emitir y las series especificas que desee que el usuario maneje. (Opcional)

![alt text](img/usuario5.jpg)

Finalmente, una vez rellenado todos los datos selecciona el botón **Guardar**. Aparecerá la lista de usuarios creados.

![alt text](img/listadeusuarios.jpg)

:::danger importante

Una vez que creas un usuario, el correo de acceso ya no se puede cambiar. Si el usuario no ha hecho ningún tipo de movimiento, como compras o ventas, puedes eliminarlo. Pero, si ya tiene movimientos registrados, no te preocupes, ¡se puede inhabilitar!

Inhabilitar a un usuario es súper útil cuando ya no necesita acceder al sistema, pero no puedes eliminarlo porque tiene historial de transacciones. Así, el usuario no podrá acceder ni hacer nada, pero sus datos (como ventas o compras) seguirán guardados. Si más adelante necesita volver a acceder, lo puedes habilitar otra vez sin problemas.

:::
