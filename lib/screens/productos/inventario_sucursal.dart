import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/articulo_provider.dart';
import 'package:vende_facil/screens/search_screenProductos.dart';
import 'package:vende_facil/widgets/input_field.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String? _selectedProduct;

  Producto? _productoSeleccionado;

  Producto? _cantidadSucursal;

  ArticuloProvider provider = ArticuloProvider();

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
                  value: producto.id.toString(),
                  child: Text(producto.producto!),
                );
              }).toList(),
              onChanged: (String? newValue) {
                _productoSeleccionado = listaProductos.firstWhere((producto) => producto.id.toString() == newValue);
                print(_productoSeleccionado!.cantidad);
                setState(() {
                  _selectedProduct = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: _productoSeleccionado?.cantidad!.toInt().toString() ?? '0',
                border: const OutlineInputBorder(),
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
                Sucursal sucursalSeleccionado = listaSucursales.firstWhere(
                  (sucursal) => sucursal.nombreSucursal == value,
                  orElse: () => Sucursal(),
                );

                //* Error: Obtengo el id de la sucursal seleccionada y la comparo con el id de la sucursal del productoSeleccionado
                //* por lo que si no se encuentra se regresa un producto con cantidad 0 y eso se manda a la API con el ArticuloProvider
                //* con nvoInventarioSuc el que le envio el producto pero la API truena en cuanto se quiere hacer el jsonDecode

                //* Dudas
                //* Si al ver que me devuelve 0 en producto debo usar nvoInventarioSuc y si me devuelve cualquier cosa diferente de 0
                //* debo usar nvoInventarioSucAgregar el que me permite actualizarlo no y dependiendo de que si me sale un error debo 
                //* mostrarlo en pantalla y si no ya lo redirecciono al InventoryPage
                Producto? producto = listaProductos.firstWhere(
                  (element) => sucursalSeleccionado.id == _productoSeleccionado!.idSucursal,
                  orElse: () => Producto(cantidad: 0, idSucursal: sucursalSeleccionado.id),
                );
                setState(() {
                  _cantidadSucursal = producto;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: _cantidadSucursal?.cantidadInv?.toInt().toString() ?? '0',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Cantidad a mover',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    //* Momentaneamente esta asi inge, de ahi en cuanto funcione lo iba a guardar en otra funcion y nada mas llamarla para que sea
                    //* legible todo
                    if(_productoSeleccionado!.cantidadInv == null|| _cantidadSucursal!.cantidadInv == null) {
                      _productoSeleccionado?.idSucursal = _cantidadSucursal?.idSucursal;
                      _productoSeleccionado?.cantidadInv = 0.0;
                      final respuesta =await provider.nvoInventarioSuc(_productoSeleccionado!);

                      print(respuesta.mensaje);
                      try {

                      } catch (e) {

                      }
                      return;
                    }

                    try {

                    } catch (e) {

                    }
                    return;
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
                  onPressed: () => Navigator.pushReplacementNamed(context, 'productos'),
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