// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/venta_provider.dart';
import 'package:vende_facil/widgets/input_field_money.dart';

class VentaScreen extends StatefulWidget {
  const VentaScreen({super.key});
  @override
  State<VentaScreen> createState() => _ventaScreenState();
}

class _ventaScreenState extends State<VentaScreen> {
  final TotalConttroller = TextEditingController();
  final EfectivoController = TextEditingController();
  final CambioController = TextEditingController();
  final TarjetaController = TextEditingController();
  final ventaCabecera = VentasProvider();
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  double efectivo = 0.0;
  double tarjeta = 0.0;
  double cambio = 0.0;
  double totalEfectivo = 0.0;
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    TotalConttroller.text = totalVentaTemporal.toStringAsFixed(2);
    EfectivoController.text = "0.00";
    TarjetaController.text = "0.00";
    CambioController.text = "0.00";
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    final VentaCabecera venta =
        ModalRoute.of(context)?.settings.arguments as VentaCabecera;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de cobro'),
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
              padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.01),
              child: Column(
                children: [
                  SizedBox(
                    height: windowHeight * 0.03,
                  ),
                  const Text(
                      'Ingrese la forma de pago y asegurese de que el cambio sea correcto.',
                      maxLines: 3,
                      textAlign: TextAlign.justify,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      )),
                  SizedBox(
                    height: windowHeight * 0.03,
                  ),

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
                          enabled: false,
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
                            child: InputFieldMoney(
                          controller: EfectivoController,
                          onChanged: (value) {
                            tuFuncion();
                          },
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
                            child: InputFieldMoney(
                          controller: TarjetaController,
                          onChanged: (value) {
                            tuFuncion();
                          },
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
                          enabled: false,
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
                            _checkVenta(venta);
                          },
                          child: const Text('Aceptar'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancelar'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _checkVenta(VentaCabecera venta) {
    if (ventaTemporal.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: const Text('No hay productos en la venta'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceptar '),
              ),
            ],
          );
        },
      );
    } else {
      efectivo = double.parse(EfectivoController.text.replaceAll(',', ''));
      total = double.parse(TotalConttroller.text);
      tarjeta = double.parse(TarjetaController.text.replaceAll(',', ''));
      cambio = double.parse(CambioController.text);
      totalEfectivo = efectivo - cambio;
      double resultado = totalEfectivo + tarjeta;
      if (tarjeta > total) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              content: const Text('El pago con tarjeta es mayor al total'),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Aceptar '),
                ),
              ],
            );
          },
        );
      } else {
        if (resultado == total) {
          _compra(venta);
        } else {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                content: const Text('El efectivo es menor al total'),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Aceptar '),
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

  _compra(VentaCabecera venta) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Procesado venta..."),
            ],
          ),
        );
      },
    );
    venta.importeTarjeta = tarjeta;
    venta.importeEfectivo = totalEfectivo;
    ventaCabecera.guardarVenta(venta).then((value) {
      if (!mounted) return; // Comprobar si el widget está montado

      if (value.status == 1) {
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
            if (value.status == 1) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    content: const Text('Venta realizada con éxito'),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            efectivo = 0.0;
                            tarjeta = 0.0;
                            total = 0.0;
                            TotalConttroller.clear();
                            EfectivoController.clear();
                            TarjetaController.clear();
                            CambioController.clear();
                            ventaTemporal.clear();
                            totalVentaTemporal = 0.00;
                          });
                          Navigator.pushReplacementNamed(context, 'home');
                        },
                        child: const Text('Aceptar'),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    content: Text('${value.mensaje}'),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Aceptar'),
                      ),
                    ],
                  );
                },
              );
            }
          });
        }
      }
    });
  }

  tuFuncion() {
    try {
      if (EfectivoController.text.contains(',')) {
        efectivo = double.parse(EfectivoController.text.replaceAll(',', ''));
      } else {
        efectivo = double.parse(EfectivoController.text);
      }
      if (TarjetaController.text.contains(',')) {
        tarjeta = double.parse(TarjetaController.text.replaceAll(',', ''));
      } else {
        tarjeta = double.parse(TarjetaController.text);
      }
      total = double.parse(TotalConttroller.text);

      var suma = efectivo + tarjeta;
      var cambio = suma - total;
      if (cambio < 0) {
        CambioController.text = "0.00";
        setState(() {});
      } else {
        CambioController.text = cambio.toStringAsFixed(2);
        setState(() {});
      }

      // ignore: empty_catches
    } catch (e) {
      // ignore: avoid_print
      print('Error: $e');
    }
  }
}
