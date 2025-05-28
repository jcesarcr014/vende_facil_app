// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/apartado_provider.dart';
import 'package:vende_facil/util/imprime_tickets.dart';
import 'package:vende_facil/widgets/widgets.dart';

class ApartadoDetalleScreen extends StatefulWidget {
  const ApartadoDetalleScreen({super.key});
  @override
  State<ApartadoDetalleScreen> createState() => _ApartadoDetalleScreenState();
}

class _ApartadoDetalleScreenState extends State<ApartadoDetalleScreen> {
  bool _isLoading = false;
  String _textLoading = '';
  bool _isPrinted = false;
  bool _x2ticket = false;
  bool _fechaValida = false;

  final _efectivoController = TextEditingController();
  final _tarjetaController = TextEditingController();
  final _fechaController = TextEditingController();
  final _totalController = TextEditingController();
  final _anticipoMinimoController = TextEditingController();
  final _apartadoProvider = ApartadoProvider();
  final _impresionesTicket = ImpresionesTickets();

  final _now = DateTime.now();
  late DateTime _fechaVencimiento;
  late DateFormat _dateFormatter;
  String _formattedEndDate = "";

  @override
  void initState() {
    super.initState();
    _totalController.text = totalVT.toStringAsFixed(2);
    _anticipoMinimoController.text =
        ((totalVT * (double.parse(listaVariables[0].valor))) / 100)
            .toStringAsFixed(2);
    _efectivoController.text = "0.00";
    _tarjetaController.text = "0.00";

    _fechaVencimiento = DateTime(_now.year, _now.month, _now.day);
    _dateFormatter = DateFormat('yyyy-MM-dd');
    _formattedEndDate = _dateFormatter.format(_fechaVencimiento);
    _fechaController.text = _formattedEndDate;
  }

