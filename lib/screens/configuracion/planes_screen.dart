import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart' hide Card; // Renombrar Card para evitar conflicto
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';

class PlanesScreen extends StatefulWidget {
  const PlanesScreen({super.key});

  @override
  State<PlanesScreen> createState() => _PlanesScreenState();
}

class _PlanesScreenState extends State<PlanesScreen> {
  final _suscripcionProvider = SuscripcionProvider();
  final _usuarioProvider = UsuarioProvider();
  bool _isLoadingPlanes = true;
  final bool _isLoadingPaymentMethod = false;
  String? _errorPlanes;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  Future<void> _cargarDatosIniciales() async {
    await Future.wait([
      _cargarPlanes(),
      // _cargarMetodoPago(),
    ]);
  }

  Future<void> _cargarPlanes() async {
    if (!mounted) return;
    setState(() {
      _isLoadingPlanes = true;
      _errorPlanes = null;
    });
    final resultado = await _suscripcionProvider.obtienePlanes();
    if (!mounted) return;
    if (resultado.status != 1) {
      _errorPlanes = resultado.mensaje ?? 'No se pudieron cargar los planes.';
    }
    setState(() => _isLoadingPlanes = false);
  }

  // Future<void> _cargarMetodoPago() async {
  //   if (!mounted) return;
  //   setState(() => _isLoadingPaymentMethod = true);
  //   await _suscripcionProvider.obtenerMetodoPago();
  //   if (!mounted) return;
  //   setState(() => _isLoadingPaymentMethod = false);
  // }

  // Future<void> _iniciarProcesoDePago(
  //     {PlanSuscripcion? planSeleccionado}) async {
  //   if (!mounted) return;
  //   setState(() => _isLoadingPaymentMethod = true);

  //   try {
  //     // 1. Siempre preparamos un SetupIntent. Es necesario para añadir o actualizar la tarjeta.
  //     final clientSecret = await _suscripcionProvider.prepararSetupDePago();
  //     if (clientSecret == null) {
  //       throw Exception('No se pudo preparar el formulario de pago.');
  //     }

  //     // 2. Inicializamos y mostramos el Payment Sheet
  //     await Stripe.instance.initPaymentSheet(
  //       paymentSheetParameters: SetupPaymentSheetParameters(
  //         merchantDisplayName: 'Vende Fácil',
  //         setupIntentClientSecret: clientSecret,
  //         style: ThemeMode.system,
  //       ),
  //     );

  //     await Stripe.instance.presentPaymentSheet();

  //     // ¡ÉXITO! El usuario completó el sheet. Ahora la lógica se divide.

  //     if (planSeleccionado != null) {
  //       // --- CASO 1: El usuario venía de seleccionar un plan ---
  //       // Después de guardar la tarjeta, procedemos a cambiar la suscripción.
  //       // PERO ahora necesitamos el ID del método de pago. La forma oficial es
  //       // recuperar el SetupIntent para obtener el paymentMethodId.
  //       final setupIntent =
  //           await Stripe.instance.retrieveSetupIntent(clientSecret);
  //       final paymentMethodId = setupIntent.paymentMethodId;

  //       // Llamamos a cambiarSuscripcion PASÁNDOLE el nuevo método de pago
  //       await _ejecutarCambioDeSuscripcion(planSeleccionado,
  //           paymentMethodId: paymentMethodId);
  //     } else {
  //       // --- CASO 2: El usuario solo quería añadir/actualizar su tarjeta ---
  //       // desde la tarjeta de "Método de Pago".
  //       // Actualizamos el método de pago por defecto en el backend.
  //       final setupIntent =
  //           await Stripe.instance.retrieveSetupIntent(clientSecret);
  //       final paymentMethodId = setupIntent.paymentMethodId;

  //       final resultado =
  //           await _suscripcionProvider.actualizarMetodoPago(paymentMethodId);

