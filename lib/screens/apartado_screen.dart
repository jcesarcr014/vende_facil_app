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
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  double efectivo = 0.0;
  double tarjeta = 0.0;
  double total = 0.0;
  int cantidad = 0;
  // ignore: non_constant_identifier_names
  final ApartadoConttoller = TextEditingController();
  // ignore: non_constant_identifier_names
  final TotalConttroller = TextEditingController();
  // ignore: non_constant_identifier_names
  final EfectivoController = TextEditingController();
  // ignore: non_constant_identifier_names
  final CambioController = TextEditingController();
  // ignore: non_constant_identifier_names
  final TarjetaController = TextEditingController();
  final _dateController = TextEditingController();
  final apartadosCabecera = ApartadoProvider();
  String formattedEndDate = "";
  String formattedStartDate = "";
  DateTime now = DateTime.now();
  late DateTime _startDate;
  late DateTime _endDate;
  late DateFormat dateFormatter;
  @override
  void initState() {
    TotalConttroller.text = totalVentaTemporal.toStringAsFixed(2);
    ApartadoConttoller.text =
        ((totalVentaTemporal * (num.parse(listaVariables[0].valor) as int)) /
                100)
            .toStringAsFixed(2);
    EfectivoController.text = "0.00";
    TarjetaController.text = "0.00";
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = _startDate.add(const Duration(days: 30));
    dateFormatter = DateFormat('yyyy-MM-dd');
    formattedStartDate = dateFormatter.format(_startDate);
    formattedEndDate = dateFormatter.format(_endDate);
    _dateController.text = '$formattedStartDate - $formattedEndDate';
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ignore: avoid_unnecessary_containers
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Flexible(child: Text("Fecha:")),
                  SizedBox(
                    width: windowWidth * 0.01,
                  ),
                  Flexible(
                    child: TextFormField(
                      controller: _dateController,
                      onTap: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2015),
                          lastDate: DateTime(2100),
                          initialDateRange: DateTimeRange(
                            start: formattedStartDate.isEmpty
                                ? DateTime.now()
                                : _startDate,
                            end: formattedEndDate.isEmpty
                                ? _startDate.add(const Duration(days: 30))
                                : _endDate,
                          ),
                        );
                        if (picked != null &&
                            picked !=
                                DateTimeRange(
                                    start: _startDate,
                                    end: formattedEndDate.isEmpty
                                        ? _startDate
                                            .add(const Duration(days: 30))
                                        : _endDate)) {
                          setState(() {
                            _startDate = picked.start;
                            _endDate = picked.end;
                            dateFormatter = DateFormat('yyyy-MM-dd');
                            formattedStartDate =
                                dateFormatter.format(_startDate);
                            formattedEndDate = dateFormatter.format(_endDate);
                            _dateController.text =
                                '$formattedStartDate - $formattedEndDate';
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Seleccionar fecha',
                        suffixIcon: IconButton(
                          onPressed: () async {
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2015),
                              lastDate: DateTime(2100),
                              initialDateRange: DateTimeRange(
                                start: formattedStartDate.isEmpty
                                    ? DateTime.now()
                                    : _startDate,
                                end: formattedEndDate.isEmpty
                                    ? _startDate.add(const Duration(days: 30))
                                    : _endDate,
                              ),
                            );
                            if (picked != null &&
                                picked !=
                                    DateTimeRange(
                                        start: _startDate,
                                        end: formattedEndDate.isEmpty
                                            ? _startDate
                                                .add(const Duration(days: 30))
                                            : _endDate)) {
                              setState(() {
                                _startDate = picked.start;
                                _endDate = picked.end;
                                dateFormatter = DateFormat('yyyy-MM-dd');
                                formattedStartDate =
                                    dateFormatter.format(_startDate);
                                formattedEndDate =
                                    dateFormatter.format(_endDate);
                                _dateController.text =
                                    '$formattedStartDate - $formattedEndDate';
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),
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
                  const Flexible(child: Text("Apartado:")),
                  SizedBox(
                    width: windowWidth * 0.01,
                  ),
                  Flexible(
                    child: TextFormField(
                      controller: ApartadoConttoller,
                      enabled: false,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Apartado',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
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
                  const Flexible(child: Text("Total:")),
                  SizedBox(
                    width: windowWidth * 0.01,
                  ),
                  Flexible(
                    child: TextFormField(
                      controller: TotalConttroller,
                      enabled: false,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Total',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
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
                    ),
                  ),
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
                    ),
                  ),
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
                    child: TextFormField(
                      controller: CambioController,
                      enabled: false,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cambio',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
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
            ),
          ],
        ),
      ),
    );
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
      var catidad = (total * num.parse(listaVariables[0].valor)) / 100;
      var cambio = suma - catidad;
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
          double.parse(EfectivoController.text.replaceAll(',', ''));
      double total = double.parse(TotalConttroller.text);
      num acticipo = total * (num.parse(listaVariables[0].valor) as int) / 100;
      double tarjeta = double.parse(TarjetaController.text.replaceAll(',', ''));
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
          cantidad=(cantidad+item.cantidad) as int;
        }
        if (double.parse(listaVariables[1].valor) < cantidad) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  content: const Text('La cantidad de artículos excede a la cantidad registrada por el usuario.'),
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
    apartado.anticipo = double.parse(EfectivoController.text) +
        double.parse(TarjetaController.text);
    apartado.pagoEfectivo = double.parse(EfectivoController.text);
    apartado.pagoTarjeta = double.parse(TarjetaController.text);
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
}
