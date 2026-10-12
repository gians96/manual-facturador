# Acceso y Visualización de Logs del Sistema

## Índice
1. [Acceso al Sistema](#acceso-al-sistema)
2. [Navegación al Panel de Logs](#navegación-al-panel-de-logs)
3. [Visualización de Logs](#visualización-de-logs)
4. [Interpretación de Errores](#interpretación-de-errores)
5. [Utilidad para Soporte Técnico](#utilidad-para-soporte-técnico)

## Acceso al Sistema

1. Ingrese a la URL del sistema de facturación.
2. En la pantalla de inicio de sesión, introduzca sus credenciales:
   - Correo electrónico
   - Contraseña
3. Haga clic en el botón "Iniciar sesión"

![Pantalla de acceso al sistema](../img/imagen_login.jpg)

## Navegación al Panel de Logs

1. Una vez dentro del Dashboard, desplácese hasta la parte inferior izquierda del panel lateral.
2. Ubique y haga clic en la opción "Logs" representada por un ícono de insecto (bug).

![Ubicación de la opción Logs](../img/imagen_menu_logs.png)

## Visualización de Logs

Al acceder a la sección de Logs (solo el superadministrador) se muestra:

1. A la izquierda, los archivos de log **agrupados por tipo** (errores de la aplicación, correos,
   tareas programadas, copias de seguridad, plataforma, app, servidor y archivados), del más
   reciente al más viejo, con tamaño y fecha.
2. Arriba, **cuántas entradas hay de cada nivel** (error, warning, info): al pulsar uno se filtra.
3. Los registros del archivo elegido, **de lo más nuevo a lo más viejo** y paginados, con su nivel,
   hora, **empresa** y **origen** (URL, comando o tarea). El buscador recorre el archivo entero.

![Visualizador de Logs](../img/imagen_log_viewer.png)

## Interpretación de Errores

Los logs muestran información técnica detallada que es fundamental para la resolución de problemas:

- **Nivel**: Indica la gravedad del evento (error, warning, info, etc.)
- **Fecha**: Fecha y hora exacta del evento
- **Mensaje y detalle**: al pulsar la fila, el error ordenado:
  - **Dónde**: el archivo y la línea del sistema donde falló
  - **Entrada**: la pantalla, API, comando o tarea por la que llegó
  - **Empresa**, **origen**, usuario e IP (en los registros desde el 12/10/2026)
  - La traza completa, el contexto y el texto original, con **Copiar enlace** para pasárselo a soporte

## Utilidad para Soporte Técnico

Esta sección de Logs es especialmente útil cuando necesite comunicarse con el equipo de soporte técnico por las siguientes razones:

1. **Diagnóstico preciso**: Permite identificar con exactitud el origen y naturaleza de los problemas.
2. **Comunicación eficiente**: Al compartir los detalles específicos del log con el equipo de soporte, se agiliza la resolución del problema.
3. **Seguimiento cronológico**: Facilita el rastreo de la secuencia de eventos que condujeron al error.

### Recomendaciones al contactar a Soporte

Cuando reporte un problema al equipo de soporte:

1. Indique la fecha y hora exacta del error según aparece en los logs
2. Comparta el mensaje de error completo, preferiblemente mediante una captura de pantalla
3. Mencione las acciones que estaba realizando cuando ocurrió el error
4. Si es posible, exporte el archivo de log específico para enviarlo al equipo de soporte

---

