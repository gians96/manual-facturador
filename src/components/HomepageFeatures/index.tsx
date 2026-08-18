import clsx from 'clsx';  
import Heading from '@theme/Heading';  
import styles from './styles.module.css';  

type FeatureItem = {  
  title: string;  
  Svg: React.ComponentType<React.ComponentProps<'svg'>>;  
  description: JSX.Element;  
};  

const FeatureList: FeatureItem[] = [  
  {  
    title: 'Sistema de Facturacion Electronica Pro 6',  
    Svg: require('@site/static/img/logo.svg').default,  
    description: (  
      <>   
        <h3>Lista de Categorías</h3>  
        <p>Te recomendamos que visites los artículos más importantes para tu negocio:</p>  
        <ul>  
          <li><a href="docs/Pro6/ventas">Ventas</a></li>  
          <li><a href="docs/Pro6/pos">POS</a></li>  
          <li><a href="docs/Pro6/tienda-virtual">Tienda Virtual</a></li>  
          <li><a href="docs/Pro6/productos-servicios">Productos y Servicios</a></li>  
          <li><a href="docs/Pro6/clientes">Clientes</a></li>  
          <li><a href="docs/Pro6/compras">Compras</a></li>  
          <li><a href="docs/Pro6/inventario">Inventario</a></li>  
          <li><a href="docs/Pro6/usuarios-locales-series">Usuarios/Locales & Series</a></li>  
          <li><a href="docs/Pro6/comprobantes-avanzados">Comprobantes avanzados</a></li>  
          <li><a href="docs/Pro6/reportes">Reportes</a></li>  
          <li><a href="docs/Pro6/contabilidad">Contabilidad</a></li>  
          <li><a href="docs/Pro6/finanzas">Finanzas</a></li>  
          <li><a href="docs/Pro6/configuracion">Configuración</a></li>  
          <li><a href="docs/Pro6/hoteles">Hoteles</a></li>  
          <li><a href="docs/Pro6/farmacia">Farmacia</a></li>  
          <li><a href="docs/Pro6/tramite-documentario">Trámite documentario</a></li>  
          <li><a href="docs/Pro6/suscripcion-escolar">Suscripción Escolar</a></li>  
          <li><a href="docs/Pro6/servicio-suscripcion">Suscripción</a></li>  
          <li><a href="docs/Pro6/produccion">Producción</a></li>  
          <li><a href="docs/Pro6/restaurante">Restaurante</a></li>  
          <li><a href="docs/Pro6/generador-link-pagos">Generador de link de pago</a></li>  
          <li><a href="docs/Pro6/generador-app-2">Generador APP 2.0</a></li>  
          <li><a href="docs/Pro6/app-para-facturacion">App Android</a></li>  
          <li><a href="docs/Pro6/guias-adicionales">Guias adicionales</a></li>  
        </ul>  
      </>  
    ),  
  },  
  {  
    title: 'Sistema de Facturacion Electronica Pro X',  
    Svg: require('@site/static/img/logo.svg').default,  
    description: (  
      <>  
        <h3>Lista de Categorías</h3>  
        <p>Te recomendamos que visites los artículos más importantes para tu negocio:</p>  
        <ul>  
          <li><a href="docs/prox/ventas-x">Ventas</a></li>  
          <li><a href="docs/prox/pos-x">POS</a></li>  
          <li><a href="docs/prox/tienda-virtual-x">Tienda Virtual</a></li>  
          <li><a href="docs/prox/productos-servicios-x">Productos y Servicios</a></li>  
          <li><a href="docs/prox/clientes-x">Clientes</a></li>  
          <li><a href="docs/prox/compras-x">Compras</a></li>  
          <li><a href="docs/prox/inventario-x">Inventario</a></li>  
          <li><a href="docs/prox/usuarios-locales-series-x">Usuarios/Locales & Series</a></li>  
          <li><a href="docs/prox/comprobantes-avanzados-x">Comprobantes avanzados</a></li>  
          <li><a href="docs/prox/reportes-x">Reportes</a></li>  
          <li><a href="docs/prox/contabilidad-x">Contabilidad</a></li>  
          <li><a href="docs/prox/finanzas-x">Finanzas</a></li>  
          <li><a href="docs/prox/configuracion-x">Configuración</a></li>  
          <li><a href="docs/prox/hoteles-x">Hoteles</a></li>  
          <li><a href="docs/prox/tramite-documentario-x">Trámite documentario</a></li>  
          <li><a href="docs/prox/suscripcion-escolar-x">Suscripción Escolar</a></li>  
          <li><a href="docs/prox/servicio-suscripcion-x">Suscripción</a></li>  
          <li><a href="docs/prox/produccion-x">Producción</a></li>  
          <li><a href="docs/prox/restaurante-x">Restaurante</a></li>  
          <li><a href="docs/prox/generador-link-pago-x">Generador de link de pago</a></li>  
          <li><a href="docs/prox/generador-app-2-0-x">Generador APP 2.0</a></li>  
          <li><a href="docs/prox/guias-adicionales-x">Guias adicionales</a></li>  
        </ul>  
      </>  
    ),  
  }, 
  {  
    title: 'Sistema de Facturacion Electronica Pro 7',  
    Svg: require('@site/static/img/logo.svg').default,  
    description: (  
      <>  
        <h3>Lista de Categorías</h3>  
        <p>Te recomendamos que visites los artículos más importantes para tu negocio:</p>  
        <ul>  
        <li><a href="docs/pro7/preventa">Preventa</a></li> 
          <li><a href="docs/pro7/ventas">Ventas</a></li>   
          <li><a href="docs/pro7/clientes">Clientes</a></li>  
          <li><a href="docs/pro7/compras">Compras</a></li>   
        </ul>  
      </>  
    ),  
  },
  {
    title: 'Sistema de Códigos QR',
    Svg: require('@site/static/img/qr-icon.svg').default, // Cambia la imagen si tienes una
    description: (
      <>
        <h3>Lista de Categorías</h3>
        <p>Explora la documentación del sistema de códigos QR:</p>
        <ul>
          <li><a href="docs/qr/introduccion">Introducción</a></li>
        </ul>
      </>
    ),
  },  
];  

function Feature({ title, Svg, description }: FeatureItem) {  
  return (  
    <div className={clsx('col col--4')}>  
      <div className="text--center">  
        <Svg className={styles.featureSvg} role="img" />  
      </div>  
      <div className="text--center padding-horiz--md">  
        <Heading as="h3">{title}</Heading>  
        <p>{description}</p>  
      </div>  
    </div>  
  );  
}  

export default function HomepageFeatures(): JSX.Element {  
  return (  
    <section className={styles.features}>  
      <div className="container">  
        <div className="row">  
          {FeatureList.map((props, idx) => (  
            <Feature key={idx} {...props} />  
          ))}  
        </div>  
      </div>  
    </section>  
  );  
}