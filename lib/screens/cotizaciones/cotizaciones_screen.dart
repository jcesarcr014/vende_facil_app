// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/screens/search_screen.dart';
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
  final clienteProvider = ClienteProvider();
  final apartadoProvider = ApartadoProvider();
  final CantidadConttroller = TextEditingController();
  final TotalConttroller = TextEditingController();
  final EfectivoConttroller = TextEditingController();
  final TarjetaConttroller = TextEditingController();
  final CambioConttroller = TextEditingController();
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;

  @override
  void initState() {
    listacotizacion.clear();
    _actualizaTotalTemporal();
    if (globals.actualizaArticulos) {
      setState(() {
        textLoading = 'Actualizando lista de articulos';
        isLoading = true;
      });
      articulosProvider.listarProductos().then((value) {
        setState(() {
          globals.actualizaArticulos = false;
          textLoading = '';
          isLoading = false;
        });
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vende Fácil Cotizaciones'),
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
                  ..._listaWidgets(),
                  const Divider(),
                  ..._productos(),
                ],
              ),
            ),
    );
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

  _listaWidgets() {
    List<Widget> listaItems = [
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
                    'No hay productos en la Cotizaciones.');
              }
            },
            child: SizedBox(
              height: windowHeight * 0.1,
              width: windowWidth * 0.4,
              child: Center(
                child:
                    Text('Cotizar \$${totalCotizacionTemporal.toStringAsFixed(2)}'),
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
          OutlinedButton(
              onPressed: () {
                showSearch(context: context, delegate: Search());
              },
              child: SizedBox(
                  width: windowWidth * 0.10,
                  height: windowHeight * 0.05,
                  child: const Center(child: Icon(Icons.search)))),
          SizedBox(
            width: windowWidth * 0.05,
          ),
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
    ];

    return listaItems;
  }

  _alertaProducto(Producto producto) {
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
                  controller: CantidadConttroller,
                  keyboardType: TextInputType.number, // This will show the numeric keyboard
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _agregaProductoVenta(
                  producto,
                  double.parse(CantidadConttroller.text),
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

  _productos() {
    List<Widget> listaProd = [];
    if (listaProductos.isNotEmpty) {
      for (Producto producto in listaProductos) {
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
                    if (producto.unidad == "0") {
                      _alertaProducto(producto);
                    } else {
                      _agregaProductoVenta(producto, 0);
                    }
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
            'No hay productos guardados.',
            style: textTheme.titleMedium,
          )
        ],
      ));
    }

    return listaProd;
  }

  _actualizaTotalTemporal() {
    totalCotizacionTemporal = 0;

    //print("Entro aca 3");
    for (ItemVenta item in cotizarTemporal) {
      totalCotizacionTemporal += item.cantidad * item.precioPublico;
      item.subTotalItem += item.cantidad * item.precioPublico;
      item.totalItem = item.cantidad * item.precioPublico;
      totalCotizacionTemporal = item.subTotalItem;
    }
    setState(() {});
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
            cantidad: 1,
            precioPublico: producto.precioPublico!,
            preciomayoreo: producto.precioMayoreo!,
            preciodistribuidor: producto.precioDist!,
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
              cantidad: cantidad,
              precioPublico: producto.precioPublico!,
              preciodistribuidor: producto.precioDist!,
              preciomayoreo: producto.precioMayoreo!,
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
}
