// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/apartado_provider.dart';
import 'package:vende_facil/widgets/widgets.dart';

class AbonoDetallesScreen extends StatefulWidget {
  const AbonoDetallesScreen({super.key});

  @override
  State<AbonoDetallesScreen> createState() => _AbonoDetallesScreen();
}

class _AbonoDetallesScreen extends State<AbonoDetallesScreen> {
  bool _isLoading = false;
  String _textLoading = '';
  final _apartadoProvider = ApartadoProvider();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalles de apartado'),
          elevation: 2,
        ),
        body: _isLoading ? _buildLoadingScreen() : _buildDetallesApartado(),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Espere...$_textLoading',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildDetallesApartado() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 20),
          _buildProductosCard(),
          const SizedBox(height: 20),
          _buildAbonosCard(),
          const SizedBox(height: 30),
          _buildBotonesAccion(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Información del apartado',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Folio:', apartadoSeleccionado.folio ?? ''),
            _buildInfoRow('Cliente:', apartadoSeleccionado.nombreCliente ?? ''),
            _buildInfoRow(
                'Fecha de apartado:', apartadoSeleccionado.fechaApartado ?? ''),
            _buildInfoRow(
              'Saldo Pendiente:',
              '\$${apartadoSeleccionado.saldoPendiente?.toStringAsFixed(2) ?? '0.00'}',
              isHighlighted: true,
            ),
            _buildInfoRow('Descuento:',
                '${apartadoSeleccionado.descuento?.toStringAsFixed(2) ?? '0.00'}%'),
            _buildInfoRow(
              'Total:',
              '\$${apartadoSeleccionado.total?.toStringAsFixed(2) ?? '0.00'}',
              isHighlighted: true,
            ),
            if (apartadoSeleccionado.pagado == 1)
              _buildInfoRow(
                  'Pagado:', apartadoSeleccionado.fechaPagoTotal ?? ''),
            if (apartadoSeleccionado.entregado == 1)
              _buildInfoRow(
                  'Entregado:', apartadoSeleccionado.fechaEntrega ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
                color: isHighlighted ? Colors.red : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductosCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_cart, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Productos',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                dataTextStyle: const TextStyle(
                  color: Colors.black87,
                ),
                columns: const [
                  DataColumn(label: Text('Producto')),
                  DataColumn(label: Text('Cantidad')),
                  DataColumn(label: Text('Descuento')),
                  DataColumn(label: Text('Total')),
                ],
                rows: detalleApartado
                    .map((detalle) => DataRow(cells: [
                          DataCell(Text(detalle.producto.toString())),
                          DataCell(Text(detalle.cantidad.toString())),
                          DataCell(Text("${detalle.descuento.toString()}%")),
                          DataCell(
                              Text("\$${detalle.total?.toStringAsFixed(2)}")),
                        ]))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbonosCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_money, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Historial de abonos',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            listaAbonos.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        'No hay abonos registrados',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      dataTextStyle: const TextStyle(
                        color: Colors.black87,
                      ),
                      columns: const [
                        DataColumn(label: Text('Fecha')),
                        DataColumn(label: Text('Abonado')),
                      ],
                      rows: listaAbonos
                          .map((detalle) => DataRow(cells: [
                                DataCell(Text(detalle.fechaAbono.toString())),
                                DataCell(Text(
                                    "\$${(detalle.cantidadEfectivo! + detalle.cantidadTarjeta!).toStringAsFixed(2)}")),
                              ]))
                          .toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonesAccion() {
    final botones = <Widget>[];

    if (apartadoSeleccionado.cancelado == 0 &&
        apartadoSeleccionado.pagado == 0) {
      botones.add(
        ElevatedButton.icon(
          onPressed: () {
            final venta = VentaCabecera(
              idCliente: apartadoSeleccionado.id,
              subtotal: apartadoSeleccionado.saldoPendiente,
              idDescuento: 0,
              descuento: 0,
              total: apartadoSeleccionado.saldoPendiente,
            );
            Navigator.pushNamed(context, 'abonosPagos', arguments: venta);
          },
          icon: const Icon(Icons.payments),
          label: const Text('Realizar abono'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      );

      botones.add(const SizedBox(height: 12));

      botones.add(
        OutlinedButton.icon(
          onPressed: _cancelarApartado,
          icon: const Icon(Icons.cancel),
          label: const Text('Cancelar apartado'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      );
    }

    if (apartadoSeleccionado.pagado == 1 &&
        apartadoSeleccionado.entregado == 0) {
      botones.add(
        ElevatedButton.icon(
          onPressed: _entregarProductos,
          icon: const Icon(Icons.local_shipping),
          label: const Text('Entregar productos'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      );
    }

    return Column(children: botones);
  }

  Future<void> _entregarProductos() async {
    setState(() {
      _textLoading = 'Actualizando pedido';
      _isLoading = true;
    });

    final resp =
        await _apartadoProvider.entregarProducto(apartadoSeleccionado.id!);

    setState(() {
      _textLoading = '';
      _isLoading = false;
    });

    if (resp.status == 0) {
      mostrarAlerta(context, 'Error', resp.mensaje!);
      return;
    }

    Navigator.pop(context);
    Navigator.pop(context);
    mostrarAlerta(
        context, 'Éxito', resp.mensaje ?? 'Producto Entregado Correctamente');
  }

  Future<void> _cancelarApartado() async {
    String metodoDevolucion = 'N';
    final montoController = TextEditingController(text: '0');

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Cancelar Apartado'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: montoController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Monto a devolver',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Método de devolución:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  RadioListTile(
                    title: const Text('Efectivo'),
                    value: 'E',
                    groupValue: metodoDevolucion,
                    onChanged: (value) {
                      setState(() => metodoDevolucion = value!);
                    },
                    activeColor: Colors.green,
                  ),
                  RadioListTile(
                    title: const Text('Bancaria'),
                    value: 'B',
                    groupValue: metodoDevolucion,
                    onChanged: (value) {
                      setState(() => metodoDevolucion = value!);
                    },
                    activeColor: Colors.green,
                  ),
                  RadioListTile(
                    title: const Text('No aplica'),
                    value: 'N',
                    groupValue: metodoDevolucion,
                    onChanged: (value) {
                      setState(() => metodoDevolucion = value!);
                    },
                    activeColor: Colors.green,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _textLoading = 'Cancelando apartado...';
        _isLoading = true;
      });

      final resp = await _apartadoProvider.cancelarApartado(
        apartadoSeleccionado.id!,
        montoController.text,
        metodoDevolucion,
      );

      setState(() {
        _textLoading = '';
        _isLoading = false;
      });

      if (resp.status == 1) {
        Navigator.pushReplacementNamed(context, 'menuAbonos');
        mostrarAlerta(
          context,
          'Alerta',
          'Se canceló el apartado correctamente.',
          tituloColor: Colors.red,
          mensajeColor: Colors.black,
        );
      } else {
        mostrarAlerta(context, "Error",
            "No se pudo cancelar el apartado. ${resp.mensaje}");
      }
    }
  }
}
