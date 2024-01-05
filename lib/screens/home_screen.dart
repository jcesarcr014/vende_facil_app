import 'package:flutter/material.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/models/models.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:vende_facil/screens/search_screen.dart';
import 'package:vende_facil/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final articulosProvider = ArticuloProvider();
  final categoriasProvider = CategoriaProvider();
  final CantidadConttroller = TextEditingController();
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  @override
  void initState() {
    _actualizaTotalTemporal();
    setState(() {
      textLoading = 'Leyendo articulos';
      isLoading = true;
    });
    categoriasProvider.listarCategorias().then((respuesta) {
      articulosProvider.listarProductos().then((value) {
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
              'ATENCIÓN',
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
            onPressed: () {},
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
          OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, 'detalle-venta');
                setState(() {});
              },
              child: SizedBox(
                  height: windowHeight * 0.1,
                  width: windowWidth * 0.25,
                  child: const Center(child: Text('Detalle'))))
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
                  child: const Center(child: Icon(Icons.qr_code_scanner)))),
          SizedBox(
            width: windowWidth * 0.05,
          ),
          ElevatedButton(
              onPressed: () {
                _alertaElimnar();
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
                if (CantidadConttroller.text == "0.0" ||
                    CantidadConttroller.text == "0"||
                    CantidadConttroller.text == ".0"||
                    CantidadConttroller.text == "0.") {
                } else {
                  _agregaProductoVenta(
                    producto,
                    double.parse(CantidadConttroller.text),
                  );
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
    List<Widget> listaProd = [];
    if (listaProductos.isNotEmpty) {
      for (Producto producto in listaProductos) {
        for (Categoria categoria in listaCategorias) {
          if (producto.idCategoria == categoria.id) {
            for (ColorCategoria color in listaColores) {
              if (color.id == categoria.idColor) {
                listaProd.add(ListTile(
                  leading: (producto.imagen == null)
                      ? Icon(
                          Icons.category,
                          color: color.color,
                        )
                      : FadeInImage(
                          placeholder: const AssetImage('assets/loading.gif'),
                          image: NetworkImage(producto.imagen!),
                          width: windowWidth * 0.1,
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
    totalVentaTemporal = 0;
    for (ItemVenta item in ventaTemporal) {
      totalVentaTemporal += item.totalItem;
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
          item.subTotalItem = item.precio * item.cantidad;
          item.totalItem = item.subTotalItem - item.descuento;
        }
      }
      if (!existe) {
        ventaTemporal.add(ItemVenta(
          idArticulo: producto.id!,
          cantidad: 1,
          precio: producto.precio!,
          idDescuento: 0,
          descuento: 0,
          subTotalItem: producto.precio!,
          totalItem: producto.precio!,
        ));
      }
      _actualizaTotalTemporal();
    } else {
      if (producto.unidad == "0") {
        for (ItemVenta item in ventaTemporal) {
          if (item.idArticulo == producto.id) {
            existe = true;
            item.cantidad++;
            item.subTotalItem = item.precio * cantidad;
            item.totalItem = item.subTotalItem - item.descuento;
          }
        }
        if (!existe) {
          ventaTemporal.add(ItemVenta(
            idArticulo: producto.id!,
            cantidad: cantidad,
            precio: producto.precio!,
            idDescuento: 0,
            descuento: 0,
            subTotalItem: producto.precio!,
            totalItem: producto.precio! * cantidad,
          ));
        }
        _actualizaTotalTemporal();
      } else {}
      _actualizaTotalTemporal();
    }
  }
}
