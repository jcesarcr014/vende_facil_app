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

  // Variables para almacenar los valores numéricos y evitar parsing repetitivo
  double _efectivoValue = 0.0;
  double _tarjetaValue = 0.0;
  double _totalValue = 0.0;

  @override
  void initState() {
    super.initState();
    // Asignar valor inicial al _totalValue también
    _totalValue =
        totalVT; // Asumiendo que totalVT es un double global o accesible
    _totalController.text = _totalValue.toStringAsFixed(2);

    // Inicializar los controladores de efectivo y tarjeta
    // El InputFieldMoney ya debería manejar el "0.00" por defecto si está vacío
    // _efectivoController.text = "0.00";
    // _tarjetaController.text = "0.00";

    _cambioController.text = "0.00";

    _efectivoController.addListener(_onEfectivoChanged);
    _tarjetaController.addListener(_onTarjetaChanged);

    // Calcular el cambio inicial por si acaso, aunque debería ser 0.00
    // _calculateAndSetCambio(); // Se llamará cuando los campos se inicialicen
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
    // No necesitamos setState aquí para actualizar los _efectivoValue y _tarjetaValue,
    // ya que los listeners se encargan de eso.
    // Solo necesitamos setState si el TEXTO del _cambioController va a cambiar.

    final totalPago = _efectivoValue + _tarjetaValue;
    double cambioCalculado = totalPago - _totalValue;

    if (cambioCalculado < 0) {
      cambioCalculado = 0.0;
    }

    final nuevoCambioTexto = cambioCalculado.toStringAsFixed(2);

    // Solo actualiza el texto del controlador y llama a setState si el valor realmente cambió
    // para evitar bucles innecesarios si el InputFieldMoney también tiene listeners.
    if (_cambioController.text != nuevoCambioTexto) {
      // Para evitar el error "setState() or markNeedsBuild() called during build":
      if (mounted &&
          SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
        // Si estamos 'idle', es seguro llamar a setState.
        setState(() {
          _cambioController.text = nuevoCambioTexto;
        });
      } else if (mounted) {
        // Si no estamos 'idle' (estamos en build, layout o paint), programar para después del frame.
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // Verificar nuevamente porque el callback se ejecuta después
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

    // Usar los valores numéricos ya parseados
    final total = _totalValue;
    // Asegurarse de que los valores de efectivo y tarjeta estén actualizados antes de usarlos
    // Los listeners deberían haberlos actualizado, pero una lectura directa es más segura aquí.
    final efectivoActual =
        double.tryParse(_efectivoController.text.replaceAll(',', '')) ?? 0.0;
    final tarjetaActual =
        double.tryParse(_tarjetaController.text.replaceAll(',', '')) ?? 0.0;
    final cambioActual =
        double.tryParse(_cambioController.text.replaceAll(',', '')) ?? 0.0;

    final totalPagadoConMedios = efectivoActual + tarjetaActual;

    if (tarjetaActual > total) {
      _mostrarError('El pago con tarjeta no puede ser mayor al total.');
      return;
    }
    // El cambio ya se calcula para ser >= 0.
    // La validación importante es que lo pagado (efectivo + tarjeta) sea >= total.
    if (totalPagadoConMedios < total) {
      _mostrarError('El monto pagado es menor al importe total de la venta.');
      return;
    }

    // El 'totalEfectivo' que pasas a procesarCompra es el efectivo neto después de dar cambio.
    // Si el pago es exacto con efectivo o hay cambio, efectivo - cambioActual es correcto.
    // Si el pago es con tarjeta o mixto, y el cambio se da del efectivo, también es correcto.
    final efectivoNetoParaCaja = efectivoActual - cambioActual;

    // Llamar a procesar compra con los valores correctos
    // El 'efectivo' que se pasa a _procesarCompra debe ser el monto recibido en efectivo.
    // El 'totalEfectivo' que se guarda en la venta es el efectivo que se queda en caja (efectivo recibido - cambio).
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
    venta.importeEfectivo =
        efectivoNetoEnCaja; // Este es el efectivo que se queda en caja
    venta.cambio = cambioEntregado;
    venta.id_sucursal = sesion.idSucursal;

    final detalles = ventaTemporal
        .map((item) => VentaDetalle(
              idVenta: 0,
              idProd: item.idArticulo,
              cantidad: item.cantidad,
              precioUnitario: item.precioUnitario,
              precio: item
                  .precioPublico, // Asumo que este es el precio final con descuentos aplicados por item
              idDesc:
                  venta.idDescuento, // Si el descuento es general a la venta
              cantidadDescuento: venta.descuento, // Valor del descuento general
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

        // Pasar efectivoRecibido a imprimirVenta, ya que es lo que el cliente dio
        final respuestaImp = await _impresionesTickets.imprimirVenta(
            venta, tarjetaPagada, efectivoRecibido, cambioEntregado, _x2ticket);

        if (respuestaImp.status != 1) {
          if (!mounted) return;
          mostrarAlerta(context, 'Advertencia',
              'Venta guardada, pero no fue posible imprimir el ticket: ${respuestaImp.mensaje}');
        }
      }

      // Limpiar estado global después de una venta exitosa
      setState(() {
        // Asegurar que este setState es seguro
        ventaTemporal.clear();
        totalVT = 0.0;
        // Podrías también resetear _efectivoController, _tarjetaController, _cambioController aquí si esta pantalla permaneciera.
        // Pero como se hace pushReplacementNamed, no es estrictamente necesario para esta instancia.
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
    // Obtener argumentos solo una vez si es posible, o asegurarse de que no cause problemas.
    // Si esta pantalla puede ser reconstruida y los argumentos cambian, esto es correcto.
    // Si los argumentos son fijos para la vida de la pantalla, podrían obtenerse en initState.
    // Pero ModalRoute.of(context) dentro de build es común.
    final VentaCabecera? venta =
        ModalRoute.of(context)?.settings.arguments as VentaCabecera?;

    // Si venta es null, ¿qué debería pasar? Mostrar un error o un estado vacío.
    if (venta == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
            child: Text('Error: No se proporcionaron datos de la venta.')),
      );
    }

    // Actualizar el total si cambia (aunque usualmente no debería cambiar en esta pantalla)
    // Esto es más por si totalVT global se modifica externamente y esta pantalla se reconstruye.
    if (_totalValue != totalVT) {
      _totalValue = totalVT;
      _totalController.text = _totalValue.toStringAsFixed(2);
      // Recalcular cambio si el total cambia
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _calculateAndSetCambio();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de cobro'),
        elevation: 2,
        // leading: IconButton( // Opcional: si quieres un botón de atrás explícito
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () => Navigator.pop(context),
        // ),
      ),
      body: _isLoading
          ? _buildLoadingScreen()
          : _buildPaymentForm(
              MediaQuery.of(context).size, venta), // Pasar la venta obtenida
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
                      icon: const Icon(
                          Icons.cancel_outlined), // Icono más adecuado
                      label: const Text('Cancelar'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                            color: Colors.grey.shade400), // Borde más sutil
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _checkVenta(venta),
                      icon: const Icon(
                          Icons.check_circle_outline), // Icono más adecuado
                      label: const Text('Completar Venta'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green.shade600, // Tono de verde
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
          flex: 2, // Dar un poco más de espacio a la etiqueta
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          flex: 3, // Dar un poco más de espacio al campo
          child: inputMoney
              ? InputFieldMoney(
                  controller:
                      controller) // Asumiendo que InputFieldMoney ya está refactorizado
              : TextField(
                  controller: controller,
                  enabled: enabled,
                  textAlign:
                      TextAlign.right, // Alinear a la derecha para montos
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    prefixText: !enabled
                        ? '\$ '
                        : null, // Mostrar '$' solo si está deshabilitado
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
          contentPadding: EdgeInsets.zero, // Ajustar padding
        ),
        if (_isPrinted)
          Padding(
            padding: const EdgeInsets.only(left: 16.0), // Ajustar indentación
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
