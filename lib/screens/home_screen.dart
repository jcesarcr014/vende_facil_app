// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/models/models.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:vende_facil/screens/search_screen.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    _actualizaTotalTemporal();
    if (globals.actualizaArticulos) {
      setState(() {
        textLoading = 'Actualizando lista de articulos';
        isLoading = true;
      });
      articulosProvider
          .listarProductosSucursal(sesion.idSucursal!)
          .then((value) {
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
    return PopScope(
      canPop: false,
      onPopInvoked: (didpop) {
        if (!didpop) Navigator.pushReplacementNamed(context, 'menu');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vende Fácil'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'menu');
              },
              icon: const Icon(Icons.menu),
            ),
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
                  '¿Desea eliminar la lista de articulos de compra ? Esta acción no podrá revertirse.',
                )
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    ventaTemporal.clear();
                    setState(() {});
                    totalVentaTemporal = 0.0;
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
              if (ventaTemporal.isNotEmpty) {
                Navigator.pushNamed(context, 'detalle-venta');
                setState(() {});
              } else {
                mostrarAlerta(
                    context, '¡Atención!', 'No hay productos en la venta.');
              }
            },
            child: SizedBox(
              height: windowHeight * 0.1,
              width: windowWidth * 0.4,
              child: Center(
                child:
                    Text('Cobrar \$${totalVentaTemporal.toStringAsFixed(2)}'),
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
          if (sesion.cotizar == false)
            ElevatedButton(
              onPressed: () async {
                var res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SimpleBarcodeScannerPage(),
                    ));
                setState(() {
                  if (res is String) {}
                });
              },
              child: SizedBox(
                  width: windowWidth * 0.10,
                  height: windowHeight * 0.05,
                  child: const Center(child: Icon(Icons.qr_code_scanner))),
            ),
          SizedBox(
            width: windowWidth * 0.05,
          ),
          ElevatedButton(
              onPressed: () {
                if (ventaTemporal.isNotEmpty) {
                  _alertaElimnar();
                } else {
                  mostrarAlerta(
                      context, '¡Atención!', 'No hay productos en la venta.');
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
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (sesion.cotizar!) {
                  _agregaProductoVenta(
                    producto,
                    double.parse(CantidadConttroller.text),
                  );
                } else {
                  if (CantidadConttroller.text.isEmpty ||
                      double.parse(CantidadConttroller.text) <= 0) {
                    mostrarAlerta(context, "AVISO", "valor invalido");
                  } else {
                    if (double.parse(CantidadConttroller.text) >
                        producto.disponibleInv!) {
                      mostrarAlerta(context, "AVISO",
                          "Nose puede agregar mas articulos de este producto :${producto.producto}, Productos Disponibles: ${producto.disponibleInv} ");
                    } else {
                      _agregaProductoVenta(
                        producto,
                        double.parse(CantidadConttroller.text),
                      );
                    }
                  }
                }
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
    final selectedList =
        sesion.cotizar! ? listaProductos : listaProductosSucursal;
    List<Widget> listaProd = [];
    if (selectedList.isNotEmpty) {
      for (Producto producto
          in sesion.cotizar! ? listaProductos : listaProductosSucursal) {
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
                      if (sesion.cotizar!) {
                        _alertaProducto(producto);
                      } else {
                        if (producto.disponibleInv! > 0) {
                          _alertaProducto(producto);
                        } else {
                          mostrarAlerta(context, "AVISO",
                              "No cuenta con productos disponibles");
                        }
                      }
                    } else {
                      if (sesion.cotizar!) {
                        _agregaProductoVenta(producto, 0);
                      } else {
                        if (producto.disponibleInv! > 0) {
                          if (ventaTemporal.isEmpty) {
                            _agregaProductoVenta(producto, 0);
                          } else {
                            ItemVenta? descue = ventaTemporal.firstWhere(
                              (descuento) =>
                                  descuento.idArticulo == producto.id,
                              orElse: () => ItemVenta(
                                  idArticulo: -1,
                                  apartado: true,
                                  cantidad: 1,
                                  descuento: 1,
                                  idDescuento: 1,
                                  precioPublico: 10,
                                  preciodistribuidor: 10,
                                  preciomayoreo: 10,
                                  subTotalItem: 10,
                                  totalItem: 10),
                            );
                            var catidad = descue.cantidad + 1;
                            if (catidad > producto.disponibleInv!) {
                              mostrarAlerta(context, "AVISO",
                                  "Nose puede agregar mas articulos de este producto :${producto.producto}");
                            } else {
                              _agregaProductoVenta(producto, 0);
                            }
                          }
                        } else {
                          mostrarAlerta(context, "AVISO",
                              "No cuenta con productos disponibles");
                        }
                      }
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
    totalVentaTemporal = 0;
    var aplica = listaVariables
        .firstWhere((variables) => variables.nombre == "aplica_mayoreo");
    for (ItemVenta item in ventaTemporal) {
      if (aplica.valor == "0") {
        totalVentaTemporal += item.cantidad * item.precioPublico;
        item.subTotalItem += item.cantidad * item.precioPublico;
        item.totalItem += item.cantidad * item.precioPublico;
      } else {
        if (item.cantidad >= double.parse(listaVariables[3].valor!)) {
          totalVentaTemporal += item.cantidad * item.preciomayoreo;
          item.subTotalItem += totalVentaTemporal;
          item.totalItem += totalVentaTemporal;
        } else {
          totalVentaTemporal += item.totalItem;
        }
      }
    }
    setState(() {});
  }

  _agregaProductoVenta(Producto producto, cantidad) {
    bool existe = false;
    if (producto.unidad == "1") {
      for (ItemVenta item in ventaTemporal) {
        if (item.idArticulo == producto.id) {
          existe = true;
          item.cantidad++;
          item.subTotalItem = item.precioPublico * item.cantidad;
          item.totalItem = item.subTotalItem - item.descuento;
        }
      }
      if (!existe) {
        ventaTemporal.add(ItemVenta(
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
        for (ItemVenta item in ventaTemporal) {
          if (item.idArticulo == producto.id) {
            existe = true;
            item.cantidad++;
            item.subTotalItem = item.precioPublico * cantidad;
            item.totalItem = item.subTotalItem - item.descuento;
          }
        }
        if (!existe) {
          ventaTemporal.add(ItemVenta(
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
