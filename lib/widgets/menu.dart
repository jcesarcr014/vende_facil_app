import 'package:vende_facil/models/models.dart';
import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  const Menu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          _Header(),
          (sesion.idNegocio != 0)
              ? ListTile(
                  leading: const Icon(Icons.paid),
                  title: const Text('Ventas'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, 'home');
                  },
                )
              : Container(),
          (sesion.idNegocio != 0)
              ? ListTile(
                  leading: const Icon(Icons.monetization_on_outlined),
                  title: const Text('Abonos'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, 'selecionarSA');
                  },
                )
              : Container(),
          (sesion.idNegocio != 0)
              ? ListTile(
                  leading: const Icon(Icons.fact_check),
                  title: const Text('Historial'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, 'historial');
                  },
                )
              : Container(),
          (sesion.idNegocio != 0)
              ? ExpansionTile(
                  leading: const Icon(Icons.list),
                  title: const Text('Articulos'),
                  children: _articulos(context),
                )
              : Container(),
          (sesion.idNegocio != 0)
              ? ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Clientes'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, 'clientes');
                  },
                )
              : Container(),
          const Divider(),
          ExpansionTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuracion'),
            children: _configuraciones(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () {
              _clear();
              sesion.idUsuario = 0;
              sesion.idNegocio = 0;
              sesion.token = '';
              Navigator.pushReplacementNamed(context, 'login');
            },
          )
        ],
      ),
    );
  }

  _clear() {
    listaAbonos.clear();
    listaApartadosPendientes.clear();
    listaApartadosPagados.clear();
    listaApartadosEntregados.clear();
    listaApartadosCancelados.clear();
    listaCategorias.clear();
    listaClientes.clear();
    listaColores.clear();
    listaDescuentos.clear();
    listaDetalles.clear();
    listaEmpleados.clear();
    listaPlanes.clear();
    listaProductos.clear();
    listaProductosSucursal.clear();
    listaSucursales.clear();
    listaTarjetas.clear();
    listaUsuarios.clear();
    listaVariables.clear();
    listaVentaCabecera.clear();
    listaVentaCabecera2.clear();
    listaVentadetalles.clear();
    listasucursalEmpleado.clear();
    listaVentas.clear();
    listacotizacion.clear();
    listacotizaciondetalles.clear();
  }

  _articulos(BuildContext context) {
    List<Widget> opcArticulos = [];
    opcArticulos.add(ListTile(
      leading: const Icon(Icons.chevron_right),
      title: const Text(
        'Productos',
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        Navigator.pushReplacementNamed(context, 'productos');
      },
    ));
    opcArticulos.add(ListTile(
      leading: const Icon(Icons.chevron_right),
      title: const Text(
        'Categorias',
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        Navigator.pushReplacementNamed(context, 'categorias');
      },
    ));
    opcArticulos.add(ListTile(
      leading: const Icon(Icons.chevron_right),
      title: const Text(
        'Descuentos',
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        Navigator.pushReplacementNamed(context, 'descuentos');
      },
    ));
    return opcArticulos;
  }

  _configuraciones(BuildContext context) {
    List<Widget> opcConfig = [];

    opcConfig.add(ListTile(
      leading: const Icon(Icons.chevron_right),
      title: const Text(
        'Empresa',
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        Navigator.pushNamed(context, 'negocio');
      },
    ));
    opcConfig.add(ListTile(
      leading: const Icon(Icons.chevron_right),
      title: const Text(
        'Generales',
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        Navigator.pushReplacementNamed(context, 'config');
      },
    ));

    return opcConfig;
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
        decoration: const BoxDecoration(color: Colors.amberAccent),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: CircleAvatar(
                radius: 35,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: const Image(image: AssetImage('assets/store.jpeg'))),
              ),
            ),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Super Store',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Align(
              alignment: Alignment.centerRight + const Alignment(0, 0.4),
              child: const Text(
                'admin@store.com',
                style: TextStyle(),
              ),
            )
          ],
        ));
  }
}
