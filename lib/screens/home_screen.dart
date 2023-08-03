import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vende Facil'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'menu');
              },
              icon: const Icon(Icons.menu)),
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
                children: _listaWidgets(),
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
              )),
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
      const Divider(),
      Column(
        children: _listaProductos(),
      )
    ];

    return listaItems;
  }

  _listaProductos() {
    List<Widget> listaProd = [];
    for (Producto producto in listaProductos) {
      for (Existencia existencia in inventario) {
        if (producto.id == existencia.idArticulo && existencia.cantidad! > 0) {
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
                    onTap: () {
                      _agregaProductoVenta(producto);
                    },
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
      }
    }

    return listaProd;
  }

  _agregaProductoVenta(Producto producto) {
    bool existe = false;
    if (producto.unidad == 'p') {
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
            totalItem: producto.precio!));
      }
    } else {}

    _actualizaTotalTemporal();
  }

  _actualizaTotalTemporal() {
    totalVentaTemporal = 0;
    for (ItemVenta item in ventaTemporal) {
      totalVentaTemporal += item.totalItem;
    }
    setState(() {});
  }
}
