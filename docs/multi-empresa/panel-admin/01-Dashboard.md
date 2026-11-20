# Dashboard

Ingresar al **Dashboard**, ubicar en **Listado de clientes** y veremos los siguientes datos del cliente y configuraciones.

![Alt text](img/dashboard-1.png)

## Secciones detalladas

![Alt text](img/dashboard-2.png)

1. **Hostname:** Nombre del link de acceso para la empresa.
2. **Nombre:** Razón social de la empresa.
3. **RUC:** Número de contribuyente.
4. **Plan:** El plan afiliado que escogió el cliente.
5. **Correo:** El correo del cliente.
6. **Entornos:** DEMO (entorno prueba) o PRODUCCIÓN (entorno funcional).
7. **Total de Comprobantes:** Total de Comprobantes desde el inicio del sistema.
8. **Notificaciones:** alerta de comprobantes no enviados, pendientes de anulación y con algún error para enviar.
9. **Inicio Ciclo Facturación:** Puedes elegir el inicio de tu ciclo de facturación.
10. **Comprobantes Ciclo de Facturación:** Número de comprobantes al mes.

![Alt text](img/acciones_de_cuenta_del_cliente3.png)

11. **Usuarios:** Número de usuarios creados/número de usuarios permitidos.
12. **Fecha Creación:** Día y hora exacta de la fecha de creación.
13. **Consultas API Perú (mes):** Número de consultas (RUC y DNI) realizadas por el API.
14. **Cant. Notas de venta:** Total mensual de documentos internos.
15. **Total (Comprobantes y notas de venta):** El total mensual del punto 7 y 14.
16. **Bloquear cuenta:** bloquea el sistema del cliente **entero**: no puede entrar ni emitir, ni desde el panel ni desde la app. Es el único bloqueo; no hay bloqueos parciales. Al encenderlo se elige el **motivo** («Falta de pago», «Pedido del cliente» u otro que se escribe), que es lo que el cliente lee al entrar. Debajo del interruptor se ve el motivo y quién bloqueó: **a mano** o **por la plataforma** de cobro.

    ![Diálogo «Bloquear cuenta» con las opciones de motivo](img/01-dashboard-bloquear-motivo.png)

    El cliente bloqueado ve el motivo y, si es por falta de pago, la pantalla **Servicio suspendido**: cuánto debe, desde cuándo está vencido («Venció el …») y el botón **Ir a pagar**, que lo lleva al estado de cuenta público de su empresa, donde cualquiera puede pagar sin iniciar sesión. Con cualquier otro motivo ve el motivo y el contacto de soporte, sin botón de pago.

    ![Pantalla del cliente bloqueado: «Servicio suspendido», «Su servicio está suspendido por falta de pago», la deuda, la fecha de vencimiento y «Ir a pagar»](img/01-dashboard-cliente-bloqueado.png)

    Cómo lo ve el cliente, y el aviso que recibe antes de llegar a esto, están en [Aviso de cobro, próximo pago y servicio suspendido](../../guias-adicionales/Otros/aviso-de-cobro-y-mis-pagos.md).

    Si la plataforma de cobro bloqueó la cuenta, la vuelve a desbloquear sola cuando se registra el pago. Si la bloqueaste tú con «Falta de pago», también se desbloquea sola cuando la plataforma avisa que ya pagó. Con cualquier otro motivo, solo se desbloquea apagando el interruptor.
17. **Pago:** si el cliente pagó o no, según la plataforma de cobro: **Pagó** (al día hasta…), **No pagó** (cuántos días lleva vencido y cuánto debe) o **En prueba**. Un guion (—) significa que a esa empresa no la cobra la plataforma. En **Filtros** puedes listar solo los que pagaron o los que no.

    ![Columnas «Bloquear cuenta» y «Pago» en la lista de clientes, con el motivo bajo el interruptor](img/01-dashboard-pago.png)
18. **Limitar Doc.:** Limitar Documentos, si el plan asignado al cliente tiene un límite de documentos, este será aplicado si la opción está activa. De desactivarse la opción esta cuenta podrá emitir documentos ilimitadamente. No es un bloqueo por falta de pago: con cupo libre, el cliente emite.
19. **Limitar Usuarios:** Si el plan asignado al cliente tiene un límite de usuarios, este será aplicado si la opción está activa. De desactivarse la opción esta cuenta podrá crear usuarios ilimitadamente.
20. **Acciones: Resetear clave:** se resetea la clave que eligió y se actualiza con el número de RUC.

![Alt text](img/resetear.png)

21. **Pagos**: Puedes hacer la programación de pagos del cliente eligiendo la fecha, el método de pago, el monto.

![Alt text](img/pago1.png)

 * **Fecha de pago:** Seleccionar el día de pago.
 * **Método de pago:** Seleccionar el método de pago de preferencia.

![Alt text](img/pago2.png)

 * **Tarjeta:** Si seleccionó tarjeta en el método de pago aparecerá la opción caso contrario no aparecerá.
 * **Referencia:** Es un dato personal para que el sistema identifique los pagos realizados.
 * **Monto:** Ingrese el monto de la deuda.
 * **Pagar:** Hay dos botones, uno que es un check para confirmar la deuda y el otro que es un aspa que cancela la deuda.

22. **E.Cuentas:** Estado de cuenta, puedes visualizar si el cliente tiene algún pago pendiente.

![Alt text](img/ecuenta.png)

23. **Editar:** Se puede editar el plan,módulos,entorno de sistema y configuración del correo pero no los datos del cliente.

![Alt text](img/editar.png)
