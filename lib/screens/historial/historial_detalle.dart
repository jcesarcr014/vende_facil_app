import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class ReporteDetalleDiaScreen extends StatefulWidget {
  const ReporteDetalleDiaScreen({super.key});

  @override
  State<ReporteDetalleDiaScreen> createState() =>
      _ReporteDetalleDiaScreenState();
}

class _ReporteDetalleDiaScreenState extends State<ReporteDetalleDiaScreen> {
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;

  // Variables para fecha
  DateTime now = DateTime.now();
  late DateTime _selectedDate;
  String formattedSelectedDate = "";
  late DateFormat dateFormatter;
  final _dateController = TextEditingController();

  // Filtro de sucursal
  String? _sucursalSeleccionada = '0';

  // Providers
  final reportesProvider = ReportesProvider();
  final provider = NegocioProvider();

  // Variables para almacenar datos filtrados
  List<ReporteVentaDetalle> ventasFiltradas = [];
  List<ReporteApartadoDetalle> apartadosFiltrados = [];
  List<ReporteAbonoDetalle> abonosFiltrados = [];

  // Mapas para agrupar ventas y apartados por folio
  Map<String, List<ReporteVentaDetalle>> ventasAgrupadas = {};
  Map<String, List<ReporteApartadoDetalle>> apartadosAgrupados = {};

  // Totales
  double totalVentas = 0.0;
  double totalApartados = 0.0;
  double totalAbonos = 0.0;
  double totalGeneral = 0.0;

  @override
  void initState() {
    super.initState();

    // Inicializar fecha
    _selectedDate = DateTime(now.year, now.month, now.day);
    dateFormatter = DateFormat('yyyy-MM-dd');
    formattedSelectedDate = dateFormatter.format(_selectedDate);
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);

    // Cargar sucursales al iniciar
    if (sesion.tipoUsuario == "P") {
      provider.getlistaSucursales();
    }

