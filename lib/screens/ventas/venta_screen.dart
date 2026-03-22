import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // Necesario para addPostFrameCallback
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/venta_provider.dart';
import 'package:vende_facil/util/imprime_tickets.dart';
import 'package:vende_facil/widgets/widgets.dart';

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

  double _efectivoValue = 0.0;
  double _tarjetaValue = 0.0;
  double _totalValue = 0.0;

  @override
  void initState() {
    super.initState();
    _totalValue = totalVT;
    _totalController.text = _totalValue.toStringAsFixed(2);

    _cambioController.text = "0.00";

    _efectivoController.addListener(_onEfectivoChanged);
    _tarjetaController.addListener(_onTarjetaChanged);
  }

  @override
  void dispose() {
    _efectivoController.removeListener(_onEfectivoChanged);
    _tarjetaController.removeListener(_onTarjetaChanged);
    _totalController.dispose();
    _efectivoController.dispose();
    _cambioController.dispose();
    _tarjetaController.dispose();
    super.dispose();
  }

  void _onEfectivoChanged() {
    _efectivoValue =
        double.tryParse(_efectivoController.text.replaceAll(',', '')) ?? 0.0;
    _calculateAndSetCambio();
  }

  void _onTarjetaChanged() {
    _tarjetaValue =
        double.tryParse(_tarjetaController.text.replaceAll(',', '')) ?? 0.0;
    _calculateAndSetCambio();
  }

  void _calculateAndSetCambio() {
    final totalPago =
        double.parse((_efectivoValue + _tarjetaValue).toStringAsFixed(2));
    final totalVentaR = double.parse(_totalValue.toStringAsFixed(2));

    double cambioCalculado = totalPago - totalVentaR;

    if (cambioCalculado < 0.01) {
      cambioCalculado = 0.0;
    }

    final nuevoCambioTexto = cambioCalculado.toStringAsFixed(2);

    if (_cambioController.text != nuevoCambioTexto) {
      if (mounted &&
          SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
        setState(() {
          _cambioController.text = nuevoCambioTexto;
        });
      } else if (mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _cambioController.text = nuevoCambioTexto;
            });
          }
        });
      }
    }
  }

  Future<void> _togglePrinter(bool? value) async {
    if (value == null) return;

    final prefs = await SharedPreferences.getInstance();
    final mac = prefs.getString('macPrinter') ?? '';

    if (mac.isEmpty && value == true) {
      // Solo mostrar alerta si intentan activarlo sin impresora
      if (!mounted) return;
      mostrarAlerta(context, 'Atención', 'No tienes una impresora configurada');
      // No cambiar _isPrinted si no hay impresora y querían activarlo
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
    if (!mounted) return;
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

    final efectivoActual =
        double.tryParse(_efectivoController.text.replaceAll(',', '')) ?? 0.0;
    final tarjetaActual =
        double.tryParse(_tarjetaController.text.replaceAll(',', '')) ?? 0.0;
    final cambioActual =
        double.tryParse(_cambioController.text.replaceAll(',', '')) ?? 0.0;

    final totalR = double.parse(_totalValue.toStringAsFixed(2));
    final tarjetaR = double.parse(tarjetaActual.toStringAsFixed(2));
    final efectivoR = double.parse(efectivoActual.toStringAsFixed(2));
    final totalPagadoConMedios =
        double.parse((efectivoR + tarjetaR).toStringAsFixed(2));

    if (tarjetaR > totalR) {
      _mostrarError(
          'El pago con tarjeta no puede ser mayor al total de la venta.\n\nTotal: \$${totalR.toStringAsFixed(2)}');
      return;
    }

    if (totalPagadoConMedios < totalR) {
      _mostrarError(
          'Falta dinero. El monto pagado es menor al total de la venta.');
      return;
    }

    final efectivoNetoParaCaja =
        double.parse((efectivoR - cambioActual).toStringAsFixed(2));

    await _procesarCompra(venta, efectivoActual, tarjetaActual,
        efectivoNetoParaCaja, cambioActual);
  }

  Future<void> _procesarCompra(
      VentaCabecera venta,
      double efectivoRecibido,
      double tarjetaPagada,
      double efectivoNetoEnCaja,
      double cambioEntregado) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _textLoading = 'Guardando venta';
    });

    venta.importeTarjeta = tarjetaPagada;
    venta.importeEfectivo = efectivoNetoEnCaja;
    venta.cambio = cambioEntregado;
    venta.id_sucursal = sesion.idSucursal;

    final detalles = ventaTemporal
        .map((item) => VentaDetalle(
              idVenta: 0,
              idProd: item.idArticulo,
              cantidad: item.cantidad,
              precioUnitario: item.precioUnitario,
              precio: item.precioUtilizado,
              idDesc: venta.idDescuento,
              cantidadDescuento: venta.descuento,
              total: item.totalItem,
              subtotal: item.subTotalItem,
              id_sucursal: sesion.idSucursal,
            ))
        .toList();

    final respuesta =
        await _ventaProvider.guardarVentaCompleta(venta, detalles);

    if (!mounted) return;

    if (respuesta.status == 1) {
      if (_isPrinted) {
        setState(() {
          _textLoading = 'Imprimiendo ticket';
        });

        final respuestaImp = await _impresionesTickets.imprimirVenta(
            venta, tarjetaPagada, efectivoRecibido, cambioEntregado, _x2ticket);

        if (respuestaImp.status != 1) {
          if (!mounted) return;
          mostrarAlerta(context, 'Advertencia',
              'Venta guardada, pero no fue posible imprimir el ticket: ${respuestaImp.mensaje}');
        }
      }

      setState(() {
        ventaTemporal.clear();
        totalVT = 0.0;
        subtotalVT = 0.0;
        descuentoVT = 0.0;
        ahorroVT = 0.0;
        ventaDomicilio = false;
      });

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, 'home');
      mostrarAlerta(context, 'Éxito', 'Venta realizada correctamente');
    } else {
      if (!mounted) return;
      mostrarAlerta(
          context, 'ERROR', respuesta.mensaje ?? 'Error al guardar la venta');
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _textLoading = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final VentaCabecera? venta =
        ModalRoute.of(context)?.settings.arguments as VentaCabecera?;

    if (venta == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
            child: Text('Error: No se proporcionaron datos de la venta.')),
      );
    }

    if (_totalValue != totalVT) {
      _totalValue = totalVT;
      _totalController.text = _totalValue.toStringAsFixed(2);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _calculateAndSetCambio();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de cobro'),
        elevation: 2,
      ),
      body: _isLoading
          ? _buildLoadingScreen()
          : _buildPaymentForm(MediaQuery.of(context).size, venta),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _textLoading.isNotEmpty ? 'Espere... $_textLoading' : 'Cargando...',
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
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancelar'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _checkVenta(venta),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Completar Venta'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.bold)),
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
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: inputMoney
              ? InputFieldMoney(controller: controller)
              : TextField(
                  controller: controller,
                  enabled: enabled,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    prefixText: !enabled ? '\$ ' : null,
                    filled: !enabled,
                    fillColor: !enabled ? Colors.grey[200] : null,
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
          activeColor: Colors.green.shade600,
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        if (_isPrinted)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: CheckboxListTile(
              title: const Text('Imprimir copia para cliente'),
              subtitle:
                  const Text('(Doble ticket)', style: TextStyle(fontSize: 12)),
              value: _x2ticket,
              onChanged: (value) => setState(() => _x2ticket = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
      ],
    );
  }
}
