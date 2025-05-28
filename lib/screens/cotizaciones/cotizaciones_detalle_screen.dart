// ignore_for_file: dead_code, prefer_final_fields, depend_on_referenced_packages, unnecessary_nullable_for_final_variable_declarations

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';
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
  final _cantidadController = TextEditingController();
  final _cotizacionProvider = CotizarProvider();
  final _ticketProvider = TicketProvider();
  final _negocioProvider = NegocioProvider();
  final _articulosProvider = ArticuloProvider();

  bool _isLoading = false;
  String _textLoading = '';

  double _subTotalItem = 0.0;
  double _descuento = 0.0;

  int _idcliente = 0;
  int _idDescuento = 0;

  String? _nombreCliente;
  String? _idSucursal;

  String _valueIdcliente = '';

  @override
  void initState() {
    super.initState();
    _inicializarDatos();
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  Future<void> _inicializarDatos() async {
    setState(() {
      _isLoading = true;
      _textLoading = 'Leyendo productos';
    });

    try {
      _actualizaTotalTemporal();
      await _cargarDatosTicket();

      // Asegurarse de que los productos estén cargados
      if (listaProductosSucursal.isEmpty) {
        await _articulosProvider.listarProductosSucursal(sesion.idSucursal!);
      }

      // Inicializar el valor del cliente seleccionado
      _valueIdcliente = listaClientes
          .firstWhere((cliente) => cliente.nombre == 'Público en general',
              orElse: () => listaClientes.first)
          .id
          .toString();

      if (sesion.tipoUsuario == 'P') {
        _idSucursal = sesion.idSucursal.toString();
        setState(() {
          _isLoading = false;
        });
      } else {
        await _negocioProvider.getlistaempleadosEnsucursales(null);
        _idSucursal = sesion.idSucursal.toString();
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      mostrarAlerta(
          context, 'Error', 'Ocurrió un error al cargar los datos: $e');
    }
  }

  Future<void> _cargarDatosTicket() async {
    try {
      setState(() {
        _textLoading = 'Cargando información del ticket';
      });

      final TicketModel? model =
          await _ticketProvider.getData(sesion.idNegocio.toString(), true);

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

  void _actualizaTotalTemporal() {
    totalCotizacionTemporal = 0;
    _subTotalItem = 0;
    _descuento = 0;

    for (ItemVenta item in cotizarTemporal) {
      totalCotizacionTemporal += item.cantidad * item.precioPublico;
      _subTotalItem += item.cantidad * item.precioPublico;
      item.totalItem = item.cantidad * item.precioPublico;
    }

    setState(() {});
  }

  void _mostrarDialogoCantidad(ItemVenta item) {
    _cantidadController.text = item.cantidad.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Cantidad'),
        content: TextField(
          controller: _cantidadController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Cantidad',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_cantidadController.text.isEmpty ||
                  double.parse(_cantidadController.text) <= 0) {
                mostrarAlerta(context, "AVISO", "Cantidad inválida");
                return;
              }

              item.cantidad = double.parse(_cantidadController.text);
              _actualizaTotalTemporal();
              Navigator.pop(context);
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _removerItemTemporal(ItemVenta item) {
    setState(() {
      cotizarTemporal.remove(item);
      _actualizaTotalTemporal();
    });
  }

  Future<void> _generarCotizacion() async {
    if (cotizarTemporal.isEmpty) {
      mostrarAlerta(context, 'Advertencia', 'No hay productos para cotizar');
      return;
    }

    Cotizacion cotiz = Cotizacion(
      idCliente: int.parse(_valueIdcliente),
      subtotal: _subTotalItem,
      idDescuento: _idDescuento,
      descuento: _descuento,
      total: totalCotizacionTemporal,
      dias_vigentes: 10,
    );

    setState(() {
      _isLoading = true;
      _textLoading = 'Guardando cotización';
    });

    try {
      // Crear una copia profunda de los items de la cotización
      List<Map<String, dynamic>> itemsCopy = [];

      for (ItemVenta item in cotizarTemporal) {
        itemsCopy.add({
          'idArticulo': item.idArticulo,
          'articulo': item.articulo,
          'cantidad': item.cantidad,
          'precioPublico': item.precioPublico,
          'precioUtilizado': item.precioUtilizado,
          'totalItem': item.totalItem
        });
      }

      List<CotizacionDetalle> detalles = [];

      for (ItemVenta item in cotizarTemporal) {
        detalles.add(CotizacionDetalle(
          idProd: item.idArticulo,
          cantidad: item.cantidad,
          precio: item.precioPublico,
          idDesc: cotiz.idDescuento,
          cantidadDescuento: cotiz.descuento,
          total: item.totalItem,
          subtotal: item.subTotalItem,
        ));
      }

      final resp =
          await _cotizacionProvider.guardarCotizacionCompleta(cotiz, detalles);

      setState(() {
        _isLoading = false;
      });

      if (resp.status == 1) {
        cotiz.folio = resp.folio;
        listacotizacion.add(cotiz);

        // Generar el PDF con la copia de los items
        await _generatePDF(cotiz, itemsCopy);

        // Limpiar después de generar el PDF
        cotizarTemporal.clear();
        totalCotizacionTemporal = 0.0;

        Navigator.of(context)
            .pushNamedAndRemoveUntil('products-menu', (route) => false);
        mostrarAlerta(context, 'Éxito', 'Cotización guardada, generando PDF.');
      } else {
        mostrarAlerta(context, 'ERROR', 'Ocurrió un error: ${resp.mensaje}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      mostrarAlerta(context, 'Error', 'Error al generar la cotización: $e');
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

  Future<void> _generatePDF(
      Cotizacion cotiz, List<Map<String, dynamic>> items) async {
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

      Sucursal negocio = await _negocioProvider.consultaSucursal(_idSucursal!);
      final String telefonoData = negocio.telefono ?? '';
      final String direccionData = negocio.direccion ?? '';
      String nombreNegocio = negocio.nombreSucursal ?? 'PENDIENTE';
      String telefono = "Teléfono: $telefonoData";
      String direccion = "Dirección: $direccionData";
      String cliente = _nombreCliente ?? 'Público en general';
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
          page.graphics.drawImage(
              image, Rect.fromLTWH(logoXPosition, 0, logoWidth, 100));
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

      // Usar los items copiados para el PDF
      for (var item in items) {
        // Buscar nombre del producto en listaProductosSucursal si es necesario
        String nombreProducto = item['articulo'] ?? 'Producto sin nombre';
        double cantidad = item['cantidad'] ?? 0.0;
        double totalItem = item['totalItem'] ?? 0.0;

        final PdfGridRow row = grid.rows.add();
        row.cells[0].value = nombreProducto;
        row.cells[1].value = cantidad.toString();
        row.cells[2].value = totalItem.toStringAsFixed(2);
        total += totalItem;
      }

      final PdfGridRow subtotalRow = grid.rows.add();
      subtotalRow.cells[0].value = 'Subtotal';
      subtotalRow.cells[1].value = '';
      subtotalRow.cells[2].value = cotiz.subtotal!.toStringAsFixed(2);
      subtotalRow.style = PdfGridRowStyle(
        font: boldFont,
        textBrush: PdfBrushes.black,
      );

      if (cotiz.descuento! > 0) {
        final PdfGridRow descuentoRow = grid.rows.add();
        descuentoRow.cells[0].value = 'Descuento';
        descuentoRow.cells[1].value = '';
        descuentoRow.cells[2].value = cotiz.descuento!.toStringAsFixed(2);
        descuentoRow.style = PdfGridRowStyle(
          font: boldFont,
          textBrush: PdfBrushes.black,
        );
      }

      final PdfGridRow totalRow = grid.rows.add();
      totalRow.cells[0].value = 'Total';
      totalRow.cells[1].value = '';
      totalRow.cells[2].value = cotiz.total!.toStringAsFixed(2);
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
      File file = File('$path/Cotizacion-Vende-Facil-${cotiz.folio}.pdf');
      await file.writeAsBytes(bytes, flush: true);

      OpenFile.open('$path/Cotizacion-Vende-Facil-${cotiz.folio}.pdf');
    } catch (e) {
      mostrarAlerta(context, 'Error', 'Error al generar el PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Cotización'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Ayuda'),
                  content: const Text('• Deslice un producto para eliminarlo\n'
                      '• Toque el ícono de edición para cambiar la cantidad\n'
                      '• Seleccione el cliente antes de generar la cotización'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Entendido'),
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingView() : _buildMainContent(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Espere... $_textLoading'),
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProductList(),
            const SizedBox(height: 16),
            _buildSummary(),
            const SizedBox(height: 16),
            _buildClientSection(),
            // Agregar espacio adicional al final para evitar que el contenido
            // quede oculto detrás de la barra inferior
            const SizedBox(height: 72),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productos (${cotizarTemporal.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            cotizarTemporal.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No hay productos en la cotización'),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cotizarTemporal.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = cotizarTemporal[index];

                      // Buscar producto en listaProductosSucursal
                      final producto = listaProductosSucursal.firstWhere(
                        (prod) => prod.id == item.idArticulo,
                        orElse: () =>
                            Producto(producto: 'Producto no encontrado'),
                      );

                      return Dismissible(
                        key: Key(item.idArticulo.toString()),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          child: const Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                        ),
                        onDismissed: (_) => _removerItemTemporal(item),
                        child: ListTile(
                          title: Text(
                            producto.producto ?? 'Producto no encontrado',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              'Precio: \$${item.precioPublico.toStringAsFixed(2)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${item.cantidad}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _mostrarDialogoCantidad(item),
                              ),
                              Text(
                                '\$${item.totalItem.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            _buildSummaryRow('Subtotal', _subTotalItem),
            _buildSummaryRow('Descuento', _descuento),
            _buildSummaryRow('Total', totalCotizacionTemporal, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                : null,
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: isTotal
                ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildClientSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cliente',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildClientDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildClientDropdown() {
    List<DropdownMenuItem<String>> listaClien = [];

    // Agregar "Público en general" primero
    for (Cliente cliente in listaClientes) {
      if (cliente.nombre == 'Público en general') {
        listaClien.add(DropdownMenuItem(
            value: cliente.id.toString(),
            child: const Text('Público en general')));
        break;
      }
    }

    // Agregar el resto de clientes
    for (Cliente cliente in listaClientes) {
      if (cliente.nombre != 'Público en general') {
        listaClien.add(DropdownMenuItem(
            value: cliente.id.toString(),
            child: Text(cliente.nombre ?? 'Sin nombre')));
      }
    }

    // Si no hay valor seleccionado, usar "Público en general"
    if (_valueIdcliente.isEmpty) {
      final defaultCliente = listaClientes.firstWhere(
          (cliente) => cliente.nombre == 'Público en general',
          orElse: () => listaClientes.isNotEmpty
              ? listaClientes.first
              : Cliente(id: 0, nombre: 'Sin clientes'));
      _valueIdcliente = defaultCliente.id.toString();
    }

    return DropdownButtonFormField<String>(
      items: listaClien,
      value: _valueIdcliente,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _valueIdcliente = value;
            var clienteSeleccionado = listaClientes.firstWhere(
                (cliente) => cliente.id.toString() == _valueIdcliente,
                orElse: () => Cliente(nombre: 'Cliente no encontrado'));
            _nombreCliente = clienteSeleccionado.nombre;

            // Si es distribuidor, aplicar precios especiales
            if (clienteSeleccionado.distribuidor == 1) {
              totalCotizacionTemporal = 0.00;
              for (ItemVenta item in cotizarTemporal) {
                totalCotizacionTemporal +=
                    item.cantidad * item.precioDistribuidor;
                _subTotalItem = totalCotizacionTemporal;
              }
            }
          });
        }
      },
      decoration: const InputDecoration(
        labelText: 'Seleccione un cliente',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomAppBarTheme.color ??
            Theme.of(context).primaryColor.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            onPressed: cotizarTemporal.isNotEmpty ? _generarCotizacion : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text(
              'Generar Cotización',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
