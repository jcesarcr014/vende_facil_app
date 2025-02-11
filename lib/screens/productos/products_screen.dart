import 'package:flutter/material.dart';
import 'package:vende_facil/models/categoria_model.dart';
import 'package:vende_facil/models/cuenta_sesion_modelo.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/mostrar_alerta_ok.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categoriasProvider = CategoriaProvider();
    final double screenWidth = MediaQuery.of(context).size.width;

    void addProduct() async {
      await categoriasProvider.listarCategorias();
      if (listaCategorias.isEmpty) {
        mostrarAlerta(context, 'Error', 'Primero crea una categoria');
        return;
      }
      Navigator.pushNamed(context, 'nvo-producto');
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didpop) {
        if (!didpop) Navigator.pushReplacementNamed(context, 'menu');
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Productos'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, 'menu');
                },
                icon: const Icon(Icons.menu)),
          ],
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.0),
            child: Column(
              children: [
                if (sesion.tipoUsuario == 'P')
                  ListTile(
                      leading: const Icon(Icons.list_alt),
                      title: const Text('Listado de Productos',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      subtitle: const Text('Visualiza tus productos'),
                      trailing: const Icon(Icons.arrow_right),
                      onTap: () {
                        Navigator.pushNamed(context, 'productos');
                      }),
                if (sesion.tipoUsuario == 'P')
                  ListTile(
                      leading: const Icon(Icons.add_box),
                      title: const Text('Agregar Producto',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      subtitle: const Text('Crea un nuevo producto'),
                      trailing: const Icon(Icons.arrow_right),
                      onTap: addProduct),
                if (sesion.tipoUsuario == 'P' ||
                    (sesion.tipoUsuario == 'E' && globals.empleadoInvetario))
                  ListTile(
                      leading: const Icon(Icons.warehouse),
                      title: const Text(
                        'Inventarios Sucursales',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: const Text(
                          'Selecciona tu sucursal y visualiza tus productos'),
                      trailing: const Icon(Icons.arrow_right),
                      onTap: () {
                        Navigator.pushNamed(context, 'InventoryPage');
                      }),
                if (sesion.tipoUsuario == 'P')
                  ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text(
                        'Agregar Producto Sucursal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: const Text('Agrega un producto a tu sucursal'),
                      trailing: const Icon(Icons.arrow_right),
                      onTap: () => Navigator.pushNamed(
                          context, 'agregar-producto-sucursal')),
                if (sesion.tipoUsuario == 'P')
                  ListTile(
                      leading: const Icon(Icons.delete),
                      title: const Text(
                        'Quitar Producto Sucursal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle:
                          const Text('Elimina un producto de una sucursal'),
                      trailing: const Icon(Icons.arrow_right),
                      onTap: () => Navigator.pushNamed(
                          context, 'eliminar-producto-sucursal')),
                ListTile(
                    leading: const Icon(Icons.request_quote),
                    title: const Text(
                      'Cotizar Productos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: const Text('Estimacion de costo de productos '),
                    trailing: const Icon(Icons.arrow_right),
                    onTap: () {
                      sesion.cotizar = true;
                      if (sesion.tipoUsuario == 'P') {
                        Navigator.pushNamed(
                            context, 'seleccionar-sucursal-cotizacion');
                        return;
                      }
                      Navigator.pushNamed(context, 'HomerCotizar');
                    }),
                ListTile(
                    leading: const Icon(Icons.add_chart_sharp),
                    title: const Text(
                      'Lista de Cotizaciones',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: const Text('visualizacion de cotizaciones'),
                    trailing: const Icon(Icons.arrow_right),
                    onTap: () {
                      Navigator.pushNamed(context, 'listaCotizaciones');
                    })
              ],
            )),
      ),
    );
  }
}
