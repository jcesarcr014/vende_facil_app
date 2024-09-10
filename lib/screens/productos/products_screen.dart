import 'package:flutter/material.dart';
import 'package:vende_facil/models/cuenta_sesion_modelo.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

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
                ListTile(
                    leading: const Icon(Icons.add_box),
                    title: const Text('Agregar Producto',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    subtitle: const Text('Crea un nuevo producto'),
                    trailing: const Icon(Icons.arrow_right),
                    onTap: () => Navigator.pushNamed(context, 'nvo-producto')),
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
                    subtitle: const Text('Elimina un producto de una sucursal'),
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
                      
                      Navigator.pushNamed(context, 'HomerCotizar');
                    }),
                                    ListTile(
                    leading: const Icon(Icons.request_quote),
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
                      Navigator.pushNamed(context,'listaCotizaciones');
                    })
              ],
            )),
      ),
    );
  }
}
