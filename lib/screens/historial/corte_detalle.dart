import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/util/imprime_tickets.dart';
import 'package:intl/intl.dart';

class CorteDetalleScreen extends StatefulWidget {
  const CorteDetalleScreen({super.key});

  @override
  State<CorteDetalleScreen> createState() => _CorteDetalleScreenState();
}

class _CorteDetalleScreenState extends State<CorteDetalleScreen> {
  final impresionesTickets = ImpresionesTickets();
  bool isLoading = false;
  String textLoading = '';
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  void _imprimirCorte() async {
    setState(() {
      isLoading = true;
      textLoading = 'Preparando impresión';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String mac = prefs.getString('macPrinter') ?? '';

      if (mac.isEmpty) {
        setState(() {
          isLoading = false;
          textLoading = '';
        });

        mostrarAlerta(context, 'Atención',
            'No tiene una impresora configurada. Configure una impresora en la sección correspondiente.');
        return;
      }

      setState(() {
        textLoading = 'Imprimiendo corte';
      });

      final result = await impresionesTickets.imprimirCorte(0);

      setState(() {
        isLoading = false;
        textLoading = '';
      });

      if (result.status != 1) {
        mostrarAlerta(context, 'Error',
            'Ocurrió un error al imprimir el corte: ${result.mensaje}');
      } else {
        mostrarAlerta(context, 'Éxito', 'El corte se ha impreso correctamente');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        textLoading = '';
      });

      mostrarAlerta(context, 'Error',
          'Error al comunicarse con la impresora. Verifique la conexión.');
    }
  }

  // Función para convertir valores String a double de manera segura
  double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;

    try {
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      } else if (value is num) {
        return value.toDouble();
      }
    } catch (e) {
      // En caso de error, retornar 0.0
    }

    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didpop) {
        if (!didpop) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Resumen de Corte'),
          automaticallyImplyLeading: false,
          elevation: 2,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close),
              tooltip: 'Volver',
            ),
          ],
        ),
        body: isLoading ? _buildLoadingIndicator() : _buildContent(),
        floatingActionButton: _buildPrintButton(),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Espere... $textLoading',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCorteCard(),
            const SizedBox(height: 20),
            _buildTotalesCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCorteCard() {
    final empleado = corteActual.empleado ?? 'Empleado';
    final fecha = corteActual.fecha ?? 'Sin fecha';
    final efectivoInicial = corteActual.efectivoInicial ?? '0.00';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              'Información del Corte',
              Icons.receipt_long_outlined,
              Colors.blue,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Empleado',
                    empleado,
                    Icons.person_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Fecha',
                    fecha,
                    Icons.calendar_today_outlined,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Efectivo Inicial',
                    '\$$efectivoInicial',
                    Icons.monetization_on_outlined,
                    isHighlighted: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 16),
            _buildMovimientosResumen(),
          ],
        ),
      ),
    );
  }

  Widget _buildMovimientosResumen() {
    // Contar tipos de movimientos
    int ventasTienda = 0;
    int ventasDomicilio = 0;
    int apartados = 0;
    int abonos = 0;

    for (var movimiento in listaMovimientosCorte) {
      switch (movimiento.tipoMovimiento) {
        case 'VT':
          ventasTienda++;
          break;
        case 'VD':
          ventasDomicilio++;
          break;
        case 'P':
          apartados++;
          break;
        case 'A':
          abonos++;
          break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen de Movimientos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMovimientoContador(
                'Ventas Tienda',
                ventasTienda,
                Icons.storefront_outlined,
                Colors.blue,
              ),
            ),
            Expanded(
              child: _buildMovimientoContador(
                'Ventas Domicilio',
                ventasDomicilio,
                Icons.delivery_dining_outlined,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMovimientoContador(
                'Apartados',
                apartados,
                Icons.bookmark_outline,
                Colors.purple,
              ),
            ),
            Expanded(
              child: _buildMovimientoContador(
                'Abonos',
                abonos,
                Icons.payments_outlined,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMovimientoContador(
      String label, int count, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                  ),
                ),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon,
      {bool isHighlighted = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: isHighlighted
            ? Colors.blue.withOpacity(0.1)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: isHighlighted
            ? Border.all(color: Colors.blue.withOpacity(0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  size: 14,
                  color: isHighlighted ? Colors.blue : Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isHighlighted ? Colors.blue[600] : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalesCard() {
    final ventasEfectivo = _parseToDouble(corteActual.ventasEfectivo);
    final ventasTarjeta = _parseToDouble(corteActual.ventasTarjeta);
    final totalIngresos = _parseToDouble(corteActual.totalIngresos);
    final diferencia = _parseToDouble(corteActual.diferencia);
    final tipoDiferencia = corteActual.tipoDiferencia ?? '';
    final totalMovimientos = listaMovimientosCorte.length;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              'Resumen Financiero',
              Icons.summarize_outlined,
              Colors.green,
            ),
            const SizedBox(height: 24),
            _buildMovimientosTotales(totalMovimientos),
            const SizedBox(height: 20),
            _buildTotalRow(
              'Ventas en Efectivo',
              ventasEfectivo,
              Icons.payments_outlined,
            ),
            const Divider(height: 24),
            _buildTotalRow(
              'Ventas con Tarjeta',
              ventasTarjeta,
              Icons.credit_card_outlined,
            ),
            const Divider(height: 24),
            _buildTotalRow(
              'Total Ingresos',
              totalIngresos,
              Icons.account_balance_wallet_outlined,
              isHighlighted: true,
            ),
            if (diferencia != 0) ...[
              const Divider(height: 24),
              _buildDiferenciaRow(
                diferencia,
                tipoDiferencia,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMovimientosTotales(int totalMovimientos) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: Colors.blue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total de Movimientos',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                ),
              ),
              Text(
                totalMovimientos.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double value, IconData icon,
      {bool isHighlighted = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isHighlighted
                ? Colors.green.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isHighlighted ? Colors.green : Colors.grey[700],
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              fontSize: isHighlighted ? 16 : 14,
            ),
          ),
        ),
        Text(
          currencyFormat.format(value),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isHighlighted ? 18 : 16,
            color: isHighlighted ? Colors.green : Colors.green[700],
          ),
        ),
      ],
    );
  }

  Widget _buildDiferenciaRow(double diferencia, String tipoDiferencia) {
    final bool esFaltante = tipoDiferencia.toLowerCase().contains('faltante');
    final Color color = esFaltante ? Colors.red : Colors.blue;
    final IconData icon =
        esFaltante ? Icons.arrow_downward : Icons.arrow_upward;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Diferencia ($tipoDiferencia)',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Text(
          currencyFormat.format(diferencia.abs()),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPrintButton() {
    return FloatingActionButton.extended(
      onPressed: _imprimirCorte,
      icon: const Icon(Icons.print_outlined),
      label: const Text('Imprimir Corte'),
      backgroundColor: Colors.blue,
      elevation: 4,
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
