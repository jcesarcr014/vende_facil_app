import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/screens/search_screenProductos.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String? _selectedProduct;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('INVENTARIOS'),
        actions: [
          IconButton(
              onPressed: () => Navigator.pushReplacementNamed(context, 'menu'),
              icon: const Icon(Icons.menu)),
          IconButton(
              onPressed: () =>
                  showSearch(context: context, delegate: Searchproductos()),
              icon: const Icon(Icons.search)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Nombre Producto',
                border: OutlineInputBorder(),
              ),
              value: _selectedProduct,
              isExpanded: true,
              items: listaProductos.map((producto) {
                return DropdownMenuItem<String>(
                  value: producto.producto,
                  child: Text(producto.producto!),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedProduct = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Disponible',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select con sucursales',
                border: OutlineInputBorder(),
              ),
              items: listaSucursales
                  .map((sucursal) => DropdownMenuItem(
                        value: sucursal.nombreSucursal,
                        child: Text(sucursal.nombreSucursal ?? ''),
                      ))
                  .toList(),
              onChanged: (value) {
                // Find the selected Sucursale based on the nombreSucursal
                sucursalSeleccionado = listaSucursales.firstWhere(
                  (sucursal) => sucursal.nombreSucursal == value,
                  orElse: () => Sucursal(),
                );
              },
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Cantidad en sucursal',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const TextField(
              decoration: InputDecoration(
                labelText: 'cantidad a mover',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, 'InventoryPage');
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Agregar',
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, 'productos');
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cancel_outlined),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Cancelar',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}