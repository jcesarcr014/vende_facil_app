import 'package:flutter/material.dart';

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
                  title: const Text('Listado de Productos', style: TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: const Text('Visualiza tus productos'),
                  trailing: const Icon(Icons.arrow_right),
                  onTap: () => Navigator.pushNamed(context, 'productos')
                ),
                ListTile(
                  leading: const Icon(Icons.add_box),
                  title: const Text('Nuevo Producto', style: TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: const Text('Crea un nuevo producto'),
                  trailing: const Icon(Icons.arrow_right),
                  onTap: () => Navigator.pushNamed(context, 'nvo-producto')
                ),
                ListTile(
                  leading: const Icon(Icons.warehouse),
                  title: const Text('Inventario', style: TextStyle(fontWeight: FontWeight.bold,), maxLines: 2, overflow: TextOverflow.ellipsis, ),
                  subtitle: const Text('PENDIENTE'), trailing: const Icon(Icons.arrow_right),
                  onTap: () => Navigator.pushNamed(context, 'InventoryPage')
                )
              ],
            )),
      ),
    );

  }
}