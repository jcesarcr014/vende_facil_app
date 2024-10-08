// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/apartado_provider.dart';
import 'package:vende_facil/widgets/mostrar_alerta_ok.dart';

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
    efectivoConttroller.text = "0.0";
    tarjetaConttroller.text = "0.0";
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) Navigator.pushReplacementNamed(context, 'nvo-abono');
        },
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Detalles de Abono'),
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
                            'Cliente: ${listaApartados2[0].nombreCliente}',
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
                            'Total: \$${listaApartados2[0].total}',
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
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                                          DataCell(Text(
                                              detalle.producto.toString())),
                                          DataCell(Text(
                                              detalle.cantidad.toString())),
                                          DataCell(Text(
                                              detalle.descuento.toString())),
                                          DataCell(Text(
                                              "\$${detalle.total.toString()}")),
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
                                              "\$${(detalle.cantidadEfectivo! + detalle.cantidadTarjeta!).toString()}")),
                                        ]))
                                    .toList(),
                              ),
                            ),
                            SizedBox(
                              height: windowHeight * 0.1,
                            ),
                            Center(
                              child: 
                                listaApartados2.first.cancelado != 1 ?
                                      ElevatedButton(
                                        onPressed: () {
                                          if (listaApartados2[0].saldoPendiente ==
                                              0.0) {
                                            mostrarAlerta(context, "Alerta",
                                                "El artículo ya se ha pagado por completo.");
                                          } else {
                                            VentaCabecera venta = VentaCabecera(
                                              idCliente: listaApartados2[0].id,
                                              subtotal:
                                                  listaApartados2[0].saldoPendiente,
                                              idDescuento: 0,
                                              descuento: 0,
                                              total: listaApartados2[0].saldoPendiente,
                                            );
                                            Navigator.pushNamed(context, 'abonosPagos',
                                                arguments: venta);
                                          }
                                        },
                                        child: SizedBox(
                                          height: windowHeight * 0.1,
                                          width: windowWidth * 0.4,
                                          child: const Center(
                                            child: Text('Agregar Abono',
                                                style: TextStyle(fontSize: 16)),
                                          ),
                                        ),
                                      ): const Text(''),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Center(
                              child:
                                listaApartados2.first.cancelado != 1 ?
                                    ElevatedButton(
                                      onPressed: () async {
                                        setState(() {
                                          textLoading = 'Actualizando apartado...';
                                          isLoading = true;
                                        });
                                        await apartado
                                            .cancelarApartado(listaApartados2[0].id!)
                                            .then((value) {
                                          if (value.status == 1) {
                                            setState(() {
                                              isLoading = false;
                                            });
                                            Navigator.pushReplacementNamed(
                                                context, 'menuAbonos');
                                            mostrarAlerta(context, 'Alerta',
                                                'Se canceló el apartado.',
                                                tituloColor: Colors.red,
                                                mensajeColor: Colors.black);
                                          } else {
                                            setState(() {
                                              isLoading = false;
                                            });
                                            mostrarAlerta(context, "Error",
                                                "No se pudo cancelar el apartado.");
                                          }
                                        }
                                      );
                                      },
                                      child: SizedBox(
                                        height: windowHeight * 0.1,
                                        width: windowWidth * 0.4,
                                        child: const Center(
                                          child: Text('Cancelar Apartado',
                                              style: TextStyle(fontSize: 16)),
                                        ),
                                      ),
                                    ) : const Text(''),
                                  ),
                            SizedBox(
                              height: windowHeight * 0.1,
                            ),
                          ],
                        )
                ],
              ),
            )));
  }
}
