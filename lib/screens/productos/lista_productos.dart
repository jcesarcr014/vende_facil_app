import 'package:flutter/material.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/widgets/widgets.dart'; // Para mostrarAlerta

// Enum Filtros se mantiene
enum Filtros { sortAZ, sortZA, categories }

class ProductosScreen extends StatefulWidget {
  const ProductosScreen(
      {super.key}); // Esta sería tu pantalla de listado para multi-sucursal

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final _articuloProvider = ArticuloProvider();
  final _busquedaController = TextEditingController();

  bool _isLoading = true;
  String _textLoading = '';
  Filtros _selectedSortOrder = Filtros.categories; // Por defecto
  List<Producto> _todosLosProductos = []; // Lista original de la API
  List<Producto> _displayedProductos = []; // Lista para la UI

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _textLoading = 'Cargando productos...';
    });

    // Para multi-sucursal o vista de almacén, llamas a la función del provider
    // que trae los productos del almacén central (ej. listarProductosGeneral o listarProductosAlmacen)
    // Asumiré que 'listarProductosGeneral' (tu 'listarProductos' original) es la correcta.
    final resultado = await _articuloProvider.listarProductosAlmacen();

    if (!mounted) return;

    if (resultado.status == 1) {
      _todosLosProductos = List.from(
          listaProductos); // Asumiendo que el provider llena 'listaProductos'
      _applyFiltersAndSort(); // Aplicar filtro y orden inicial
    } else {
      _todosLosProductos = [];
      _displayedProductos = [];
      if (mounted) {
        mostrarAlerta(context, 'Error',
            resultado.mensaje ?? 'No se pudieron cargar los productos.');
      }
    }

    setState(() {
      _isLoading = false;
      _textLoading = '';
    });
  }

  void _applyFiltersAndSort() {
    String query = _busquedaController.text.toLowerCase();
    List<Producto> tempProductos = List.from(_todosLosProductos);

    if (query.isNotEmpty) {
      tempProductos = tempProductos.where((producto) {
        final productName = producto.producto?.toLowerCase() ?? '';
        final productClave = producto.clave?.toLowerCase() ?? '';
        final productCodigo = producto.codigoBarras?.toLowerCase() ?? '';
        return productName.contains(query) ||
            productClave.contains(query) ||
            productCodigo.contains(query);
      }).toList();
    }

    if (_selectedSortOrder == Filtros.sortAZ) {
      tempProductos.sort((a, b) => (a.producto ?? '')
          .toLowerCase()
          .compareTo((b.producto ?? '').toLowerCase()));
    } else if (_selectedSortOrder == Filtros.sortZA) {
      tempProductos.sort((a, b) => (b.producto ?? '')
          .toLowerCase()
          .compareTo((a.producto ?? '').toLowerCase()));
    } else if (_selectedSortOrder == Filtros.categories) {
      tempProductos.sort((a, b) {
        int categoryCompare =
            (a.idCategoria ?? 0).compareTo(b.idCategoria ?? 0);
        if (categoryCompare == 0) {
          return (a.producto ?? '')
              .toLowerCase()
              .compareTo((b.producto ?? '').toLowerCase());
        }
        return categoryCompare;
      });
    }

    if (mounted) {
      setState(() {
        _displayedProductos = tempProductos;
      });
    }
  }

  String _getSortOrderText(Filtros filter) {
    // ... (igual que antes) ...
    switch (filter) {
      case Filtros.sortAZ:
        return 'Nombre (A-Z)';
      case Filtros.sortZA:
        return 'Nombre (Z-A)';
      case Filtros.categories:
        return 'Categoría';
      default:
        return 'Ordenar por';
    }
  }

  void _navegarAEditarProducto(Producto producto) async {
    // Navegar a AgregaProductoScreen para edición.
    // Para multi-sucursal, la 'cantidad' en AgregaProductoScreen
    // se referirá al stock del almacén central.
    final fueModificado =
        await Navigator.pushNamed(context, 'nvo-producto', arguments: {
      // Pasar argumentos como mapa si es necesario para AgregaProductoScreen
      'producto': producto,
      'origen_pantalla': 'listaProductosMulti' // O un identificador similar
    });

    if (fueModificado == true && mounted) {
      _cargarDatos(); // Recargar si hubo cambios
    }
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
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
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Catálogo de Productos'), // Título más general
          elevation: 2,
          actions: [
            IconButton(
              // Botón de refrescar
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _cargarDatos,
              tooltip: 'Actualizar lista',
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
        body: Column(
          children: [
            _buildFilterAndSortControls(), // Contiene el TextField y el PopupMenuButton
            Expanded(
              child: _isLoading
                  ? _buildLoadingIndicator()
                  : RefreshIndicator(
                      onRefresh: _cargarDatos,
                      child: _displayedProductos.isEmpty
                          ? _buildEmptyState(
                              _busquedaController.text.isNotEmpty)
                          : ListView.builder(
                              key: UniqueKey(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              itemCount: _displayedProductos.length,
                              itemBuilder: (context, index) {
                                final producto = _displayedProductos[index];
                                return _buildSingleProductoCard(producto,
                                    key: ValueKey(producto.id));
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterAndSortControls() {
    // ... (igual que la versión anterior que te di para ProductosScreen.dart) ...
    // (Contiene el TextField para búsqueda y el PopupMenuButton para ordenar)
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _busquedaController,
              decoration: InputDecoration(
                hintText: 'Buscar producto...',
                prefixIcon: const Icon(Icons.search, size: 22),
                suffixIcon: _busquedaController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _busquedaController.clear();
                          _applyFiltersAndSort();
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
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 12.0),
              ),
              onChanged: (value) => _applyFiltersAndSort(),
            ),
          ),
          const SizedBox(width: 10),
          PopupMenuButton<Filtros>(
            initialValue: _selectedSortOrder,
            onSelected: (Filtros item) {
              if (mounted) {
                setState(() {
                  _selectedSortOrder = item;
                });
                _applyFiltersAndSort();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Filtros>>[
              const PopupMenuItem<Filtros>(
                  value: Filtros.sortAZ, child: Text('Nombre (A-Z)')),
              const PopupMenuItem<Filtros>(
                  value: Filtros.sortZA, child: Text('Nombre (Z-A)')),
              const PopupMenuItem<Filtros>(
                  value: Filtros.categories, child: Text('Categoría')),
            ],
            tooltip: "Ordenar por",
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.sort, size: 20),
                  const SizedBox(width: 6),
                  Text(_getSortOrderText(_selectedSortOrder).split(' ')[0],
                      style: const TextStyle(fontSize: 14)),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    /* ... (igual que antes) ... */
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

  Widget _buildEmptyState(bool isSearching) {
    /* ... (igual que antes, pero texto para "catálogo") ... */
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
                          : Icons.style_outlined,
                      size: 80,
                      color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    isSearching
                        ? 'No se encontraron productos'
                        : 'Tu catálogo de productos está vacío',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSearching
                        ? 'Intenta con otros términos de búsqueda.'
                        : 'Agrega productos desde la opción "Nuevo Producto".',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSingleProductoCard(Producto producto, {Key? key}) {
    // ... (similar a InventarioUnicaSucScreen, pero muestra producto.cantidad (del almacén)) ...
    Categoria? categoriaDelProducto;
    Color colorDeCategoria = Colors.blueGrey.shade300; // Default
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
    // Aquí mostramos producto.cantidad, que para esta vista es la del "almacén central"
    String cantidadMostrada =
        (producto.cantidad ?? 0).toStringAsFixed(esPorPiezas ? 0 : 3);
    String unidadTexto =
        esPorPiezas ? "pzs" : (producto.unidad == "0" ? "uds" : "");

    return Card(
      key: key,
      elevation: 2.5,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        // El InkWell ahora navega a editar detalles
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navegarAEditarProducto(producto),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: colorDeCategoria.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.style_outlined,
                    color: colorDeCategoria, size: 24), // Icono de catálogo
              ),
              const SizedBox(width: 12),
              Expanded(
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
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(cantidadMostrada,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              Colors.blueGrey.shade700)), // Cantidad de almacén
                  if (unidadTexto.isNotEmpty)
                    Text(unidadTexto,
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[700])),
                  Text("en almacén",
                      style: TextStyle(
                          fontSize: 10, color: Colors.grey[500])), // Indicador
                ],
              ),
              const SizedBox(width: 10),
              Icon(Icons.edit_note_outlined,
                  size: 20, color: Colors.grey[400]), // Icono para editar
            ],
          ),
        ),
      ),
    );
  }
}
