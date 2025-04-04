import 'package:flutter/material.dart';
import 'package:vende_facil/models/cuenta_sesion_modelo.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/abono_provider.dart';
import 'package:vende_facil/providers/apartado_provider.dart';
import 'package:vende_facil/providers/negocio_provider.dart';
import 'package:vende_facil/providers/reportes_provider.dart';
import 'package:vende_facil/providers/venta_provider.dart';
import 'package:intl/intl.dart';
import 'package:vende_facil/widgets/mostrar_alerta_ok.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final ventaProvider = VentasProvider();
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  String formattedSelectedDate = "";
  DateTime now = DateTime.now();

  late DateTime _selectedDate;
  double totalVentas = 0.0;
  late DateFormat dateFormatter;
  final _dateController = TextEditingController();

  String? _sucursalSeleccionada = '0';

  final provider = NegocioProvider();
  final reportesProvider = ReportesProvider();

  final ventasProvider = VentasProvider();
  final apartadoProvider = ApartadoProvider();
  final abonoProvider = AbonoProvider();

  final negocioProvider = NegocioProvider();

  // Lista para almacenar todas las ventas sin filtrar
  List<VentaCabecera> todasLasVentas = [];
  // Lista filtrada que se muestra en pantalla
  List<VentaCabecera> ventasFiltradas = [];

  // Mapa para agrupar ventas por folio
  Map<String, List<VentaCabecera>> ventasAgrupadas = {};

  @override
  void initState() {
    _selectedDate = DateTime(now.year, now.month, now.day);
    dateFormatter = DateFormat('yyyy-MM-dd');
    formattedSelectedDate = dateFormatter.format(_selectedDate);
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);

    listaVentas.clear();
    listasucursalEmpleado.clear();
    ventasFiltradas.clear();
    todasLasVentas.clear();

    // Cargar sucursales al iniciar
    if (sesion.tipoUsuario == "P") {
      provider.getlistaSucursales();
    }

    super.initState();
  }

  // Consultar ventas para la fecha seleccionada
  Future<void> _consultarVentas() async {
    isLoading = true;
    textLoading =
        'Consultando ventas del ${DateFormat('dd/MM/yyyy').format(_selectedDate)}';
    setState(() {});

    final resultado = await reportesProvider.reporteGeneral(
        formattedSelectedDate, formattedSelectedDate);

    if (resultado.status != 1) {
      isLoading = false;
      setState(() {});
      mostrarAlerta(context, 'Error', resultado.mensaje!);
      return;
    }

    // Guardamos todas las ventas sin filtrar
    todasLasVentas = List.from(listaVentas);
    _filtrarVentas();

    isLoading = false;
    setState(() {});
  }

  // Filtrar ventas según la sucursal seleccionada
  void _filtrarVentas() {
    if (_sucursalSeleccionada == '0') {
      // Mostrar todas las ventas
      ventasFiltradas = List.from(todasLasVentas);
    } else {
      // Filtrar por sucursal
      ventasFiltradas = todasLasVentas
          .where(
              (venta) => venta.id_sucursal.toString() == _sucursalSeleccionada)
          .toList();
    }

    // Actualizar el total de ventas
    totalVentas = ventasFiltradas.fold(0.0, (sum, item) => sum + item.total!);

    // Agrupar ventas por folio
    ventasAgrupadas.clear();
    for (var venta in ventasFiltradas) {
      String folio = venta.folio ?? venta.idMovimiento.toString();
      if (!ventasAgrupadas.containsKey(folio)) {
        ventasAgrupadas[folio] = [];
      }
      ventasAgrupadas[folio]!.add(venta);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      onPopInvoked: (didpop) {
        if (!didpop) {
          Navigator.pushReplacementNamed(context, 'menu-historial');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Historial de Ventas'),
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
                    ]),
              )
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.04),
                child: Column(
                  children: [
                    SizedBox(
                      height: windowHeight * 0.02,
                    ),
                    const Text(
                      'Seleccione una fecha y sucursal para consultar las ventas.',
                      maxLines: 2,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(
                      height: windowHeight * 0.02,
                    ),
                    // Selector de fecha (un solo día)
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            child: TextFormField(
                              controller: _dateController,
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2015),
                                  lastDate: DateTime.now(),
                                  initialDate: _selectedDate,
                                );
                                if (picked != null && picked != _selectedDate) {
                                  setState(() {
                                    _selectedDate = picked;
                                    formattedSelectedDate =
                                        dateFormatter.format(_selectedDate);
                                    _dateController.text =
                                        DateFormat('dd/MM/yyyy')
                                            .format(_selectedDate);
                                  });

                                  // Consultar ventas con la nueva fecha
                                  await _consultarVentas();
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Seleccionar fecha',
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime(2015),
                                      lastDate: DateTime.now(),
                                      initialDate: _selectedDate,
                                    );
                                    if (picked != null &&
                                        picked != _selectedDate) {
                                      setState(() {
                                        _selectedDate = picked;
                                        formattedSelectedDate =
                                            dateFormatter.format(_selectedDate);
                                        _dateController.text =
                                            DateFormat('dd/MM/yyyy')
                                                .format(_selectedDate);
                                      });

                                      // Consultar ventas con la nueva fecha
                                      await _consultarVentas();
                                    }
                                  },
                                  icon: const Icon(Icons.calendar_today),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),

                    // Dropdown de sucursales
                    if (sesion.tipoUsuario == "P") _sucursales(),

                    SizedBox(
                      height: windowHeight * 0.02,
                    ),

                    // Encabezado con información resumida
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      color: Colors.blue.shade50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Total ventas: ${ventasAgrupadas.length}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),

                    // Lista de ventas
                    Expanded(
                      child: ventasFiltradas.isEmpty
                          ? const Center(
                              child: Text(
                                  'No hay ventas registradas en la fecha seleccionada'),
                            )
                          : ListView.builder(
                              itemCount: ventasAgrupadas.length,
                              itemBuilder: (context, index) {
                                String folio =
                                    ventasAgrupadas.keys.elementAt(index);
                                List<VentaCabecera> items =
                                    ventasAgrupadas[folio]!;
                                VentaCabecera primeraVenta = items.first;

                                // Calcular el total por venta
                                double totalVenta = items.fold(
                                    0.0, (sum, item) => sum + item.total!);

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Folio: ${primeraVenta.folio ?? primeraVenta.idMovimiento}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  decoration:
                                                      primeraVenta.cancelado ==
                                                              '1'
                                                          ? TextDecoration
                                                              .lineThrough
                                                          : null,
                                                  color:
                                                      primeraVenta.cancelado ==
                                                              '1'
                                                          ? Colors.red
                                                          : null,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              // Mostrar solo la hora
                                              DateFormat('HH:mm').format(
                                                  DateTime.parse(primeraVenta
                                                      .fecha_venta!)),
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text('Empleado: ${primeraVenta.name}'),
                                        Text(
                                            'Sucursal: ${primeraVenta.nombreSucursal ?? "No especificada"}'),
                                        const SizedBox(height: 4),
                                        Text(
                                          _getTipoMovimientoText(
                                              primeraVenta.tipo_movimiento),
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Divider(),

                                        // Mostrar total
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            const Text(
                                              'Total:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '\$${totalVenta.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: primeraVenta.cancelado ==
                                                        '1'
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    // Botones en la parte inferior
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              // Función para exportar a PDF (sin implementar)
                            },
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Exportar PDF'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Función para imprimir (sin implementar)
                            },
                            icon: const Icon(Icons.print),
                            label: const Text('Imprimir'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        persistentFooterButtons: [
          BottomAppBar(
            child: SizedBox(
              height: 50,
              child: Center(
                child: Text(
                    'Total de ventas: \$ ${totalVentas.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para dropdown de sucursales
  Widget _sucursales() {
    var listades = [
      const DropdownMenuItem(
        value: '0',
        child: SizedBox(child: Text('Todas las Sucursales')),
      ),
    ];

    listades.addAll(
      listaSucursales.map((sucursal) {
        return DropdownMenuItem(
          value: sucursal.id.toString(),
          child: SizedBox(child: Text(sucursal.nombreSucursal ?? '')),
        );
      }).toList(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SUCURSALES',
          style: TextStyle(fontSize: 13),
        ),
        DropdownButton(
          items: listades,
          isExpanded: true,
          value: _sucursalSeleccionada,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _sucursalSeleccionada = value;
              });
              _filtrarVentas();
            }
          },
        ),
      ],
    );
  }

  // Función para obtener detalles de la venta seleccionada
  void _getDetails(VentaCabecera venta) async {
    isLoading = true;
    setState(() {});

    await negocioProvider.getlistaSucursales();

    if (venta.tipo_movimiento == "VT" || venta.tipo_movimiento == "VD") {
      final resultado = await ventaProvider.consultarventa(venta.idMovimiento!);
      isLoading = false;
      setState(() {});
      if (resultado.status != 1) {
        mostrarAlerta(
            context, 'Error', resultado.mensaje ?? 'Intentalo mas tarde');
        return;
      }
      Navigator.pushNamed(context, 'ventasD');
      return;
    }

    if (venta.tipo_movimiento == "P") {
      final resultado =
          await apartadoProvider.detallesApartado(venta.idMovimiento!);
      isLoading = false;
      setState(() {});
      if (resultado.status != 1) {
        mostrarAlerta(
            context, 'Error', resultado.mensaje ?? 'Intentalo mas tarde');
        return;
      }
      Navigator.pushNamed(context, 'apartadosD');
      return;
    }

    if (venta.tipo_movimiento == "A") {
      final resultado =
          await abonoProvider.obtenerAbono(venta.idMovimiento.toString());
      isLoading = false;
      setState(() {});
      if (resultado.status != 1) {
        mostrarAlerta(
            context, 'Error', resultado.mensaje ?? 'Intentalo mas tarde');
        return;
      }
      Navigator.pushNamed(context, 'abonoD');
      return;
    }

    isLoading = false;
    setState(() {});
  }

  // Función para obtener texto descriptivo del tipo de movimiento
  String _getTipoMovimientoText(String? tipoMovimiento) {
    switch (tipoMovimiento) {
      case 'VD':
        return 'Venta a domicilio';
      case 'VT':
        return 'Venta en tienda';
      case 'P':
        return 'Apartado';
      case 'A':
        return 'Abono';
      case 'E':
        return 'Entrega apartado';
      case 'CV':
        return 'Cancelación venta';
      case 'CA':
        return 'Cancelación apartado';
      default:
        return 'Movimiento';
    }
  }
}