    // Consultar movimientos para la fecha actual
    _consultarDetalles();
  }

  // Consultar detalles para la fecha seleccionada
  Future<void> _consultarDetalles() async {
    setState(() {
      isLoading = true;
      textLoading =
          'Consultando detalles del ${DateFormat('dd/MM/yyyy').format(_selectedDate)}';
    });

    final resultado =
        await reportesProvider.reporteDetalle(formattedSelectedDate);

    if (resultado.status != 1) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        mostrarAlerta(
            context, 'Error', resultado.mensaje ?? 'Error al consultar');
      }
      return;
    }

    _filtrarDetalles();

    setState(() {
      isLoading = false;
    });
  }

  // Filtrar detalles según la sucursal seleccionada
  void _filtrarDetalles() {
    if (_sucursalSeleccionada == '0') {
      // Mostrar todos los detalles
      ventasFiltradas = List.from(ReporteDetalleDia.listaVentasDia);
      apartadosFiltrados = List.from(ReporteDetalleDia.listaApartadosDia);
      abonosFiltrados = List.from(ReporteDetalleDia.listaAbonosDia);
    } else {
      // Filtrar por sucursal
      ventasFiltradas = ReporteDetalleDia.listaVentasDia
          .where((venta) =>
              venta.nombreSucursal ==
              _obtenerNombreSucursal(_sucursalSeleccionada))
          .toList();

      apartadosFiltrados = ReporteDetalleDia.listaApartadosDia
          .where((apartado) =>
              apartado.nombreSucursal ==
              _obtenerNombreSucursal(_sucursalSeleccionada))
          .toList();

      abonosFiltrados = ReporteDetalleDia.listaAbonosDia
          .where((abono) =>
              abono.nombreSucursal ==
              _obtenerNombreSucursal(_sucursalSeleccionada))
          .toList();
    }

    // Agrupar ventas por folio
    ventasAgrupadas.clear();
    for (var venta in ventasFiltradas) {
      if (!ventasAgrupadas.containsKey(venta.folio)) {
        ventasAgrupadas[venta.folio!] = [];
      }
      ventasAgrupadas[venta.folio!]!.add(venta);
    }

    // Agrupar apartados por folio
    apartadosAgrupados.clear();
    for (var apartado in apartadosFiltrados) {
      if (!apartadosAgrupados.containsKey(apartado.folio)) {
        apartadosAgrupados[apartado.folio!] = [];
      }
      apartadosAgrupados[apartado.folio!]!.add(apartado);
    }

    // Calcular totales
    _calcularTotales();
  }

  String _obtenerNombreSucursal(String? idSucursal) {
    if (idSucursal == null) return "";

    for (var sucursal in listaSucursales) {
      if (sucursal.id.toString() == idSucursal) {
        return sucursal.nombreSucursal ?? "";
      }
    }
    return "";
  }

  void _calcularTotales() {
    totalVentas = 0.0;
    totalApartados = 0.0;
    totalAbonos = 0.0;

    // Sumar ventas
    for (var venta in ventasFiltradas) {
      totalVentas += double.tryParse(venta.total ?? "0") ?? 0.0;
    }

    // Sumar apartados (solo anticipo)
    for (var apartado in apartadosFiltrados) {
      totalApartados += double.tryParse(apartado.anticipo ?? "0") ?? 0.0;
    }

    // Sumar abonos
    for (var abono in abonosFiltrados) {
      double efectivo = double.tryParse(abono.cantidadEfectivo ?? "0") ?? 0.0;
      double tarjeta = double.tryParse(abono.cantidadTarjeta ?? "0") ?? 0.0;
      totalAbonos += efectivo + tarjeta;
    }

    // Total general
    totalGeneral = totalVentas + totalApartados + totalAbonos;
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
          title: const Text('Detalle de Movimientos'),
        ),
        body: isLoading ? _buildLoadingView() : _buildMainContent(),
        persistentFooterButtons: [
          BottomAppBar(
            child: SizedBox(
              height: 50,
              child: Center(
                child:
                    Text('Total General: \$ ${totalGeneral.toStringAsFixed(2)}',
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

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Espere...$textLoading'),
          SizedBox(height: windowHeight * 0.01),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // Encabezado con la fecha
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 8),
              Text(
                'Ventas: ${ventasAgrupadas.length} | Apartados: ${apartadosAgrupados.length} | Abonos: ${abonosFiltrados.length}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),

        // Selector de fecha y sucursal
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: windowWidth * 0.04, vertical: 16),
          child: Column(
            children: [
              // Selector de fecha
              TextFormField(
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
                          DateFormat('dd/MM/yyyy').format(_selectedDate);
                    });

                    // Consultar detalles con la nueva fecha
                    await _consultarDetalles();
                  }
                },
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Seleccionar fecha',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () async {
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
                              DateFormat('dd/MM/yyyy').format(_selectedDate);
                        });

                        // Consultar detalles con la nueva fecha
                        await _consultarDetalles();
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                  ),
                ),
              ),

              SizedBox(height: windowHeight * 0.02),

              // Dropdown de sucursales (solo para propietarios)
              if (sesion.tipoUsuario == "P") _sucursales(),
            ],
          ),
        ),

        // Contenido con pestañas
        Expanded(
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                TabBar(
                  tabs: const [
                    Tab(text: 'Ventas'),
                    Tab(text: 'Apartados'),
                    Tab(text: 'Abonos'),
                  ],
                  labelColor: Theme.of(context).primaryColor,
                  indicatorColor: Theme.of(context).primaryColor,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Pestaña de Ventas
                      _buildVentasTab(),

                      // Pestaña de Apartados
                      _buildApartadosTab(),

                      // Pestaña de Abonos
                      _buildAbonosTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Botones en la parte inferior
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: (ventasFiltradas.isNotEmpty ||
                        apartadosFiltrados.isNotEmpty ||
                        abonosFiltrados.isNotEmpty)
                    ? () {
                        _generarPDF();
                      }
                    : null,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Exportar PDF'),
              ),
              // ElevatedButton.icon(
              //   onPressed: (ventasFiltradas.isNotEmpty ||
              //           apartadosFiltrados.isNotEmpty ||
              //           abonosFiltrados.isNotEmpty)
              //       ? () {
              //           _generarPDF();
              //         }
              //       : null,
              //   icon: const Icon(Icons.print),
              //   label: const Text('Imprimir'),
              // ),
            ],
          ),
        ),
      ],
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
              _filtrarDetalles();
            }
          },
        ),
      ],
    );
  }

  // Pestaña de Ventas
  Widget _buildVentasTab() {
    return ventasAgrupadas.isEmpty
        ? const Center(
            child: Text('No hay ventas registradas en la fecha seleccionada'))
        : ListView.builder(
            itemCount: ventasAgrupadas.length,
            itemBuilder: (context, index) {
              String folio = ventasAgrupadas.keys.elementAt(index);
              List<ReporteVentaDetalle> items = ventasAgrupadas[folio]!;
              ReporteVentaDetalle primeraVenta = items.first;

              // Calcular el total de la venta
              double totalVenta = 0;
              for (var item in items) {
                totalVenta += double.parse(item.total ?? "0");
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Folio: $folio',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            primeraVenta.createdAt != null
                                ? primeraVenta.createdAt!
                                    .substring(11, 16) // Mostrar solo la hora
                                : '',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Empleado: ${primeraVenta.vendedor ?? ""}'),
                      Text('Cliente: ${primeraVenta.cliente ?? ""}'),
                      Text('Sucursal: ${primeraVenta.nombreSucursal ?? ""}'),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Productos
                      Column(
                        children: items
                            .map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 30,
                                        child: Text(
                                          item.cantidad ?? "",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(item.producto ?? ""),
                                      ),
                                      SizedBox(
                                        width: 80,
                                        child: Text(
                                          '\$${item.precio ?? "0"}',
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 80,
                                        child: Text(
                                          '\$${item.total ?? "0"}',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),

                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  // Pestaña de Apartados
  Widget _buildApartadosTab() {
    return apartadosAgrupados.isEmpty
        ? const Center(
            child:
                Text('No hay apartados registrados en la fecha seleccionada'))
        : ListView.builder(
            itemCount: apartadosAgrupados.length,
            itemBuilder: (context, index) {
              String folio = apartadosAgrupados.keys.elementAt(index);
              List<ReporteApartadoDetalle> items = apartadosAgrupados[folio]!;
              ReporteApartadoDetalle primerApartado = items.first;

              // Calcular el total y anticipo del apartado
              double totalApartado = 0;
              double anticipoApartado = 0;
              double saldoPendiente = 0;

              for (var item in items) {
                totalApartado += double.parse(item.total ?? "0");
                // Usar solo el anticipo del primer item para evitar duplicación
                if (item == primerApartado) {
                  anticipoApartado = double.parse(item.anticipo ?? "0");
                  saldoPendiente = double.parse(item.saldoPendiente ?? "0");
                }
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Folio: $folio',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Empleado: ${primerApartado.usuario ?? ""}'),
                      Text('Cliente: ${primerApartado.cliente ?? ""}'),
                      Text('Sucursal: ${primerApartado.nombreSucursal ?? ""}'),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Productos
                      Column(
                        children: items
                            .map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 30,
                                        child: Text(
                                          item.cantidad ?? "",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(item.producto ?? ""),
                                      ),
                                      SizedBox(
                                        width: 80,
                                        child: Text(
                                          '\$${item.precio ?? "0"}',
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 80,
                                        child: Text(
                                          '\$${item.total ?? "0"}',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),

                      const Divider(),

                      // Sección resumen del apartado
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('\$${totalApartado.toStringAsFixed(2)}'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Anticipo:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('\$${anticipoApartado.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.green)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Saldo Pendiente:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('\$${saldoPendiente.toStringAsFixed(2)}',
                              style: TextStyle(
                                  color: saldoPendiente > 0
                                      ? Colors.red
                                      : Colors.green)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  // Pestaña de Abonos
  Widget _buildAbonosTab() {
    return abonosFiltrados.isEmpty
        ? const Center(
            child: Text('No hay abonos registrados en la fecha seleccionada'))
        : ListView.builder(
            itemCount: abonosFiltrados.length,
            itemBuilder: (context, index) {
              ReporteAbonoDetalle abono = abonosFiltrados[index];

              // Calcular total del abono
              double efectivo = double.parse(abono.cantidadEfectivo ?? "0");
              double tarjeta = double.parse(abono.cantidadTarjeta ?? "0");
              double totalAbono = efectivo + tarjeta;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Apartado: ${abono.folioApartado ?? ""}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            abono.createdAt != null
                                ? abono.createdAt!
                                    .substring(11, 16) // Mostrar solo la hora
                                : '',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Cliente: ${abono.cliente ?? ""}'),
                      Text('Empleado: ${abono.usuario ?? ""}'),
                      Text('Sucursal: ${abono.nombreSucursal ?? ""}'),
                      const SizedBox(height: 8),
                      const Divider(),

                      // Detalles del abono
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Saldo Anterior:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('\$${abono.saldoAnterior ?? "0"}'),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Efectivo:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('\$${abono.cantidadEfectivo ?? "0"}'),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tarjeta:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('\$${abono.cantidadTarjeta ?? "0"}'),
                          ],
                        ),
                      ),

                      const Divider(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Abono:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('\$${totalAbono.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.green)),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Saldo Restante:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('\$${abono.saldoActual ?? "0"}',
                              style: TextStyle(
                                  color:
                                      double.parse(abono.saldoActual ?? "0") > 0
                                          ? Colors.red
                                          : Colors.green)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Future<void> _generarPDF() async {
    if (ventasFiltradas.isEmpty &&
        apartadosFiltrados.isEmpty &&
        abonosFiltrados.isEmpty) {
      mostrarAlerta(context, 'Advertencia', 'No hay movimientos para exportar');
      return;
    }

    setState(() {
      isLoading = true;
      textLoading = 'Generando PDF';
    });

    try {
      // Crear documento PDF
      final PdfDocument document = PdfDocument();
      PdfPage page = document.pages.add();

      // Configurar fuentes
      final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 18,
          style: PdfFontStyle.bold);
      final PdfFont headerFont = PdfStandardFont(PdfFontFamily.helvetica, 14,
          style: PdfFontStyle.bold);
      final PdfFont boldFont = PdfStandardFont(PdfFontFamily.helvetica, 12,
          style: PdfFontStyle.bold);
      final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 10);
      final PdfFont italicFont = PdfStandardFont(PdfFontFamily.helvetica, 10,
          style: PdfFontStyle.italic);
      final PdfBrush brush = PdfSolidBrush(PdfColor(0, 0, 0));

      // Obtener información de la sucursal
      String nombreNegocio = "Reporte de Movimientos";
      String sucursalText = "Todas las sucursales";

      if (_sucursalSeleccionada != '0') {
        for (var sucursal in listaSucursales) {
          if (sucursal.id.toString() == _sucursalSeleccionada) {
            nombreNegocio = sucursal.nombreSucursal ?? "Reporte de Movimientos";
            sucursalText = "Sucursal: ${sucursal.nombreSucursal}";
            break;
          }
        }
      }

      // Encabezado del documento
      double pageWidth = page.getClientSize().width;
      double yPosition = 0;

      // Título del reporte
      page.graphics.drawString(nombreNegocio, titleFont,
          brush: brush, bounds: Rect.fromLTWH(0, yPosition, pageWidth, 30));
      yPosition += 30;

      // Información de fecha y sucursal
      page.graphics.drawString(
          'Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}', boldFont,
          brush: brush, bounds: Rect.fromLTWH(0, yPosition, pageWidth, 20));
      yPosition += 20;

      page.graphics.drawString(sucursalText, boldFont,
          brush: brush, bounds: Rect.fromLTWH(0, yPosition, pageWidth, 20));
      yPosition += 30;

      // Sección de resumen
      page.graphics.drawString('RESUMEN DE MOVIMIENTOS', headerFont,
          brush: brush, bounds: Rect.fromLTWH(0, yPosition, pageWidth, 20));
      yPosition += 25;

      // Tabla de resumen
      final PdfGrid summaryGrid = PdfGrid();
      summaryGrid.columns.add(count: 2);
      summaryGrid.style = PdfGridStyle(
        font: font,
        cellPadding: PdfPaddings(left: 5, right: 5, top: 3, bottom: 3),
      );

      // Filas de resumen
      _addSummaryRow(summaryGrid, 'Ventas:', '${ventasAgrupadas.length}');
      _addSummaryRow(
          summaryGrid, 'Total Ventas:', '\$${totalVentas.toStringAsFixed(2)}');
      _addSummaryRow(summaryGrid, 'Apartados:', '${apartadosAgrupados.length}');
      _addSummaryRow(summaryGrid, 'Total Apartados:',
          '\$${totalApartados.toStringAsFixed(2)}');
      _addSummaryRow(summaryGrid, 'Abonos:', '${abonosFiltrados.length}');
      _addSummaryRow(
          summaryGrid, 'Total Abonos:', '\$${totalAbonos.toStringAsFixed(2)}');

      // Fila de total general
      final PdfGridRow totalRow = summaryGrid.rows.add();
      totalRow.cells[0].value = 'TOTAL GENERAL:';
      totalRow.cells[1].value = '\$${totalGeneral.toStringAsFixed(2)}';
      totalRow.style = PdfGridRowStyle(
        backgroundBrush: PdfSolidBrush(PdfColor(200, 200, 200)),
        font: boldFont,
      );

      // Dibujar tabla de resumen
      // summaryGrid.draw(
      //     page: page, bounds: Rect.fromLTWH(0, yPosition, pageWidth * 0.5, 0));
      // yPosition += 100; // Espacio para la tabla de resumen

      summaryGrid.draw(
          page: page, bounds: Rect.fromLTWH(0, yPosition, pageWidth * 0.5, 0));

      // Necesitamos calcular el alto de la tabla de resumen según su número de filas
      // En lugar de un valor fijo de 100, calcularlo en base al número de filas:
      int summaryRowCount =
          7; // Número total de filas de la tabla de resumen (6 filas + el total general)
      yPosition += (summaryRowCount * 20) + 30;
      // ----- SECCIÓN DE VENTAS -----
      if (ventasFiltradas.isNotEmpty) {
        page.graphics.drawString('DETALLE DE VENTAS', headerFont,
            brush: brush, bounds: Rect.fromLTWH(0, yPosition, pageWidth, 20));
        yPosition += 25;

        // Agrupar ventas por folio
        Map<String, List<ReporteVentaDetalle>> ventasPorFolio = {};
        for (var venta in ventasFiltradas) {
          if (!ventasPorFolio.containsKey(venta.folio)) {
            ventasPorFolio[venta.folio!] = [];
          }
          ventasPorFolio[venta.folio!]!.add(venta);
        }

        // Para cada folio, añadir una sección en el PDF
        for (var folio in ventasPorFolio.keys) {
          var ventasGrupo = ventasPorFolio[folio]!;
          var primeraVenta = ventasGrupo.first;
          double totalVenta = 0;

          // Verificar si necesitamos añadir una nueva página
          if (yPosition > page.getClientSize().height - 100) {
            page = document.pages.add();
            yPosition = 20;
          }

          // Información de la venta
          page.graphics.drawString('Folio: $folio', boldFont,
              brush: brush, bounds: Rect.fromLTWH(0, yPosition, pageWidth, 20));
          yPosition += 15;

          page.graphics.drawString(
              'Cliente: ${primeraVenta.cliente ?? ""}', font,
              brush: brush,
              bounds: Rect.fromLTWH(20, yPosition, pageWidth, 15));
          yPosition += 15;

          page.graphics.drawString(
              'Empleado: ${primeraVenta.vendedor ?? ""}', font,
              brush: brush,
              bounds: Rect.fromLTWH(20, yPosition, pageWidth, 15));
          yPosition += 15;

          page.graphics.drawString(
              'Fecha: ${primeraVenta.createdAt ?? ""}', font,
              brush: brush,
              bounds: Rect.fromLTWH(20, yPosition, pageWidth, 15));
          yPosition += 20;

          // Tabla de productos
          final PdfGrid grid = PdfGrid();
          grid.columns.add(count: 4);
          grid.style = PdfGridStyle(
            font: font,
            cellPadding: PdfPaddings(left: 5, right: 5, top: 3, bottom: 3),
          );

          // Encabezados
          final PdfGridRow headerRow = grid.headers.add(1)[0];
          headerRow.style = PdfGridRowStyle(
            backgroundBrush: PdfSolidBrush(PdfColor(142, 170, 219)),
            textBrush: PdfBrushes.white,
            font: boldFont,
          );
          headerRow.cells[0].value = 'Cant.';
          headerRow.cells[1].value = 'Producto';
          headerRow.cells[2].value = 'Precio';
          headerRow.cells[3].value = 'Total';

          // Ajustar anchos de columnas
          grid.columns[0].width = 40; // Ancho para "Cant."
          grid.columns[1].width =
              pageWidth - 200; // Reducir el ancho de la columna "Producto"
          grid.columns[2].width = 70; // Incrementar ancho para "Precio"
          grid.columns[3].width = 70;

          // Añadir productos
          for (var item in ventasGrupo) {
            final PdfGridRow row = grid.rows.add();
            row.cells[0].value = item.cantidad ?? "";
            row.cells[1].value = item.producto ?? "";
            row.cells[2].value = '\$${item.precio ?? "0"}';
            row.cells[3].value = '\$${item.total ?? "0"}';

            totalVenta += double.parse(item.total ?? "0");
          }

          // Fila de total
          final PdfGridRow totalVentaRow = grid.rows.add();
          totalVentaRow.cells[0].value = '';
          totalVentaRow.cells[1].value = '';
          totalVentaRow.cells[2].value = 'Total:';
          totalVentaRow.cells[3].value = '\$${totalVenta.toStringAsFixed(2)}';
          totalVentaRow.style = PdfGridRowStyle(
            backgroundBrush: PdfSolidBrush(PdfColor(222, 222, 222)),
            font: boldFont,
          );

          // Dibujar la tabla
          grid.draw(page: page, bounds: Rect.fromLTWH(20, yPosition, 0, 0));

          // Actualizar posición Y para el siguiente grupo
          yPosition += (ventasGrupo.length + 2) * 20 +
              30; // Filas + encabezado + total + espacio extra
        }
      }

      // ----- SECCIÓN DE APARTADOS -----
      if (apartadosFiltrados.isNotEmpty) {
        // Verificar si necesitamos añadir una nueva página
        if (yPosition > page.getClientSize().height - 100) {
          page = document.pages.add();
          yPosition = 20;
        }

        page.graphics.drawString('DETALLE DE APARTADOS', headerFont,
            brush: brush, bounds: Rect.fromLTWH(0, yPosition, pageWidth, 20));
        yPosition += 25;

        // Agrupar apartados por folio
        Map<String, List<ReporteApartadoDetalle>> apartadosPorFolio = {};
        for (var apartado in apartadosFiltrados) {
          if (!apartadosPorFolio.containsKey(apartado.folio)) {
            apartadosPorFolio[apartado.folio!] = [];
          }
          apartadosPorFolio[apartado.folio!]!.add(apartado);
        }

        // Para cada folio, añadir una sección en el PDF
        for (var folio in apartadosPorFolio.keys) {
          var apartadosGrupo = apartadosPorFolio[folio]!;
          var primerApartado = apartadosGrupo.first;
          double totalApartado = 0;
          double anticipoApartado =
              double.parse(primerApartado.anticipo ?? "0");
          double saldoPendiente =
              double.parse(primerApartado.saldoPendiente ?? "0");

          // Verificar si necesitamos añadir una nueva página
          if (yPosition > page.getClientSize().height - 100) {
            page = document.pages.add();
            yPosition = 20;
          }

          // Información del apartado
          page.graphics.drawString('Folio: $folio', boldFont,
              brush: brush, bounds: Rect.fromLTWH(0, yPosition, pageWidth, 20));
          yPosition += 15;

          page.graphics.drawString(
              'Cliente: ${primerApartado.cliente ?? ""}', font,
              brush: brush,
              bounds: Rect.fromLTWH(20, yPosition, pageWidth, 15));
          yPosition += 15;

          page.graphics.drawString(
              'Empleado: ${primerApartado.usuario ?? ""}', font,
              brush: brush,
              bounds: Rect.fromLTWH(20, yPosition, pageWidth, 15));
          yPosition += 20;

          // Tabla de productos
          final PdfGrid grid = PdfGrid();
          grid.columns.add(count: 4);
          grid.style = PdfGridStyle(
            font: font,
            cellPadding: PdfPaddings(left: 5, right: 5, top: 3, bottom: 3),
          );

          // Encabezados
          final PdfGridRow headerRow = grid.headers.add(1)[0];
          headerRow.style = PdfGridRowStyle(
            backgroundBrush: PdfSolidBrush(PdfColor(142, 170, 219)),
            textBrush: PdfBrushes.white,
            font: boldFont,
          );
          headerRow.cells[0].value = 'Cant.';
          headerRow.cells[1].value = 'Producto';
          headerRow.cells[2].value = 'Precio';
          headerRow.cells[3].value = 'Total';

          // Ajustar anchos de columnas
          grid.columns[0].width = 40; // Ancho para "Cant."
          grid.columns[1].width =
              pageWidth - 200; // Reducir el ancho de la columna "Producto"
          grid.columns[2].width = 70; // Incrementar ancho para "Precio"
          grid.columns[3].width = 70;

          // Añadir productos
          for (var item in apartadosGrupo) {
            final PdfGridRow row = grid.rows.add();
            row.cells[0].value = item.cantidad ?? "";
            row.cells[1].value = item.producto ?? "";
            row.cells[2].value = '\$${item.precio ?? "0"}';
            row.cells[3].value = '\$${item.total ?? "0"}';

            totalApartado += double.parse(item.total ?? "0");
          }

          // Filas de resumen
          final PdfGridRow totalApartadoRow = grid.rows.add();
          totalApartadoRow.cells[0].value = '';
          totalApartadoRow.cells[1].value = '';
          totalApartadoRow.cells[2].value = 'Total:';
          totalApartadoRow.cells[3].value =
              '\$${totalApartado.toStringAsFixed(2)}';
          totalApartadoRow.style = PdfGridRowStyle(
            font: boldFont,
          );

          final PdfGridRow anticipoRow = grid.rows.add();
          anticipoRow.cells[0].value = '';
          anticipoRow.cells[1].value = '';
          anticipoRow.cells[2].value = 'Anticipo:';
          anticipoRow.cells[3].value =
              '\$${anticipoApartado.toStringAsFixed(2)}';
          anticipoRow.style = PdfGridRowStyle(
            font: boldFont,
          );

          final PdfGridRow saldoRow = grid.rows.add();
          saldoRow.cells[0].value = '';
          saldoRow.cells[1].value = '';
          saldoRow.cells[2].value = 'Saldo:';
          saldoRow.cells[3].value = '\$${saldoPendiente.toStringAsFixed(2)}';
          saldoRow.style = PdfGridRowStyle(
            backgroundBrush: PdfSolidBrush(PdfColor(222, 222, 222)),
            font: boldFont,
          );

          // Dibujar la tabla
          grid.draw(page: page, bounds: Rect.fromLTWH(20, yPosition, 0, 0));

          // Actualizar posición Y para el siguiente grupo
          yPosition += (apartadosGrupo.length + 4) * 20 +
              50; // Filas + encabezado + total + anticipo + saldo + espacio extra
        }
      }

      // ----- SECCIÓN DE ABONOS -----
      if (abonosFiltrados.isNotEmpty) {
        // Verificar si necesitamos añadir una nueva página
        if (yPosition > page.getClientSize().height - 100) {
          page = document.pages.add();
          yPosition = 20;
        }

        page.graphics.drawString('DETALLE DE ABONOS', headerFont,
            brush: brush, bounds: Rect.fromLTWH(0, yPosition, pageWidth, 20));
        yPosition += 25;

        // Tabla de abonos
        final PdfGrid grid = PdfGrid();
        grid.columns.add(count: 7);
        grid.style = PdfGridStyle(
          font: font,
          cellPadding: PdfPaddings(left: 5, right: 5, top: 3, bottom: 3),
        );

        // Encabezados
        final PdfGridRow headerRow = grid.headers.add(1)[0];
        headerRow.style = PdfGridRowStyle(
          backgroundBrush: PdfSolidBrush(PdfColor(142, 170, 219)),
          textBrush: PdfBrushes.white,
          font: boldFont,
        );
        headerRow.cells[0].value = 'Folio';
        headerRow.cells[1].value = 'Cliente';
        headerRow.cells[2].value = 'Empleado';
        headerRow.cells[3].value = 'Saldo Anterior';
        headerRow.cells[4].value = 'Efectivo';
        headerRow.cells[5].value = 'Tarjeta';
        headerRow.cells[6].value = 'Saldo Actual';

        // Añadir abonos
        for (var abono in abonosFiltrados) {
          final PdfGridRow row = grid.rows.add();
          row.cells[0].value = abono.folioApartado ?? "";
          row.cells[1].value = abono.cliente ?? "";
          row.cells[2].value = abono.usuario ?? "";
          row.cells[3].value = '\$${abono.saldoAnterior ?? "0"}';
          row.cells[4].value = '\$${abono.cantidadEfectivo ?? "0"}';
          row.cells[5].value = '\$${abono.cantidadTarjeta ?? "0"}';
          row.cells[6].value = '\$${abono.saldoActual ?? "0"}';
        }

        // Fila de total
        final PdfGridRow totalAbonosRow = grid.rows.add();
        totalAbonosRow.cells[0].value = '';
        totalAbonosRow.cells[1].value = '';
        totalAbonosRow.cells[2].value = '';
        totalAbonosRow.cells[3].value = 'Total Abonos:';

        double totalEfectivo = 0;
        double totalTarjeta = 0;
        for (var abono in abonosFiltrados) {
          totalEfectivo += double.parse(abono.cantidadEfectivo ?? "0");
          totalTarjeta += double.parse(abono.cantidadTarjeta ?? "0");
        }

        totalAbonosRow.cells[4].value = '\$${totalEfectivo.toStringAsFixed(2)}';
        totalAbonosRow.cells[5].value = '\$${totalTarjeta.toStringAsFixed(2)}';
        totalAbonosRow.cells[6].value = '\$${totalAbonos.toStringAsFixed(2)}';
        totalAbonosRow.style = PdfGridRowStyle(
          backgroundBrush: PdfSolidBrush(PdfColor(222, 222, 222)),
          font: boldFont,
        );

        // Dibujar la tabla
        grid.draw(
            page: page, bounds: Rect.fromLTWH(0, yPosition, pageWidth, 0));
      }

      // Pie de página con fecha y hora de generación
      for (int i = 0; i < document.pages.count; i++) {
        final PdfPage footerPage = document.pages[i];
        final String texto =
            'Página ${i + 1} de ${document.pages.count} - Generado: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())} desde Vendo Facil';

        // Posicionar texto en la parte inferior
        footerPage.graphics.drawString(
          texto,
          font,
          brush: brush,
          bounds: Rect.fromLTWH(
              10, // Margen izquierdo
              footerPage.getClientSize().height -
                  20, // 20 píxeles desde el fondo
              footerPage.getClientSize().width -
                  20, // Ancho total menos márgenes
              20 // Altura
              ),
        );
      }

      // Guardar el documento
      List<int> bytes = await document.save();
      document.dispose();

      // Obtener directorio para guardar
      final directory = await getApplicationSupportDirectory();
      final path = directory.path;
      final fileName =
          'Reporte_Movimientos_${DateFormat('yyyyMMdd').format(_selectedDate)}.pdf';
      File file = File('$path/$fileName');
      await file.writeAsBytes(bytes, flush: true);

      // Abrir el archivo PDF
      await OpenFile.open('$path/$fileName');

      setState(() {
        isLoading = false;
      });

      mostrarAlerta(context, 'Éxito', 'PDF generado correctamente');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      mostrarAlerta(context, 'Error', 'Error al generar el PDF: $e');
    }
  }

// Función auxiliar para añadir filas al resumen
  void _addSummaryRow(PdfGrid grid, String label, String value) {
    final PdfGridRow row = grid.rows.add();
    row.cells[0].value = label;
    row.cells[1].value = value;
  }
}
