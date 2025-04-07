import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/widgets/widgets.dart';

class HomeCotizarScreen extends StatefulWidget {
  const HomeCotizarScreen({super.key});

  @override
  State<HomeCotizarScreen> createState() => _HomeCotizarScreenState();
}

class _HomeCotizarScreenState extends State<HomeCotizarScreen> {
  final _articulosProvider = ArticuloProvider();
  final _categoriasProvider = CategoriaProvider();
  final _descuentoProvider = DescuentoProvider();
  final _clienteProvider = ClienteProvider();
  final _busquedaController = TextEditingController();

  List<Producto> _productosFiltrados = [];
  bool _isLoading = false;
  String _textLoading = '';

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _cargaInicial();

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
    _busquedaController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _cargaInicial() async {
    _actualizaTotalTemporal();

    setState(() {
      _textLoading = 'Actualizando listado de productos';
      _isLoading = true;
    });

    await _articulosProvider.listarProductosSucursal(sesion.idSucursal!);
    setState(() {
      _productosFiltrados = List.from(listaProductosSucursal);
      _textLoading = 'Cargando descuentos';
    });

    await _descuentoProvider.listarDescuentos();
    setState(() {
      _textLoading = 'Cargando clientes';
    });

    await _clienteProvider.listarClientes();
    setState(() {
      _textLoading = '';
      _isLoading = false;
    });
  }

  void _filtrarProductos(String query) {
    setState(() {
      _productosFiltrados = query.isEmpty
          ? List.from(listaProductosSucursal)
          : listaProductosSucursal
              .where((producto) => producto.producto!
                  .toLowerCase()
                  .contains(query.toLowerCase()))
              .toList();
    });
  }

  void _agregarProducto(Producto producto) {
    _mostrarDialogoCantidad(producto);
  }

  void _mostrarDialogoCantidad(Producto producto) {
    final cantidadController = TextEditingController(text: '1');
    final esEntero = producto.unidad == '1';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar ${producto.producto}'),
        content: TextField(
          controller: cantidadController,
          autofocus: true,
          keyboardType: esEntero
              ? TextInputType.number
              : const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                esEntero ? RegExp(r'^[1-9]\d*') : RegExp(r'^\d+(\.\d{0,4})?$'))
          ],
          decoration: const InputDecoration(
            labelText: 'Cantidad',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final cantidad = double.tryParse(cantidadController.text) ?? 0;
              if (cantidad <= 0) {
                mostrarAlerta(context, "AVISO", "Cantidad inválida");
                return;
              }
              _agregaProductoVenta(producto, cantidad);
              Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _agregaProductoVenta(Producto producto, double cantidad) {
    bool existe = false;

    if (producto.unidad == "1") {
      for (ItemVenta item in cotizarTemporal) {
        if (item.idArticulo == producto.id) {
          existe = true;
          item.cantidad += cantidad;
          item.subTotalItem = item.precioPublico * item.cantidad;
          item.totalItem = item.subTotalItem - item.descuento;
        }
      }
      if (!existe) {
        cotizarTemporal.add(ItemVenta(
            idArticulo: producto.id!,
            articulo: producto.producto!,
            cantidad: cantidad,
            precioPublico: producto.precioPublico!,
            precioMayoreo: producto.precioMayoreo!,
            precioDistribuidor: producto.precioDist!,
            precioUtilizado: producto.precioPublico!,
            idDescuento: 0,
            descuento: 0,
            subTotalItem: producto.precioPublico!,
            totalItem: producto.precioPublico!,
            apartado: producto.apartado == 1));
      }
    } else if (producto.unidad == "0") {
      for (ItemVenta item in cotizarTemporal) {
        if (item.idArticulo == producto.id) {
          existe = true;
          item.cantidad += cantidad;
          item.subTotalItem = item.precioPublico * cantidad;
          item.totalItem = item.subTotalItem - item.descuento;
        }
      }
      if (!existe) {
        cotizarTemporal.add(ItemVenta(
            idArticulo: producto.id!,
            articulo: producto.producto!,
            cantidad: cantidad,
            precioPublico: producto.precioPublico!,
            precioDistribuidor: producto.precioDist!,
            precioMayoreo: producto.precioMayoreo!,
            precioUtilizado: producto.precioPublico!,
            idDescuento: 0,
            descuento: 0,
            subTotalItem: producto.precioPublico!,
            totalItem: producto.precioPublico! * cantidad,
            apartado: producto.apartado == 1));
      }
    }

    _actualizaTotalTemporal();
  }

  void _actualizaTotalTemporal() {
    totalCotizacionTemporal = 0;
    for (ItemVenta item in cotizarTemporal) {
      totalCotizacionTemporal += item.cantidad * item.precioPublico;
      item.subTotalItem = item.cantidad * item.precioPublico;
      item.totalItem = item.cantidad * item.precioPublico;
    }
    setState(() {});
  }

  void _mostrarDialogoEliminarCotizacion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cotización',
            style: TextStyle(color: Colors.red)),
        content: const Text(
            '¿Desea eliminar todos los productos de la cotización? Esta acción no podrá revertirse.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              cotizarTemporal.clear();
              totalCotizacionTemporal = 0.0;
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Focus(
        focusNode: _focusNode,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Cotizar productos'),
            automaticallyImplyLeading: true,
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
        _buildSearchBar(),
        Expanded(
          child: _productosFiltrados.isEmpty
              ? _buildEmptyState()
              : _buildProductList(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _busquedaController,
        decoration: InputDecoration(
          hintText: 'Buscar producto',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _busquedaController.clear();
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

  Widget _buildProductList() {
    return ListView.builder(
      itemCount: _productosFiltrados.length,
      itemBuilder: (context, index) {
        final producto = _productosFiltrados[index];
        return _buildProductListTile(producto);
      },
    );
  }

  Widget _buildProductListTile(Producto producto) {
    final categoria = listaCategorias.firstWhere(
        (cat) => cat.id == producto.idCategoria,
        orElse: () => Categoria(categoria: 'Sin categoría'));

    final color = listaColores.firstWhere((c) => c.id == categoria.idColor,
        orElse: () => ColorCategoria(color: Colors.grey));

    return ListTile(
      leading: Icon(Icons.category, color: color.color),
      title: Text(
        producto.producto!,
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(categoria.categoria!),
      trailing: Text(
        '\$${producto.precioPublico?.toStringAsFixed(2) ?? '0.00'}',
      ),
      onTap: () => _agregarProducto(producto),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.filter_alt_off, size: 100, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No se encontraron productos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
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
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: cotizarTemporal.isNotEmpty
                  ? _mostrarDialogoEliminarCotizacion
                  : null,
              tooltip: 'Eliminar cotización',
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: cotizarTemporal.isNotEmpty
                    ? () {
                        Navigator.pushNamed(context, 'DetalleCotizar');
                        setState(() {});
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                    'Cotizar \$${totalCotizacionTemporal.toStringAsFixed(2)}'),
              ),
            ),
            const SizedBox(width: 48), // Placeholder para equilibrar el diseño
          ],
        ),
      ),
    );
  }
}
