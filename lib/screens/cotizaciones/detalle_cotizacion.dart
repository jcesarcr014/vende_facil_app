// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/cliente_provider.dart';
import 'package:vende_facil/providers/negocio_provider.dart';

import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'package:vende_facil/providers/ticket_provider.dart';

class CotizacionDetallesScreen extends StatefulWidget {
  const CotizacionDetallesScreen({Key? key}) : super(key: key);

  @override
  State<CotizacionDetallesScreen> createState() =>
      _CotizacionDetallesScreenState();
}

class _CotizacionDetallesScreenState extends State<CotizacionDetallesScreen> {
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;

  final negocioProvider = NegocioProvider();
  final clienteProvider = ClienteProvider();
  final ticketProvider = TicketProvider();

  late Cliente clienteData;

  bool isLoading = true;

  @override
  void initState() {
    loadData();
    super.initState();
  }

  void loadData() async {
    final TicketModel? model =
        await ticketProvider.getData(sesion.idNegocio.toString(), true);
    setState(() {
      ticketModel.id = model?.id;
      ticketModel.negocioId = model?.negocioId;
      ticketModel.logo = model?.logo;
      ticketModel.message = model?.message;
      isLoading = false;
    });
  }

  Future<Uint8List?> _downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Cotizacion: ${cotActual.folio}'),
        automaticallyImplyLeading: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nombre de la Sucursal: ${cotActual.nombreSucursal}'),
                    const SizedBox(height: 5),
                    Text('Dirección de la Sucursal: ${cotActual.dirSucursal}'),
                    const SizedBox(height: 5),
                    Text('Teléfono: ${cotActual.telsucursal}'),
                    const SizedBox(height: 5),
                    Text('Fecha de Cotizacion: ${cotActual.fecha_cotizacion}'),
                    const SizedBox(
                      height: 5,
                    ),
                    Text('Nombre del Cliente: ${cotActual.nombreCliente}'),
                    const Divider(),

