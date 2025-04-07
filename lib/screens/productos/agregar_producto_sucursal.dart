// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/screens/search_screenProductos.dart';
import 'package:vende_facil/providers/articulo_provider.dart';
import 'package:vende_facil/widgets/widgets.dart';
import '../../widgets/custom_dropdown_search.dart';

class AgregarProductoSucursal extends StatefulWidget {
  const AgregarProductoSucursal({super.key});

  @override
  State<AgregarProductoSucursal> createState() =>
      _AgregarProductoSucursalState();
}

class _AgregarProductoSucursalState extends State<AgregarProductoSucursal> {
  String? _selectedProduct;
  Producto? _productoSeleccionado;
  int? _selectedSucursal;
  String? _cantidadSucursal;
  ArticuloProvider provider = ArticuloProvider();
  bool isLoading = false;
  bool _valuePieza = true;
  bool? existe;
  final _formKey = GlobalKey<FormState>();

  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    provider.listarProductos().then((respProd) {
      setState(() {
        isLoading = false;
      });
    });
  }

  void _setProductsSucursal(int? value) async {
    _selectedSucursal = value;
    isLoading = true;
    setState(() {});

    Sucursal sucursalSeleccionado = listaSucursales.firstWhere(
      (sucursal) => sucursal.id == value,
      orElse: () => Sucursal(),
    );

    if (sucursalSeleccionado.id == null) {
      isLoading = false;
      setState(() {});
      mostrarAlerta(context, 'Error', 'Selecciona otra sucursal');
      return;
    }

    _productoSeleccionado?.idSucursal = sucursalSeleccionado.id!;

    try {
      Resultado resultado =
          await provider.listarProductosSucursal(sucursalSeleccionado.id!);
      if (resultado.status != 1) {
        isLoading = false;
        setState(() {});
        mostrarAlerta(context, 'Error', resultado.mensaje!);
        return;
      }
      Producto producto = listaProductosSucursal.firstWhere(
          (producto) => producto.id == _productoSeleccionado!.id,
          orElse: () => Producto(id: null, producto: 'No encontrado'));

      if (producto.id == null) {
        existe = false;
        isLoading = false;
        _cantidadSucursal = '0';
        setState(() {});
        return;
      }

      _cantidadSucursal = producto.disponibleInv?.toString();

      _productoSeleccionado?.idInv = producto.idInv;
      isLoading = false;
      existe = true;
      setState(() {});
    } catch (e) {
      isLoading = false;
      setState(() {});
      mostrarAlerta(context, 'Error', e.toString());
    }
  }

  void _validarYGuardarProductoSucursal() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_productoSeleccionado == null) {
      mostrarAlerta(context, 'Error', 'Selecciona un producto');
      return;
    }

    if (_selectedSucursal == null) {
      mostrarAlerta(context, 'Error', 'Selecciona una sucursal');
      return;
    }

    if (double.parse(controller.text) <= 0) {
      mostrarAlerta(context, 'Error', 'La cantidad debe ser mayor a 0');
      return;
    }

    _guardarProductoSucursal();
  }

  void _updateCantidadSucursal() async {
    if (_selectedSucursal == null || _productoSeleccionado == null) {
      _cantidadSucursal = '0';
      setState(() {});
      return;
    }

    isLoading = true;
    setState(() {});

    try {
      Resultado resultado = await provider.listarProductosSucursal(
          listaSucursales.firstWhere((s) => s.id == _selectedSucursal).id!);

      if (resultado.status != 1) {
        isLoading = false;
        setState(() {});
        mostrarAlerta(context, 'Error', resultado.mensaje!);
        return;
      }

      Producto producto = listaProductosSucursal.firstWhere(
          (producto) => producto.id == _productoSeleccionado!.id,
          orElse: () => Producto(id: null, producto: 'No encontrado'));

      _cantidadSucursal = producto.id != null
          ? producto.disponibleInv!.toInt().toString()
          : '0';
      isLoading = false;
      setState(() {});
    } catch (e) {
      isLoading = false;
      setState(() {});
      mostrarAlerta(context, 'Error', e.toString());
    }
  }

  void _guardarProductoSucursal() async {
    if (controller.text.isEmpty || _cantidadSucursal == null) return;
    setState(() {
      isLoading = true;
      textLoading = 'Guardando producto en sucursal';
    });

    // Asigna la cantidad ingresada al producto seleccionado
    _productoSeleccionado?.cantidadInv = double.parse(controller.text);

    _selectedProduct = null;
    _selectedSucursal = null;
    _updateCantidadSucursal();

    controller.clear();
    // Si el producto no existe en la sucursal, crea un nuevo inventario
    if (existe == false) {
      Resultado resultado =
          await provider.nvoInventarioSuc(_productoSeleccionado!);
      setState(() {
        isLoading = false;
        textLoading = '';
      });

      if (resultado.status != 1) {
        mostrarAlerta(context, 'Error', resultado.mensaje!);
        return;
      }

      // Añade el producto a la lista de productos de la sucursal
      listaProductosSucursal.add(_productoSeleccionado!);
      _productoSeleccionado = null;

      mostrarAlerta(context, 'Éxito',
          'Se agregó correctamente el producto a la sucursal.');
      return;
    }

    // Si el producto ya existe en la sucursal, actualiza la cantidad
    Resultado resultado =
        await provider.inventarioSucAgregar(_productoSeleccionado!);
    setState(() {
      isLoading = false;
      textLoading = '';
    });

    if (resultado.status != 1) {
      mostrarAlerta(context, 'Error', resultado.mensaje!);
      return;
    }

    // Actualiza la lista de productos de la sucursal
    listaProductosSucursal.add(_productoSeleccionado!);
    _productoSeleccionado = null;

    mostrarAlerta(
        context, 'Éxito', 'Se agregó correctamente el producto a la sucursal.');
  }

  String textLoading = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Producto a Sucursal'),
        automaticallyImplyLeading: false,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: () =>
                showSearch(context: context, delegate: Searchproductos()),
            icon: const Icon(Icons.search),
            tooltip: 'Buscar producto',
          ),
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, 'products-menu');
            },
            icon: const Icon(Icons.close),
            tooltip: 'Cancelar',
          ),
        ],
      ),
      body: isLoading ? _buildLoadingIndicator() : _buildForm(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Espere... $textLoading',
            style: const TextStyle(fontSize: 16),
          ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              'Selección de Producto',
              Icons.inventory_2_outlined,
              Colors.blue,
            ),
            const SizedBox(height: 24),
            CustomDropdownSearch(
              items:
                  listaProductos.map((producto) => producto.producto!).toList(),
              selectedItem: _selectedProduct ?? "Selecciona un producto",
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _productoSeleccionado = listaProductos
                      .firstWhere((producto) => producto.producto == newValue);
                  _valuePieza =
                      _productoSeleccionado!.unidad == "0" ? true : false;
                  setState(() {
                    _selectedProduct = newValue;
                  });
                  _updateCantidadSucursal();
                }
              },
              labelText: 'Nombre del producto *',
            ),
            const SizedBox(height: 16),
            _buildInfoField(
              labelText: 'Existencia en almacén:',
              value: (_productoSeleccionado?.cantidad.toString() != 'null'
                      ? _productoSeleccionado?.cantidad.toString()
                      : '0') ??
                  '0',
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              'Selección de Sucursal',
              Icons.store_outlined,
              Colors.green,
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'Sucursal destino *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                prefixIcon: const Icon(Icons.storefront_outlined, size: 20),
              ),
              value: _selectedSucursal,
              isExpanded: true,
              validator: (value) {
                if (value == null) {
                  return 'Seleccione una sucursal';
                }
                return null;
              },
              items: listaSucursales
                  .map((sucursal) => DropdownMenuItem(
                        value: sucursal.id,
                        child: Text(sucursal.nombreSucursal ?? ''),
                      ))
                  .toList(),
              onChanged: _setProductsSucursal,
            ),
            const SizedBox(height: 16),
            _buildInfoField(
              labelText: 'Existencia en sucursal:',
              value: _cantidadSucursal ?? '0',
              icon: Icons.shopping_bag_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCantidadCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              'Cantidad a Agregar',
              Icons.add_circle_outline,
              Colors.orange,
            ),
            const SizedBox(height: 24),
            _buildFormField(
              labelText: 'Cantidad a agregar:',
              keyboardType:
                  TextInputType.numberWithOptions(decimal: !_valuePieza),
              controller: controller,
              icon: Icons.numbers_outlined,
              required: true,
              inputFormatters: [
                if (_valuePieza)
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}'))
                else
                  FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La cantidad es requerida';
                }
                if (double.tryParse(value) == null) {
                  return 'Ingrese un valor numérico válido';
                }
                if (double.parse(value) <= 0) {
                  return 'La cantidad debe ser mayor a 0';
                }
                return null;
              },
              suffix: _productoSeleccionado != null
                  ? Text(
                      _valuePieza ? 'Kg/m' : 'Piezas',
                      style: TextStyle(color: Colors.grey[600]),
                    )
                  : null,
            ),
          ],
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
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoField({
    required String labelText,
    required String value,
    required IconData icon,
  }) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                labelText,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
          borderSide: const BorderSide(width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _validarYGuardarProductoSucursal,
        icon: const Icon(Icons.save_outlined),
        label: const Text('Agregar a Sucursal'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
