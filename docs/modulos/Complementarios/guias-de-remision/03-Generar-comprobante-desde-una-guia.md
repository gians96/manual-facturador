# Generar Comprobante desde una Guía de Remisión

Cuando la mercadería sale antes que la factura, primero emites la guía y después el
comprobante. El sistema te deja hacerlo sin volver a escribir el cliente ni los productos:
los toma de la guía.

Hay **dos caminos**, y no hacen exactamente lo mismo. Elige según tengas una guía o varias.

## Camino 1 · Una guía, un comprobante

1. Entra al listado de **Guías de remisión**.
2. Busca la guía y pulsa **Generar comprobante** en su fila.
3. Se abre el formulario con el **cliente** y los **productos** de la guía ya cargados.
   Solo tienes que revisar precios, elegir la serie y el tipo de comprobante, y guardar.

:::info El botón desaparece cuando ya está facturada
**Generar comprobante** solo se muestra si la guía todavía no tiene comprobante. Es la
protección para que no se facture dos veces la misma mercadería.
:::

## Camino 2 · Varias guías, un solo comprobante

Cuando le has hecho varios traslados al mismo cliente y quieres cobrarlos todos juntos.

1. En el listado de **Guías de remisión**, pulsa **Generar comprobante desde múltiples
   guías** (arriba a la derecha).
2. Busca el **cliente**. La lista te ofrece sus guías **aceptadas y todavía sin facturar**.
3. Marca las que quieras incluir y pulsa **Generar CPE**.
4. Se abre el formulario de nuevo comprobante con **los productos de todas las guías
   sumados**: si un mismo artículo aparecía en dos guías, las cantidades se juntan en una
   sola línea.
5. Completa precios, serie y tipo, y guarda. Las guías quedan marcadas como facturadas.

:::warning Revisa el stock si tus guías descuentan existencias
Por este segundo camino, el comprobante **vuelve a descontar el stock** que las guías ya
habían descontado, así que el inventario se resta dos veces. Ocurre solo cuando el motivo
de traslado de las guías descuenta existencias (una venta, por ejemplo).

Es un fallo conocido y pendiente de corregir. Mientras tanto, si emites así de forma
habitual, conviene revisar el kardex de los productos implicados.

El **camino 1 no tiene este problema**: ahí el comprobante no vuelve a descontar.
:::

## Qué queda enlazado en cada camino

Los dos dejan la guía ligada al comprobante y hacen que su número aparezca en la columna
**N° Comprobante** del listado. La diferencia está en el sentido del vínculo:

| | Camino 1 (una guía) | Camino 2 (varias guías) |
|---|---|---|
| El comprobante recuerda de qué guía nació | **Sí** | No |
| La guía recuerda qué comprobante la facturó | No | **Sí** |
| Vuelve a ofrecer «Generar comprobante» en la fila | No | No |
| Vuelve a aparecer en la lista de «múltiples guías» | **Sí** | No |
| El comprobante descuenta stock otra vez | No | **Sí** |

La fila que conviene mirar es la penúltima: una guía facturada por el **camino 1** sigue
apareciendo como disponible en el buscador del camino 2, así que **se podría facturar por
segunda vez desde ahí**. Si usas los dos caminos, comprueba antes que la guía no tenga ya
un comprobante en la columna **N° Comprobante**.

## El sentido contrario: del comprobante a la guía

Si la factura va primero y el traslado después, el camino es el inverso: desde el
**Listado de Comprobantes**, menú de tres puntos, opción **Guía**. Ver
[Lista de Comprobantes](../../esenciales/ventas/2-lista-de-comprobantes.md) y
[Generar Guías de Remisión](./05-Generar-guias-de-remision.md#crear-guía-de-remisión-a-partir-de-un-comprobante).

## Desde la API

Las dos direcciones existen también en la API, con las claves `guia_de_origen`,
`guias_relacionadas` y `comprobante_de_referencia`:
[Documentos relacionados](/devs/api/documentos-relacionados).

## Ver también

- [Listado de Guías de Remisión](./02-Listado-de-guias-de-remision.md)
- [Generar Guías de Remisión](./05-Generar-guias-de-remision.md)
