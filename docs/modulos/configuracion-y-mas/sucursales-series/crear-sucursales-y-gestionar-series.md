---
sidebar_position: 1
title: Sucursales & series
---

# Crear sucursales y gestionar series

En esta área te ayudaremos a crear establecimientos o locales. Sigue estos pasos para realizarlo:

Ingresa al módulo de **Configuración y más** luego selecciona la subcategoría **Sucursales & series**.

![alt text](img/sucursales_y_series_1.png)

## Nuevo establecimiento

En la parte superior derecha selecciona el botón **Nuevo**.

![alt text](img/sucursales_y_series_2.png)

Aparecerá el formulario para llenar los datos del **Nuevo Establecimiento**.

![alt text](img/sucursales_y_series_3.png)

- **1. Descripción:** Ingresa el nombre del establecimiento.
- **2. Código domicilio fiscal:** Ingresa el código del domicilio fiscal, se encuentra en tu ficha RUC.
- **3. País:** Selecciona el país.
- **4. Departamento:** Selecciona el departamento.
- **5. Provincia:** Selecciona la provincia.
- **6. Distrito:** Selecciona el distrito.
- **7. Dirección fiscal:** Ingresa la dirección fiscal.
- **8. Teléfono:** Ingresa el número de teléfono.
- **9. Dirección comercial:** Ingresa la dirección comercial del establecimiento.
- **10. Correo de contacto:** Ingresa el correo electrónico de contacto.
- **11. Dirección web:** Ingresa la dirección web si tuviera.
- **12. Información adicional:** Agrega alguna información adicional.
- **13. Cliente por defecto:** Agrega si hubiera algún cliente específico para el establecimiento.
- **14. Cambiar logo del establecimiento:** Selecciona para poder cambiar el logo de tu establecimiento.
- **15. Casilla de verificación:**
  - **Sujeto al IGV - Ley 31556:** Si perteneces al sector de restaurantes, hoteles y agencias de turismo, selecciona esta casilla para aplicar el IGV que te corresponde.
## Dirección secundaria (anexos del RUC)

En la pestaña **Dirección secundaria** se registran los otros locales de la empresa: los
**establecimientos anexos** que figuran en tu ficha RUC (Consulta RUC → Establecimientos anexos),
como un almacén, una obra o una mina. Con **Agregar dirección** se añade cada uno:

- **País** y **Ubigeo:** dónde está el anexo.
- **Dirección:** tal como figura en el RUC.
- **Código de anexo SUNAT:** el código de cuatro dígitos que SUNAT le asignó al anexo (por ejemplo `0001`).

![Pestaña «Dirección secundaria» con un anexo registrado: país, ubigeo, dirección y código de anexo SUNAT](img/crear-sucursales-y-gestionar-series-direccion-secundaria.png)

Estas direcciones se usan en dos sitios:

- **Guías de remisión:** como punto de partida, cuando la mercadería sale de un lugar distinto a la dirección principal.
- **Facturas y boletas:** como **Establecimiento del emisor**, el local donde entregas el bien o prestas
  el servicio. Se elige al emitir (ver [Nuevo comprobante](../../esenciales/ventas/01-nuevo-comprobante.md)),
  y el comprobante muestra el domicilio fiscal en la cabecera y el anexo en una fila aparte, en el PDF y en
  el XML. Por API se envía con `establecimiento_del_emisor` y la lista de anexos se consulta con
  `GET /api/establishments/annexes`.

Solo se ofrecen las direcciones **activas** del establecimiento. Si el anexo no está registrado en tu
RUC, regístralo primero en SUNAT.

## Listado de establecimientos

![alt text](img/sucursales_y_series_4.png)

Hay podemos observar que hay tres botones:

- **Editar:** Se puede editar el establecimiento una vez creado.
- **Eliminar:** Elimina el establecimiento.

:::danger importante

No se puede eliminar un establecimiento cuando hay ventas o compras relacionadas.

:::

- **Series:** Se pueden editar las series de cada establecimiento.

## Series que acepta SUNAT

Cada comprobante electrónico se emite con una serie de su tipo y con el formato que acepta SUNAT:

| Comprobante | Serie |
|---|---|
| Factura | Empieza con **F** (`F001`, `FF01`) |
| Boleta | Empieza con **B** (`B001`, `BB01`) |
| Nota de crédito o débito | Empieza con **F** si modifica una factura y con **B** si modifica una boleta (`FC01`, `BC01`) |
| Cualquiera de ellos en contingencia | Cuatro dígitos (`0001`) |

Al emitir, el sistema lo comprueba. Si la serie es de otro tipo de comprobante o tiene otro formato, no emite y lo dice, por ejemplo *La serie NV01 es de nota de venta, no de boleta: elige una serie de boleta.* Antes se podía emitir una boleta con la serie de una nota de venta: SUNAT no la acepta, y rechazaba con ella todo el resumen diario del día.
