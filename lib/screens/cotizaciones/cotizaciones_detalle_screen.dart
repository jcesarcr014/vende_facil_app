// ignore_for_file: dead_code, prefer_final_fields, depend_on_referenced_packages, unnecessary_nullable_for_final_variable_declarations

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
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
  final cantidadControllers = TextEditingController();
  final cotizaciones = CotizarProvider();
  final TicketProvider ticketProvider = TicketProvider();
  final NegocioProvider negocioProvider = NegocioProvider();
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  double subTotalItem = 0.0;
  double descuento = 0.0;
  double restate = 0.0;
  int idcliente = 0;
  int idDescuento = 0;
  String? nombreCliente;
  String? idSucursal;
  final cantidadConttroller = TextEditingController();
  List<DropdownMenuItem> listaClien = [];
  List<Producto> listaProductosCotizaciones = [];
  String _valueIdcliente = listaClientes
      .firstWhere((cliente) => cliente.nombre == 'Público en general')
      .id
      .toString();

  @override
  void initState() {
    setState(() {
      isLoading = true;
      textLoading = 'Leyendo productos';
    });

    _actualizaTotalTemporal();
    listaDescuentos;
    _loadData();
    super.initState();
    if (sesion.tipoUsuario == 'P') {
      idSucursal = sesion.idSucursal.toString();
      isLoading = false;
      setState(() {});
    } else {
      negocioProvider.getlistaempleadosEnsucursales(null).then((value) {
        idSucursal = sesion.idSucursal.toString();
        isLoading = false;
        setState(() {});
      });
    }
  }

  void _loadData() async {
    final TicketModel? model =
        await ticketProvider.getData(sesion.idNegocio.toString(), true);
    setState(() {
      ticketModel.id = model?.id;
      ticketModel.negocioId = model?.negocioId;
      ticketModel.logo = model?.logo;
      ticketModel.message = model?.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Cotización'),
        automaticallyImplyLeading: true,
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
                        'Selecione cliente',
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
                                  'Generar Cotización',
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
    setState(() {
      isLoading = true;
      textLoading = 'Guardando cotización';
    });
    List<CotizacionDetalle> detalles = [];
    for (ItemVenta item in cotizarTemporal) {
      CotizacionDetalle ventaDetalle = CotizacionDetalle(
        idProd: item.idArticulo,
        cantidad: item.cantidad,
        precio: item.precioPublico,
        idDesc: cotiz.idDescuento,
        cantidadDescuento: cotiz.descuento,
        total: item.totalItem,
        subtotal: item.subTotalItem,
      );
      detalles.add(ventaDetalle);
    }
    cotizaciones.guardarCotizacionCompleta(cotiz, detalles).then((resp) {
      setState(() {
        isLoading = false;
        textLoading = '';
      });
      if (resp.status == 1) {
        cotizarTemporal.clear();
        totalCotizacionTemporal = 0.0;
        cotiz.folio = resp.folio;
        listacotizacion.add(cotiz);
        setState(() {});
        _generatePDF(cotiz);
        Navigator.of(context)
            .pushNamedAndRemoveUntil('products-menu', (route) => false);
        mostrarAlerta(context, '', 'Cotizacion guardada, generando PDF.');
      } else {
        mostrarAlerta(context, 'ERROR', 'Ocurrio un error: ${resp.mensaje}');
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
                                          cantidadControllers.text =
                                              '${item.cantidad}';
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
                                                      _actualizaTotalTemporal();
                                                      cantidadControllers.text =
                                                          '${item.cantidad}';
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
    totalCotizacionTemporal = 0;
    subTotalItem = 0;
    descuento = 0;
    for (ItemVenta item in cotizarTemporal) {
      totalCotizacionTemporal += item.cantidad * item.precioPublico;
      subTotalItem += item.cantidad * item.precioPublico;
      item.totalItem = item.cantidad * item.precioPublico;
    }
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
        setState(() {
          var clienteseleccionado = listaClientes.firstWhere(
              (cliente) => cliente.id == int.parse(_valueIdcliente));
          nombreCliente = clienteseleccionado.nombre!;
          if (clienteseleccionado.distribuidor == 1) {
            setState(() {
              totalCotizacionTemporal = 0.00;
              for (ItemVenta item in cotizarTemporal) {
                totalCotizacionTemporal =
                    item.cantidad * item.precioDistribuidor;
                subTotalItem = totalCotizacionTemporal;
              }
            });
          }
        });
      },
    );
  }

  Future<void> _generatePDF(Cotizacion cotiz) async {
    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();
    final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);
    final PdfFont boldFont =
        PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
    final PdfFont titleFont =
        PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold);
    final PdfFont italicFont = PdfStandardFont(PdfFontFamily.helvetica, 14,
        style: PdfFontStyle.italic);
    final PdfBrush brush = PdfSolidBrush(PdfColor(51, 51, 51));
    Sucursal negocio = await negocioProvider.consultaSucursal(idSucursal!);
    final String telefonoData = negocio.telefono ?? '';
    final String direccionData = negocio.direccion ?? '';
    String nombreNegocio = negocio.nombreSucursal ?? 'PENDIENTE';
    String telefono = "Teléfono: $telefonoData";
    String direccion = "Dirección: $direccionData";
    String cliente = nombreCliente ?? 'Público en general';
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
        logoBitmap,
        Rect.fromLTWH(logoXPosition, 0, logoWidth, 100),
      );
    }
    page.graphics.drawString(nombreNegocio, titleFont,
        brush: brush,
        bounds:
            Rect.fromLTWH(nombreXPosition, 0, pageWidth - nombreXPosition, 30));
    page.graphics.drawString(telefono, italicFont,
        brush: brush,
        bounds: Rect.fromLTWH(
            nombreXPosition, 30, pageWidth - nombreXPosition, 20));
    page.graphics.drawString(direccion, italicFont,
        brush: brush,
        bounds: Rect.fromLTWH(
            nombreXPosition, 50, pageWidth - nombreXPosition, 20));

    page.graphics.drawString(cliente, italicFont,
        brush: brush,
        bounds: Rect.fromLTWH(
            nombreXPosition, 70, pageWidth - nombreXPosition, 20));
    double yPosAfterMessage = 120;
    page.graphics.drawString('Cotización de Productos', boldFont,
        brush: brush, bounds: Rect.fromLTWH(0, yPosAfterMessage, 500, 30));
    page.graphics.drawString('Folio: ${cotiz.folio}', font,
        bounds: Rect.fromLTWH(0, yPosAfterMessage + 30, 500, 30));
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 3);
    grid.style = PdfGridStyle(
      font: font,
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
    for (var producto in listaProductosCotizaciones) {
      final PdfGridRow row = grid.rows.add();
      row.cells[0].value = producto.producto;
      row.cells[1].value = producto.cantidad.toString();
      row.cells[2].value = producto.costo!.toStringAsFixed(2);
      total += producto.costo!;
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
        page: page, bounds: Rect.fromLTWH(0, yPosAfterMessage + 60, 0, 0));
    List<int> bytes = document.saveSync();
    document.dispose();
    final directory = await getApplicationSupportDirectory();
    final path = directory.path;
    File file = File('$path/Cotizacion-Vendo-Facil-${cotiz.folio}.pdf');
    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open('$path/Cotizacion-Vendo-Facil-${cotiz.folio}.pdf');
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
}
