import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/venta_provider.dart';
import 'package:vende_facil/util/imprime_tickets.dart';
import 'package:vende_facil/widgets/input_field_money.dart';
import 'package:vende_facil/widgets/mostrar_alerta_ok.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

class VentaScreen extends StatefulWidget {
  const VentaScreen({super.key});

  @override
  State<VentaScreen> createState() => _VentaScreenState();
}

class _VentaScreenState extends State<VentaScreen> {
  final _totalController = TextEditingController();
  final _efectivoController = TextEditingController();
  final _cambioController = TextEditingController();
  final _tarjetaController = TextEditingController();
  final _ventaProvider = VentasProvider();
  final _impresionesTickets = ImpresionesTickets();

  bool _isLoading = false;
  String _textLoading = '';
  bool _isPrinted = false;
  bool _x2ticket = false;

  @override
  void initState() {
    super.initState();
    _totalController.text = totalVT.toStringAsFixed(2);
    _efectivoController.text = "0.00";
    _tarjetaController.text = "0.00";
    _cambioController.text = "0.00";
    _efectivoController.addListener(_updateCambio);
    _tarjetaController.addListener(_updateCambio);
  }

  @override
  void dispose() {
    _totalController.dispose();
    _efectivoController.dispose();
    _cambioController.dispose();
    _tarjetaController.dispose();
    super.dispose();
  }

  void _updateCambio() {
    if (!mounted) return;

    setState(() {
      final efectivo =
          double.tryParse(_efectivoController.text.replaceAll(',', '')) ?? 0.0;
      final tarjeta =
          double.tryParse(_tarjetaController.text.replaceAll(',', '')) ?? 0.0;
      final total = double.tryParse(_totalController.text) ?? 0.0;
      final totalEfectivo = efectivo + tarjeta;
      double cambio = totalEfectivo - total;

      if (cambio < 0) {
        cambio = 0.0;
      }

      _cambioController.text = cambio.toStringAsFixed(2);
    });
  }

  Future<void> _togglePrinter(bool? value) async {
    if (value == null) return;

    final prefs = await SharedPreferences.getInstance();
    final mac = prefs.getString('macPrinter') ?? '';

    if (mac.isEmpty) {
      if (!mounted) return;
      mostrarAlerta(context, 'Atención', 'No tienes una impresora configurada');
      return;
    }

    setState(() {
      _isPrinted = value;
      if (!_isPrinted) {
        _x2ticket = false;
      }
    });
  }

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Atención'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkVenta(VentaCabecera venta) async {
    if (ventaTemporal.isEmpty) {
      _mostrarError('No hay productos en la venta');
      return;
    }

    final efectivo = double.parse(_efectivoController.text.replaceAll(',', ''));
    final total = double.parse(_totalController.text);
    final tarjeta = double.parse(_tarjetaController.text.replaceAll(',', ''));
    final cambio = double.parse(_cambioController.text);
    final totalEfectivo = efectivo - cambio;
    final resultado = efectivo + tarjeta;

    if (tarjeta > total) {
      _mostrarError('El pago con tarjeta no puede ser mayor al total');
    } else if (resultado < total) {
      _mostrarError('El pago total es menor al importe de la venta');
    } else {
      await _procesarCompra(venta, efectivo, tarjeta, totalEfectivo, cambio);
    }
  }

  Future<void> _procesarCompra(VentaCabecera venta, double efectivo,
      double tarjeta, double totalEfectivo, double cambio) async {
    setState(() {
      _isLoading = true;
      _textLoading = 'Guardando venta';
    });
    venta.importeTarjeta = tarjeta;
    venta.importeEfectivo = totalEfectivo;
    venta.cambio = cambio;
    venta.id_sucursal = sesion.idSucursal;

    final detalles = ventaTemporal
        .map((item) => VentaDetalle(
              idVenta: 0,
              idProd: item.idArticulo,
              cantidad: item.cantidad,
              precio: item.precioPublico,
              idDesc: venta.idDescuento,
              cantidadDescuento: venta.descuento,
              total: item.totalItem,
              subtotal: item.subTotalItem,
              id_sucursal: sesion.idSucursal,
            ))
        .toList();

    final respuesta =
        await _ventaProvider.guardarVentaCompleta(venta, detalles);

    if (respuesta.status == 1) {
      if (_isPrinted) {
        setState(() {
          _textLoading = 'Imprimiendo ticket';
        });

        final respuestaImp = await _impresionesTickets.imprimirVenta(
            venta, tarjeta, efectivo, cambio, _x2ticket);

        if (respuestaImp.status != 1) {
          if (!mounted) return;
          mostrarAlerta(context, 'Advertencia',
              'Venta guardada, pero no fue posible imprimir el ticket: ${respuestaImp.mensaje}');
        }
      }

      setState(() {
        ventaTemporal.clear();
        totalVT = 0.0;
        globals.actualizaArticulos = true;
      });

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, 'home');
      mostrarAlerta(context, 'Éxito', 'Venta realizada correctamente');
    } else {
      if (!mounted) return;
      mostrarAlerta(
          context, 'ERROR', respuesta.mensaje ?? 'Error al guardar la venta');
    }

    setState(() {
      _isLoading = false;
      _textLoading = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final venta = ModalRoute.of(context)?.settings.arguments as VentaCabecera;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de cobro'),
        elevation: 2,
      ),
      body: _isLoading
          ? _buildLoadingScreen()
          : _buildPaymentForm(screenSize, venta),
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

  Widget _buildPaymentForm(Size screenSize, VentaCabecera venta) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Ingrese la forma de pago',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Asegúrese de que el cambio sea correcto',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const Divider(height: 30),
              _buildPaymentField("Total:", _totalController, enabled: false),
              const SizedBox(height: 16),
              _buildPaymentField("Efectivo:", _efectivoController,
                  inputMoney: true),
              const SizedBox(height: 16),
              _buildPaymentField("Tarjeta:", _tarjetaController,
                  inputMoney: true),
              const SizedBox(height: 16),
              _buildPaymentField("Cambio:", _cambioController, enabled: false),
              const SizedBox(height: 24),
              _buildPrintingOptions(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancelar'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _checkVenta(venta),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Completar Venta'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentField(String label, TextEditingController controller,
      {bool enabled = true, bool inputMoney = false}) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: inputMoney
              ? InputFieldMoney(controller: controller)
              : TextField(
                  controller: controller,
                  enabled: enabled,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    prefixText: enabled ? null : '\$ ',
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPrintingOptions() {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Imprimir ticket'),
          value: _isPrinted,
          onChanged: _togglePrinter,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: Colors.green,
          dense: true,
        ),
        if (_isPrinted)
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: CheckboxListTile(
              title: const Text('Imprimir copia para cliente'),
              value: _x2ticket,
              onChanged: (value) => setState(() => _x2ticket = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),
          ),
      ],
    );
  }
}
