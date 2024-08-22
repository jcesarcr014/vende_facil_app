// ignore_for_file: unnecessary_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vende_facil/formatters/double_input_formatter.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/models/producto_model.dart';
import 'package:vende_facil/providers/articulo_provider.dart';
import 'package:vende_facil/screens/search_screenProductos.dart';
import 'package:vende_facil/widgets/mostrar_alerta_ok.dart';

class EliminarProductoSucursal extends StatefulWidget {
  const EliminarProductoSucursal({super.key});

  @override
  State<EliminarProductoSucursal> createState() => _EliminarProductoSucursalState();
}

class _EliminarProductoSucursalState extends State<EliminarProductoSucursal> {
  int? _selectedProduct;
  int? _selectedSucursalId;

  String? cantidad;
  Producto? _producto;

  bool isLoading = false;

  ArticuloProvider provider = ArticuloProvider();

  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    listaProductosSucursal.clear();
  }

  void _seleccionarSucursal(int? value) async {
    sucursalSeleccionado = listaSucursales.firstWhere(
      (sucursal) => sucursal.id == value,
      orElse: () => Sucursal(id: null),
    );

    if(sucursalSeleccionado.id == null) return;

    isLoading = true;
    setState(() {});
    Resultado resultado = await provider.listarProductosSucursal(sucursalSeleccionado.id!);
    if(resultado.status != 1) {
      mostrarAlerta(context, 'Error', resultado.mensaje!);
      return;
    }

    _selectedSucursalId = sucursalSeleccionado.id;
    isLoading = false;
    setState(() {});
  }

  void _seleccionarProducto(int? value) async {
    if(_selectedSucursalId == null) {
      mostrarAlerta(context, 'Error', 'Selecciona una sucursal primero');
      return;
    }

    Producto producto = listaProductosSucursal.firstWhere(
      (producto) => producto.id == value,
      orElse: () => Producto(id: null),
    );

    if(producto.id == null) return;

    _producto = producto;
    cantidad = producto.disponibleInv.toString();
    setState(() {});

  }

  void _quitar() async {
    if(_producto == null) {
      mostrarAlerta(context, 'Error', 'Primero seleccione una sucursal y producto de la sucursal seleccionada');
      return;
    }

    _producto!.cantidad = double.parse(controller.text);
    Resultado resultado = await provider.inventarioSucQuitar(_producto!);

    if(resultado.status != 1) {
      mostrarAlerta(context, 'Error', resultado.mensaje!);
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context, 'products-menu', (route) => false);
    mostrarAlerta(context, 'Exito', resultado.mensaje!);
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eliminar Producto Sucursal'),
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
      body:
        isLoading
            ? Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Espere...'),
                      SizedBox(
                        height: screenHeight * 0.01,
                      ),
                      const CircularProgressIndicator(),
                    ]),
              )
            :
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Select con Sucursales',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedSucursalId,
                    isExpanded: true,
                    items: listaSucursales
                        .map((sucursal) => DropdownMenuItem(
                              value: sucursal.id,
                              child: Text(sucursal.nombreSucursal ?? ''),
                            ))
                        .toList(),
                    onChanged: _seleccionarSucursal,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Nombre Producto',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedProduct,
                    isExpanded: true,
                    items: listaProductosSucursal.map((producto) {
                      return DropdownMenuItem<int>(
                        value: producto.id,
                        child: Text(producto.producto!),
                      );
                    }).toList(),
                    onChanged: _seleccionarProducto,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    readOnly: true,
                    controller: TextEditingController()..text = cantidad ?? '0',
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                      RegExp(r'^[0-9]*\.?[0-9]*$')),
                      DoubleInputFormatter(),
                    ],
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad a Mover',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _quitar,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Eliminar',
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
