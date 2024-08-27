// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/articulo_provider.dart';
import 'package:vende_facil/screens/search_screenProductos.dart';
import 'package:vende_facil/widgets/widgets.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String? _selectedSucursal;
  ArticuloProvider provider = ArticuloProvider();
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;

  @override
  void initState() {
    super.initState();
    listaProductosSucursal.clear();
  }

  void _setProductsSucursal(String? value) async {
    setState(() {
      isLoading = true;
      _selectedSucursal = value;
    });

    Sucursal sucursalSeleccionado = listaSucursales.firstWhere(
      (sucursal) => sucursal.nombreSucursal == value,
      orElse: () => Sucursal(),
    );

    if (sucursalSeleccionado.id == null) {
      setState(() {
        isLoading = false;
      });
      mostrarAlerta(context, 'Error', 'Selecciona otra sucursal');
      return;
    }

    try {
      Resultado resultado =
          await provider.listarProductosSucursal(sucursalSeleccionado.id!);

      if (resultado.status != 1) {
        setState(() {
          isLoading = false;
        });
        mostrarAlerta(context, 'Error', resultado.mensaje!);
        return;
      }

      if (listaProductosSucursal.isEmpty) {
        setState(() {
          isLoading = false;
        });
        mostrarAlerta(
            context, 'Error', 'No cuentas con productos en esta sucursal');
        return;
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      mostrarAlerta(context, 'Error', e.toString());
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      onPopInvoked: (didpop) {
        if (!didpop)
          Navigator.pushNamedAndRemoveUntil(
            context,
            'products-menu',
            (route) => false,
          );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('INVENTARIOS'),
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
                      Text('Espere...$textLoading'),
                      SizedBox(
                        height: windowHeight * 0.01,
                      ),
                      const CircularProgressIndicator(),
                    ]),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Seleccione una sucursal',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedSucursal,
                      isExpanded: true,
                      items: listaSucursales
                          .map((sucursal) => DropdownMenuItem(
                                value: sucursal.nombreSucursal,
                                child: Text(sucursal.nombreSucursal ?? ''),
                              ))
                          .toList(),
                      onChanged: _setProductsSucursal,
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    Column(children: _productosSucursal()),
                  ],
                ),
              ),
      ),
    );
  }

  List<Widget> _productosSucursal() {
    List<Widget> listaProd = [];
    if (listaProductosSucursal.isNotEmpty) {
      for (Producto producto in listaProductosSucursal) {
        for (Categoria categoria in listaCategorias) {
          if (producto.idCategoria == categoria.id) {
            for (ColorCategoria color in listaColores) {
              if (color.id == categoria.idColor) {
                listaProd.add(ListTile(
                  leading: Icon(
                    Icons.category,
                    color: color.color,
                  ),
                  onTap: (() {
                    setState(() {
                      textLoading = 'Leyendo producto';
                      isLoading = true;
                    });

                    provider.consultaProducto(producto.id!).then((value) {
                      setState(() {
                        textLoading = '';
                        isLoading = false;
                      });
                      if (value.id != 0) {
                        value.id = -1;
                        Navigator.pushNamed(context, 'nvo-producto',
                            arguments: value);
                      } else {
                        mostrarAlerta(context, 'ERROR',
                            'Error en la consulta: ${value.producto}');
                      }
                    });
                  }),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: windowWidth * 0.45,
                        child: Text(
                          producto.producto!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(categoria.categoria!),
                ));
              }
            }
          }
        }
      }
    } else {
      final TextTheme textTheme = Theme.of(context).textTheme;

      listaProd.add(Column(
        children: [
          const Opacity(
            opacity: 0.2,
            child: Icon(
              Icons.filter_alt_off,
              size: 130,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            'No hay productos guardados en esta sucursal.',
            style: textTheme.titleMedium,
          )
        ],
      ));
    }

    return listaProd;
  }
}
