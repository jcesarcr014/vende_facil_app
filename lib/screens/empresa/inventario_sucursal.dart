import 'package:flutter/material.dart';
import 'package:vende_facil/models/sucursales.model.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('INVENTARIOS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Nombre Producto',
                border: OutlineInputBorder(),
              ),
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
                orElse: () => Sucursale(),
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