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
  @override
  void initState() {
    ventaTemporal.clear();
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
                    print(producto.producto);
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
    print("que llega a la funcion  ${producto.producto}");
    bool existe = false;
    print("el id que llega ${producto.id!.toInt()}");
    articulosProvider.consultaProducto(producto.id!.toInt()).then((value) {
      print(" el dato que llega de la consulta ${value.producto}");
      print(" el dato que llega de la unidad ${value.unidad}");
      if (value.unidad == "1") {
        print('entro al primer if ');
        print('el arreglo  esta $ventaTemporal');
        for (ItemVenta item in ventaTemporal) {
          print("el itemventa  esta  ${item.idArticulo}");
          if (item.idArticulo == value.id) {
            print("entro al segundo  if ");
            print("el id del value ${value.id}");
            print("el id del item ${item.idArticulo}");
            existe = true;
            item.cantidad++;
            item.subTotalItem = item.precio * item.cantidad;
            print("el precio es ${item.precio}");
            print("la cantidad es ${item.cantidad}");
            print("el  subtotal es ${item.subTotalItem}");
            item.totalItem = item.subTotalItem - item.descuento;
            print(" el total ${item.totalItem}");
            print(" el descuento es ${item.descuento}");
          }
        }
        if (!existe) {
          ventaTemporal.add(ItemVenta(
            idArticulo: value.id!,
            cantidad: 1,
            precio: value.precio!,
            idDescuento: 0,
            descuento: 0,
            subTotalItem: value.precio!,
            totalItem: value.precio!,
          ));
          print(" el arreglo  esta lleno $ventaTemporal");
        }
      } else {}
    });

    _actualizaTotalTemporal();
  }

  _actualizaTotalTemporal() {
    //totalVentaTemporal = 0;
    for (ItemVenta item in ventaTemporal) {
      totalVentaTemporal += item.totalItem;
    }
    setState(() {});
  }
}
