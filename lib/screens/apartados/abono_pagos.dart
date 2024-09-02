// ignore_for_file: non_constant_identifier_names, camel_case_types, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/widgets/input_field_money.dart';
import '../../providers/apartado_provider.dart';

class AbonoScreenpago extends StatefulWidget {
  const AbonoScreenpago({super.key});
  @override
  State<AbonoScreenpago> createState() => _AbonoScreenState();
}

class _AbonoScreenState extends State<AbonoScreenpago> {
  final TotalConttroller = TextEditingController();
  final EfectivoController = TextEditingController();
  final CambioController = TextEditingController();
  final TarjetaController = TextEditingController();
  final apartado = ApartadoProvider();
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
    EfectivoController.addListener(_updateCambio);
  }

  void _updateCambio() {
    setState(() {
      double efectivo =
          double.tryParse(EfectivoController.text.replaceAll(',', '')) ?? 0.0;
      double tarjeta =
          double.tryParse(TarjetaController.text.replaceAll(',', '')) ?? 0.0;
      double total = double.tryParse(TotalConttroller.text) ?? 0.0;
      double totalEfectivo = efectivo - tarjeta;
      double cambio = totalEfectivo - total;

      if (cambio < 0) {
        cambio = 0.0;
      }

      CambioController.text = cambio.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    final VentaCabecera venta =
        ModalRoute.of(context)?.settings.arguments as VentaCabecera;
     TotalConttroller.text= "${venta.total}";
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de cobro abonos'),
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
      efectivo = double.parse(EfectivoController.text.replaceAll(',', ''));
      total = double.parse(TotalConttroller.text);
      tarjeta = double.parse(TarjetaController.text.replaceAll(',', ''));
      cambio = double.parse(CambioController.text);
      totalEfectivo = efectivo - cambio;
      double resultado = totalEfectivo + tarjeta;
      if (0 > resultado) {
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
          final abono = Abono(
                                            id: 0,
                                            apartadoId: listaApartados2[0].id,
                                            cantidadEfectivo: efectivo,
                                            cantidadTarjeta: tarjeta,
                                          );
          _compra(abono);
      }
    
  }

  _compra(Abono venta) async {
    setState(() {
      isLoading = true;
      textLoading = 'Agregado abono';
    });
    venta.cantidadTarjeta = tarjeta;
    venta.cantidadEfectivo = totalEfectivo;
                                              apartado
                                              .abono(
                                                  listaApartados2[0].id!, venta)
                                              .then((value) {
                                            if (value.status == 1) {
                                              Navigator.pop(context);
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Abono Agregado'),
                                                    content: const Text(
                                                        'El abono se ha agregado correctamente'),
                                                    actions: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pushNamed(
                                                              context,
                                                              'nvo-abono',
                                                              arguments: value);
                                                        },
                                                        child: const Text(
                                                            'Aceptar'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text('Error'),
                                                    content: const Text(
                                                        'No se pudo agregar el abono'),
                                                    actions: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                            'Aceptar'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          });
                                        }}