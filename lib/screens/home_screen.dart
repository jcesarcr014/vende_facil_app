import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/screens/productos/qr_scanner_screen.dart';
import 'package:vende_facil/screens/ventas/resultados.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/util/actualiza_venta.dart' as totales;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _articulosProvider = ArticuloProvider();
  final _clientesProvider = ClienteProvider();
  final _descuentosProvider = DescuentoProvider();
  final _busquedaController = TextEditingController();
  final _actualizaMontos = totales.ActualizaMontos();

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
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _cargaInicial() async {
    setState(() {
      _textLoading = 'Actualizando lista de articulos';
      _isLoading = true;
    });

    await _articulosProvider.listarProductosSucursal(sesion.idSucursal!);
    setState(() {
      _productosFiltrados = List.from(listaProductosSucursal);
      _textLoading = 'Actualizando lista de clientes';
    });
    await _clientesProvider.listarClientes();
    setState(() {
      clienteVentaActual = listaClientes
          .firstWhere((cliente) => cliente.nombre == 'Público en general');
      _textLoading = 'Actualizando lista de descuentos';
    });
    await _descuentosProvider.listarDescuentos();
    setState(() {
      descuentoVentaActual.id = 0;
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
              : TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                esEntero ? RegExp(r'^[1-9]\d*') : RegExp(r'^\d+(\.\d{0,4})?$'))
          ],
          decoration: InputDecoration(
            labelText: 'Cantidad',
            helperText: (varEmpleadoInventario)
                ? 'Disponibles: ${producto.disponibleInv}'
                : '',
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
              if (!varAplicaInventario) {
                if (cantidad > producto.disponibleInv!) {
                  mostrarAlerta(context, "AVISO",
                      "No hay suficientes productos disponibles");
                  return;
                }
              }
              _procesarAgregarProducto(producto, cantidad);
              Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _procesarAgregarProducto(Producto producto, double cantidad) {
    bool existe = ventaTemporal.any((item) => item.idArticulo == producto.id);
    if (!existe) {
      ventaTemporal.add(ItemVenta(
          idArticulo: producto.id!,
          articulo: producto.producto!,
          cantidad: cantidad,
          precioPublico: producto.precioPublico!,
          precioMayoreo: producto.precioMayoreo!,
          precioDistribuidor: producto.precioDist!,
          precioUtilizado: producto.precioPublico!,
          idDescuento: 0,
          descuento: 0,
          subTotalItem: producto.precioPublico! * cantidad,
          totalItem: producto.precioPublico! * cantidad,
          apartado: producto.apartado == 1));
    } else {
      final index =
          ventaTemporal.indexWhere((item) => item.idArticulo == producto.id);
      ventaTemporal[index].cantidad += cantidad;
    }
    _actualizaMontos.actualizaTotalVenta();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            Navigator.pushReplacementNamed(context, 'menu');
          }
        },
        child: Focus(
          focusNode: _focusNode,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text('${sesion.sucursal}'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, 'menu'),
                ),
              ],
            ),
            body: _isLoading ? _buildLoadingView() : _buildMainContent(),
            bottomNavigationBar: _buildBottomBar(),
          ),
        ));
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_textLoading),
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
        style: TextStyle(
          color: (varEmpleadoInventario)
              ? producto.disponibleInv! > 0
                  ? Colors.green
                  : Colors.red
              : Colors.black,
        ),
      ),
      onTap: (!varAplicaInventario)
          ? producto.disponibleInv! > 0
              ? () => _agregarProducto(producto)
              : () => mostrarAlerta(
                  context, "AVISO", "No hay productos disponibles")
          : () => _agregarProducto(producto),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanQR,
          ),
          ElevatedButton(
            onPressed: ventaTemporal.isNotEmpty
                ? () async {
                    await Navigator.pushNamed(context, 'detalle-venta');
                    setState(() {});
                  }
                : null,
            child: Text('Cobrar \$${totalVT.toStringAsFixed(2)}'),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed:
                ventaTemporal.isNotEmpty ? _mostrarDialogoEliminarVenta : null,
          ),
        ],
      ),
    );
  }

  void _scanQR() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRScannerScreen()),
    );

    if (result == null) return;

    final resultados = listaProductosSucursal
        .where((producto) =>
            producto.producto?.toLowerCase().contains(result.toLowerCase()) ??
            false)
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Resultados(resultados: resultados),
      ),
    );
  }

  void _mostrarDialogoEliminarVenta() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            const Text('Eliminar Venta', style: TextStyle(color: Colors.red)),
        content: const Text('¿Estás seguro de eliminar todos los productos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ventaTemporal.clear();
              _actualizaMontos.actualizaTotalVenta();
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
