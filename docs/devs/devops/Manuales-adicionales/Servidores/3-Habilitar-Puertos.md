# Manual de Google Cloud: Habilitando Puertos en Firewall

:::danger No abras el puerto de la base de datos
El ejemplo de abajo habilita un puerto de MySQL solo para ilustrar el procedimiento. **No lo hagas con la base de
producción**: un puerto de MariaDB abierto a internet recibe intentos de acceso de todo el mundo. Para entrar a la
base usa un túnel SSH (ver «Ingreso a la base de datos»). Abre solo 80, 443 y el de SSH.
:::

## Pasos

1. Ingresar a su panel de Google Cloud y dirigirse al menú de firewall.

![alt text](img/habilitar_puerto_1.png)

2. Crear una nueva regla.

![alt text](img/habilitar_puerto_2.png)

3. Llenar el nombre con el servicio para que pueda reconocerse en la lista.

![alt text](img/habilitar_puerto_3.png)

4. Completar los siguientes 3 puntos (para el ejemplo se está habilitando un puerto para MySQL, lo que comúnmente sería el 3306).

![alt text](img/habilitar_puerto_4.png)

5. Finalizar pulsando en el botón crear. En el menú de firewall podrá observar las reglas registradas disponibles para las instancias de su cuenta.

![alt text](img/habilitar_puerto_5.png)

De esta manera podrá acceder a su servidor por diferentes puertos. Para el caso de Odoo, suele habilitarse el 8069, siempre dependerá del servicio que desee observar.

---


