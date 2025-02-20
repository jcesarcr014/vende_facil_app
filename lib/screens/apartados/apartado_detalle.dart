// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/apartado_provider.dart';
import 'package:vende_facil/widgets/mostrar_alerta_ok.dart';

class AbonoDetallesScreen extends StatefulWidget {
  const AbonoDetallesScreen({super.key});

  @override
  State<AbonoDetallesScreen> createState() => _AbonoDetallesScreen();
}

class _AbonoDetallesScreen extends State<AbonoDetallesScreen> {
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  final totalConttroller = TextEditingController();
  final efectivoConttroller = TextEditingController();
  final tarjetaConttroller = TextEditingController();
  final cambioConttroller = TextEditingController();
  final apartadoProvider = ApartadoProvider();

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
              title: const Text('Detalles de apartado'),
            ),
            body: (isLoading)
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
                : SingleChildScrollView(
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
                                  'Folio: ${apartadoSeleccionado.folio}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Cliente: ${apartadoSeleccionado.nombreCliente}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Fecha de apartado: ${apartadoSeleccionado.fechaApartado}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Saldo Pediente: ${apartadoSeleccionado.saldoPendiente}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Descuento: ${apartadoSeleccionado.descuento}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Total: \$${apartadoSeleccionado.total}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                (apartadoSeleccionado.pagado == 1)
                                    ? Text(
                                        'Pagado: ${apartadoSeleccionado.fechaPagoTotal}')
                                    : Container(),
                                (apartadoSeleccionado.entregado == 1)
                                    ? Text(
                                        'Pagado: ${apartadoSeleccionado.fechaEntrega}')
                                    : Container(),
                              ],
                            ),
                          ),
                        ),
                        const Center(
                          child: Text(
                            'Productos',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Column(
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
                          ],
                        ),
                        Column(
                          children: _botonesAbono(),
                        ),
                      ],
                    ),
                  )));
  }

  _botonesAbono() {
    List<Widget> botones = [];
    if (apartadoSeleccionado.cancelado == 0 &&
        apartadoSeleccionado.pagado == 0) {
      botones.add(ElevatedButton(
          onPressed: () {
            VentaCabecera venta = VentaCabecera(
              idCliente: apartadoSeleccionado.id,
              subtotal: apartadoSeleccionado.saldoPendiente,
              idDescuento: 0,
              descuento: 0,
              total: apartadoSeleccionado.saldoPendiente,
            );
            Navigator.pushNamed(context, 'abonosPagos', arguments: venta);
          },
          child: Text('Abonar')));
      botones.add(SizedBox(
        height: windowHeight * 0.02,
      ));
      botones.add(ElevatedButton(
          onPressed: () {
            _cancelarApartado();
          },
          child: Text('Cancelar apartado')));
    }
    if (apartadoSeleccionado.pagado == 1 &&
        apartadoSeleccionado.entregado == 0) {
      botones.add(ElevatedButton(
          onPressed: _entregarProductos, child: Text('Entregar productos')));
    }
    return botones;
  }

  void _entregarProductos() async {
    setState(() {
      textLoading = 'Actualizando pedido';
      isLoading = false;
    });
    apartadoProvider.entregarProducto(apartadoSeleccionado.id!).then((resp) {
      setState(() {
        textLoading = '';
        isLoading = false;
      });
      if (resp.status == 0) {
        mostrarAlerta(context, 'Error', resp.mensaje!);
        return;
      }
      Navigator.pop(context);
      Navigator.pop(context);
      mostrarAlerta(context, 'Exitoso',
          resp.mensaje ?? 'Producto Entregado Correctamente');
    });
  }

  _cancelarApartado() async {
    setState(() {
      textLoading = 'Cancelando...';
      isLoading = true;
    });
    apartadoProvider.cancelarApartado(apartadoSeleccionado.id!).then((resp) {
      setState(() {
        textLoading = '';
        isLoading = false;
      });
      if (resp.status == 1) {
        Navigator.pushReplacementNamed(context, 'menuAbonos');
        mostrarAlerta(context, 'Alerta', 'Se canceló el apartado.',
            tituloColor: Colors.red, mensajeColor: Colors.black);
      } else {
        setState(() {
          isLoading = false;
        });
        mostrarAlerta(context, "Error", "No se pudo cancelar el apartado.");
      }
    });
  }
}
