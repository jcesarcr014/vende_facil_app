// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/articulo_provider.dart';
import 'package:vende_facil/providers/negocio_provider.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vende_facil/util/imprime_tickets.dart';

import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String? _selectedSucursal;
  final _provider = ArticuloProvider();
  final _negocioProvider = NegocioProvider();
  final impresionesTickets = ImpresionesTickets();
  bool _isLoading = false;
  String _textLoading = '';

  // Búsqueda
  final _searchController = TextEditingController();
  List<Producto> _productosFiltrados = [];

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    listaProductosSucursal.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.addListener(() {
        if (_focusNode.hasFocus) {
          setState(() {});
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filtrarProductos(String query) {
    setState(() {
      if (query.isEmpty) {
        _productosFiltrados = List.from(listaProductosSucursal);
      } else {
        _productosFiltrados = listaProductosSucursal
            .where((producto) =>
                producto.producto!
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                (producto.clave?.toLowerCase().contains(query.toLowerCase()) ??
                    false) ||
                (producto.codigoBarras
                        ?.toLowerCase()
                        .contains(query.toLowerCase()) ??
                    false))
            .toList();
      }
    });
  }

  void _setProductsSucursal(String? value) async {
    if (value == null) return;

    setState(() {
      _isLoading = true;
      _textLoading = 'Cargando productos...';
      _selectedSucursal = value;
      _searchController.clear(); // Limpiar búsqueda
    });

    Sucursal sucursalSeleccionado = listaSucursales.firstWhere(
      (sucursal) => sucursal.nombreSucursal == value,
      orElse: () => Sucursal(),
    );

    if (sucursalSeleccionado.id == null) {
      setState(() {
        _isLoading = false;
        _productosFiltrados = [];
      });
      mostrarAlerta(context, 'Error', 'Selecciona otra sucursal');
      return;
    }

    try {
      Resultado resultado =
          await _provider.listarProductosSucursal(sucursalSeleccionado.id!);

      if (resultado.status != 1) {
        setState(() {
          _isLoading = false;
          _productosFiltrados = [];
        });
        mostrarAlerta(context, 'Error', resultado.mensaje!);
        return;
      }

      setState(() {
        _productosFiltrados = List.from(listaProductosSucursal);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _productosFiltrados = [];
      });
      mostrarAlerta(context, 'Error', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, 'products-menu');
        }
      },
      child: Focus(
        focusNode: _focusNode,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('INVENTARIOS'),
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Ayuda'),
                      content: const Text(
                          '• Seleccione una sucursal para ver los productos disponibles\n'
                          '• Use el buscador para filtrar los productos\n'
                          '• Cada tarjeta muestra los detalles del producto\n'
                          '• Use los botones de PDF o imprimir para generar reportes'),
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
        ),
      ),
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
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _buildProductsGrid(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Selector de sucursal
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Seleccione una sucursal',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            value: _selectedSucursal,
            isExpanded: true,
            items: listaSucursales
                .map((sucursal) => DropdownMenuItem(
                      value: sucursal.nombreSucursal,
                      child: Text(sucursal.nombreSucursal ?? ''),
                    ))
                .toList(),
            onChanged: _setProductsSucursal,
          ),

          const SizedBox(height: 16),

          // Buscador
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, clave o código de barras',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _filtrarProductos('');
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: _filtrarProductos,
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid() {
    if (_productosFiltrados.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Productos (${_productosFiltrados.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _productosFiltrados.length,
              itemBuilder: (context, index) {
                return _buildProductCard(_productosFiltrados[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory, size: 100, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _selectedSucursal == null
                ? 'Seleccione una sucursal para ver los productos'
                : 'No hay productos disponibles en esta sucursal',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Producto producto) {
    // Buscar categoría y color
    final categoria = listaCategorias.firstWhere(
      (cat) => cat.id == producto.idCategoria,
      orElse: () => Categoria(categoria: 'Sin categoría'),
    );

    final color = listaColores.firstWhere(
      (c) => c.id == categoria.idColor,
      orElse: () => ColorCategoria(color: Colors.grey),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado del producto
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono de categoría
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.color!.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.inventory_2,
                    color: color.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Información principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.producto ?? 'Sin nombre',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Categoría: ${categoria.categoria ?? 'Sin categoría'}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 24),
            Row(
              children: [
                _buildDetailItem('Clave', producto.clave ?? 'N/A'),
                _buildDetailItem(
                    'Código de Barras', producto.codigoBarras ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildDetailItem('Cantidad', '${producto.cantidadInv ?? 0}',
                    valueColor: Colors.black, valueBold: true),
                _buildDetailItem('Apartados', '${producto.apartadoInv ?? 0}',
                    valueColor: Colors.black, valueBold: true),
                _buildDetailItem(
                    'Disponibles', '${producto.disponibleInv ?? 0}',
                    valueColor: (producto.disponibleInv ?? 0) > 0
                        ? Colors.green
                        : Colors.red,
                    valueBold: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value,
      {Color? valueColor, bool valueBold = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
                color: valueColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _productosFiltrados.isNotEmpty
                    ? () => _generatePDF()
                    : null,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Generar PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _productosFiltrados.isNotEmpty
                    ? () {
                        setState(() {
                          _isLoading = true;
                          _textLoading = 'Imprimiendo...';
                        });
                        final sucursalSeleccionada = listaSucursales.firstWhere(
                          (sucursal) =>
                              sucursal.nombreSucursal == _selectedSucursal,
                          orElse: () => Sucursal(
                              nombreSucursal: 'Sucursal no especificada'),
                        );
                        impresionesTickets
                            .imprimirInventario(
                                sucursalSeleccionada.id.toString(),
                                _productosFiltrados)
                            .then((resp) {
                          setState(() {
                            _isLoading = false;
                            _textLoading = '';
                          });
                          if (resp.status != 1) {
                            mostrarAlerta(
                                context, 'Error', 'Error al imprimir');
                          }
                        });
                      }
                    : null,
                icon: const Icon(Icons.print),
                label: const Text('Imprimir'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generatePDF() async {
    setState(() {
      _isLoading = true;
      _textLoading = 'Generando PDF...';
    });

    try {
      // Configurar el documento
      final PdfDocument document = PdfDocument();
      document.pageSettings.margins.all = 30;
      final PdfPage page = document.pages.add();

      // Configurar las fuentes
      final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 18,
          style: PdfFontStyle.bold);
      final PdfFont subTitleFont = PdfStandardFont(PdfFontFamily.helvetica, 14,
          style: PdfFontStyle.bold);
      final PdfFont normalBoldFont = PdfStandardFont(
          PdfFontFamily.helvetica, 10,
          style: PdfFontStyle.bold);
      final PdfFont normalFont = PdfStandardFont(PdfFontFamily.helvetica, 10);

      // Configurar colores
      final PdfColor primaryColor = PdfColor(68, 114, 196); // Azul corporativo
      final PdfColor accentColor = PdfColor(230, 230, 230); // Gris claro
      final PdfColor textColor = PdfColor(51, 51, 51); // Gris oscuro para texto

      // Obtener información de la sucursal
      final sucursalSeleccionada = listaSucursales.firstWhere(
        (sucursal) => sucursal.nombreSucursal == _selectedSucursal,
        orElse: () => Sucursal(nombreSucursal: 'Sucursal no especificada'),
      );

      // Obtener información del negocio
      Sucursal negocio = await _negocioProvider
          .consultaSucursal(sucursalSeleccionada.id.toString());

      // Obtener dimensiones de la página
      final double pageWidth = page.getClientSize().width;
      final double headerHeight = 100;
      final DateTime now = DateTime.now();
      final String fechaGeneracion =
          "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";

      // Logo e información de encabezado
      double logoWidth = 70;
      double logoXPosition = 0;
      double nombreXPosition = logoWidth + 20;

      // Dibujar rectángulo de encabezado
      page.graphics.drawRectangle(
          brush: PdfSolidBrush(accentColor),
          bounds: Rect.fromLTWH(0, 0, pageWidth, headerHeight));

      // Cargar e insertar el logo
      try {
        final ByteData imageData = await rootBundle.load('assets/logo.png');
        final List<int> imageBytes = imageData.buffer.asUint8List();
        final PdfBitmap logoBitmap = PdfBitmap(imageBytes);
        page.graphics.drawImage(
            logoBitmap, Rect.fromLTWH(logoXPosition, 15, logoWidth, logoWidth));
      } catch (e) {
        // Si no puede cargar el logo, dejar el espacio en blanco
      }

      // Escribir el título e información de la sucursal
      page.graphics.drawString('INVENTARIO', titleFont,
          brush: PdfSolidBrush(primaryColor),
          bounds: Rect.fromLTWH(
              nombreXPosition, 15, pageWidth - nombreXPosition - 10, 20));

      page.graphics.drawString(
          'Sucursal: ${sucursalSeleccionada.nombreSucursal}', normalBoldFont,
          brush: PdfSolidBrush(textColor),
          bounds: Rect.fromLTWH(
              nombreXPosition, 40, pageWidth - nombreXPosition - 10, 20));

      page.graphics.drawString(
          "Teléfono: ${negocio.telefono ?? 'N/A'}", normalFont,
          brush: PdfSolidBrush(textColor),
          bounds: Rect.fromLTWH(
              nombreXPosition, 55, pageWidth - nombreXPosition - 10, 20));

      page.graphics.drawString(
          "Fecha de generación: $fechaGeneracion", normalFont,
          brush: PdfSolidBrush(textColor),
          bounds: Rect.fromLTWH(
              nombreXPosition, 70, pageWidth - nombreXPosition - 10, 20));

      // Título de la tabla
      double yPosition = headerHeight + 20;

      page.graphics.drawString('Lista de Productos', subTitleFont,
          brush: PdfSolidBrush(primaryColor),
          bounds: Rect.fromLTWH(0, yPosition, pageWidth, 20));

      yPosition += 25;

      // Crear la tabla de productos
      final PdfGrid grid = PdfGrid();
      grid.columns.add(count: 6);
      grid.style = PdfGridStyle(
        font: normalFont,
        cellPadding: PdfPaddings(left: 5, right: 5, top: 5, bottom: 5),
      );

      // Configurar anchos de columna
      grid.columns[0].width = 150; // Producto
      grid.columns[1].width = 80; // Clave
      grid.columns[2].width = 80; // Categoría
      grid.columns[3].width = 60; // Cantidad
      grid.columns[4].width = 60; // Apartados
      grid.columns[5].width = 60; // Disponibles

      // Crear encabezados
      final PdfGridRow headerRow = grid.headers.add(1)[0];
      headerRow.style = PdfGridRowStyle(
        backgroundBrush: PdfSolidBrush(primaryColor),
        textPen: PdfPens.white,
        textBrush: PdfBrushes.white,
        font: normalBoldFont,
      );

      headerRow.cells[0].value = 'Producto';
      headerRow.cells[1].value = 'Clave';
      headerRow.cells[2].value = 'Categoría';
      headerRow.cells[3].value = 'Cantidad';
      headerRow.cells[4].value = 'Apartados';
      headerRow.cells[5].value = 'Disponibles';

      // Agregar filas con los datos de los productos
      for (var i = 0; i < _productosFiltrados.length; i++) {
        final producto = _productosFiltrados[i];
        final categoria = listaCategorias.firstWhere(
          (cat) => cat.id == producto.idCategoria,
          orElse: () => Categoria(categoria: 'Sin categoría'),
        );

        final PdfGridRow row = grid.rows.add();

        // Alternar colores para mejorar legibilidad
        if (i % 2 == 1) {
          row.style = PdfGridRowStyle(
              backgroundBrush: PdfSolidBrush(PdfColor(245, 245, 245)));
        }

        row.cells[0].value = producto.producto ?? 'N/A';
        row.cells[1].value = producto.clave ?? 'N/A';
        row.cells[2].value = categoria.categoria ?? 'N/A';
        row.cells[3].value = (producto.cantidadInv ?? 0).toString();
        row.cells[4].value = (producto.apartadoInv ?? 0).toString();
        row.cells[5].value = (producto.disponibleInv ?? 0).toString();
      }

      // Dibujar la tabla
      grid.draw(page: page, bounds: Rect.fromLTWH(0, yPosition, 0, 0));

      // Añadir pie de página
      final double footerY = page.getClientSize().height - 30;
      page.graphics.drawLine(PdfPen(primaryColor, width: 1), Offset(0, footerY),
          Offset(pageWidth, footerY));

      page.graphics.drawString('Inventario generado por Vende Fácil',
          PdfStandardFont(PdfFontFamily.helvetica, 8),
          brush: PdfSolidBrush(textColor),
          bounds: Rect.fromLTWH(0, footerY + 5, pageWidth, 20),
          format: PdfStringFormat(alignment: PdfTextAlignment.center));

      page.graphics.drawString(
          'Página 1 de 1', PdfStandardFont(PdfFontFamily.helvetica, 8),
          brush: PdfSolidBrush(textColor),
          bounds: Rect.fromLTWH(0, footerY + 15, pageWidth, 20),
          format: PdfStringFormat(alignment: PdfTextAlignment.center));

      // Guardar y abrir el PDF
      List<int> bytes = document.saveSync();
      document.dispose();

      final directory = await getApplicationSupportDirectory();
      final path = directory.path;
      final fileName =
          'Inventario-${sucursalSeleccionada.nombreSucursal}-${now.day}${now.month}${now.year}.pdf';
      File file = File('$path/$fileName');
      await file.writeAsBytes(bytes, flush: true);

      setState(() {
        _isLoading = false;
      });

      OpenFile.open('$path/$fileName');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      mostrarAlerta(context, 'Error', 'Error al generar el PDF: $e');
    }
  }
}
