import 'package:flutter/material.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/widgets/widgets.dart';

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
    setState(() {
      textLoading = 'Leyendo articulos';
      isLoading = true;
    });

    categoriasProvider.listarCategorias().then((respuesta) {
      articulosProvider.listarProductos().then((value) {});
    });
    articulosProvider.listarProductos().then((value) {
      categoriasProvider.listarCategorias().then((respuesta) {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.qr_code_scanner)),
          IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'menu');
              },
              icon: const Icon(Icons.menu)),
        ],
      ),
      drawer: const Menu(),
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
    );
  }

  _productos() {
    List<Widget> listaProd = [];
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
                onTap: (() => Navigator.pushNamed(context, 'nvo-producto',
                    arguments: producto)),
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
                    Text('\$ ${producto.precio!.toStringAsFixed(2)}')
                  ],
                ),
                subtitle: Text(categoria.categoria!),
              ));
            }
          }
        }
      }
    }

    return listaProd;
  }
}