                    // Usamos Expanded para que la tabla ocupe el espacio disponible
                    SizedBox(
                      height: 350, // Puedes ajustar esta altura
                      child: SingleChildScrollView(
                        scrollDirection: Axis
                            .horizontal, // Hacemos que la tabla sea desplazable horizontalmente si es necesario
                        child: DataTable(
                          columnSpacing: 20,
                          columns: const [
                            DataColumn(label: Text('Producto')),
                            DataColumn(label: Text('Cantidad')),
                            DataColumn(label: Text('Descuento')),
                            DataColumn(label: Text('Total')),
                          ],
                          rows: detalleCotActual.map((detalle) {
                            return DataRow(cells: [
                              DataCell(Text(detalle.nombreProducto.toString())),
                              DataCell(Text(detalle.cantidad.toString())),
                              DataCell(
                                  Text(detalle.cantidadDescuento.toString())),
                              DataCell(Text(detalle.total.toString())),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Divider(),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text('Subtotal: ',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text('${cotActual.subtotal}')
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text('Total: ',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text('${cotActual.total}')
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text('Descuento: ',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text('${cotActual.descuento}')
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: ElevatedButton(
                        child: const Text('Generar archivo PDF',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          _generatePDF();
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _generatePDF() async {
    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();
    final PdfFont titleFont =
        PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold);
    final PdfFont italicFont = PdfStandardFont(PdfFontFamily.helvetica, 14,
        style: PdfFontStyle.italic);
    final PdfFont boldFont =
        PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
    final PdfBrush brush = PdfSolidBrush(PdfColor(51, 51, 51));
    double yPosAfterMessage = 120;
    Negocio negocio = await negocioProvider.consultaNegocio();
    String nombreNegocio = negocio.nombreNegocio ?? 'PENDIENTE';
    String telefono = "Teléfono: ${cotActual.telsucursal}";
    String direccion = "Dirección: ${cotActual.dirSucursal}";
    String cliente = cotActual.nombreCliente ?? 'Público en general';
    cliente = "Nombre Cliente: $cliente";
    double pageWidth = page.getClientSize().width;
    double logoWidth = 100;
    double logoXPosition = 0;
    double nombreXPosition = logoWidth + 20;
    PdfBitmap? logoBitmap;
    if (ticketModel.logo != null && ticketModel.logo!.isNotEmpty) {
      final logoImage = await _downloadImage(ticketModel.logo!);
      if (logoImage != null) {
        final PdfBitmap image = PdfBitmap(logoImage);
        page.graphics
            .drawImage(image, Rect.fromLTWH(logoXPosition, 0, logoWidth, 100));
      }
    } else {
      final ByteData imageData = await rootBundle.load('assets/logo.png');
      final List<int> imageBytes = imageData.buffer.asUint8List();
      logoBitmap = PdfBitmap(imageBytes);
    }
    if (logoBitmap != null) {
      page.graphics.drawImage(
          logoBitmap, Rect.fromLTWH(logoXPosition, 0, logoWidth, 100));
    }
    page.graphics.drawString(nombreNegocio, titleFont,
        bounds:
            Rect.fromLTWH(nombreXPosition, 0, pageWidth - nombreXPosition, 30));
    page.graphics.drawString(telefono, italicFont,
        bounds: Rect.fromLTWH(
            nombreXPosition, 30, pageWidth - nombreXPosition, 20));
    page.graphics.drawString(direccion, italicFont,
        bounds: Rect.fromLTWH(
            nombreXPosition, 50, pageWidth - nombreXPosition, 20));
    page.graphics.drawString(cliente, italicFont,
        bounds: Rect.fromLTWH(
            nombreXPosition, 70, pageWidth - nombreXPosition, 20));

    page.graphics.drawString('Cotización de Productos', boldFont,
        brush: brush, bounds: Rect.fromLTWH(0, yPosAfterMessage, 500, 30));
    page.graphics.drawString('Folio: ${cotActual.folio}', italicFont,
        bounds: Rect.fromLTWH(0, 140, pageWidth, 20));
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 3);
    grid.style = PdfGridStyle(
      font: boldFont,
      cellPadding: PdfPaddings(left: 5, right: 5, top: 3, bottom: 3),
    );
    final PdfGridRow headerRow = grid.headers.add(1)[0];
    headerRow.style = PdfGridRowStyle(
      backgroundBrush: PdfSolidBrush(PdfColor(68, 114, 196)),
      textPen: PdfPens.white,
      textBrush: PdfBrushes.white,
      font: boldFont,
    );
    headerRow.cells[0].value = 'Producto';
    headerRow.cells[1].value = 'Cantidad';
    headerRow.cells[2].value = 'Total';
    double total = 0;
    for (var producto in detalleCotActual) {
      final PdfGridRow row = grid.rows.add();
      row.cells[0].value = producto.nombreProducto;
      row.cells[1].value = producto.cantidad.toString();
      row.cells[2].value = producto.total!.toStringAsFixed(2);
      total += producto.total!;
    }
    final PdfGridRow subtotalRow = grid.rows.add();
    subtotalRow.cells[0].value = 'Subtotal';
    subtotalRow.cells[1].value = '';
    subtotalRow.cells[2].value = total.toStringAsFixed(2);
    subtotalRow.style = PdfGridRowStyle(
      font: boldFont,
      textBrush: PdfBrushes.black,
    );
    final PdfGridRow totalRow = grid.rows.add();
    totalRow.cells[0].value = 'Total';
    totalRow.cells[1].value = '';
    totalRow.cells[2].value = total.toStringAsFixed(2);
    totalRow.style = PdfGridRowStyle(
      font: boldFont,
      textBrush: PdfBrushes.black,
    );
    grid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, yPosAfterMessage + 60, 0, 0),
    );
    List<int> bytes = document.saveSync();
    document.dispose();
    final directory = await getApplicationSupportDirectory();
    final path = directory.path;
    File file = File('$path/Cotizacion-Vende-Facil-${cotActual.folio}.pdf');

    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open('$path/Cotizacion-Vende-Facil-${cotActual.folio}.pdf');
  }
}
