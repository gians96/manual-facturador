# Envío automático de facturas y el aviso «SUNAT no respondió»

:::info

Cómo se envían las facturas (y sus notas de crédito y débito) a SUNAT cuando el envío del
momento falla, qué significa cada aviso y qué papel tienen los **Días de plazo de envío**.

:::

## Al emitir: el envío del momento

Cada factura se envía a SUNAT en el mismo momento en que se emite. Si SUNAT responde, queda
**Aceptada** (o Rechazada u Observada, según lo que diga SUNAT).

Si SUNAT **no responde** (está saturada, en mantenimiento o caída), la factura **se genera
igual** y queda **Registrada**. El aviso es ámbar:

> **SUNAT no respondió.** El comprobante se generó y quedó registrado; no es un error del
> comprobante ni del sistema. Se reenviará automáticamente hasta el *dd/mm/aaaa*.

Lo mismo se ve en el listado de comprobantes: el triángulo junto al estado es **ámbar**.
No hace falta hacer nada: el sistema la reenvía solo.

:::note Captura pendiente
Pantalla: Ventas → Comprobantes, modal «Comprobante Generado» de una factura que SUNAT no respondió.
Debe verse: el aviso ámbar «SUNAT no respondió» con la fecha límite de reenvío. Y en el listado, el
triángulo ámbar junto al estado «Registrado».
:::

| Aviso | Qué significa | Qué hacer |
|---|---|---|
| Ámbar, «SUNAT no respondió» | El servicio de SUNAT no contestó (por ejemplo `HTTP - Error Fetching http headers`) | Nada: se reenvía sola mientras esté en plazo |
| Rojo, «Por regularizar: código - descripción» | SUNAT o el sistema encontraron algo que corregir (usuario SOL, certificado, RUC…) | Revisar el código; corregido, reenviarla |

## El reintento automático

Cada **2 horas** el servidor vuelve a intentar las facturas que quedaron registradas porque
SUNAT no respondió. Lo hace con todas las empresas, aunque no tengan ninguna tarea programada.
Si SUNAT ya la había recibido, al reenviarla responde que está registrada y la factura pasa a
**Aceptada**.

## Días de plazo de envío

SUNAT solo acepta una factura durante unos días desde su fecha de emisión. Pasado el plazo la
**rechaza**, y la factura se pierde. Por eso el sistema **no la reenvía sola fuera de plazo**: la
deja **Registrada** con el aviso «Venció el plazo de envío», para revisarla con su contador.

El plazo se configura en **Configuración → Avanzado → Interfaz y parámetros generales → Días de
plazo de envío**. Con el valor por defecto, **4**, se puede enviar el día de emisión y los 3 días
siguientes: una factura del 08/10 se envía hasta el 11/10.

:::warning

El botón **Reenviar** del listado sigue enviando aunque haya vencido el plazo. Si la factura está
vencida, SUNAT probablemente la rechace.

:::

## La tarea «Enviar comprobantes pendientes a SUNAT»

Además del reintento cada 2 horas, cada empresa puede programar una pasada diaria que envía
**todas** las facturas y notas registradas que sigan en plazo, también las que fallaron por otro
motivo. En su resultado lista las que ya vencieron.

1. Ir a **Configuración** → **Configuraciones Globales** → **Avanzado** → **Tareas programadas**

![Tareas programadas en Configuraciones Globales](img/envio-facturas-automatico-1.png)

2. Hacer clic en **Agregar**.
3. Seleccionar **Enviar comprobantes pendientes a SUNAT**.
4. Elegir la hora y hacer clic en **Guardar**.

:::tip Configuración recomendada
Las empresas nuevas ya traen esta tarea. Si a la tuya le falta, en *Tareas programadas* pulsa
**Aplicar configuración recomendada**: la crea con su hora, junto con las de boletas.
:::

Las boletas no se envían con esta tarea: van en el resumen diario
([Envío de boletas automático](envio-boletas-automatico.md)).
