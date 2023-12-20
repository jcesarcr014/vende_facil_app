import 'package:flutter/material.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final articulosProvider = ArticuloProvider();
  final categoriasProvider = CategoriaProvider();
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  double totalVentaTemporal = 0.0;
  @override
  void initState() {
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
              onPressed: () {},
              child: SizedBox(
                  width: windowWidth * 0.25,
                  height: windowHeight * 0.05,
                  child: const Center(child: Icon(Icons.search)))),
          SizedBox(
            width: windowWidth * 0.05,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, 'bar-code');
              },
              child: SizedBox(
                  width: windowWidth * 0.25,
                  height: windowHeight * 0.05,
                  child: const Center(child: Icon(Icons.qr_code_scanner))))
        ],
      ),
    ];

    return listaItems;
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
                    _agregaProductoVenta(producto);
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
                      // Text('\$ ${producto.precio!.toStringAsFixed(2)}')
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

  _agregaProductoVenta(Producto producto) {
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
    } else {}

    _actualizaTotalTemporal();
  }

  _actualizaTotalTemporal() {
    for (ItemVenta item in ventaTemporal) {
      totalVentaTemporal += item.totalItem;
    }
    setState(() {});
  }
}
