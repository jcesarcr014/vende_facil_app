import 'package:flutter/material.dart';
// Quitar Scheduler y Services si ya no son necesarios aquí directamente
// import 'package:flutter/scheduler.dart';
// import 'package:flutter/services.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';

// Ya no necesitamos el enum ProductoInventarioAction
// enum ProductoInventarioAction { ajustarCantidad, editarDetallesCompletos }

class InventarioUnicaSucScreen extends StatefulWidget {
  const InventarioUnicaSucScreen({super.key});

  @override
  State<InventarioUnicaSucScreen> createState() =>
      _InventarioUnicaSucScreenState();
}

class _InventarioUnicaSucScreenState extends State<InventarioUnicaSucScreen> {
  final _articuloProvider = ArticuloProvider();
  final _searchController = TextEditingController();

  bool _isLoading = true;
  String _textLoading = 'Cargando inventario...';
  List<Producto> _productosInventario = [];
  List<Producto> _productosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _cargarInventario();
  }

  Future<void> _cargarInventario() async {
    if (!mounted) return;
    bool needsSetStateForLoading = !_isLoading;
    if (needsSetStateForLoading) {
      setState(() {
        _isLoading = true;
        _textLoading = 'Actualizando inventario...';
      });
    } else if (_isLoading &&
        _textLoading != 'Actualizando inventario...' &&
        _textLoading != 'Cargando inventario...') {
      _textLoading = 'Actualizando inventario...';
      if (mounted) setState(() {});
    } else if (!_isLoading && _textLoading.isEmpty) {
      if (mounted)
        setState(() {
          _isLoading = true;
          _textLoading = 'Cargando inventario...';
        });
    }

    List<Producto> tempInventario = [];
    List<Producto> tempFiltrados = [];
    String? mensajeErrorApi;

    try {
      final resultado = await _articuloProvider.listarInventarioUnicaSucursal();
      if (!mounted) return;

      if (resultado.status == 1) {
        tempInventario = List.from(listaProductos);
        String currentQuery = _searchController.text.toLowerCase();
        if (currentQuery.isEmpty) {
          tempFiltrados = List.from(tempInventario);
        } else {
          tempFiltrados = tempInventario
              .where((producto) =>
                  (producto.producto?.toLowerCase().contains(currentQuery) ??
                      false) ||
                  (producto.clave?.toLowerCase().contains(currentQuery) ??
                      false) ||
                  (producto.codigoBarras
                          ?.toLowerCase()
                          .contains(currentQuery) ??
                      false))
              .toList();
        }
      } else {
        mensajeErrorApi =
            resultado.mensaje ?? 'No se pudo cargar el inventario.';
      }
    } catch (e) {
      mensajeErrorApi = 'Ocurrió un error: ${e.toString()}';
    }

    if (mounted) {
      setState(() {
        _productosInventario = tempInventario;
        _productosFiltrados = tempFiltrados;
        _isLoading = false;
        _textLoading = '';
      });
      if (mensajeErrorApi != null) {
        Future.microtask(() {
          // Para asegurar que se muestre después del build
          if (mounted && context.mounted)
            mostrarAlerta(context, 'Error', mensajeErrorApi!);
        });
      }
    }
  }

  void _filtrarProductos(String query) {
    if (!mounted) return;
    setState(() {
      if (query.isEmpty) {
        _productosFiltrados = List.from(_productosInventario);
      } else {
        _productosFiltrados = _productosInventario
            .where((producto) =>
                (producto.producto
                        ?.toLowerCase()
                        .contains(query.toLowerCase()) ??
                    false) ||
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

  // Navegar a editar producto completo
  void _navegarAEditarProducto(Producto producto) async {
    if (!mounted) return;
    final fueModificado = await Navigator.pushNamed(
        context, 'nvo-producto', // Ruta de tu pantalla AgregaProductoScreen
        arguments: {
          'producto': producto,
          'origen_pantalla':
              'inventarioUnisucursal' // Para que AgregaProductoScreen sepa cómo volver
        });
    if (fueModificado == true && mounted) {
      _cargarInventario(); // Recargar si AgregaProductoScreen indicó cambios
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
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
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mi Inventario (Tienda)'),
          automaticallyImplyLeading: false,
          elevation: 2,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _cargarInventario,
              tooltip: 'Actualizar inventario',
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'products-menu');
              },
              icon: const Icon(Icons.close),
              tooltip: 'Cerrar',
            ),
          ],
        ),
        body: _isLoading ? _buildLoadingView() : _buildMainContent(),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_textLoading.isNotEmpty ? _textLoading : 'Cargando...'),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        _buildSearchField(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Text(
            'Toque un producto para editar sus detalles y cantidad.', // Texto ajustado
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: _productosFiltrados.isEmpty
              ? _buildEmptyState(_searchController.text.isNotEmpty)
              : _buildProductsList(),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    // ... (igual que antes) ...
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre, clave o código...',
          prefixIcon: const Icon(Icons.search, size: 22),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    _filtrarProductos('');
                  },
                )
              : null,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade400)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade400)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: Theme.of(context).primaryColor, width: 1.5)),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
        ),
        onChanged: _filtrarProductos,
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    // ... (igual que antes) ...
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                      isSearching
                          ? Icons.search_off_outlined
                          : Icons.inventory_2_outlined,
                      size: 80,
                      color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                      isSearching
                          ? 'No se encontraron productos'
                          : 'Aún no tienes productos en tu inventario',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700]),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                      isSearching
                          ? 'Intenta con otros términos de búsqueda.'
                          : 'Agrega productos desde la opción "Nuevo Producto".',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildProductsList() {
    // ... (igual que antes, usando _buildProductCard) ...
    return ListView.builder(
      key: UniqueKey(),
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
      itemCount: _productosFiltrados.length,
      itemBuilder: (context, index) {
        final producto = _productosFiltrados[index];
        return _buildProductCard(producto, key: ValueKey(producto.id));
      },
    );
  }

  Widget _buildProductCard(Producto producto, {Key? key}) {
    // Añadir Key
    // ... (lógica para categoría y color igual que antes) ...
    Categoria? categoriaDelProducto;
    Color colorDeCategoria = Colors.blueGrey.shade300;
    if (listaCategorias.isNotEmpty) {
      try {
        categoriaDelProducto = listaCategorias.firstWhere(
            (cat) => cat.id == producto.idCategoria,
            orElse: () => Categoria(id: 0, categoria: 'Desconocida'));
        if (listaColores.isNotEmpty && categoriaDelProducto.idColor != null) {
          final ColorCategoria? colorCat = listaColores.firstWhere(
              (color) => color.id == categoriaDelProducto?.idColor,
              orElse: () =>
                  ColorCategoria(id: 0, color: Colors.blueGrey.shade300));
          if (colorCat != null && colorCat.color != null)
            colorDeCategoria = colorCat.color!;
        }
      } catch (e) {/* Usar defaults */}
    }

    bool esPorPiezas = producto.unidad == "1";
    String cantidadMostrada =
        (producto.cantidad ?? 0).toStringAsFixed(esPorPiezas ? 0 : 3);
    String unidadTexto =
        esPorPiezas ? "pzs" : (producto.unidad == "0" ? "uds" : "");

    return Card(
      key: key,
      elevation: 2.5,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        // InkWell para que toda la tarjeta sea táctil
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navegarAEditarProducto(
            producto), // Acción principal: editar detalles
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding uniforme
          child: Row(
            children: [
              Container(
                /* ... (icono) ... */
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: colorDeCategoria.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.inventory_2_outlined,
                    color: colorDeCategoria, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                /* ... (info del producto) ... */
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(producto.producto ?? 'Producto sin nombre',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    if (categoriaDelProducto != null &&
                        categoriaDelProducto.categoria != null)
                      Text('Cat: ${categoriaDelProducto.categoria}',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                /* ... (cantidad) ... */
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(cantidadMostrada,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColorDark)),
                  if (unidadTexto.isNotEmpty)
                    Text(unidadTexto,
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[700])),
                ],
              ),
              const SizedBox(
                  width: 10), // Espacio antes del icono de "ir a editar"
              Icon(
                // Icono para indicar que se navega a editar
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Colors.grey[500],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
