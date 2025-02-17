import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/util/imprime_tickets.dart';

class CorteDetalleScreen extends StatefulWidget {
  const CorteDetalleScreen({super.key});

  @override
  State<CorteDetalleScreen> createState() => _CorteDetalleScreenState();
}

class _CorteDetalleScreenState extends State<CorteDetalleScreen> {
  final impresionesTickets = ImpresionesTickets();
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  bool isLoading = false;
  String textLoading = '';
  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      onPopInvoked: (didpop) {
        if (!didpop) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Corte de Caja'),
        ),
        body: (isLoading)
            ? Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Espere...'),
                      SizedBox(
                        height: windowHeight * 0.01,
                      ),
                      const CircularProgressIndicator(),
                    ]),
              )
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.04),
                child: Column(
                  children: [
                    SizedBox(height: windowHeight * 0.02),
                    Text(
                      'Corte de ${corteActual.empleado}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Efectivo en caja: \$${corteActual.efectivoInicial}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: windowHeight * 0.02),
                    Expanded(
                      child: ListView.builder(
                        itemCount: listaMovimientosCorte.length,
                        itemBuilder: (context, index) {
                          final movimiento = listaMovimientosCorte[index];
                          String tipoMovimiento = '';
                          if (movimiento.tipoMovimiento == 'VD') {
                            tipoMovimiento = 'Venta domicilio';
                          } else if (movimiento.tipoMovimiento == 'VT') {
                            tipoMovimiento = 'Venta tienda';
                          } else if (movimiento.tipoMovimiento == 'P') {
                            tipoMovimiento = 'Apartado';
                          } else if (movimiento.tipoMovimiento == 'A') {
                            tipoMovimiento = 'Abono';
                          }
                          return ListTile(
                            title: Text(
                              '$tipoMovimiento - Folio: ${movimiento.folio}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Efectivo: \$${movimiento.montoEfectivo ?? '0.00'} | '
                              'Tarjeta: \$${movimiento.montoTarjeta ?? '0.00'}',
                            ),
                            trailing: Text(
                              '\$${movimiento.total ?? '0.00'}',
                              style: TextStyle(color: Colors.green),
                            ),
                          );
                        },
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: windowWidth * 0.04, vertical: 10),
                      child: Column(
                        children: [
                          _buildTotalRow('Ventas en Efectivo',
                              corteActual.ventasEfectivo ?? '0.0'),
                          _buildTotalRow('Ventas con Tarjeta',
                              corteActual.ventasTarjeta ?? '0.0'),
                          _buildTotalRow('Total Ingresos',
                              corteActual.totalIngresos ?? '0.0'),
                          if (corteActual.diferencia != null &&
                              corteActual.diferencia != 0)
                            _buildDiferenciaRow(corteActual.diferencia ?? '0.0',
                                corteActual.tipoDiferencia ?? ''),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        impresionesTickets.imprimirCorte(0).then((value) {
                          if (value.status != 1) {
                            mostrarAlerta(context, 'ERROR',
                                'Ocurrio un error al imprimir el corte: ${value.mensaje}');
                          }
                        });
                      },
                      child: Text('Imprimir Corte'),
                    ),
                    SizedBox(height: windowHeight * 0.02),
                  ],
                ),
              ),
      ),
    );
  }

  _buildTotalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            '\$$value',
            style: TextStyle(color: Colors.green),
          ),
        ],
      ),
    );
  }

  _buildDiferenciaRow(String diferencia, String tipoDiferencia) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Diferencia ($tipoDiferencia)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '\$${double.parse(diferencia).abs().toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
