import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/venta_provider.dart';

class VentaScreen extends StatefulWidget {
  const VentaScreen({super.key});
  @override
  State<VentaScreen> createState() => _ventaScreenState();
}

// ignore: camel_case_types
class _ventaScreenState extends State<VentaScreen> {
  final TotalConttroller = TextEditingController();
  final EfectivoController = TextEditingController();
  final CambioController = TextEditingController();
  final TarjetaController = TextEditingController();
    final ventaCabecera = VentasProvider();
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
   final VentaCabecera venta = ModalRoute.of(context)?.settings.arguments as VentaCabecera;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Venta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ignore: avoid_unnecessary_containers
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Flexible(child: Text("Total:")),
                  SizedBox(
                    width: windowWidth * 0.01,
                  ),
                  Flexible(
                      child: TextField(
                    controller: TotalConttroller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Total',
                      border: OutlineInputBorder(),
                    ),
                  ))
                ],
              ),
            ),
            SizedBox(
              height: windowHeight * 0.05,
            ),
            // ignore: avoid_unnecessary_containers
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Flexible(child: Text("Efectivo:")),
                  SizedBox(
                    width: windowWidth * 0.01,
                  ),
                  Flexible(
                      child: TextField(
                    controller: EfectivoController,
                    decoration: const InputDecoration(
                      labelText: 'Efectivo',
                      border: OutlineInputBorder(),
                    ),
                  ))
                ],
              ),
            ),
            SizedBox(
              height: windowHeight * 0.05,
            ),
            // ignore: avoid_unnecessary_containers
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Flexible(child: Text("Tarjeta:")),
                  SizedBox(
                    width: windowWidth * 0.01,
                  ),
                  Flexible(
                      child: TextField(
                    controller: TarjetaController,
                    decoration: const InputDecoration(
                      labelText: 'Tarjeta',
                      border: OutlineInputBorder(),
                    ),
                  ))
                ],
              ),
            ),
            SizedBox(
              height: windowHeight * 0.05,
            ),
            // ignore: avoid_unnecessary_containers
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Flexible(child: Text("Cambio:")),
                  SizedBox(
                    width: windowWidth * 0.01,
                  ),
                  Flexible(
                      child: TextField(
                    controller: CambioController,
                    decoration: const InputDecoration(
                      labelText: 'Cambio',
                      border: OutlineInputBorder(),
                    ),
                  ))
                ],
              ),
            ),
            SizedBox(
              height: windowHeight * 0.05,
            ),
            // ignore: avoid_unnecessary_containers
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      venta.importeTarjeta = double.parse(TarjetaController.text);
                      venta.importeEfectivo = double.parse(EfectivoController.text);
                      ventaCabecera.guardarVenta(venta).then((value) {
                        if (value.status==1) {
                          Navigator.pop(context);
                          for (ItemVenta item in ventaTemporal) {
        VentaDetalle ventaDetalle = VentaDetalle(
          idVenta: value.id,
          idProd: item.idArticulo,
          cantidad: item.cantidad,
          precio: item.precio,
          idDesc: venta.idDescuento,
          cantidadDescuento: venta.descuento,
          total: item.totalItem,
          subtotal: item.subTotalItem,
        );

        ventaCabecera.guardarVentaDetalle(ventaDetalle).then((value) {
        });
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: const Text('Venta realizada con exito'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  TotalConttroller.clear();
                  EfectivoController.clear();
                  TarjetaController.clear();
                  CambioController.clear();
                  ventaTemporal.clear();
                  totalVentaTemporal = 0.00;
                  Navigator.pushReplacementNamed(context, 'home');
                },
                child: const Text('Aceptar '),
              ),
            ],
          );
        },
      );
                        } else {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return AlertDialog(
                                shape:
                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                content: Text('${value.mensaje}'),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Aceptar '),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      });

                    },
                    child: Text('Aceptar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Lógica para el botón Cancelar
                    },
                    child: Text('Cancelar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
