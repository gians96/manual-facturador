# Creacion de Vehículos

En este artículo te enseñaremos a como crear vehículos para tu guía de remisión. Sigue estos pasos para realizarlo:

Ingresa al módulo de **Guias de Remisión** y luego selecciona la subcategoría **Vehículos**. En la parte superior derecha selecciona el botón **Nuevo**.

![Alt text](img/modulovehihiculos.jpg)

Completa los siguientes campos para crear un nuevo vehículo:

![Alt text](img/modulovehihiculos2.jpg)

**1. Nro. de Placa:** Inserta el nro. de la placa. Puedes escribirla como se lee, con guion
(`ABC-123`): el sistema la guarda en el formato que exige SUNAT, **en mayúsculas y sin guiones ni
espacios** (`ABC123`), y te lo muestra debajo del campo. Debe tener **de 6 a 8 letras y números**;
si no, no se guarda, porque SUNAT rechazaría la guía (código 2567). Al buscar un vehículo, `ABC-123`
y `ABC123` lo encuentran igual.

**2. Modelo:** Inserta el modelo del vehículo.

**3. Marca:** Inserta la marca del vehículo.

**4. Predeterminado**: Activa si el vehículo es de manera frecuente.

**5. Certificado de habilitación vehicular:** Campo donde se debe ingresar el número del certificado que acredita la habilitación del vehículo para operar (TUC), de 10 a 15 caracteres. Es el mismo número que otros sistemas llaman **Constancia de Inscripción MTC** o **TUCE** (por ejemplo `15MRP24004544E`). Un remolque o semirremolque se registra como un vehículo más, con **su propia** constancia.

Además hay dos campos opcionales para la **autorización especial** del vehículo:

- **Autorización especial (N°):** número de la autorización, de 3 a 50 caracteres; admite espacios, guiones y barras, pero no tabulaciones ni saltos de línea (formato de SUNAT).
- **Entidad emisora (D-37):** la entidad que la otorgó, elegida del catálogo D-37 de SUNAT.

Los dos van **juntos**: si llenas uno, el sistema pide el otro.

:::info Cuándo viajan el TUC y la autorización a SUNAT
En la guía de remisión remitente, el TUC y la autorización del vehículo se envían a SUNAT cuando la guía es de **transporte público** con la casilla **Registrar vehículos y conductores del transportista** marcada. Si en ese caso el vehículo no tiene TUC, SUNAT acepta la guía pero la observa, y el sistema lo avisa antes. En la guía de transportista, el TUC y la autorización de **cada** vehículo viajan **siempre** (desde el 2026-09-18 también la autorización, que antes se guardaba y no se enviaba).
:::

Seguido seleccione el botón **Guardar**. Y podrá visualizar el vehículo creado.
