import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:intl/intl.dart';
import 'package:vende_facil/widgets/mostrar_alerta_ok.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:vende_facil/util/imprime_tickets.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  // Función para imprimir ticket de movimientos

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  String formattedSelectedDate = "";
  DateTime now = DateTime.now();

  late DateTime _selectedDate;
  double totalMovimientos = 0.0;
  late DateFormat dateFormatter;
  final _dateController = TextEditingController();

  String? _sucursalSeleccionada = '0';

  final provider = NegocioProvider();
  final reportesProvider = ReportesProvider();
  final ticketProvider = TicketProvider();

  // Lista para almacenar todos los movimientos sin filtrar
  List<MovimientoCorte> todosLosMovimientos = [];
  // Lista filtrada que se muestra en pantalla
  List<MovimientoCorte> movimientosFiltrados = [];

  @override
  void initState() {
    _selectedDate = DateTime(now.year, now.month, now.day);
    dateFormatter = DateFormat('yyyy-MM-dd');
    formattedSelectedDate = dateFormatter.format(_selectedDate);
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);

    listaMovimientosReporte.clear();
    listasucursalEmpleado.clear();
    movimientosFiltrados.clear();
    todosLosMovimientos.clear();

    // Cargar sucursales al iniciar
    if (sesion.tipoUsuario == "P") {
      provider.getlistaSucursales();
    }

    // Consultar movimientos para la fecha actual
    _consultarMovimientos();

    // Cargar datos del ticket
    _cargarDatosTicket();

    super.initState();
  }

  Future<void> _cargarDatosTicket() async {
    try {
      final TicketModel? model =
          await ticketProvider.getData(sesion.idNegocio.toString(), true);

      if (model != null) {
        ticketModel.id = model.id;
        ticketModel.negocioId = model.negocioId;
        ticketModel.logo = model.logo;
        ticketModel.message = model.message;
      }
    } catch (e) {
      mostrarAlerta(context, 'Error', 'Error al cargar datos del ticket: $e');
    }
  }

  // Consultar movimientos para la fecha seleccionada
  Future<void> _consultarMovimientos() async {
    setState(() {
      isLoading = true;
      textLoading =
          'Consultando movimientos del ${DateFormat('dd/MM/yyyy').format(_selectedDate)}';
    });

    final resultado =
        await reportesProvider.reporteGeneral(formattedSelectedDate);

    if (resultado.status != 1) {
      setState(() {
        isLoading = false;
      });
      mostrarAlerta(context, 'Error', resultado.mensaje!);
      return;
    }

    // Guardamos todos los movimientos sin filtrar
    todosLosMovimientos = List.from(listaMovimientosReporte);
    _filtrarMovimientos();

    setState(() {
      isLoading = false;
    });
  }

  // Filtrar movimientos según la sucursal seleccionada
  void _filtrarMovimientos() {
    if (_sucursalSeleccionada == '0') {
      // Mostrar todos los movimientos
      movimientosFiltrados = List.from(todosLosMovimientos);
    } else {
      // Filtrar por sucursal
      movimientosFiltrados = todosLosMovimientos
          .where((movimiento) =>
              movimiento.idSucursal.toString() == _sucursalSeleccionada)
          .toList();
    }

    // Actualizar el total de movimientos
    totalMovimientos = movimientosFiltrados.fold(
        0.0,
        (sum, item) =>
            sum + (item.total != null ? double.parse(item.total!) : 0.0));

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
          title: const Text('Historial de Movimientos'),
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
            : Column(
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
                          'Fecha: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total movimientos: ${movimientosFiltrados.length}',
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
                        // Selector de fecha (un solo día)
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
                                _dateController.text = DateFormat('dd/MM/yyyy')
                                    .format(_selectedDate);
                              });

                              // Consultar movimientos con la nueva fecha
                              await _consultarMovimientos();
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
                                        DateFormat('dd/MM/yyyy')
                                            .format(_selectedDate);
                                  });

                                  // Consultar movimientos con la nueva fecha
                                  await _consultarMovimientos();
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

                  // Lista de movimientos
                  Expanded(
                    child: movimientosFiltrados.isEmpty
                        ? const Center(
                            child: Text(
                                'No hay movimientos registrados en la fecha seleccionada'),
                          )
                        : ListView.builder(
                            itemCount: movimientosFiltrados.length,
                            itemBuilder: (context, index) {
                              MovimientoCorte movimiento =
                                  movimientosFiltrados[index];

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
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
                                              'Folio: ${movimiento.folio}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            movimiento.hora ??
                                                '', // Mostrar solo la hora
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                          'Empleado: ${movimiento.nombreUsuario}'),
                                      Text(
                                          'Sucursal: ${movimiento.nombreSucursal}'),
                                      const SizedBox(height: 4),
                                      Text(
                                        _getTipoMovimientoText(
                                            movimiento.tipoMovimiento),
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Divider(),

                                      // Mostrar detalles de pago
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  'Efectivo: \$${movimiento.montoEfectivo}'),
                                              Text(
                                                  'Tarjeta: \$${movimiento.montoTarjeta}'),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              const Text(
                                                'Total:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                '\$${movimiento.total}',
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
                          onPressed: movimientosFiltrados.isNotEmpty
                              ? () => _generarPDF()
                              : null,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Exportar PDF'),
                        ),
                        ElevatedButton.icon(
                          onPressed: movimientosFiltrados.isNotEmpty
                              ? () => _imprimirTicket()
                              : null,
                          icon: const Icon(Icons.print),
                          label: const Text('Imprimir'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        persistentFooterButtons: [
          BottomAppBar(
            child: SizedBox(
              height: 50,
              child: Center(
                child: Text('Total: \$ ${totalMovimientos.toStringAsFixed(2)}',
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
              _filtrarMovimientos();
            }
          },
        ),
      ],
    );
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

  Future<Uint8List?> _downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _imprimirTicket() async {
    if (movimientosFiltrados.isEmpty) {
      mostrarAlerta(context, 'Advertencia', 'No hay movimientos para imprimir');
      return;
    }

    setState(() {
      isLoading = true;
      textLoading = 'Imprimiendo ticket';
    });

    try {
      // Obtener ID de la sucursal seleccionada o usar la del usuario
      String idSucursal = _sucursalSeleccionada == '0'
          ? sesion.idSucursal.toString()
          : _sucursalSeleccionada!;

      // Crear instancia de la clase de impresiones
      final impresiones = ImpresionesTickets();

      // Llamar a la función de impresión
      final resultado = await impresiones.imprimirTicketMovimientos(
        idSucursal,
        movimientosFiltrados,
        formattedSelectedDate,
      );

      setState(() {
        isLoading = false;
      });

      // Mostrar mensaje según el resultado
      mostrarAlerta(context, resultado.status == 1 ? 'Éxito' : 'Error',
          resultado.mensaje!);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      mostrarAlerta(context, 'Error', 'Error al imprimir: $e');
    }
  }

  Future<void> _generarPDF() async {
    if (movimientosFiltrados.isEmpty) {
      mostrarAlerta(context, 'Advertencia', 'No hay movimientos para exportar');
      return;
    }

    setState(() {
      isLoading = true;
      textLoading = 'Generando PDF';
    });

    try {
      final PdfDocument document = PdfDocument();
      final PdfPage page = document.pages.add();
      final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);
      final PdfFont boldFont = PdfStandardFont(PdfFontFamily.helvetica, 12,
          style: PdfFontStyle.bold);
      final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 18,
          style: PdfFontStyle.bold);
      final PdfFont italicFont = PdfStandardFont(PdfFontFamily.helvetica, 14,
          style: PdfFontStyle.italic);
      final PdfBrush brush = PdfSolidBrush(PdfColor(51, 51, 51));

      // Obtener información de la sucursal seleccionada o usar datos generales
      String nombreNegocio = "Vende Fácil";
      String telefono = "Teléfono: ";
      String direccion = "Dirección: ";

      if (_sucursalSeleccionada != '0') {
        Sucursal? sucursal = listaSucursales.firstWhere(
          (s) => s.id.toString() == _sucursalSeleccionada,
          orElse: () => Sucursal(),
        );

        if (sucursal.nombreSucursal != null) {
          nombreNegocio = sucursal.nombreSucursal!;
          telefono = "Teléfono: ${sucursal.telefono ?? ''}";
          direccion = "Dirección: ${sucursal.direccion ?? ''}";
        }
      } else {
        nombreNegocio = "Reporte de Movimientos";
        telefono = "Todos los movimientos";
        direccion = "Todas las sucursales";
      }

      double pageWidth = page.getClientSize().width;
      double logoWidth = 100;
      double logoXPosition = 0;
      double nombreXPosition = logoWidth + 20;

      // Dibujar el logo si está disponible
      PdfBitmap? logoBitmap;
      if (ticketModel.logo != null && ticketModel.logo!.isNotEmpty) {
        final logoImage = await _downloadImage(ticketModel.logo!);
        if (logoImage != null) {
          final PdfBitmap image = PdfBitmap(logoImage);
          page.graphics.drawImage(
              image, Rect.fromLTWH(logoXPosition, 0, logoWidth, 100));
        }
      } else {
        try {
          final ByteData imageData = await rootBundle.load('assets/logo.png');
          final List<int> imageBytes = imageData.buffer.asUint8List();
          logoBitmap = PdfBitmap(imageBytes);
          page.graphics.drawImage(
            logoBitmap,
            Rect.fromLTWH(logoXPosition, 0, logoWidth, 100),
          );
        } catch (e) {
          // Si no se puede cargar el logo, continuar sin él
        }
      }

      // Dibujar información del encabezado
      page.graphics.drawString(nombreNegocio, titleFont,
          brush: brush,
          bounds: Rect.fromLTWH(
              nombreXPosition, 0, pageWidth - nombreXPosition, 30));

      page.graphics.drawString(telefono, italicFont,
          brush: brush,
          bounds: Rect.fromLTWH(
              nombreXPosition, 30, pageWidth - nombreXPosition, 20));

      page.graphics.drawString(direccion, italicFont,
          brush: brush,
          bounds: Rect.fromLTWH(
              nombreXPosition, 50, pageWidth - nombreXPosition, 20));

      String fechaReporte =
          "Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}";
      page.graphics.drawString(fechaReporte, italicFont,
          brush: brush,
          bounds: Rect.fromLTWH(
              nombreXPosition, 70, pageWidth - nombreXPosition, 20));

      double yPosAfterMessage = 120;

      // Título del reporte
      page.graphics.drawString('Reporte de Movimientos', boldFont,
          brush: brush, bounds: Rect.fromLTWH(0, yPosAfterMessage, 500, 30));

      // Crear tabla de movimientos
      final PdfGrid grid = PdfGrid();
      grid.columns.add(count: 5);
      grid.style = PdfGridStyle(
        font: font,
        cellPadding: PdfPaddings(left: 5, right: 5, top: 3, bottom: 3),
      );

      // Encabezados de la tabla
      final PdfGridRow headerRow = grid.headers.add(1)[0];
      headerRow.style = PdfGridRowStyle(
        backgroundBrush: PdfSolidBrush(PdfColor(68, 114, 196)),
        textPen: PdfPens.white,
        textBrush: PdfBrushes.white,
        font: boldFont,
      );

      headerRow.cells[0].value = 'Folio';
      headerRow.cells[1].value = 'Tipo';
      headerRow.cells[2].value = 'Efectivo';
      headerRow.cells[3].value = 'Tarjeta';
      headerRow.cells[4].value = 'Total';

      // Ajustar anchos de columnas
      grid.columns[0].width = 130;
      grid.columns[1].width = 110;
      grid.columns[2].width = 80;
      grid.columns[3].width = 80;
      grid.columns[4].width = 80;

      double totalEfectivo = 0;
      double totalTarjeta = 0;
      double totalGeneral = 0;

      // Añadir filas de datos
      for (var movimiento in movimientosFiltrados) {
        final PdfGridRow row = grid.rows.add();
        row.cells[0].value = movimiento.folio ?? '';
        row.cells[1].value = _getTipoMovimientoText(movimiento.tipoMovimiento);
        row.cells[2].value = movimiento.montoEfectivo ?? '0.00';
        row.cells[3].value = movimiento.montoTarjeta ?? '0.00';
        row.cells[4].value = movimiento.total ?? '0.00';

        // Sumar totales
        totalEfectivo += double.tryParse(movimiento.montoEfectivo ?? '0') ?? 0;
        totalTarjeta += double.tryParse(movimiento.montoTarjeta ?? '0') ?? 0;
        totalGeneral += double.tryParse(movimiento.total ?? '0') ?? 0;
      }

      // Añadir fila de totales
      final PdfGridRow totalRow = grid.rows.add();
      totalRow.cells[0].value = '';
      totalRow.cells[1].value = 'TOTALES';
      totalRow.cells[2].value = totalEfectivo.toStringAsFixed(2);
      totalRow.cells[3].value = totalTarjeta.toStringAsFixed(2);
      totalRow.cells[4].value = totalGeneral.toStringAsFixed(2);
      totalRow.style = PdfGridRowStyle(
        font: boldFont,
        backgroundBrush: PdfSolidBrush(PdfColor(240, 240, 240)),
      );

      // Dibujar la tabla en el PDF
      grid.draw(
          page: page, bounds: Rect.fromLTWH(0, yPosAfterMessage + 40, 0, 0));

      // Añadir pie de página
      final String fecha =
          DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
      page.graphics.drawString(
        'Reporte generado el $fecha',
        font,
        brush: brush,
        bounds: Rect.fromLTWH(0, page.getClientSize().height - 30,
            page.getClientSize().width, 30),
      );

      // Guardar y abrir el PDF
      List<int> bytes = document.saveSync();
      document.dispose();

      final directory = await getApplicationSupportDirectory();
      final path = directory.path;
      final String fileName =
          'Reporte-Movimientos-${DateFormat('yyyyMMdd').format(_selectedDate)}.pdf';
      File file = File('$path/$fileName');
      await file.writeAsBytes(bytes, flush: true);

      OpenFile.open('$path/$fileName');

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
}