  //       if (resultado.status == 1 && mounted) {
  //         mostrarAlerta(context, 'Éxito',
  //             resultado.mensaje ?? 'Tu método de pago ha sido guardado.');
  //         await _cargarMetodoPago(); // Refrescamos la UI para mostrar la nueva tarjeta
  //       } else if (mounted) {
  //         mostrarAlerta(context, 'Error',
  //             resultado.mensaje ?? 'No se pudo guardar el método de pago.');
  //       }
  //     }
  //   } on StripeException catch (e) {
  //     if (e.error.code != FailureCode.Canceled && mounted) {
  //       mostrarAlerta(context, 'Error de pago',
  //           e.error.localizedMessage ?? 'Ocurrió un error.');
  //     }
  //   } catch (e) {
  //     if (mounted) mostrarAlerta(context, 'Error', e.toString());
  //   } finally {
  //     if (mounted) setState(() => _isLoadingPaymentMethod = false);
  //   }
  // }

  // ¡FUNCIÓN REFACTORIZADA! Separamos la lógica de selección de la de pago.
  Future<void> _seleccionarPlan(PlanSuscripcion planSeleccionado) async {
    if (planSeleccionado.idStripe == null ||
        planSeleccionado.idStripe!.isEmpty) {
      if (mounted) {
        mostrarAlerta(context, 'Error', 'Este plan no está configurado.');
      }
      return;
    }

    await _ejecutarCambioDeSuscripcion(planSeleccionado);

    // if (metodoPagoActual == null) {
    //   // Si no hay método de pago, iniciamos el flujo completo de pago.
    //   await _iniciarProcesoDePago(planSeleccionado: planSeleccionado);
    // } else {
    //   // Si YA hay un método de pago, cambiamos el plan directamente.
    //   await _ejecutarCambioDeSuscripcion(planSeleccionado);
    // }
  }

