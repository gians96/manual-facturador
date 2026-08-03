---
sidebar_position: 3
---

# Reinstalación limpia de BuhoPrinter

Sigue estos pasos cuando BuhoPrinter dejó de funcionar, quedó con errores después de una actualización, o cuando los pasos de la seccion [Qué hacer si algo no funciona](solucion-problemas) no solucionaron el problema. Este procedimiento borra por completo BuhoPrinter de la computadora (incluyendo archivos de configuración ocultos) y lo deja listo para una instalación desde cero.

## 1. Desinstalar BuhoPrinter desde Windows

- Ubique la barra de tareas en la seccion derecha inferior de la pantalla
- Seleccione la flecha para mostrar todas las aplicaciones en ejecución

![alt text](img/reinstalacion_limpia_new_1.png)

- Haga click derecho sobre la aplicacion y seleccione en **Desinstalar**

![alt text](img/reinstalacion_limpia_new_2.png)

- Confirme en el mensaje de seguridad, seleccione **SI**

![alt text](img/reinstalacion_limpia_new_3.png)

## 2. Borrar la carpeta de AppData Local

- Presiona las teclas **Windows + R** al mismo tiempo. Se abrirá una ventana pequeña llamada Ejecutar en la esquina inferior izquierda de la pantalla
- Escribe exactamente `%localappdata%` (con los dos signos de porcentaje, sin espacios) y presiona Enter

![alt text](img/reinstalacion_limpia_new_4.png)

- Se abrirá una carpeta oculta del sistema ubicada en `C:\Users\TuUsuario\AppData\Local`
  1. Dentro de esa carpeta, busca la subcarpeta llamada `buhoprinter` (también puede aparecer como `BuhoPrinter`)
  2. Haz clic derecho sobre la carpeta y selecciona **Eliminar**. Debe desaparecer por completo, con todo lo que tiene dentro

![alt text](img/reinstalacion_limpia_new_5.png)

> Si Windows no te deja eliminarla porque dice que "el archivo está en uso", abre el Administrador de tareas (Ctrl + Shift + Esc), busca cualquier proceso que diga buhoprinter y dale **Finalizar tarea**. Después vuelve a intentar eliminar la carpeta.

## 3. Borrar la carpeta de AppData Roaming

- Vuelve a presionar las teclas **Windows + R** para abrir otra vez la ventana Ejecutar
- Esta vez escribe exactamente `%appdata%` (ojo: esta vez sin la palabra local) y presiona Enter

![alt text](img/reinstalacion_limpia_new_6.png)

- Se abrirá una carpeta distinta ubicada en `C:\Users\TuUsuario\AppData\Roaming`
- Busca de nuevo la subcarpeta `buhoprinter`, haz clic derecho y selecciona **Eliminar**. Con esto queda limpia también la configuración del usuario

![alt text](img/reinstalacion_limpia_new_5.png)

## 4. Vaciar la Papelera de reciclaje

- En el escritorio, haz clic derecho sobre el ícono de la Papelera de reciclaje y selecciona **Vaciar Papelera de reciclaje**
- Este paso garantiza que no queden archivos residuales que puedan interferir con la nueva instalación

## 5. Reiniciar la computadora

Reinicia la PC antes de instalar de nuevo. No te saltes este paso: es necesario para que Windows libere cualquier archivo temporal de BuhoPrinter que haya quedado cargado en memoria.

## 6. Volver a instalar BuhoPrinter y probar

- Sigue nuevamente los pasos de la [**Instalación BuhoPrinter**](/guias-adicionales/buho-printer/buho-printer-manual#instalación-buhoprinter-en-la-computadora-de-la-impresora) de este manual para instalarlo desde cero
- Después entra al sistema, vuelve a hacer clic en "Verificar y actualizar" (como se indica en la [**Configuración de impresoras**](/guias-adicionales/buho-printer/buho-printer-manual#configurar-las-impresoras-en-el-sistema)) y realiza una impresión de prueba para confirmar que todo quedó funcionando correctamente
