import 'package:flutter/material.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/models/models.dart';
// Ya no necesitas SearchScreenProductos
import 'package:vende_facil/widgets/widgets.dart';

// El enum Filtros se mantiene igual
enum Filtros { sortAZ, sortZA, categories }

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final articulosProvider = ArticuloProvider();
  // final categoriasProvider = CategoriaProvider(); // No parece usarse directamente aquí
  final _busquedaController = TextEditingController();

  bool isLoading = true; // Iniciar en true
  String textLoading = '';

  Filtros selectedSortOrder = Filtros.categories; // Renombrado para claridad
  List<Producto> _displayedProductos = []; // Lista que se muestra en la UI

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    if (!mounted) return;
    setState(() {
      textLoading = 'Cargando productos...';
      isLoading = true;
    });

    // Asumo que listarProductos actualiza 'listaProductos' globalmente
    await articulosProvider.listarProductos();
    if (!mounted) return;

    setState(() {
      // Inicializa _displayedProductos y aplica el ordenamiento/filtrado inicial
      _applyFiltersAndSort();
      isLoading = false;
      textLoading = '';
    });
  }

  void _applyFiltersAndSort() {
    String query = _busquedaController.text.toLowerCase();
    List<Producto> tempProductos = List.from(
        listaProductos); // Trabajar con una copia de la lista original

    // 1. Filtrar por texto
    if (query.isNotEmpty) {
      tempProductos = tempProductos.where((producto) {
        final productName = producto.producto?.toLowerCase() ?? '';
        // Podrías añadir más campos al filtro si es necesario (ej. código, descripción)
        return productName.contains(query);
      }).toList();
    }

    // 2. Aplicar ordenamiento
    if (selectedSortOrder == Filtros.sortAZ) {
      tempProductos
          .sort((a, b) => (a.producto ?? '').compareTo(b.producto ?? ''));
    } else if (selectedSortOrder == Filtros.sortZA) {
      tempProductos
          .sort((a, b) => (b.producto ?? '').compareTo(a.producto ?? ''));
    } else if (selectedSortOrder == Filtros.categories) {
      // Ordenar por ID de categoría, luego por nombre de producto para consistencia dentro de la categoría
      tempProductos.sort((a, b) {
        int categoryCompare =
            (a.idCategoria ?? 0).compareTo(b.idCategoria ?? 0);
        if (categoryCompare == 0) {
          return (a.producto ?? '').compareTo(b.producto ?? '');
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

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ya no necesitas windowWidth y windowHeight si usas Layouts flexibles
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
          title: const Text('Lista de Productos'),
          elevation: 2,
          actions: [
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
            _buildFilterAndSortControls(),
            Expanded(
              child: isLoading
                  ? _buildLoadingIndicator()
                  : RefreshIndicator(
                      onRefresh: _cargarDatos,
                      child: _displayedProductos.isEmpty
                          ? _buildEmptyState(
                              _busquedaController.text.isNotEmpty)
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              itemCount: _displayedProductos.length,
                              itemBuilder: (context, index) {
                                final producto = _displayedProductos[index];
                                return _buildSingleProductoCard(producto);
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
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 1.5),
                ),
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
            initialValue: selectedSortOrder,
            onSelected: (Filtros item) {
              if (mounted) {
                setState(() {
                  selectedSortOrder = item;
                  _applyFiltersAndSort();
                });
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Filtros>>[
              const PopupMenuItem<Filtros>(
                value: Filtros.sortAZ,
                child: Text('Nombre (A-Z)'),
              ),
              const PopupMenuItem<Filtros>(
                value: Filtros.sortZA,
                child: Text('Nombre (Z-A)'),
              ),
              const PopupMenuItem<Filtros>(
                value: Filtros.categories,
                child: Text('Categoría'),
              ),
            ],
            tooltip: "Ordenar por",
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.sort, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    _getSortOrderText(selectedSortOrder).split(' ')[
                        0], // Mostrar solo la primera palabra ej. "Nombre" o "Categoría"
                    style: const TextStyle(fontSize: 14),
                  ),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            textLoading.isNotEmpty ? textLoading : 'Cargando...',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
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
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isSearching
                        ? 'No se encontraron productos'
                        : 'Aún no hay productos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSearching
                        ? 'Intenta con otros términos de búsqueda.'
                        : 'Los productos que agregues aparecerán aquí.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
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

  Widget _buildSingleProductoCard(Producto producto) {
    // Encontrar la categoría y el color
    Categoria? categoriaDelProducto;
    Color colorDeCategoria = Colors.grey; // Color por defecto

    // Asumo que 'listaCategorias' y 'listaColores' están disponibles globalmente
    // o a través de un provider si es necesario cargarlas.
    if (listaCategorias.isNotEmpty) {
      try {
        categoriaDelProducto = listaCategorias.firstWhere(
          (cat) => cat.id == producto.idCategoria,
        );
        if (listaColores.isNotEmpty) {
          final ColorCategoria? colorCat = listaColores.firstWhere(
            (color) => color.id == categoriaDelProducto?.idColor,
            orElse: () => ColorCategoria(
                id: 0, color: Colors.grey), // Manejo de orElse seguro
          );
          if (colorCat != null) {
            colorDeCategoria = colorCat.color ?? Colors.grey;
          }
        }
      } catch (e) {
        // Categoría no encontrada, se mantiene el color por defecto.
        // Podrías loggear este error si es importante: print('Error encontrando categoría/color: $e');
      }
    }

    return Card(
      elevation: 2.5,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          // Hacer onTap async
          if (!mounted) return;
          setState(() {
            textLoading = 'Consultando producto...';
            isLoading = true; // Mostrar indicador mientras se consulta
          });

          // La consulta del producto ahora se hace aquí antes de navegar
          final productoConsultado =
              await articulosProvider.consultaProducto(producto.id!);

          if (!mounted) return;
          setState(() {
            isLoading = false; // Ocultar indicador
            textLoading = '';
          });

          if (productoConsultado != null && productoConsultado.id != 0) {
            Navigator.pushNamed(context, 'nvo-producto',
                    arguments: productoConsultado)
                .then((value) {
              // Si la pantalla 'nvo-producto' puede modificar datos, recargar al volver
              if (value == true) {
                _cargarDatos();
              }
            });
          } else {
            mostrarAlerta(context, 'ERROR',
                'Error al consultar el producto: ${productoConsultado?.producto ?? "No se pudo obtener la información."}');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorDeCategoria.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2_outlined, // Icono genérico de producto
                  color: colorDeCategoria,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.producto ?? 'Producto sin nombre',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (categoriaDelProducto != null &&
                        categoriaDelProducto.categoria != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Cat: ${categoriaDelProducto.categoria}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    // Puedes añadir más detalles aquí si es necesario (ej. precio, stock)
                    // Por ejemplo:
                    // const SizedBox(height: 4),
                    // Text(
                    //   'Precio: \$${producto.precioVenta?.toStringAsFixed(2) ?? "N/A"}',
                    //   style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14, fontWeight: FontWeight.w500),
                    // ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
