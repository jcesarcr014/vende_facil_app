import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/articulo_provider.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/widgets/custom_dropdown_search.dart';

class AgregarProductoSucursal extends StatefulWidget {
  const AgregarProductoSucursal({super.key});

  @override
  State<AgregarProductoSucursal> createState() =>
      _AgregarProductoSucursalState();
}

class _AgregarProductoSucursalState extends State<AgregarProductoSucursal> {
  final _provider = ArticuloProvider();
  final _formKey = GlobalKey<FormState>();
  final _cantidadController = TextEditingController();

  bool _isLoading = true;
  String _textLoading = '';

  Producto? _productoSeleccionado;
  int? _selectedSucursalId;
  String _cantidadEnSucursal = '0';
  bool _productoYaExisteEnSucursal = false;

  @override
  void initState() {
    super.initState();
    _cargarProductosAlmacen();
  }

  Future<void> _cargarProductosAlmacen() async {
    setState(() {
      _isLoading = true;
      _textLoading = 'Cargando productos del almacén...';
    });
    // Llama a la función que trae la lista de productos del almacén
    final resultado = await _provider.listarProductosAlmacen();
    if (!mounted) return;
    if (resultado.status != 1) {
      mostrarAlerta(context, 'Error',
          resultado.mensaje ?? 'No se pudo cargar la lista de productos.');
    }
    setState(() => _isLoading = false);
  }

  void _onProductoSeleccionado(String? nombreProducto) {
    if (nombreProducto == null || !mounted) return;
    setState(() {
      _productoSeleccionado =
          listaProductos.firstWhere((p) => p.producto == nombreProducto);
    });

    if (_selectedSucursalId != null) {
      _actualizarStockSucursal();
    }
  }

  void _onSucursalSeleccionada(int? sucursalId) {
    if (sucursalId == null || !mounted) return;
    setState(() {
      _selectedSucursalId = sucursalId;
    });

    if (_productoSeleccionado != null) {
      _actualizarStockSucursal();
    }
  }

