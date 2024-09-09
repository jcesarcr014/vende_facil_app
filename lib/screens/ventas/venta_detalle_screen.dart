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


class VentaDetalleScreen extends StatefulWidget {
  const VentaDetalleScreen({super.key});
  @override
  State<VentaDetalleScreen> createState() => _VentaDetalleScreenState();
}

class _VentaDetalleScreenState extends State<VentaDetalleScreen> {
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  double subTotalItem = 0.0;
  String _valueIdDescuento = '0';
  String _valueIdcliente = listaClientes
      .firstWhere((cliente) => cliente.nombre == 'Público en general')
      .id
      .toString();
  final cotizaciones = CotizarProvider();
  double descuento = 0.0;
  double restate = 0.0;
  int idcliente = 0;
  int idDescuento = 0;
  bool _valuePieza = false;

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
      try {
        final TicketModel model = await ticketProvider.getData(sesion.idNegocio.toString());
        setState(() {
          ticketModel.id = model.id;
          ticketModel.negocioId = model.negocioId;
          ticketModel.logo = model.logo;
          ticketModel.message = model.message;
        });
      } catch(e) {
        mostrarAlerta(context, 'Error', e.toString());
      }
  }

  Future<void> _generatePDF() async {
    // Crear un documento PDF
    final PdfDocument document = PdfDocument();

    // Agregar una página
    final PdfPage page = document.pages.add();

    // Crear fuentes
    final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);
    final PdfFont boldFont = PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
    final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold);
    final PdfFont italicFont = PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.italic);

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

    // Dibujar el logo y el nombre de la empresa juntos en la parte superior
    if (ticketModel.logo != null && ticketModel.logo!.isNotEmpty) {
      final logoImage = await _downloadImage(ticketModel.logo!);
      if (logoImage != null) {
        final PdfBitmap image = PdfBitmap(logoImage);
        page.graphics.drawImage(image, Rect.fromLTWH(logoXPosition, 0, logoWidth, 100)); // Ajustar el tamaño del logo
      }
    }
    
    // Dibujar el nombre de la empresa al lado del logo
    page.graphics.drawString(nombreNegocio, titleFont, brush: brush, 
        bounds: Rect.fromLTWH(nombreXPosition, 0, pageWidth - nombreXPosition, 30));

    // Dibujar el teléfono y la dirección debajo del nombre
    page.graphics.drawString(telefono, italicFont, brush: brush, 
        bounds: Rect.fromLTWH(nombreXPosition, 30, pageWidth - nombreXPosition, 20));
    page.graphics.drawString(direccion, italicFont, brush: brush, 
        bounds: Rect.fromLTWH(nombreXPosition, 50, pageWidth - nombreXPosition, 20));

    // Ajustar el mensaje del ticketModel debajo del logo
    if (ticketModel.message != null && ticketModel.message!.isNotEmpty) {
      double yPosition = 100; // Justo debajo de la imagen y el encabezado del negocio

      // Si el texto es más largo que el ancho de la página, dividir en varias líneas
      final List<String> messageLines = _wrapText(ticketModel.message!, pageWidth, italicFont);

      for (var line in messageLines) {
        page.graphics.drawString(
          line,
          italicFont,
          brush: brush,
          bounds: Rect.fromLTWH(0, yPosition, pageWidth, 30), // Alinear a la izquierda
        );
        yPosition += 20; // Espacio entre líneas
      }
    }

    // Reducir el espacio antes de la cotización de productos
    double yPosAfterMessage = 120; // Ajusta esta variable según sea necesario

    // Dibujar encabezado de la cotización
    page.graphics.drawString('Cotización de Productos', boldFont, brush: brush,
        bounds: Rect.fromLTWH(0, yPosAfterMessage, 500, 30)); // Encabezado
    page.graphics.drawString('Folio: ${cotizacionDetalle.folio}', font,
        bounds: Rect.fromLTWH(0, yPosAfterMessage + 30, 500, 30)); // Número de folio

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
      row.cells[0].value = producto.producto; // Asume que tienes un campo nombre
      row.cells[1].value = producto.cantidad.toString(); // Campo cantidad
      row.cells[2].value = producto.costo!.toStringAsFixed(2); // Total
    }

    // Añadir fila de subtotal
    final PdfGridRow subtotalRow = grid.rows.add();
    subtotalRow.cells[0].value = 'Subtotal';
    subtotalRow.cells[1].value = ''; // Celda vacía para alineación
    subtotalRow.cells[2].value = cotizacionDetalle.subtotal!.toStringAsFixed(2);
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
      bounds: Rect.fromLTWH(0, yPosAfterMessage + 60, 0, 0), // Reducir espacio antes de la tabla
    );

    // Guardar el PDF en bytes
    List<int> bytes = document.saveSync();

    // Liberar el documento
    document.dispose();

    // Guardar el archivo en el dispositivo
    final directory = await getApplicationSupportDirectory();
    final path = directory.path;
    File file = File('$path/Cotizacion-Vende Fácil-${cotizacionDetalle.folio}.pdf');

    await file.writeAsBytes(bytes, flush: true);

    // Abrir el PDF generado en el dispositivo
    OpenFile.open('$path/Cotizacion-Vende Fácil-${cotizacionDetalle.folio}.pdf');
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
            const Text('Detalle de venta'),
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
                  const SizedBox(height: 0.5),
                  if (sesion.cotizar == false)
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      SizedBox(width: windowWidth * 0.1),
                      SizedBox(
                        width: windowWidth * 0.2,
                        child: const Text(
                          'Descuento ',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: windowWidth * 0.1),
                      Expanded(
                        child: _descuentos(),
                      ),
                      SizedBox(width: windowWidth * 0.1),
                      SizedBox(
                          width: windowWidth * 0.2,
                          child: Text(
                            '\$${descuento.toStringAsFixed(2)}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )),
                    ]),
                  SizedBox(
                    height: windowHeight * 0.03,
                  ),
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
                          '\$${totalVentaTemporal.toStringAsFixed(2)}',
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
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SwitchListTile.adaptive(
                      title: const Text('Tipo de venta:'),
                      subtitle: Text(_valuePieza ? 'Domicilio' : 'Tienda'),
                      value: _valuePieza,
                      onChanged: (value) {
                        _valuePieza = value;
                        setState(() {
                          _actualizaTotalTemporal();
                        });
                      },
                    ),
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    SizedBox(width: windowWidth * 0.1),
                    SizedBox(
                      width: windowWidth * 0.2,
                      height: windowHeight * 0.1,
                    ),
                  ]),
                  if (sesion.cotizar == false)
                    Center(
                      child: Column(
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                VentaCabecera venta = VentaCabecera(
                                  idCliente: int.parse(_valueIdcliente),
                                  subtotal: subTotalItem,
                                  idDescuento: idDescuento,
                                  descuento: descuento,
                                  total: totalVentaTemporal,
                                );
                                Navigator.pushNamed(context, 'venta',
                                    arguments: venta);
                                setState(() {});
                              },
                              child: SizedBox(
                                height: windowHeight * 0.1,
                                width: windowWidth * 0.6,
                                child: Center(
                                  child: Text(
                                    'Cobrar   \$${totalVentaTemporal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )),
                          const SizedBox(
                            height: 30,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                _validaApartado();
                              },
                              child: SizedBox(
                                height: windowHeight * 0.07,
                                width: windowWidth * 0.6,
                                child: const Center(
                                  child: Text(
                                    'Apartar',
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
                  if (sesion.cotizar == true)
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
                                  total: totalVentaTemporal,
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
        for (ItemVenta item in ventaTemporal) {
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

        if (detallesGuardadosCorrectamente == ventaTemporal.length) {
          setState(() {
            textLoading = '';
            isLoading = false;
          });
          ventaTemporal.clear();
          setState(() {});
          totalVentaTemporal = 0.0;
          globals.actualizaArticulos = true;
          listacotizacion.add(cotiz);
          mostrarAlerta(context, '', 'cotizacion realizada');
          _generatePDF();
          Navigator.pushReplacementNamed(context, 'home');
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
    for (ItemVenta item in ventaTemporal) {
      for (Producto prod
          in sesion.cotizar! ? listaProductos : listaProductosSucursal) {
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
                          child: IconButton(
                            onPressed: item.totalItem > 0.00
                                ? () {
                                    item.cantidad--;
                                    // item.subTotalItem =
                                    //     item.precioPublico * item.cantidad;
                                    // item.totalItem =
                                    //     item.subTotalItem - item.descuento;
                                    if (item.cantidad == 0) {
                                      _removerItemTemporal(item);
                                    }
                                    _actualizaTotalTemporal();
                                  }
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                        ),
                        SizedBox(
                            width: windowWidth * 0.15,
                            child: Text(
                              '  ${item.cantidad} ',
                              textAlign: TextAlign.center,
                            )),
                        SizedBox(
                            width: windowWidth * 0.1,
                            child: IconButton(
                                onPressed: () {
                                  var catidad = item.cantidad + 1;
                                  
                                  if (catidad > prod.disponibleInv!) {
                                    mostrarAlerta(context, "AVISO",
                                        "Nose puede agregar mas articulos de este producto ");
                                  } else {
                                    item.cantidad++;
                                    // item.subTotalItem =
                                    //     item.precioPublico * item.cantidad;
                                    // item.totalItem =
                                    //     item.subTotalItem - item.descuento;
                                    _actualizaTotalTemporal();
                                  }
                                },
                                icon: const Icon(Icons.add_circle_outline))),
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

  _validaApartado() {
    apartadoValido = true;
    double numArticulos = 0;
    for (ItemVenta articuloTemporal in ventaTemporal) {
      if (articuloTemporal.apartado == false) {
        apartadoValido = false;
        mostrarAlerta(context, 'ERROR',
            'El articulo nose puede apartar. Para modificar este valor, ve a Productos -> Editar producto.');

        return;
      } else {
        numArticulos = numArticulos + articuloTemporal.cantidad;
      }
    }
    if (double.parse(listaVariables[1].valor!) < numArticulos) {
      apartadoValido = false;
      mostrarAlerta(context, 'ERROR',
          'Superas la cantidad de artículos que se pueden apartar. Para modificar este valor, ve a Configuración -> Ajustes apartado.');
      return;
    }
    if (apartadoValido) {
      ApartadoCabecera apartado = ApartadoCabecera(
        clienteId: int.parse(_valueIdcliente),
        subtotal: subTotalItem,
        descuentoId: idDescuento,
        descuento: descuento,
        total: totalVentaTemporal,
      );
      Navigator.pushNamed(context, 'apartado', arguments: apartado);
    } else {
      mostrarAlerta(
          context, 'ERROR', 'Todos los articulos deben ser apartables.');
    }
  }

  _removerItemTemporal(ItemVenta item) {
    setState(() {
      ventaTemporal.remove(item);
      _actualizaTotalTemporal();
    });
  }

  _actualizaTotalTemporal() {
    if (sesion.cotizar!) {
      for (ItemVenta item in ventaTemporal) {
        totalVentaTemporal += item.cantidad * item.precioPublico;
        subTotalItem += item.cantidad * item.precioPublico;
        item.totalItem = item.cantidad * item.precioPublico;
        descuento += item.descuento;
      }
      setState(() {});
    } else {
      var aplica = listaVariables
          .firstWhere((variables) => variables.nombre == "aplica_mayoreo");
      totalVentaTemporal = 0;
      subTotalItem = 0;
      descuento = 0;
      if (_valuePieza == true) {
        for (ItemVenta item in ventaTemporal) {
          totalVentaTemporal += item.cantidad * item.precioPublico;
          subTotalItem += item.cantidad * item.precioPublico;
          item.totalItem = item.cantidad * item.precioPublico;
        }
      } else {
        for (ItemVenta item in ventaTemporal) {
          if (aplica.valor == "0") {
            totalVentaTemporal += item.cantidad * item.precioPublico;
            subTotalItem += item.cantidad * item.precioPublico;
            item.totalItem = item.cantidad * item.precioPublico;
            descuento += item.descuento;
          } else {
            if (item.cantidad >= double.parse(listaVariables[3].valor!)) {
              totalVentaTemporal += item.cantidad * item.preciomayoreo;
              subTotalItem += item.cantidad * item.preciomayoreo;
              item.totalItem = item.cantidad * item.preciomayoreo;
              descuento += item.descuento;
            } else {
              totalVentaTemporal += item.cantidad * item.precioPublico;
              subTotalItem += item.cantidad * item.precioPublico;
              item.totalItem = item.cantidad * item.precioPublico;
              descuento += item.descuento;
            }
          }
        }
      }
      setState(() {});
    }
  }

  _descuentos() {
    var listades = [
      const DropdownMenuItem(
        value: '0',
        child: SizedBox(child: Text('Ninguno')),
      )
    ];
    for (Descuento descuentos in listaDescuentos) {
      listades.add(DropdownMenuItem(
          value: descuentos.id.toString(), child: Text(descuentos.nombre!)));
    }
    if (_valueIdDescuento.isEmpty) {
      _valueIdDescuento = '0';
    }
    return DropdownButton(
      items: listades,
      isExpanded: true,
      value: _valueIdDescuento,
      onChanged: (value) {
        _valueIdDescuento = value!;
        if (value == "0") {
          setState(() {});
          descuento = 0.00;
          totalVentaTemporal = subTotalItem;
        } else {
          Descuento descuentoSeleccionado = listaDescuentos
              .firstWhere((descuento) => descuento.id.toString() == value);
          if (descuentoSeleccionado.valorPred == 0) {
            if (descuentoSeleccionado.tipoValor == 1) {
              setState(() {
                idDescuento = descuentoSeleccionado.id!;
                descuento = 0.00;
                descuento = descuentoSeleccionado.valor!;
                totalVentaTemporal = subTotalItem;
                descuento = (totalVentaTemporal * descuento) / 100;
                totalVentaTemporal = totalVentaTemporal - descuento;
                _valuePieza = false;
              });
            } else {
              setState(() {
                idDescuento = descuentoSeleccionado.id!;
                descuento = 0.00;
                descuento = descuentoSeleccionado.valor!;
                totalVentaTemporal = subTotalItem;
                totalVentaTemporal =
                    totalVentaTemporal - descuentoSeleccionado.valor!;
                _valuePieza = false;
              });
            }
          } else {
            _alertadescuento(descuentoSeleccionado);
          }
        }
      },
    );
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
          if (clienteseleccionado.distribuidor == 1) {
            setState(() {
              // totalVentaTemporal += item.totalItem;
              // subTotalItem += item.subTotalItem;
              // descuento += item.descuento;
              totalVentaTemporal = 0.00;
              for (ItemVenta item in ventaTemporal) {
                totalVentaTemporal = item.cantidad * item.preciodistribuidor;
                subTotalItem = totalVentaTemporal;
              }
              _valuePieza = false;
            });
          }
        });
      },
    );
  }

  _alertadescuento(Descuento descuentos) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Row(
            children: [
              const Flexible(
                child: Text(
                  'Cantidad :',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              SizedBox(
                width: windowWidth * 0.05,
              ),
              Flexible(
                child: InputField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: cantidadConttroller,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (descuentos.tipoValor == 1) {
                  double.parse(cantidadConttroller.text);
                  setState(() {
                    idDescuento = descuentos.id!;
                    descuento = 0.00;
                    descuento = double.parse(cantidadConttroller.text);
                    totalVentaTemporal = subTotalItem;
                    descuento = (totalVentaTemporal * descuento) / 100;
                    totalVentaTemporal = totalVentaTemporal - descuento;
                    _valuePieza = false;
                  });
                } else {
                  setState(() {
                    idDescuento = descuentos.id!;
                    descuento = 0.00;
                    descuento = double.parse(cantidadConttroller.text);
                    totalVentaTemporal = subTotalItem;
                    totalVentaTemporal = totalVentaTemporal - descuento;
                    _valuePieza = false;
                  });
                }
              },
              child: const Text('Aceptar '),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}
