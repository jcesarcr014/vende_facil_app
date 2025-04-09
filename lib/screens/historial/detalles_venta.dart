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

    // Verificar si la venta está cancelada
    bool ventaCancelada = listaVentaCabecera2.first.cancelado == '1';

    return Scaffold(
      appBar: AppBar(
        title: Text('Venta: ${listaVentaCabecera2[0].folio}'),
        actions: [
          // Si la venta está cancelada, mostrar un indicador en el AppBar
          if (ventaCancelada)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: Text(
                'CANCELADO',
                style: TextStyle(
                  color: Colors.red.shade800,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: (isLoading)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Espere...$textLoading'),
                  SizedBox(height: windowHeight * 0.01),
                  const CircularProgressIndicator(),
                ],
              ),
            )
          : Column(
              children: [
                // Encabezado con información principal
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.shade50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Folio: ${listaVentaCabecera2[0].folio}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Fecha: ${listaVentaCabecera2[0].fecha_venta}'),
                      Text('Cliente: ${listaVentaCabecera2[0].nombreCliente}'),
                    ],
                  ),
                ),

                // Detalles de la sucursal
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Información de la Sucursal',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Nombre: ${sucursalVenta.nombreSucursal ?? ""}'),
                          Text('Dirección: ${sucursalVenta.direccion ?? ""}'),
                          Text('Teléfono: ${sucursalVenta.telefono ?? ""}'),
                        ],
                      ),
                    ),
                  ),
                ),

                // Tabla de productos
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Productos',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SingleChildScrollView(
                                  child: DataTable(
                                    columnSpacing: 20,
                                    headingRowColor: MaterialStateProperty.all(
                                      Colors.blue.shade100,
                                    ),
                                    columns: const [
                                      DataColumn(label: Text('Producto')),
                                      DataColumn(label: Text('Cantidad')),
                                      DataColumn(label: Text('Descuento')),
                                      DataColumn(label: Text('Total')),
                                    ],
                                    rows: listaVentadetalles
                                        .map((detalle) => DataRow(cells: [
                                              DataCell(Text(detalle
                                                  .nombreProducto
                                                  .toString())),
                                              DataCell(Text(
                                                  detalle.cantidad.toString())),
                                              DataCell(Text(detalle
                                                  .cantidadDescuento
                                                  .toString())),
                                              DataCell(Text(
                                                  detalle.total.toString())),
                                            ]))
                                        .toList(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Resumen de totales
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildSummaryRow('Subtotal',
                              '\$${listaVentaCabecera2.first.subtotal?.toStringAsFixed(2) ?? "0.00"}'),
                          _buildSummaryRow('Descuento',
                              '\$${listaVentaCabecera2.first.descuento?.toStringAsFixed(2) ?? "0.00"}'),
                          const Divider(),
                          _buildSummaryRow('Total',
                              '\$${listaVentaCabecera2.first.total?.toStringAsFixed(2) ?? "0.00"}'),
                          _buildSummaryRow('Cambio',
                              '\$${listaVentaCabecera2.first.cambio?.toStringAsFixed(2) ?? "0.00"}'),
                        ],
                      ),
                    ),
                  ),
                ),

                // Botones de acción (solo si la venta no está cancelada)
                if (!ventaCancelada)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _reimprimirTicket,
                            icon: const Icon(Icons.print),
                            label: const Text('Reimprimir Ticket'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _cancelarVenta,
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('Cancelar Venta'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  // Mensaje de venta cancelada
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.cancel,
                            color: Colors.red.shade800,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Esta venta ha sido cancelada',
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Volver al historial'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
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
          content: const Text(
              '¿Está seguro que desea cancelar la venta? Esta acción no se puede deshacer y restaurará los productos al inventario.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No, regresar'),
            ),
            ElevatedButton(
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
                    Navigator.pop(context);
                    Navigator.pop(context); // Regresar a la pantalla anterior
                    mostrarAlerta(
                        context, 'Éxito', 'Venta cancelada correctamente.');
                  } else {
                    mostrarAlerta(context, 'ERROR', '${value.mensaje}');
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sí, cancelar venta'),
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
        precioUnitario: detalle.precioUnitario!,
        precioPublico: detalle.precio!,
        precioMayoreo: 0,
        precioDistribuidor: 0,
        precioUtilizado: detalle.precio!,
        idDescuento: detalle.idDesc ?? 0,
        descuento: detalle.cantidadDescuento ?? 0,
        subTotalItem: detalle.subtotal!,
        totalItem: detalle.total!,
        apartado: false,
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
      } else {
        mostrarAlerta(context, 'Éxito', 'Ticket reimpreso correctamente');
      }
    });
  }
}
