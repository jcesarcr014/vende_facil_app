import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';

class VentaDetalleScreen extends StatefulWidget {
  const VentaDetalleScreen({Key? key}) : super(key: key);

  @override
  State<VentaDetalleScreen> createState() => _VentaDetalleScreenState();
}

class _VentaDetalleScreenState extends State<VentaDetalleScreen> {
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
        title: const Text('Detalle de venta'),
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
                  Column(children: _listaTemporal()),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    SizedBox(width: windowWidth * 0.1),
                    SizedBox(
                      width: windowWidth * 0.2,
                      child: const Text(
                        'Subtotal ',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    SizedBox(width: windowWidth* 0.1),
                    SizedBox(
                      width: windowWidth * 0.2,
                      child: const Text(
                        'Descuento ',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    SizedBox(width: windowWidth * 0.1),
                    SizedBox(
                      width: windowWidth * 0.2,
                      child: const Text(
                        'Total ',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    SizedBox(width: windowWidth * 0.1),
                    SizedBox(
                      width: windowWidth * 0.2,
                      height: windowHeight* 0.2,
                    ),
                  ]),
                  Center(
                    child: ElevatedButton(
                        onPressed: () {},
                        child: SizedBox(
                          height: windowHeight * 0.1,
                          width: windowWidth * 0.6,
                          child: Center(
                            child: Text(
                                'Cobrar \$${totalVentaTemporal.toStringAsFixed(2)}'),
                          ),
                        )),
                  ),
                ],
              )),
    );
  }

  _listaTemporal() {
    List<Widget> productos = [];
    for (ItemVenta item in ventaTemporal) {
      for (Producto prod in listaProductos) {
        if (prod.id == item.idArticulo) {
          productos.add(ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: windowWidth * 0.3,
                  child: Text(
                    '${prod.producto} ',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: windowWidth * 0.1,
                        child: IconButton(
                            onPressed: () {
                              item.cantidad--;
                              item.subTotalItem = item.precio * item.cantidad;
                              item.totalItem =
                                  item.subTotalItem - item.descuento;
                              setState(() {});
                            },
                            icon: const Icon(Icons.remove_circle_outline))),
                    SizedBox(
                        width: windowWidth * 0.15,
                        child: Text(
                          '  ${item.cantidad} ',
                          textAlign: TextAlign.center,
                        )),
                    SizedBox(
                        width: windowWidth * 0.1,
                        child: IconButton(
                            onPressed: () {
                              item.cantidad++;
                              item.subTotalItem = item.precio * item.cantidad;
                              item.totalItem =
                                  item.subTotalItem - item.descuento;
                              setState(() {});
                            },
                            icon: const Icon(Icons.add_circle_outline))),
                  ],
                ),
                Text('\$${item.totalItem.toStringAsFixed(2)}')
              ],
            ),
            subtitle: const Divider(),
          ));
        }
      }
    }
    return productos;
  }
}
