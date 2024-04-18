// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/apartado_provider.dart';

class AbonoDetallesScreen extends StatefulWidget {
  const AbonoDetallesScreen({super.key});

  @override
  State<AbonoDetallesScreen> createState() => _VentaDetallesScreenState();
}

class _VentaDetallesScreenState extends State<AbonoDetallesScreen> {
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  final totalConttroller = TextEditingController();
  final efectivoConttroller = TextEditingController();
  final tarjetaConttroller = TextEditingController();
  final cambioConttroller = TextEditingController();
  final apartado = ApartadoProvider();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Detalles de Abono'),
          automaticallyImplyLeading: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Folio: ${listaApartados2[0].folio}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Cliente: ${sesion.nombreUsuario}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Fecha de Abono: ${listaApartados2[0].fechaApartado}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Saldo Pediente: ${listaApartados2[0].saldoPendiente}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Descuento: ${listaApartados2[0].descuento}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Total: \$${listaApartados2[0].total}0',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'Productos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              (isLoading)
                  ? Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Espere...$textLoading'),
                            const SizedBox(
                              height: 10,
                            ),
                            const CircularProgressIndicator(),
                          ]),
                    )
                  : Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: DataTable(
                          columnSpacing: 20, // Espacio entre columnas
                          columns: const [
                            DataColumn(label: Text('Producto')),
                            DataColumn(label: Text('Cantidad')),
                            DataColumn(label: Text('Descuento')),
                            DataColumn(label: Text('Total')),
                          ],
                          rows: detalleApartado
                              .map((detalle) => DataRow(cells: [
                                    DataCell(
                                        Text(detalle.producto.toString())),
                                    DataCell(
                                        Text(detalle.cantidad.toString())),
                                    DataCell(
                                        Text(detalle.descuento.toString())),
                                    DataCell(Text(
                                        "\$${detalle.total.toString()}0")),
                                  ]))
                              .toList(),
                        ),
                      ),
                      SizedBox(
                        height: windowHeight * 0.1,
                      ),
                      const Center(
                        child: Text(
                          'Abonos',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: DataTable(
                          columnSpacing: 20, // Espacio entre columnas
                          columns: const [
                            DataColumn(label: Text('Fecha')),
                            DataColumn(label: Text('Abonado')),
                          ],
                          rows: listaAbonos
                              .map((detalle) => DataRow(cells: [
                                    DataCell(Text(
                                        detalle.fechaAbono.toString())),
                                    DataCell(Text(
                                        "\$${(detalle.cantidadEfectivo! + detalle.cantidadTarjeta!).toString()}0")),
                                  ]))
                              .toList(),
                        ),
                      ),
                      SizedBox(
                        height: windowHeight * 0.1,
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20)),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding:
                                              EdgeInsetsDirectional
                                                  .all(5.0),
                                        ),
                                        SizedBox(
                                            height: windowHeight * 0.05),
                                        Container(
                                          width: windowWidth * 0.9,
                                          child: Row(
                                            children: [
                                              const Flexible(
                                                child: Text(
                                                  'Efectivo :',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                              SizedBox(
                                                  width:
                                                      windowWidth * 0.05),
                                              Flexible(
                                                fit: FlexFit.loose,
                                                child: TextFormField(
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .words,
                                                  controller:
                                                      efectivoConttroller,
                                                  decoration:
                                                      InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: 15.0,
                                                            horizontal:
                                                                1.0),
                                                    border:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                                  10.0),
                                                    ),
                                                  ),
                                                  onChanged: (value) {},
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                            height: windowHeight * 0.05),
                                        Container(
                                          width: windowWidth * 0.9,
                                          child: Row(
                                            children: [
                                              const Flexible(
                                                child: Text(
                                                  'Tarjeta  :',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                              SizedBox(
                                                  width:
                                                      windowWidth * 0.05),
                                              Flexible(
                                                fit: FlexFit.loose,
                                                child: TextFormField(
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .words,
                                                  controller:
                                                      tarjetaConttroller,
                                                  decoration:
                                                      InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: 15.0,
                                                            horizontal:
                                                                1.0),
                                                    border:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                                  10.0),
                                                    ),
                                                  ),
                                                  onChanged: (value) {},
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        final abono = Abono(
                                          id: 0,
                                          apartadoId: listaApartados2[0].id,
                                          cantidadEfectivo: double.parse(
                                              efectivoConttroller.text),
                                          cantidadTarjeta: double.parse(
                                              tarjetaConttroller.text),
                                        );
                                        apartado
                                            .abono(listaApartados2[0].id!,
                                                abono)
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
                                                        setState(() {});
                                                        Navigator.pushNamed(
                                                            context,
                                                            'nvo-abono',
                                                            arguments:
                                                                value);
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
                                                  title:
                                                      const Text('Error'),
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
                                      },
                                      child: const Text('Aceptar '),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context),
                                      child: const Text('Cancelar'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: SizedBox(
                            height: windowHeight * 0.1,
                            width: windowWidth * 0.4,
                            child: const Center(
                              child: Text('Agregar Abono',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
            ],
          ),
        ));
  }
}