  // ¡NUEVA FUNCIÓN AYUDANTE! Encapsula la llamada a la API para cambiar de plan.
  Future<void> _ejecutarCambioDeSuscripcion(PlanSuscripcion plan) async {
    if (!mounted) return;
    setState(() => _isLoadingPlanes = true);

    try {
      final resultadoCambio =
          await _suscripcionProvider.cambiarSuscripcion(plan.idStripe!);
      if (!mounted) return;

      if (resultadoCambio.status == 1) {
        mostrarAlerta(context, '¡Felicidades!',
            resultadoCambio.mensaje ?? 'Tu plan ha sido actualizado.');
        await _usuarioProvider.userInfo();
        await _cargarDatosIniciales();
      } else {
        throw Exception(
            resultadoCambio.mensaje ?? 'No se pudo actualizar tu plan.');
      }
    } catch (e) {
      if (mounted) mostrarAlerta(context, 'Error', e.toString());
    } finally {
      if (mounted) setState(() => _isLoadingPlanes = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, 'config');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Planes y Suscripción'),
          automaticallyImplyLeading: false,
          elevation: 2,
          actions: [
            IconButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, 'config'),
              icon: const Icon(Icons.close),
              tooltip: 'Volver a Configuración',
            ),
          ],
        ),
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _cargarDatosIniciales,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildAnuncioPromocional(),
                  const SizedBox(height: 24),
                  // _buildPaymentMethodCard(),
                  // const SizedBox(height: 24),
                  if (_isLoadingPlanes)
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator()))
                  else if (_errorPlanes != null)
                    _buildErrorView() // Ahora esta función existe
                  else
                    ...listaPlanes.map((plan) {
                      final bool esPlanActual =
                          (suscripcionActual.idPlan == plan.id);
                      return _buildPlanCard(
                          plan, esPlanActual); // Ahora esta función existe
                    }),
                ],
              ),
            ),
            // El loading de PaymentMethod ahora cubre toda la pantalla si está activo
            if (_isLoadingPaymentMethod)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  // --- AÑADIDO: Widget de anuncio promocional ---
  Widget _buildAnuncioPromocional() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade500, Colors.purple.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.star_rounded, color: Colors.amber, size: 40),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Oferta de Lanzamiento!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Todos los planes son GRATIS por tiempo limitado. ¡Aprovecha!',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- WIDGETS DE CONSTRUCCIÓN (AÑADIDOS) ---

  // Widget _buildPaymentMethodCard() {
  //   return Card(
  //     elevation: 2,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text('Método de Pago',
  //               style: Theme.of(context).textTheme.titleLarge),
  //           const SizedBox(height: 16),
  //           if (_isLoadingPaymentMethod)
  //             const Center(child: CircularProgressIndicator(strokeWidth: 2))
  //           else if (metodoPagoActual != null)
  //             ListTile(
  //               contentPadding: EdgeInsets.zero, // Para controlar el padding
  //               leading: Icon(Icons.credit_card,
  //                   color: Theme.of(context).primaryColor, size: 40),
  //               title: Text(
  //                   '${metodoPagoActual!.marca} terminada en ${metodoPagoActual!.ultimos4}'),
  //               subtitle: Text(
  //                   'Expira ${metodoPagoActual!.mesExp.toString().padLeft(2, '0')}/${metodoPagoActual!.anoExp}'),
  //               trailing: TextButton(
  //                 onPressed: () => _iniciarProcesoDePago(),
  //                 child: const Text('Cambiar'),
  //               ),
  //             )
  //           else
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.stretch,
  //               children: [
  //                 Text('No tienes un método de pago guardado.',
  //                     style: TextStyle(color: Colors.grey[700])),
  //                 const SizedBox(height: 16),
  //                 ElevatedButton.icon(
  //                   onPressed: () => _iniciarProcesoDePago(),
  //                   icon: const Icon(Icons.add_card),
  //                   label: const Text('Agregar Tarjeta'),
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: Colors.grey[800],
  //                     foregroundColor: Colors.white,
  //                     shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(10)),
  //                     padding: const EdgeInsets.symmetric(vertical: 12),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(_errorPlanes!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _cargarPlanes,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(PlanSuscripcion plan, bool esPlanActual) {
    final textTheme = Theme.of(context).textTheme;
    final Color colorPrimario = Theme.of(context).primaryColor;
    final borderColor = esPlanActual ? colorPrimario : Colors.grey.shade300;
    final bool tieneCostoOriginal =
        (double.tryParse(plan.monto ?? '0') ?? 0) > 0;

    return Container(
      margin: const EdgeInsets.only(top: 12.0, bottom: 16.0),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Card(
              elevation: esPlanActual ? 5 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side:
                    BorderSide(color: borderColor, width: esPlanActual ? 2 : 1),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 28.0, 20.0, 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      plan.nombrePlan ?? 'Sin nombre',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: esPlanActual ? colorPrimario : null,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (tieneCostoOriginal)
                      Text(
                        '\$${plan.monto ?? "0.00"} ${plan.divisa ?? "MXN"}',
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.grey[500],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    Text(
                      '\$0.00',
                      textAlign: TextAlign.center,
                      style: textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade600),
                    ),

                    Text(
                      plan.periodicidad == 'month' ? '/ mes' : '/ año',
                      // ... (resto del texto)
                    ),
                    const Divider(height: 32),

                    // --- SECCIÓN DE CARACTERÍSTICAS (CORREGIDA Y AÑADIDA) ---
                    _buildFeatureRow(Icons.store_outlined,
                        '${plan.sucursales ?? 0}', 'Sucursal(es)'),
                    _buildFeatureRow(Icons.people_alt_outlined,
                        '${plan.empleados ?? 0}', 'Empleado(s)'),
                    _buildFeatureRow(
                        Icons.inventory_2_outlined,
                        (plan.productos ?? 0) == 0
                            ? 'Ilimitados'
                            : '${plan.productos}',
                        'Productos'),
                    _buildFeatureRow(
                        Icons.receipt_long_outlined,
                        (plan.ventas ?? 0) == 0
                            ? 'Ilimitadas'
                            : '${plan.ventas}',
                        'Ventas por mes'),
                    const SizedBox(height: 24),
                    if (!esPlanActual)
                      ElevatedButton(
                        onPressed: (_isLoadingPlanes || _isLoadingPaymentMethod)
                            ? null
                            : () => _seleccionarPlan(
                                plan), // Esta función ahora es la simplificada
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorPrimario,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                            'Seleccionar Plan Gratis', // Texto del botón actualizado
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (esPlanActual)
            Positioned(
              top: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: colorPrimario,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  child: Text('PLAN ACTUAL',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String value, String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade700, size: 22),
          const SizedBox(width: 16),
          Expanded(child: Text(feature, style: const TextStyle(fontSize: 16))),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
