import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/apartado_provider.dart';
import 'package:vende_facil/widgets/widgets.dart';

class ApartadoDetalleScreen extends StatefulWidget {
  const ApartadoDetalleScreen({super.key});
  @override
  State<ApartadoDetalleScreen> createState() => _ApartadoDetalleScreenState();
}

class _ApartadoDetalleScreenState extends State<ApartadoDetalleScreen> {
  bool isLoading = false;
  String textLoading = '';
  String totalCompra = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  double efectivo = 0.0;
  double tarjeta = 0.0;
  double total = 0.0;
  int cantidad = 0;

  final efectivoController = TextEditingController();
  final tarjetaController = TextEditingController();
  final fechaController = TextEditingController();
  final apartadosCabecera = ApartadoProvider();
  String formattedEndDate = "";
  DateTime now = DateTime.now();
  late DateTime _fechaVencimiento;
  late DateFormat dateFormatter;
  String anticipoMinimo = '';

  @override
  void initState() {
    totalCompra = totalVentaTemporal.toStringAsFixed(2);
    anticipoMinimo =
        ((totalVentaTemporal * (num.parse(listaVariables[0].valor) as double)) /
                100)
            .toStringAsFixed(2);
    efectivoController.text = "0.00";
    tarjetaController.text = "0.00";
    _fechaVencimiento = DateTime(now.year, now.month, now.day);
    dateFormatter = DateFormat('yyyy-MM-dd');
    formattedEndDate = dateFormatter.format(_fechaVencimiento);
    fechaController.text = formattedEndDate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    final ApartadoCabecera apartado =
        ModalRoute.of(context)?.settings.arguments as ApartadoCabecera;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apartado'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Total de la compra: ',
                    maxLines: 2,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                Text('\$ $totalCompra',
                    style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 25))
              ],
            ),
            SizedBox(
              height: windowHeight * 0.03,
            ),
            Row(
              children: [
                const Text('Anticipo minimo: ',
                    maxLines: 2,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text('\$ $anticipoMinimo',
                    style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 20))
              ],
            ),
            SizedBox(
              height: windowHeight * 0.03,
            ),
            const Text('Fecha de vencimiento:',
                maxLines: 2,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            TextFormField(
              controller: fechaController,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2015),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    dateFormatter = DateFormat('yyyy-MM-dd');
                    formattedEndDate = dateFormatter.format(picked);
                    fechaController.text = formattedEndDate;
                  });
                }
              },
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2015),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        dateFormatter = DateFormat('yyyy-MM-dd');
                        formattedEndDate = dateFormatter.format(picked);
                        fechaController.text = formattedEndDate;
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                ),
              ),
            ),
            SizedBox(
              height: windowHeight * 0.05,
            ),
            const Text('Anticipo en efectivo:',
                maxLines: 2,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            SizedBox(
              height: windowHeight * 0.01,
            ),
            InputFieldMoney(
              controller: efectivoController,
              labelText: 'Efectivo',
            ),
            SizedBox(
              height: windowHeight * 0.05,
            ),
            const Text("Anticipo en tarjeta:",
                maxLines: 2,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            SizedBox(
              height: windowHeight * 0.01,
            ),
            InputFieldMoney(
              controller: tarjetaController,
              labelText: 'Tarjeta',
            ),
            SizedBox(
              height: windowHeight * 0.05,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _checkVenta(apartado);
                  },
                  child: const Text('Aceptar'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _checkVenta(ApartadoCabecera apartado) {
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
      double efectivo =
          double.parse(efectivoController.text.replaceAll(',', ''));
      double total = double.parse(totalCompra);
      num acticipo = total * (num.parse(listaVariables[0].valor) as int) / 100;
      double tarjeta = double.parse(tarjetaController.text.replaceAll(',', ''));
      double resultado = efectivo + tarjeta;
      if (tarjeta > acticipo) {
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
        for (ItemVenta item in ventaTemporal) {
          cantidad = (cantidad + item.cantidad) as int;
        }
        if (double.parse(listaVariables[1].valor) < cantidad) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                content: const Text(
                    'La cantidad de artículos excede a la cantidad registrada por el usuario.'),
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
          if (resultado >= acticipo) {
            _apartado(apartado);
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
  }

  _apartado(ApartadoCabecera apartado) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Procesado Apartado..."),
            ],
          ),
        );
      },
    );
    apartado.anticipo = double.parse(efectivoController.text) +
        double.parse(tarjetaController.text);
    apartado.pagoEfectivo = double.parse(efectivoController.text);
    apartado.pagoTarjeta = double.parse(tarjetaController.text);
    apartado.saldoPendiente = (apartado.total! - apartado.anticipo!);
    apartadosCabecera.guardaApartado(apartado).then((value) {
      if (!mounted) return; // Comprobar si el widget está montado

      if (value.status == 1) {
        Navigator.pop(context);
        for (ItemVenta item in ventaTemporal) {
          ApartadoDetalle ventaDetalle = ApartadoDetalle(
            apartadoId: value.id,
            productoId: item.idArticulo,
            cantidad: item.cantidad,
            precio: item.precio,
            descuentoId: apartado.descuentoId,
            descuento: apartado.descuento,
            total: item.totalItem,
            subtotal: item.subTotalItem,
          );

          apartadosCabecera.guardaApartadoDetalle(ventaDetalle).then((value) {
            if (value.status == 1) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    content: const Text('Apartado realizada con éxito'),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            efectivo = 0.0;
                            tarjeta = 0.0;
                            total = 0.0;
                            efectivoController.clear();
                            tarjetaController.clear();
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
}