  @override
  void dispose() {
    _totalController.dispose();
    _anticipoMinimoController.dispose();
    _efectivoController.dispose();
    _tarjetaController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _now.add(const Duration(days: 1)),
      firstDate: _now,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      _formattedEndDate = _dateFormatter.format(picked);
      DateTime referencia = DateTime(_now.year, _now.month, _now.day);

      if (picked.isBefore(referencia) || picked.isAtSameMomentAs(referencia)) {
        _fechaValida = false;
        if (!mounted) return;
        mostrarAlerta(context, 'ERROR',
            'La fecha de vencimiento del apartado debe ser posterior al día de hoy.');
        return;
      }

      _fechaValida = true;
      setState(() {
        _fechaController.text = _formattedEndDate;
      });
    }
  }

  void _validaciones(ApartadoCabecera apartado) {
    bool validaciones = true;
    if (!_fechaValida && _fechaController.text == _dateFormatter.format(_now)) {
      // Si la fecha no ha sido cambiada, seleccionar el día siguiente automáticamente
      final tomorrow = _now.add(const Duration(days: 1));
      _fechaController.text = _dateFormatter.format(tomorrow);
      _fechaValida = true;
    } else if (!_fechaValida) {
      validaciones = false;
      mostrarAlerta(context, 'ERROR',
          'La fecha de vencimiento no es válida, debe ser mayor al día de hoy.');
      return;
    }

    double totalAnticipo =
        double.parse(_efectivoController.text.replaceAll(',', '')) +
            double.parse(_tarjetaController.text.replaceAll(',', ''));
    double totalCompra = double.parse(_totalController.text);
    double anticipoMinimo = double.parse(_anticipoMinimoController.text);

    if (totalAnticipo >= totalCompra) {
      validaciones = false;
      mostrarAlerta(context, 'ERROR',
          'Estás ingresando un monto mayor o igual al total de la compra. Para apartado, el anticipo debe ser menor al total de la compra ${totalCompra.toStringAsFixed(2)}.');
      return;
    }

    if (totalAnticipo < anticipoMinimo) {
      validaciones = false;
      mostrarAlerta(context, 'ERROR',
          'El anticipo ingresado es menor al monto mínimo requerido de ${anticipoMinimo.toStringAsFixed(2)}');
      return;
    }

    if (validaciones) {
      _procesarApartado(apartado, totalAnticipo);
    }
  }

  Future<void> _procesarApartado(
      ApartadoCabecera apartado, double totalAnticipo) async {
    setState(() {
      _isLoading = true;
      _textLoading = 'Guardando datos';
    });

    final fechaActual = DateTime(_now.year, _now.month, _now.day);
    apartado.pagoEfectivo =
        double.parse(_efectivoController.text.replaceAll(',', ''));
    apartado.pagoTarjeta =
        double.parse(_tarjetaController.text.replaceAll(',', ''));
    apartado.anticipo = totalAnticipo;
    apartado.saldoPendiente = apartado.total! - totalAnticipo;
    apartado.fechaApartado = fechaActual.toString();
    apartado.fechaVencimiento = _fechaController.text;

    List<ApartadoDetalle> detalles = [];
    for (ItemVenta item in ventaTemporal) {
      ApartadoDetalle apartadoDetalle = ApartadoDetalle(
        productoId: item.idArticulo,
        cantidad: item.cantidad,
        precio: item.precioPublico,
        subtotal: item.subTotalItem,
        descuentoId: apartado.descuentoId,
        descuento: item.descuento,
        total: item.totalItem,
      );
      detalles.add(apartadoDetalle);
    }

    final resp =
        await _apartadoProvider.guardaApartadoCompleto(apartado, detalles);

    if (resp.status == 1) {
      if (_isPrinted) {
        setState(() {
          _textLoading = 'Imprimiendo ticket';
        });

        final result = await _impresionesTicket.imprimirApartado(
            apartado,
            totalAnticipo,
            apartado.total! - totalAnticipo,
            apartado.pagoTarjeta!,
            apartado.pagoEfectivo!,
            _x2ticket);

        if (result.status != 1) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _textLoading = '';
          });
          mostrarAlerta(
              context,
              'Error',
              result.mensaje ??
                  'No se pudo imprimir el ticket, pero el apartado fue registrado.');
          return;
        }
      }

      setState(() {
        ventaTemporal.clear();
        totalVT = 0.0;
      });

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, 'home');
      mostrarAlerta(context, 'Éxito', 'Apartado realizado correctamente');
    } else {
      if (!mounted) return;
      mostrarAlerta(
          context, 'ERROR', 'Ocurrió el siguiente error: ${resp.mensaje}');
    }

    setState(() {
      _isLoading = false;
      _textLoading = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final apartado =
        ModalRoute.of(context)?.settings.arguments as ApartadoCabecera;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de apartado'),
        elevation: 2,
      ),
      body: _isLoading ? _buildLoadingScreen() : _buildApartadoForm(apartado),
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

  Widget _buildApartadoForm(ApartadoCabecera apartado) {
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
                'Ingrese los datos del apartado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Asegúrese de que el anticipo cumpla con el mínimo requerido',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const Divider(height: 30),
              _buildPaymentField("Total:", _totalController, enabled: false),
              const SizedBox(height: 16),
              _buildPaymentField("Anticipo mínimo:", _anticipoMinimoController,
                  enabled: false),
              const SizedBox(height: 16),
              _buildFechaField(),
              const SizedBox(height: 16),
              _buildPaymentField("Efectivo:", _efectivoController,
                  inputMoney: true),
              const SizedBox(height: 16),
              _buildPaymentField("Tarjeta:", _tarjetaController,
                  inputMoney: true),
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
                      onPressed: () => _validaciones(apartado),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Registrar Apartado'),
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

  Widget _buildFechaField() {
    return Row(
      children: [
        const Expanded(
          flex: 1,
          child: Text(
            "Fecha vencimiento:",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: TextField(
            controller: _fechaController,
            readOnly: true,
            onTap: _selectDate,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _selectDate,
              ),
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
          onChanged: (value) => setState(() => _isPrinted = value ?? false),
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
