// ignore_for_file: unnecessary_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/articulo_provider.dart';
import 'package:vende_facil/screens/search_screenProductos.dart';
import 'package:vende_facil/widgets/mostrar_alerta_ok.dart';

import '../../widgets/custom_dropdown_search.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

class EliminarProductoSucursal extends StatefulWidget {
  const EliminarProductoSucursal({super.key});

  @override
  State<EliminarProductoSucursal> createState() => _EliminarProductoSucursalState();
}

class _EliminarProductoSucursalState extends State<EliminarProductoSucursal> {
  String? _selectedProduct;
  int? _selectedSucursal;
  String? cantidad;
  Producto? _producto;

  bool isLoading = false;
  bool _valuePieza = true;  // Variable para determinar si es pieza o no
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

    if (sucursalSeleccionado.id == null) return;

    isLoading = true;
    setState(() {});
    Resultado resultado = await provider.listarProductosSucursal(sucursalSeleccionado.id!);
    if (resultado.status != 1) {
      mostrarAlerta(context, 'Error', resultado.mensaje!);
      return;
    }

    _selectedSucursal = sucursalSeleccionado.id;
    isLoading = false;
    setState(() {});
  }

  void _seleccionarProducto(String? value, {bool show = true}) async {
    if (_selectedSucursal == null && show) {
      mostrarAlerta(context, 'Error', 'Selecciona una sucursal primero');
      return;
    }

    Producto producto = listaProductosSucursal.firstWhere(
      (producto) => producto.producto == value,
      orElse: () => Producto(id: null),
    );

    if (producto.id == null) return;

    _producto = producto;
    cantidad = producto.disponibleInv.toString();
    _valuePieza = _producto?.unidad == "0" ? true : false; // Determinar si es pieza o fracción
    setState(() {});
  }

  void _quitar() async {
    if (_producto == null) {
      mostrarAlerta(context, 'Error', 'Primero seleccione una sucursal y producto de la sucursal seleccionada');
      return;
    }

    isLoading = true;
    setState(() {});
    Resultado resultado = await provider.inventarioSucQuitar(_producto!.idInv.toString(), controller.text);
    isLoading = false;
    setState(() {});
    if (resultado.status != 1) {
      mostrarAlerta(context, 'Error', resultado.mensaje!);
      return;
    }
    //Navigator.pushNamedAndRemoveUntil(context, 'products-menu', (route) => false);
    _selectedSucursal = null;
    _selectedProduct = null;
    _seleccionarProducto(null, show: false);
    controller.clear();
    cantidad = '0';
    _producto = null;
    setState(() {});
    globals.actualizaArticulos = true;
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
              onPressed: () =>
                  showSearch(context: context, delegate: Searchproductos()),
              icon: const Icon(Icons.search)),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Espere...'),
                  SizedBox(
                    height: screenHeight * 0.01,
                  ),
                  const CircularProgressIndicator(),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Selecciona una sucursal',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedSucursal,
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
                  CustomDropdownSearch(
                    items: listaProductosSucursal.map((producto) => producto.producto!).toList(),
                    selectedItem: _selectedProduct,
                    onChanged: (String? newValue) {
                      _seleccionarProducto(newValue);
                    },
                    labelText: 'Nombre Producto',
                    emptyMessage: 'Primero Selecciona una Sucursal',
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
                    keyboardType: TextInputType.numberWithOptions(decimal: _valuePieza),
                    inputFormatters: [
                      if (_valuePieza)
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')) // Permitir fracciones
                      else
                        FilteringTextInputFormatter.digitsOnly, // Solo números enteros
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
                      )
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
