import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/util/imprime_tickets.dart';
import 'package:vende_facil/widgets/widgets.dart';

class VentaDetallesScreen extends StatefulWidget {
  const VentaDetallesScreen({super.key});

  @override
  State<VentaDetallesScreen> createState() => _VentaDetallesScreenState();
}

class _VentaDetallesScreenState extends State<VentaDetallesScreen> {
  final negocioProvider = NegocioProvider();
  final ventaProvider = VentasProvider();
  bool isLoading = false;
  String textLoading = '';
  Sucursal sucursalVenta = Sucursal();
  double windowHeight = 0;
  double windowWidth = 0;

  @override
  void initState() {
    setState(() {
      isLoading = true;
      textLoading = 'Cargando datos...';
    });
    negocioProvider
        .consultaSucursal(listaVentaCabecera2[0].id_sucursal.toString())
        .then((value) {
      sucursalVenta = value;
      setState(() {
        isLoading = false;
        textLoading = '';
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height;
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Venta: ${listaVentaCabecera2[0].folio}'),
        automaticallyImplyLeading: true,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Nombre de la Sucursal: ${sucursalVenta.nombreSucursal}'),
                    const SizedBox(height: 5),
                    Text(
                        'Dirección de la Sucursal: ${sucursalVenta.direccion}'),
                    const SizedBox(height: 5),
                    Text('Telefono: ${sucursalVenta.telefono}'),
                    const SizedBox(height: 5),
                    Text('Cliente: ${listaVentaCabecera2[0].nombreCliente}'),
                    const SizedBox(height: 5),
                    Text(
                        'Fecha de compra: ${listaVentaCabecera2[0].fecha_venta}'),
                    const Divider(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 20,
                        columns: const [
                          DataColumn(label: Text('Producto')),
                          DataColumn(label: Text('Cantidad')),
                          DataColumn(label: Text('Descuento')),
                          DataColumn(label: Text('Total')),
                        ],
                        rows: listaVentadetalles
                            .map((detalle) => DataRow(cells: [
                                  DataCell(
                                      Text(detalle.nombreProducto.toString())),
                                  DataCell(Text(detalle.cantidad.toString())),
                                  DataCell(Text(
                                      detalle.cantidadDescuento.toString())),
                                  DataCell(Text(detalle.total.toString())),
                                ]))
                            .toList(),
                      ),
                    ),
                    const Divider(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildSummaryRow('Subtotal',
                            '${listaVentaCabecera2.first.subtotal}'),
                        _buildSummaryRow('Descuento',
                            '${listaVentaCabecera2.first.descuento}'),
                        _buildSummaryRow(
                            'Total', '${listaVentaCabecera2.first.total}'),
                        _buildSummaryRow(
                            'Cambio', '${listaVentaCabecera2.first.cambio}'),
                      ],
                    ),
                    const Divider(height: 20),
                    (listaVentaCabecera2.first.cancelado == '0')
                        ? Center(
                            child: Text('Acciones',
                                style: const TextStyle(fontSize: 20),
                                textAlign: TextAlign.center),
                          )
                        : Center(
                            child: Text('Venta cancelada',
                                style: const TextStyle(fontSize: 20),
                                textAlign: TextAlign.center),
                          ),
                    (listaVentaCabecera2.first.cancelado == '0')
                        ? Column(
                            children: [
                              SizedBox(height: windowHeight * 0.05),
                              ElevatedButton(
                                onPressed: () {
                                  _reimprimirTicket();
                                },
                                child: SizedBox(
                                  height: windowHeight * 0.1,
                                  width: windowWidth * 0.8,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.print),
                                      const SizedBox(width: 10),
                                      const Text(
                                        'Reimprimir Ticket',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  _cancelarVenta();
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.cancel),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Cancelar venta',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: windowHeight * 0.05),
                            ],
                          )
                        : Container()
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(value)
        ],
      ),
    );
  }

  _cancelarVenta() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancelar venta'),
          content: const Text('¿Está seguro que desea cancelar la venta?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isLoading = true;
                  textLoading = 'Cancelando venta...';
                });
                ventaProvider
                    .cancelarVenta(listaVentaCabecera2[0].id!)
                    .then((value) {
                  setState(() {
                    isLoading = false;
                    textLoading = '';
                  });
                  if (value.status == 1) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    mostrarAlerta(
                        context, 'Éxito', 'Venta cancelada correctamente.');
                  } else {
                    mostrarAlerta(context, 'ERROR', '${value.mensaje}');
                  }
                });
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  _reimprimirTicket() {
    setState(() {
      isLoading = true;
      textLoading = 'Reimprimiendo ticket.';
    });
    ventaTemporal.clear();
    for (VentaDetalle detalle in listaVentadetalles) {
      ItemVenta item = ItemVenta(
        idArticulo: detalle.idProd!,
        articulo: detalle.nombreProducto!,
        cantidad: detalle.cantidad!,
        precioPublico: detalle.precio!,
        idDescuento: detalle.idDesc ?? 0,
        descuento: detalle.cantidadDescuento ?? 0,
        subTotalItem: detalle.subtotal!,
        totalItem: detalle.total!,
        apartado: false,
        preciomayoreo: 0,
        preciodistribuidor: 0,
      );
      ventaTemporal.add(item);
    }
    final tarjeta = listaVentaCabecera2[0].importeTarjeta!;
    final efectivo = listaVentaCabecera2[0].importeEfectivo!;
    final cambio = listaVentaCabecera2[0].cambio!;
    final copia = false;

    ImpresionesTickets()
        .imprimirVenta(
      listaVentaCabecera2[0],
      tarjeta,
      efectivo,
      cambio,
      copia,
    )
        .then((resp) {
      setState(() {
        isLoading = false;
        textLoading = '';
      });
      if (resp.status != 1) {
        mostrarAlerta(context, 'ERROR', '${resp.mensaje}');
      }
    });
  }
}
