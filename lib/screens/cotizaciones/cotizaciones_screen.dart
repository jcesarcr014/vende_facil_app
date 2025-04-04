import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

class HomeCotizarScreen extends StatefulWidget {
  const HomeCotizarScreen({super.key});

  @override
  State<HomeCotizarScreen> createState() => _HomeCotizarScreenState();
}

class _HomeCotizarScreenState extends State<HomeCotizarScreen> {
  final articulosProvider = ArticuloProvider();
  final categoriasProvider = CategoriaProvider();
  final descuentoProvider = DescuentoProvider();
  final cantidadConttroller = TextEditingController();
  final busquedaController = TextEditingController();
  List<Producto> productosFiltrados = [];
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;

  @override
  void dispose() {
    busquedaController.dispose();
    cantidadConttroller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _actualizaTotalTemporal();
    setState(() {
      textLoading = 'Actualizando listado de productos';
      isLoading = true;
    });
    articulosProvider.listarProductosSucursal(sesion.idSucursal!).then((value) {
      setState(() {
        productosFiltrados = List.from(listaProductosSucursal);
        textLoading = 'Cargando descuentos';
      });
      descuentoProvider.listarDescuentos().then((resp) {
        setState(() {
          textLoading = '';
          isLoading = false;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotizar productos'),
        automaticallyImplyLeading: true,
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
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.0),
              child: Column(
                children: [
                  SizedBox(
                    height: windowHeight * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (cotizarTemporal.isNotEmpty) {
                            Navigator.pushNamed(context, 'DetalleCotizar');
                            setState(() {});
                          } else {
                            mostrarAlerta(context, '¡Atención!',
                                'No hay productos en la lista.');
                          }
                        },
                        child: SizedBox(
                          height: windowHeight * 0.1,
                          width: windowWidth * 0.4,
                          child: Center(
                            child: Text(
                                'Cotizar \$${totalCotizacionTemporal.toStringAsFixed(2)}'),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: windowWidth * 0.05,
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            if (cotizarTemporal.isNotEmpty) {
                              _alertaElimnar();
                            } else {
                              mostrarAlerta(context, '¡Atención!',
                                  'No hay productos en la Cotizacion.');
                            }
                          },
                          child: SizedBox(
                              width: windowWidth * 0.10,
                              height: windowHeight * 0.05,
                              child: const Center(child: Icon(Icons.delete)))),
                    ],
                  ),
                  const Divider(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: windowWidth * 0.05, vertical: 10),
                    child: TextField(
                      controller: busquedaController,
                      decoration: InputDecoration(
                        labelText: 'Buscar producto',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            busquedaController.clear();
                            _filtrarProductos('');
                          },
                        ),
                      ),
                      onChanged: _filtrarProductos,
                    ),
                  ),
                  const Divider(),
                  Column(children: _productosSucursal())
                ],
              ),
            ),
    );
  }

  void _filtrarProductos(String query) {
    setState(() {
      if (query.isEmpty) {
        productosFiltrados = List.from(listaProductosSucursal);
      } else {
        productosFiltrados = listaProductosSucursal
            .where((producto) =>
                producto.producto!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  _productosSucursal() {
    List<Widget> listaProd = [];
    if (productosFiltrados.isNotEmpty) {
      for (Producto producto in productosFiltrados) {
        for (Categoria categoria in listaCategorias) {
          if (producto.idCategoria == categoria.id) {
            for (ColorCategoria color in listaColores) {
              if (color.id == categoria.idColor) {
                listaProd.add(ListTile(
                  leading: Icon(
                    Icons.category,
                    color: color.color,
                  ),
                  onTap: (() => _alertaProducto(producto)),
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
            'No hay productos para mostrar.',
            style: textTheme.titleMedium,
          )
        ],
      ));
    }

    return listaProd;
  }

  _alertaProducto(Producto producto) {
    bool isInt = producto.unidad == '1' ? true : false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Row(
            children: [
              const Flexible(
                child: Text(
                  'Cantidad :',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              SizedBox(
                width: windowWidth * 0.05,
              ),
              Flexible(
                child: InputField(
                  textCapitalization: TextCapitalization.words,
                  controller: cantidadConttroller..text = '1',
                  keyboardType: isInt
                      ? TextInputType.number
                      : TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(isInt ? r'^[1-9]\d*' : r'^\d+(\.\d{0,4})?$'))
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (cantidadConttroller.text.isEmpty) return;
                _agregaProductoVenta(
                  producto,
                  double.parse(cantidadConttroller.text),
                );
              },
              child: const Text('Aceptar '),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  _agregaProductoVenta(Producto producto, cantidad) {
    bool existe = false;
    if (producto.unidad == "1") {
      for (ItemVenta item in cotizarTemporal) {
        if (item.idArticulo == producto.id) {
          existe = true;
          item.cantidad++;
          item.subTotalItem = item.precioPublico * item.cantidad;
          item.totalItem = item.subTotalItem - item.descuento;
        }
      }
      if (!existe) {
        cotizarTemporal.add(ItemVenta(
            idArticulo: producto.id!,
            articulo: producto.producto!,
            cantidad: cantidad,
            precioPublico: producto.precioPublico!,
            precioMayoreo: producto.precioMayoreo!,
            precioDistribuidor: producto.precioDist!,
            precioUtilizado: producto.precioPublico!,
            idDescuento: 0,
            descuento: 0,
            subTotalItem: producto.precioPublico!,
            totalItem: producto.precioPublico!,
            apartado: (producto.apartado == 1) ? true : false));
      }
      _actualizaTotalTemporal();
    } else {
      if (producto.unidad == "0") {
        for (ItemVenta item in cotizarTemporal) {
          if (item.idArticulo == producto.id) {
            existe = true;
            item.cantidad++;
            item.subTotalItem = item.precioPublico * cantidad;
            item.totalItem = item.subTotalItem - item.descuento;
          }
        }
        if (!existe) {
          cotizarTemporal.add(ItemVenta(
              idArticulo: producto.id!,
              articulo: producto.producto!,
              cantidad: cantidad,
              precioPublico: producto.precioPublico!,
              precioDistribuidor: producto.precioDist!,
              precioMayoreo: producto.precioMayoreo!,
              precioUtilizado: producto.precioPublico!,
              idDescuento: 0,
              descuento: 0,
              subTotalItem: producto.precioPublico!,
              totalItem: producto.precioPublico! * cantidad,
              apartado: (producto.apartado == 1) ? true : false));
        }
        _actualizaTotalTemporal();
      } else {}
      _actualizaTotalTemporal();
    }
  }

  _alertaElimnar() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              '¡Alerta!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '¿Desea eliminar la lista de articulos de la cotizacion ? Esta acción no podrá revertirse.',
                )
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    cotizarTemporal.clear();
                    setState(() {});
                    totalCotizacionTemporal = 0.0;
                    Navigator.pop(context);
                  },
                  child: const Text('Eliminar')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'))
            ],
          );
        });
  }

  _actualizaTotalTemporal() {
    totalCotizacionTemporal = 0;
    for (ItemVenta item in cotizarTemporal) {
      totalCotizacionTemporal += item.cantidad * item.precioPublico;
      item.subTotalItem += item.cantidad * item.precioPublico;
      item.totalItem = item.cantidad * item.precioPublico;
    }
    setState(() {});
  }
}
