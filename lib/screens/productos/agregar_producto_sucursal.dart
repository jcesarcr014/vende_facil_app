// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vende_facil/formatters/double_input_formatter.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/screens/search_screenProductos.dart';
import 'package:vende_facil/providers/articulo_provider.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

import '../../widgets/custom_dropdown_search.dart';

class AgregarProductoSucursal extends StatefulWidget {
  const AgregarProductoSucursal({super.key});

  @override
  State<AgregarProductoSucursal> createState() =>
      _AgregarProductoSucursalState();
}

class _AgregarProductoSucursalState extends State<AgregarProductoSucursal> {
  String? _selectedProduct;
  Producto? _productoSeleccionado;
  String? _selectedSucursal;
  String? _cantidadSucursal;
  ArticuloProvider provider = ArticuloProvider();
  bool isLoading = false;

  bool? existe;

  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (globals.actualizaArticulos) {
      setState(() {
        isLoading = true;
      });
      provider.listarProductos().then((respProd) {
        if (respProd.status == 1) {
          globals.actualizaArticulos = false;
        }
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  void _setProductsSucursal(String? value) async {
    _selectedSucursal = value;
    isLoading = true;
    setState(() {});

    Sucursal sucursalSeleccionado = listaSucursales.firstWhere(
      (sucursal) => sucursal.nombreSucursal == value,
      orElse: () => Sucursal(),
    );

    if (sucursalSeleccionado.id == null) {
      isLoading = false;
      setState(() {});
      mostrarAlerta(context, 'Error', 'Selecciona otra sucursal');
      return;
    }

    _productoSeleccionado?.idSucursal = sucursalSeleccionado.id!;

    try {
      Resultado resultado =
          await provider.listarProductosSucursal(sucursalSeleccionado.id!);
      if (resultado.status != 1) {
        isLoading = false;
        setState(() {});
        mostrarAlerta(context, 'Error', resultado.mensaje!);
        return;
      }
      Producto producto = listaProductosSucursal.firstWhere(
          (producto) => producto.id == _productoSeleccionado!.id,
          orElse: () => Producto(id: null, producto: 'No encontrado'));

      if (producto.id == null) {
        existe = false;
        isLoading = false;
        _cantidadSucursal = '0';
        setState(() {});
        return;
      }

      _cantidadSucursal = producto.disponibleInv?.toString();

      _productoSeleccionado?.idInv = producto.idInv;
      isLoading = false;
      existe = true;
      setState(() {});
    } catch (e) {
      isLoading = false;
      setState(() {});
      mostrarAlerta(context, 'Error', e.toString());
    }
  }

  void _updateCantidadSucursal() async {
    if (_selectedSucursal == null || _productoSeleccionado == null) {
      _cantidadSucursal = '0';
      setState(() {});
      return;
    }

    isLoading = true;
    setState(() {});

    try {
      Resultado resultado = await provider.listarProductosSucursal(
          listaSucursales.firstWhere((s) => s.id.toString() == _selectedSucursal).id!);

      if (resultado.status != 1) {
        isLoading = false;
        setState(() {});
        mostrarAlerta(context, 'Error', resultado.mensaje!);
        return;
      }

      Producto producto = listaProductosSucursal.firstWhere(
          (producto) => producto.id == _productoSeleccionado!.id,
          orElse: () => Producto(id: null, producto: 'No encontrado'));

      _cantidadSucursal = producto.id != null
          ? producto.disponibleInv!.toInt().toString()
          : '0';
      isLoading = false;
      setState(() {});
    } catch (e) {
      isLoading = false;
      setState(() {});
      mostrarAlerta(context, 'Error', e.toString());
    }
  }

  void _guardarProductoSucursal() async {
    if (controller.text.isEmpty || _cantidadSucursal == null) return;

    // Asigna la cantidad ingresada al producto seleccionado
    _productoSeleccionado?.cantidadInv = double.parse(controller.text);

    globals.actualizaArticulos = true;

    // Si el producto no existe en la sucursal, crea un nuevo inventario
    if (existe == false) {
      Resultado resultado =
          await provider.nvoInventarioSuc(_productoSeleccionado!);
      if (resultado.status != 1) {
        mostrarAlerta(context, 'Error', resultado.mensaje!);
        return;
      }

      // Añade el producto a la lista de productos de la sucursal
      listaProductosSucursal.add(_productoSeleccionado!);
      Navigator.pushReplacementNamed(context, 'products-menu');
      mostrarAlerta(context, 'Exitoso',
          'Se agrego correctamente el producto a la sucursal.');
      return;
    }

    // Si el producto ya existe en la sucursal, actualiza la cantidad
    Resultado resultado =
        await provider.inventarioSucAgregar(_productoSeleccionado!);
    if (resultado.status != 1) {
      mostrarAlerta(context, 'Error', resultado.mensaje!);
      return;
    }

    // Actualiza la lista de productos de la sucursal y navega a la pantalla de productos
    listaProductosSucursal.add(_productoSeleccionado!);
    Navigator.pushNamedAndRemoveUntil(
        context, 'products-menu', (route) => false);
    mostrarAlerta(context, 'Exitoso',
        'Se agrego correctamente el producto a la sucursal.');
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Producto Sucursal'),
        actions: [
          IconButton(
              onPressed: () =>
                  showSearch(context: context, delegate: Searchproductos()),
              icon: const Icon(Icons.search)),
        ],
      ),
      body: (isLoading)
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
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomDropdownSearch(
                    items: listaProductos.map((producto) => producto.producto!).toList(),
                    selectedItem: _selectedProduct ?? "Selecciona un producto",
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _productoSeleccionado = listaProductos
                            .firstWhere((producto) => producto.producto == newValue);
                        setState(() {
                          _selectedProduct = newValue;
                        });
                        _updateCantidadSucursal();
                      }
                    },
                    labelText: 'Nombre Producto',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    readOnly: true,
                    controller: TextEditingController()
                      ..text =
                          _productoSeleccionado?.cantidad!.toInt().toString() ??
                              '0',
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  CustomDropdownSearch(
                    items: listaSucursales.map((sucursal) => sucursal.nombreSucursal!).toList(),
                    selectedItem: _selectedSucursal,
                    onChanged: (String? newValue) {
                      _setProductsSucursal(newValue);
                    },
                    labelText: 'Select con sucursales',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = _cantidadSucursal ?? '0',
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^[0-9]*\.?[0-9]*$')),
                      DoubleInputFormatter(),
                    ],
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad a mover',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _guardarProductoSucursal,
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
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
