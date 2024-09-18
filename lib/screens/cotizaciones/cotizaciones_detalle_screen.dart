// ignore_for_file: dead_code, prefer_final_fields, depend_on_referenced_packages

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/providers/ticket_provider.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/services.dart' show rootBundle;


class CotizacionDetalleScreen extends StatefulWidget {
  const CotizacionDetalleScreen({super.key});
  @override
  State<CotizacionDetalleScreen> createState() => _CotizarDetalleScreenState();
}

class _CotizarDetalleScreenState extends State<CotizacionDetalleScreen> {
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  double subTotalItem = 0.0;
  final cantidadControllers = TextEditingController();
  String _valueIdcliente = listaClientes
      .firstWhere((cliente) => cliente.nombre == 'Público en general')
      .id
      .toString();
  final cotizaciones = CotizarProvider();
  double descuento = 0.0;
  double restate = 0.0;
  int idcliente = 0;
  int idDescuento = 0;

  final TicketProvider ticketProvider = TicketProvider();
  final NegocioProvider negocioProvider = NegocioProvider();
  List<Producto> listaProductosCotizaciones = [];

  final cantidadConttroller = TextEditingController();

  @override
  void initState() {
    _actualizaTotalTemporal();
    listaDescuentos;
    _loadData();
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {});
  }

  void _loadData() async {
    final TicketModel model = await ticketProvider.getData(sesion.idNegocio.toString());
    setState(() {
      ticketModel.id = model.id;
      ticketModel.negocioId = model.negocioId;
      ticketModel.logo = model.logo;
      ticketModel.message = model.message;
    });
  }

  Future<void> _generatePDF() async {
    // Crear un documento PDF
    final PdfDocument document = PdfDocument();

    // Agregar una página
    final PdfPage page = document.pages.add();

    // Crear fuentes
    final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);
    final PdfFont boldFont =
        PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
    final PdfFont titleFont =
        PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold);
    final PdfFont italicFont = PdfStandardFont(PdfFontFamily.helvetica, 14,
        style: PdfFontStyle.italic);

    // Definir color para la tabla
    final PdfBrush brush = PdfSolidBrush(PdfColor(51, 51, 51));

    Negocio negocio = await negocioProvider.consultaNegocio();

    // Información estática del negocio
    String nombreNegocio = negocio.nombreNegocio ?? 'PENDIENTE';
    String telefono = "Teléfono: ${negocio.telefono}";
    String direccion = "Dirección: ${negocio.direccion}";

    // Calcular posición del logo y el nombre del negocio
    double pageWidth = page.getClientSize().width;
    double logoWidth = 100;
    double logoXPosition = 0;
    double nombreXPosition = logoWidth + 20; // Espacio entre el logo y el nombre

    // Cargar la imagen del logo si está disponible, o cargar la imagen de los assets si está vacío o nulo
    PdfBitmap? logoBitmap;
  
    // Dibujar el logo y el nombre de la empresa juntos en la parte superior
    if (ticketModel.logo != null && ticketModel.logo!.isNotEmpty) {
      final logoImage = await _downloadImage(ticketModel.logo!);
      if (logoImage != null) {
        final PdfBitmap image = PdfBitmap(logoImage);
        page.graphics.drawImage(
            image,
            Rect.fromLTWH(logoXPosition, 0, logoWidth,
                100)); // Ajustar el tamaño del logo
      }
      } else {
      // Cargar la imagen desde los assets
      final ByteData imageData = await rootBundle.load('assets/logo.png');
      final List<int> imageBytes = imageData.buffer.asUint8List();
      logoBitmap = PdfBitmap(imageBytes);
    }

    // Dibujar el logo si existe
    if (logoBitmap != null) {
      page.graphics.drawImage(
        logoBitmap,
        Rect.fromLTWH(logoXPosition, 0, logoWidth, 100), // Ajustar el tamaño del logo
      );
    }
    // Dibujar el nombre de la empresa al lado del logo
    page.graphics.drawString(nombreNegocio, titleFont,
        brush: brush,
        bounds:
            Rect.fromLTWH(nombreXPosition, 0, pageWidth - nombreXPosition, 30));

    // Dibujar el teléfono y la dirección debajo del nombre
    page.graphics.drawString(telefono, italicFont,
        brush: brush,
        bounds: Rect.fromLTWH(
            nombreXPosition, 30, pageWidth - nombreXPosition, 20));
    page.graphics.drawString(direccion, italicFont,
        brush: brush,
        bounds: Rect.fromLTWH(
            nombreXPosition, 50, pageWidth - nombreXPosition, 20));

    // Ajustar el mensaje del ticketModel debajo del logo
    if (ticketModel.message != null && ticketModel.message!.isNotEmpty) {
      double yPosition =
          100; // Justo debajo de la imagen y el encabezado del negocio

      // Si el texto es más largo que el ancho de la página, dividir en varias líneas
      final List<String> messageLines =
          _wrapText(ticketModel.message!, pageWidth, italicFont);

      for (var line in messageLines) {
        page.graphics.drawString(
          line,
          italicFont,
          brush: brush,
          bounds: Rect.fromLTWH(
              0, yPosition, pageWidth, 30), // Alinear a la izquierda
        );
        yPosition += 20; // Espacio entre líneas
      }
    }

    // Reducir el espacio antes de la cotización de productos
    double yPosAfterMessage = 120; // Ajusta esta variable según sea necesario

    // Dibujar encabezado de la cotización
    page.graphics.drawString('Cotización de Productos', boldFont,
        brush: brush,
        bounds: Rect.fromLTWH(0, yPosAfterMessage, 500, 30)); // Encabezado
    page.graphics.drawString('Folio: ${cotizacionDetalle.folio}', font,
        bounds: Rect.fromLTWH(
            0, yPosAfterMessage + 30, 500, 30)); // Número de folio

    // Crear la tabla
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 3); // Añadir 3 columnas: Producto, Cantidad, Total

    // Estilo para la tabla
    grid.style = PdfGridStyle(
      font: font,
      cellPadding: PdfPaddings(left: 5, right: 5, top: 3, bottom: 3),
    );

    // Añadir encabezados a la tabla
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

    // Rellenar filas dinámicamente desde listaProductosCotizaciones
    for (var producto in listaProductosCotizaciones) {
      final PdfGridRow row = grid.rows.add();
      row.cells[0].value =
          producto.producto; // Asume que tienes un campo nombre
      row.cells[1].value = producto.cantidad.toString(); // Campo cantidad
      row.cells[2].value = producto.costo!.toStringAsFixed(2); // Total
    }

    // Añadir fila de subtotal
    final PdfGridRow subtotalRow = grid.rows.add();
    subtotalRow.cells[0].value = 'Subtotal';
    subtotalRow.cells[1].value = ''; // Celda vacía para alineación
    subtotalRow.cells[2].value = cotizacionDetalle.total!.toStringAsFixed(2);
    subtotalRow.style = PdfGridRowStyle(
      font: boldFont,
      textBrush: PdfBrushes.black,
    );

    // Añadir fila de total
    final PdfGridRow totalRow = grid.rows.add();
    totalRow.cells[0].value = 'Total';
    totalRow.cells[1].value = ''; // Celda vacía para alineación
    totalRow.cells[2].value = cotizacionDetalle.total!.toStringAsFixed(2);
    totalRow.style = PdfGridRowStyle(
      font: boldFont,
      textBrush: PdfBrushes.black,
    );

    // Dibujar la tabla en el PDF
    grid.draw(
      page: page,
      bounds: Rect.fromLTWH(
          0, yPosAfterMessage + 60, 0, 0), // Reducir espacio antes de la tabla
    );

    // Guardar el PDF en bytes
    List<int> bytes = document.saveSync();

    // Liberar el documento
    document.dispose();

    // Guardar el archivo en el dispositivo
    final directory = await getApplicationSupportDirectory();
    final path = directory.path;
    File file =
        File('$path/Cotizacion-Vende Fácil-${cotizacionDetalle.folio}.pdf');

    await file.writeAsBytes(bytes, flush: true);

    // Abrir el PDF generado en el dispositivo
    OpenFile.open(
        '$path/Cotizacion-Vende Fácil-${cotizacionDetalle.folio}.pdf');
  }

  List<String> _wrapText(String text, double maxWidth, PdfFont font) {
    final List<String> lines = [];
    String currentLine = '';

    for (var word in text.split(' ')) {
      final testLine = currentLine.isEmpty ? word : '$currentLine $word';
      if (font.measureString(testLine).width < maxWidth) {
        currentLine = testLine;
      } else {
        lines.add(currentLine);
        currentLine = word;
      }
    }
    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    return lines;
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
      mostrarAlerta(context, 'Error', 'Error al descargar la imagen: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'home');
              },
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 8),
            const Text('Detalle de Cotización'),
          ],
        ),
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
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.0),
              child: Column(
                children: [
                  SizedBox(
                    height: windowHeight * 0.02,
                  ),
                  Column(children: _listaTemporal()),
                  const SizedBox(height: 0.5),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    SizedBox(width: windowWidth * 0.1),
                    SizedBox(
                      width: windowWidth * 0.2,
                      child: const Text(
                        'Subtotal ',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: windowWidth * 0.5),
                    SizedBox(
                      width: windowWidth * 0.2,
                      child: Text(
                        '\$${subTotalItem.toStringAsFixed(2)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    SizedBox(width: windowWidth * 0.1),
                    SizedBox(
                      width: windowWidth * 0.2,
                      child: const Text(
                        'Total ',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: windowWidth * 0.5),
                    SizedBox(
                        width: windowWidth * 0.2,
                        child: Text(
                          '\$${totalCotizacionTemporal.toStringAsFixed(2)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )),
                  ]),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    SizedBox(width: windowWidth * 0.1),
                    SizedBox(
                      width: windowWidth * 0.2,
                      child: const Text(
                        'Selecione el  cliente',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: windowWidth * 0.1),
                    Expanded(
                      child: _clientes(),
                    ),
                    SizedBox(width: windowWidth * 0.1),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    SizedBox(width: windowWidth * 0.1),
                    SizedBox(
                      width: windowWidth * 0.2,
                      height: windowHeight * 0.1,
                    ),
                  ]),
                  Center(
                    child: Column(
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Cotizacion cotiz = Cotizacion(
                                idCliente: int.parse(_valueIdcliente),
                                subtotal: subTotalItem,
                                idDescuento: idDescuento,
                                descuento: descuento,
                                total: totalCotizacionTemporal,
                                dias_vigentes: 10,
                              );
                              _cotizacion(cotiz);
                            },
                            child: SizedBox(
                              height: windowHeight * 0.07,
                              width: windowWidth * 0.6,
                              child: const Center(
                                child: Text(
                                  'General',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              )),
    );
  }

  _cotizacion(Cotizacion cotiz) async {
    int idCabecera = 0;
    int detallesGuardadosCorrectamente = 0;
    setState(() {
      isLoading = true;
      textLoading = 'Guardando cotizacion';
    });
    await cotizaciones.guardarCotizacion(cotiz).then((respCab) async {
      if (respCab.status == 1) {
        idCabecera = respCab.id!;
        for (ItemVenta item in cotizarTemporal) {
          CotizacionDetalle ventaDetalle = CotizacionDetalle(
            folio: respCab.folio,
            idcotizacion: idCabecera,
            idProd: item.idArticulo,
            cantidad: item.cantidad,
            precio: item.precioPublico,
            idDesc: cotiz.idDescuento,
            cantidadDescuento: cotiz.descuento,
            total: item.totalItem,
            subtotal: item.subTotalItem,
          );
          cotizacionDetalle = ventaDetalle;

          await cotizaciones
              .guardarCotizacionDetalle(ventaDetalle)
              .then((respDet) {
            if (respDet.status == 1) {
              detallesGuardadosCorrectamente++;
            } else {
              setState(() {
                isLoading = false;
                textLoading = '';
              });
              mostrarAlerta(context, 'ERROR', respDet.mensaje!);
            }
          });
        }

        if (detallesGuardadosCorrectamente == cotizarTemporal.length) {
          setState(() {
            textLoading = '';
            isLoading = false;
          });
          cotizarTemporal.clear();
          setState(() {});
          totalCotizacionTemporal = 0.0;
          globals.actualizaArticulos = true;
          listacotizacion.add(cotiz);
          mostrarAlerta(context, '', 'cotizacion realizada');
          _generatePDF();
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.popAndPushNamed(context, 'HomerCotizar');
        }
      } else {
        setState(() {
          isLoading = false;
          textLoading = '';
        });
        mostrarAlerta(context, 'ERROR', respCab.mensaje!);
      }
    });
  }

  _listaTemporal() {
    List<Widget> productos = [];
    for (ItemVenta item in cotizarTemporal) {
      for (Producto prod in listaProductos) {
        if (prod.id == item.idArticulo) {
          prod.costo = item.totalItem;
          prod.cantidad = item.cantidad;
          if (!listaProductosCotizaciones.any((p) => p.id == prod.id)) {
            listaProductosCotizaciones.add(prod);
          }
          productos.add(Dismissible(
              key: Key(item.idArticulo.toString()),
              onDismissed: (direction) {
                _removerItemTemporal(item);
              },
              background: Container(
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: windowWidth * 0.3,
                      child: Text(
                        '${prod.producto} ',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
SizedBox(
                          width: windowWidth * 0.1,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: Tooltip(
                              message: 'Editar Cantidad',
                              child: IconButton(
                                key: ValueKey<double>(item.cantidad),
                                onPressed: item.totalItem > 0.00
                                    ? () {
                                        setState(() {
                                          cantidadControllers.text ='${item.cantidad}';
                                        });
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              content: Row(
                                                children: [
                                                  const Flexible(
                                                    child: Text(
                                                      'Cantidad :',
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: windowWidth * 0.05,
                                                  ),
                                                  Flexible(
                                                    child: InputField(
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .words,
                                                      controller:
                                                          cantidadControllers,
                                                      keyboardType: TextInputType
                                                          .number, // This will show the numeric keyboard
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    if (cantidadControllers
                                                            .text.isEmpty ||
                                                        double.parse(
                                                                cantidadControllers
                                                                    .text) <=
                                                            0) {
                                                      mostrarAlerta(
                                                          context,
                                                          "AVISO",
                                                          "valor invalido");
                                                    } else {
                                                        item.cantidad =
                                                            double.parse(
                                                                cantidadControllers
                                                                    .text);
                                                        _actualizaTotalTemporal();cantidadControllers.text = '${item.cantidad}';
                                                    }
                                                  },
                                                  child: const Text('Aceptar '),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('Cancelar'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    : null,
                                icon: const Icon(Icons.edit),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            width: windowWidth * 0.15,
                            child: Text(
                              '  ${item.cantidad} ',
                              textAlign: TextAlign.center,
                            )),
                      ],
                    ),
                    Text('\$${item.totalItem.toStringAsFixed(2)}')
                  ],
                ),
                subtitle: const Divider(),
              )));
        }
      }
    }
    setState(() {});
    return productos;
  }

  _removerItemTemporal(ItemVenta item) {
    setState(() {
      cotizarTemporal.remove(item);
      _actualizaTotalTemporal();
    });
  }

  _actualizaTotalTemporal() {
    for (ItemVenta item in cotizarTemporal) {
      totalCotizacionTemporal += item.cantidad * item.precioPublico;
      subTotalItem += item.cantidad * item.precioPublico;
      item.totalItem = item.cantidad * item.precioPublico;
      descuento += item.descuento;
    }
    setState(() {});
  }

  _clientes() {
    List<DropdownMenuItem> listaClien = [];
    for (Cliente cliente in listaClientes) {
      if (cliente.nombre == 'Público en general') {
        listaClien.add(DropdownMenuItem(
            value: cliente.id.toString(),
            child: const Text('Público en general')));
      }
    }

    for (Cliente cliente in listaClientes) {
      if (cliente.nombre != 'Público en general') {
        listaClien.add(DropdownMenuItem(
            value: cliente.id.toString(), child: Text(cliente.nombre!)));
      }
    }
    if (_valueIdcliente.isEmpty) {
      _valueIdcliente = listaClientes
          .firstWhere((cliente) => cliente.nombre == 'Público en general')
          .id
          .toString();
    }
    return DropdownButton(
      items: listaClien,
      isExpanded: true,
      value: _valueIdcliente,
      onChanged: (value) {
        _valueIdcliente = value!;
      },
    );
  }
}
