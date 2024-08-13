import 'package:flutter/material.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/screens/search_screenProductos.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final articulosProvider = ArticuloProvider();
  final categoriasProvider = CategoriaProvider();
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;

  @override
  void initState() {
    if (globals.actualizaArticulos) {
      setState(() {
        textLoading = 'Leyendo articulos';
        isLoading = true;
      });
      articulosProvider.listarProductos().then((respProd) {
        if (respProd.status == 1) {
          globals.actualizaArticulos = false;
        }
        setState(() {
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
          title: const Text('Productos'),
          automaticallyImplyLeading: false,
          actions: [
            //IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            //IconButton(onPressed: () {}, icon: const Icon(Icons.qr_code_scanner)),
            IconButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, 'menu');
                },
                icon: const Icon(Icons.menu)),
            IconButton(
                onPressed: () {
                  showSearch(context: context, delegate: Searchproductos());
                },
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
                padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: windowHeight * 0.02,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: windowWidth * 0.07),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, 'nvo-producto');
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add),
                            SizedBox(
                              width: 5,
                            ),
                            Text('Nuevo producto'),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: windowHeight * 0.02,
                    ),
                    const Divider(),
                    SizedBox(
                      height: windowHeight * 0.01,
                    ),
                    Column(children: _productos())
                  ],
                ),
              ),
      ),
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
                    setState(() {
                      textLoading = 'Leyendo producto';
                      isLoading = true;
                    });

                    articulosProvider
                        .consultaProducto(producto.id!)
                        .then((value) {
                      setState(() {
                        textLoading = '';
                        isLoading = false;
                      });
                      if (value.id != 0) {
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
            'No hay productos guardados.',
            style: textTheme.titleMedium,
          )
        ],
      ));
    }

    return listaProd;
  }
}