  Future<void> _actualizarStockSucursal() async {
    if (_selectedSucursalId == null || _productoSeleccionado == null) return;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _textLoading = 'Consultando stock en sucursal...';
    });

    final resultado =
        await _provider.listarProductosSucursal(_selectedSucursalId!);
    if (!mounted) return;

    if (resultado.status != 1) {
      mostrarAlerta(context, 'Error', resultado.mensaje!);
      setState(() => _isLoading = false);
      return;
    }

    final productoEnSucursal = listaProductosSucursal.firstWhere(
        (p) => p.id == _productoSeleccionado!.id,
        orElse: () => Producto(id: null));

    if (productoEnSucursal.id != null) {
      _productoYaExisteEnSucursal = true;
      _cantidadEnSucursal = (productoEnSucursal.disponibleInv ?? 0)
          .toStringAsFixed(productoEnSucursal.unidad == "1" ? 0 : 3);
      _productoSeleccionado!.idInv = productoEnSucursal.idInv;
    } else {
      _productoYaExisteEnSucursal = false;
      _cantidadEnSucursal = '0';
      _productoSeleccionado!.idInv = null;
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _guardarProductoSucursal() async {
    if (!_formKey.currentState!.validate()) return;
    if (_productoSeleccionado == null || _selectedSucursalId == null) {
      mostrarAlerta(
          context, 'Atención', 'Debe seleccionar un producto y una sucursal.');
      return;
    }

    final double cantidadAAgregar =
        double.tryParse(_cantidadController.text) ?? 0.0;
    if (cantidadAAgregar <= 0) {
      mostrarAlerta(
          context, 'Error', 'La cantidad a agregar debe ser mayor a 0.');
      return;
    }

    if (cantidadAAgregar > (_productoSeleccionado!.cantidad ?? 0)) {
      mostrarAlerta(context, 'Error',
          'No puedes agregar más de la existencia en almacén (${_productoSeleccionado!.cantidad}).');
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _textLoading = 'Agregando a sucursal...';
    });

    Resultado resultadoApi;

    _productoSeleccionado!.cantidadInv = cantidadAAgregar;
    if (_productoYaExisteEnSucursal) {
      resultadoApi =
          await _provider.inventarioSucAgregar(_productoSeleccionado!);
    } else {
      _productoSeleccionado!.idSucursal = _selectedSucursalId!;
      resultadoApi = await _provider.nvoInventarioSuc(_productoSeleccionado!);
    }

    if (!mounted) return;

    if (resultadoApi.status == 1) {
      mostrarAlerta(
          context, 'Éxito', resultadoApi.mensaje ?? 'Operación exitosa.');
      // Limpiar la UI para una nueva operación
      setState(() {
        _productoSeleccionado = null;
        _selectedSucursalId = null;
        _cantidadEnSucursal = '0';
        _cantidadController.clear();
      });
      // Recargar la data de fondo para que la próxima selección esté actualizada
      await _cargarProductosAlmacen();
    } else {
      setState(() {
        _isLoading = false;
        _textLoading = '';
      });
      mostrarAlerta(
          context, 'Error', resultadoApi.mensaje ?? 'No se pudo guardar.');
    }
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Producto a Sucursal'),
        automaticallyImplyLeading: false,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, 'products-menu');
            },
            icon: const Icon(Icons.close),
            tooltip: 'Cancelar',
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingIndicator() : _buildForm(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Espere... $_textLoading', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSeleccionProductoCard(),
            const SizedBox(height: 20),
            _buildSeleccionSucursalCard(),
            const SizedBox(height: 20),
            _buildCantidadCard(),
            const SizedBox(height: 32),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSeleccionProductoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Selección de Producto',
                Icons.inventory_2_outlined, Colors.blue),
            const SizedBox(height: 24),
            CustomDropdownSearch(
              items: listaProductos
                  .map((producto) => producto.producto ?? '')
                  .toList(),
              selectedItem:
                  _productoSeleccionado?.producto, // Pasar el nombre, o null
              onChanged: _onProductoSeleccionado,
              labelText: 'Nombre del producto *',
            ),
            const SizedBox(height: 16),
            _buildInfoField(
              labelText: 'Existencia en almacén:',
              value: (_productoSeleccionado?.cantidad?.toStringAsFixed(
                      _productoSeleccionado?.unidad == "1" ? 0 : 3) ??
                  '0'),
              icon: Icons.warehouse_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeleccionSucursalCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
                'Selección de Sucursal', Icons.store_outlined, Colors.green),
            const SizedBox(height: 24),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'Sucursal destino *',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                prefixIcon: const Icon(Icons.storefront_outlined, size: 20),
              ),
              initialValue: _selectedSucursalId,
              isExpanded: true,
              validator: (value) =>
                  value == null ? 'Seleccione una sucursal' : null,
              items: listaSucursales
                  .map((sucursal) => DropdownMenuItem(
                      value: sucursal.id,
                      child: Text(sucursal.nombreSucursal ?? '')))
                  .toList(),
              onChanged: _onSucursalSeleccionada,
            ),
            const SizedBox(height: 16),
            _buildInfoField(
              labelText: 'Existencia actual en sucursal:',
              value: _cantidadEnSucursal,
              icon: Icons.shopping_bag_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCantidadCard() {
    bool esPorPiezas = _productoSeleccionado?.unidad == "1";
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
                'Cantidad a Agregar', Icons.add_circle_outline, Colors.orange),
            const SizedBox(height: 24),
            _buildFormField(
              labelText: 'Cantidad a agregar:',
              keyboardType:
                  TextInputType.numberWithOptions(decimal: !esPorPiezas),
              controller: _cantidadController,
              icon: Icons.numbers_outlined,
              required: true,
              inputFormatters: [
                if (esPorPiezas)
                  FilteringTextInputFormatter.digitsOnly
                else
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La cantidad es requerida';
                }
                if (double.tryParse(value) == null) {
                  return 'Ingrese un valor numérico válido';
                }
                return null;
              },
              suffix: Text(esPorPiezas ? 'Piezas' : 'Kg/m/l',
                  style: TextStyle(color: Colors.grey[600])),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _guardarProductoSucursal,
        icon: const Icon(Icons.save_outlined),
        label: const Text('Agregar a Sucursal'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInfoField(
      {required String labelText,
      required String value,
      required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(labelText,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String labelText,
    TextInputType? keyboardType,
    required TextEditingController controller,
    required IconData icon,
    bool required = false,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: required ? '$labelText *' : labelText,
        prefixIcon: Icon(icon, size: 20),
        suffix: suffix,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(width: 1)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}
