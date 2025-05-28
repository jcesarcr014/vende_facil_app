import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/articulo_provider.dart';
import 'package:vende_facil/widgets/widgets.dart';

class AlmacenInventoryPage extends StatefulWidget {
  const AlmacenInventoryPage({super.key});

  @override
  State<AlmacenInventoryPage> createState() => _AlmacenInventoryPageState();
}

class _AlmacenInventoryPageState extends State<AlmacenInventoryPage> {
  final _provider = ArticuloProvider();
  bool _isLoading = true;
  String _textLoading = 'Cargando productos...';

  // Búsqueda
  final _searchController = TextEditingController();
  List<Producto> _productosFiltrados = [];
  List<Producto> _todosProductos = [];

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _cargarProductos();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.addListener(() {
        if (_focusNode.hasFocus) {
          setState(() {});
        }
      });
    });
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _isLoading = true;
      _textLoading = 'Cargando productos del almacén...';
    });

    try {
      final resultado = await _provider.listarProductosAlmacen();

      if (resultado.status != 1) {
        setState(() {
          _isLoading = false;
          _productosFiltrados = [];
          _todosProductos = [];
        });
        mostrarAlerta(context, 'Error', resultado.mensaje!);
        return;
      }

      setState(() {
        _todosProductos = List.from(listaProductos);
        _productosFiltrados = List.from(listaProductos);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _productosFiltrados = [];
        _todosProductos = [];
      });
      mostrarAlerta(context, 'Error', e.toString());
    }
  }

  void _filtrarProductos(String query) {
    setState(() {
      if (query.isEmpty) {
        _productosFiltrados = List.from(_todosProductos);
      } else {
        _productosFiltrados = _todosProductos
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

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, 'products-menu');
        }
      },
      child: Focus(
        focusNode: _focusNode,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('INVENTARIO ALMACÉN'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _cargarProductos,
                tooltip: 'Actualizar inventario',
              ),
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Ayuda'),
                      content: const Text(
                          '• Use el buscador para filtrar los productos\n'
                          '• Toque un producto para actualizar su cantidad\n'
                          '• Cada tarjeta muestra los detalles del producto'),
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
        _buildSearchField(),
        Expanded(
          child: _buildProductsGrid(),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
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
            'No hay productos disponibles en el almacén',
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
      child: InkWell(
        onTap: () => _showEditCantidadDialog(producto),
        borderRadius: BorderRadius.circular(8),
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
                  _buildDetailItem('Cantidad', '${producto.cantidad ?? 0}',
                      valueColor: Colors.blue, valueBold: true),
                  _buildDetailItem('Unidad',
                      producto.unidad == "1" ? 'Pieza' : 'Unidad (kg/m/l)'),
                ],
              ),

              // Botón de editar
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showEditCantidadDialog(producto),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Editar Cantidad'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              )
            ],
          ),
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

  void _showEditCantidadDialog(Producto producto) {
    final TextEditingController cantidadController = TextEditingController(
        text: producto.cantidad
                ?.toStringAsFixed(producto.unidad == "1" ? 0 : 3) ??
            '0');
    bool isPieza = producto.unidad == "1";

    showDialog(
      context: context,
      barrierDismissible: false, // Evita que se cierre tocando fuera
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar Cantidad'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  TextSpan(text: 'Producto: '),
                  TextSpan(
                    text: producto.producto ?? 'Sin nombre',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: cantidadController,
              decoration: InputDecoration(
                labelText: 'Nueva cantidad',
                border: OutlineInputBorder(),
                suffixText: isPieza ? 'pzs' : 'unidades',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: !isPieza),
              inputFormatters: [
                if (isPieza)
                  FilteringTextInputFormatter.digitsOnly
                else
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final String cantidadText = cantidadController.text;
              // Usa dialogContext en lugar de context para cerrar el diálogo
              Navigator.pop(dialogContext);

              double? nuevaCantidad = double.tryParse(cantidadText);
              if (nuevaCantidad == null) {
                // Usa Future.microtask para asegurar que el diálogo se haya cerrado completamente
                Future.microtask(() {
                  if (mounted) {
                    mostrarAlerta(
                        context, 'Error', 'Ingrese una cantidad válida');
                  }
                });
                return;
              }
              _guardaCantidad(producto, nuevaCantidad);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    ).then((_) {
      // Asegúrate de liberar recursos
      cantidadController.dispose();
    });
  }

  Future<void> _guardaCantidad(Producto producto, double nuevaCantidad) async {
    // Verifica si el widget está montado antes de actualizar el estado
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _textLoading = 'Actualizando cantidad...';
    });

    try {
      // Usa async/await en lugar de .then()
      final resp = await _provider.actualizarCantidadProducto(
          producto.id!, nuevaCantidad);

      // Verifica nuevamente si el widget está montado después de la operación asíncrona
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (resp.status == 1) {
        // Actualiza el producto solo si el status es correcto
        setState(() {
          producto.cantidad = nuevaCantidad;
        });

        // Usa un pequeño retraso para asegurar que el árbol de widgets se estabilice
        Future.microtask(() {
          if (mounted) {
            mostrarAlerta(
                context, 'Éxito', 'Cantidad actualizada correctamente');
          }
        });
      } else {
        // En caso de error de la API
        Future.microtask(() {
          if (mounted) {
            mostrarAlerta(context, 'Error', resp.mensaje!);
          }
        });
      }
    } catch (e) {
      // Manejo de excepciones
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        Future.microtask(() {
          if (mounted) {
            mostrarAlerta(context, 'Error', e.toString());
          }
        });
      }
    }
  }
}
