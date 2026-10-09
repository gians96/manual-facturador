---
sidebar_position: 3
---
# Listado de Unidades

El **Listado de Unidades de Medida** de SUNAT incluye los códigos que especifican las distintas unidades utilizadas para describir productos o servicios en documentos tributarios. Estas unidades son obligatorias para cumplir con las normativas de facturación electrónica y garantizar la precisión en la descripción de las cantidades.

Cada unidad de medida está representada por un **código** y su correspondiente **descripción**, lo que facilita la correcta identificación y registro de cantidades en los comprobantes de pago electrónicos.

Para agregar más unidades, dirígete a **Configuración y más**, luego selecciona **Configuraciones Globales** y, a continuación, haz clic en **Listado de tipos de unidades**.

![alt text](img/listadounidades.jpg)

Listado de unidades de medida, para productos o servicios:

Leyenda:

* **CÓDIGO** → Descripción
* 4A → BOBINAS
* BJ → BALDE
* BLL → BARRILES
* BG →  BOLSA
* BO →  BOTELLAS
* BX→  CAJA
* CT →  CARTONES
* CMK →  CENTÍMETRO CUADRADO
* CMQ →  CENTIMETRO CUBICO
* CMT →  CENTÍMETRO LINEAL
* CEN → CIENTO DE UNIDADES
* CY → CILINDRO
* CJ → CONOS
* DZN → DOCENA
* DZP → DOCENA POR 10**6
* BE → FARDO
* GLI → GALÓN INGLÉS (4,545956L)
* GRM → GRAMO
* GRO → GRUESA
* HLT→ HECTOLITRO
* LEF → HOJA
* HUR → HORA
* SET → JUEGO
* KGM → KILOGRAMO
* KTM → KILÓMETRO
* KWH → KILOVATIO HORA
* KT → KIT
* CA → LATAS
* BR → LIBRAS
* LTR → LITRO
* MWH → MEGAWATT HORA
* MTR → METRO
* MTK → METRO CUADRADO
* MTQ → METRO CUBICO
* MGM → MILIGRAMOS
* MLT → MILILITRO
* MMT → MILÍMETRO
* MMK → MILÍMETRO CUADRADO
* MMQ → MILLIMETRO CUBICO
* MIL → MILLARES
* UM →  MILLÓN DE UNIDADES
* ONZ → ONZAS
* PF → PALETAS
* PK → PAQUETE
* PR → PAR
* FOT → PIES
* FTK → PIES CUADRADOS
* FTQ → PIES CÚBICOS
* C62 → PIEZAS
* PG → PLACAS
* ST → PLIEGO
* INH → PULGADAS
* RM → RESMA
* ROL → ROLLO
* DR → TAMBOR
* STN → TONELADA CORTA
* LTN → TONELADA LARGA
* TNE → TONELADAS
* TU → TUBOS
* NIU → UNIDAD
* ZZ → SERVICIOS
* GLL → GALÓN
* YRD → YARDA
* YDK → YARDA CUADRADA

![alt text](img/listadounidades2.jpg)

## Unidades activas e inactivas

El listado muestra por defecto solo las unidades **activas**. Para ver las demás, elige **Inactivos** o **Todos** en el filtro **Estado**. Una unidad se activa o desactiva con el interruptor de la columna **Activo**.

## El código de la unidad va al comprobante

El **código** de la unidad (NIU, BX, U2…) es el que se envía a SUNAT en el comprobante electrónico: es el **Catálogo N.° 03**, que usa los códigos de la UN/ECE. La descripción solo se ve en el sistema; lo que SUNAT lee es el código. Antes de usar una unidad, revisa que su código signifique lo que vendes:

- **U2 → Tableta** es **una tableta suelta**. No la uses para un blíster ni para una caja: «1 blíster» con U2 se declara como 1 tableta.
- **Blíster:** SUNAT no tiene un código de blíster. Usa **NIU → Unidades** y escribe «Blíster» como descripción de la presentación. Es lo que hace el botón **+ Blíster** de farmacia.
- **Caja:** usa **BX → Caja**.

Más detalles en [Farmacia › Productos: Presentaciones y Lotes](../../../rubros/farmacia/Productos-Presentaciones-y-Lotes.md).

:::danger IMPORANTE

Puedes crear un nueva nueva unidad seleccionando el botón **Nuevo**, asegurándote previamente de verificar el código correspondiente. Es fundamental utilizar el código correcto para garantizar que el código de la unidad esté correctamente clasificado dentro del sistema y cumpla con los requerimientos de sunat.

:::
