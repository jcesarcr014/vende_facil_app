// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/apartado_provider.dart';
import 'package:vende_facil/util/imprime_tickets.dart';
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
  bool isPrinted = false;

  final efectivoController = TextEditingController();
  final tarjetaController = TextEditingController();
  final fechaController = TextEditingController();
  final apartadosCabecera = ApartadoProvider();
  final impresionesTicket = ImpresionesTickets();
  String formattedEndDate = "";
  DateTime now = DateTime.now();
  late DateTime _fechaVencimiento;
  late DateFormat dateFormatter;
  bool fechaValida = false;
  String anticipoMinimo = '';

  @override
  void initState() {
    totalCompra = totalVentaTemporal.toStringAsFixed(2);
    anticipoMinimo =
        ((totalVentaTemporal * (double.parse(listaVariables[0].valor!))) / 100)
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
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Total de la compra: ',
                          maxLines: 2,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25)),
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
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  TextFormField(
                    controller: fechaController,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: now,
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        dateFormatter = DateFormat('yyyy-MM-dd');
                        formattedEndDate = dateFormatter.format(picked);
                        DateTime referencia =
                            DateTime(now.year, now.month, now.day);

                        if (picked.isBefore(referencia) ||
                            picked.isAtSameMomentAs(referencia)) {
                          fechaValida = false;
                          mostrarAlerta(context, 'ERROR',
                              'La fecha de vencimiento del apartadodebe ser posterior al dia de hoy.');
                          return;
                        }
                        fechaValida = true;
                        setState(() {
                          fechaController.text = formattedEndDate;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: now,
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            dateFormatter = DateFormat('yyyy-MM-dd');
                            formattedEndDate = dateFormatter.format(picked);
                            DateTime referencia =
                                DateTime(now.year, now.month, now.day);

                            if (picked.isBefore(referencia) ||
                                picked.isAtSameMomentAs(referencia)) {
                              fechaValida = false;
                              mostrarAlerta(context, 'ERROR',
                                  'La fecha de vencimiento del apartadodebe ser posterior al dia de hoy.');
                              return;
                            }
                            fechaValida = true;
                            setState(() {
                              fechaController.text = formattedEndDate;
                            });
                            setState(() {
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  SizedBox(
                    height: windowHeight * 0.01,
                  ),
                  InputFieldMoney(
                    controller: tarjetaController,
                    labelText: 'Tarjeta',
                  ),
                  SizedBox(height: windowHeight * 0.025),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        Checkbox(
                            value: isPrinted,
                            onChanged: (value) => setState(() {
                                  isPrinted = value!;
                                })),
                        Text('Imprimir ticket')
                      ],
                    ),
                  ),
                  SizedBox(height: windowHeight * 0.025),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _validaciones(apartado);
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
                ],
              ),
            ),
    );
  }

  _validaciones(ApartadoCabecera apartado) {
    bool validaciones = true;
    if (!fechaValida) {
      validaciones = false;
      mostrarAlerta(context, 'ERROR',
          'La fecha de vencimiento no es válida, debe ser mayor al dia de hoy.');
      return;
    }
    double totalAnticipo = double.parse(efectivoController.text) +
        double.parse(tarjetaController.text);

    if (totalAnticipo >= double.parse(totalCompra)) {
      validaciones = false;
      mostrarAlerta(context, 'ERROR',
          'Estas ingresando un monto mayor o igual al total de la compra, para apartado, el anticipo debe ser menor al total de la compra $totalCompra.');
      return;
    }

    if (totalAnticipo < double.parse(anticipoMinimo)) {
      validaciones = false;
      mostrarAlerta(context, 'ERROR',
          'El anticipo ingresado es menor al monto mínimo requerido de $anticipoMinimo');
      return;
    }

    if (validaciones) {
      setState(() {
        isLoading = true;
        textLoading = 'Guardando datos';
      });
      final fechaActual = DateTime(now.year, now.month, now.day);
      DateFormat fechaFormateada = DateFormat('yyyy-MM-dd');
      formattedEndDate = dateFormatter.format(_fechaVencimiento);
      apartado.pagoEfectivo =
          double.parse(efectivoController.text.replaceAll(',', ''));
      apartado.pagoTarjeta =
          double.parse(tarjetaController.text.replaceAll(',', ''));
      apartado.anticipo = totalAnticipo;
      apartado.saldoPendiente = apartado.total! - totalAnticipo;
      apartado.fechaApartado = fechaFormateada.format(fechaActual);
      apartado.fechaVencimiento = fechaController.text;
      List<ApartadoDetalle> detalles = [];
      for (ItemVenta item in ventaTemporal) {
        ApartadoDetalle apartadoDetalle = ApartadoDetalle(
          productoId: item.idArticulo,
          cantidad: item.cantidad,
          precio: item.precioPublico,
          subtotal: item.subTotalItem,
          descuentoId: apartado.descuentoId,
          descuento: item.descuento,
          total: item.totalItem,
        );
        detalles.add(apartadoDetalle);
      }

      apartadosCabecera
          .guardaApartadoCompleto(apartado, detalles)
          .then((resp) async {
        if (resp.status == 1) {
          setState(() {
            textLoading = '';
            isLoading = false;
            totalVentaTemporal = 0.0;
          });
          if (isPrinted) {
            final result = await impresionesTicket.imprimirApartado(
                apartado,
                totalAnticipo,
                double.parse(totalCompra) - totalAnticipo,
                double.parse(tarjetaController.text),
                double.parse(efectivoController.text));
            if (result.status == 1) {
              Navigator.pushReplacementNamed(context, 'home');
              ventaTemporal.clear();
              return;
            }
            isLoading = false;
            setState(() {});
            mostrarAlerta(context, 'Error', result.mensaje ?? 'Algo salio mal');
            return;
          }
          Navigator.pushReplacementNamed(context, 'home');
          mostrarAlerta(context, '', 'Apartado realizada');
        } else {
          setState(() {
            textLoading = '';
            isLoading = false;
          });
          mostrarAlerta(
              context, 'ERROR', 'Ocurrio el siguiente error: ${resp.mensaje}');
        }
      });
    }
  }
}
