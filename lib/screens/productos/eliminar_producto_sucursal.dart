// ignore_for_file: unnecessary_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/articulo_provider.dart';
import 'package:vende_facil/screens/search_screenProductos.dart';
import 'package:vende_facil/widgets/mostrar_alerta_ok.dart';
import '../../widgets/custom_dropdown_search.dart';

class EliminarProductoSucursal extends StatefulWidget {
  const EliminarProductoSucursal({super.key});

  @override
  State<EliminarProductoSucursal> createState() =>
      _EliminarProductoSucursalState();
}

class _EliminarProductoSucursalState extends State<EliminarProductoSucursal> {
  String? _selectedProduct;
  int? _selectedSucursal;
  String? cantidad;
  Producto? _producto;
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String textLoading = '';
  bool _valuePieza = true; // Variable para determinar si es pieza o no
  ArticuloProvider provider = ArticuloProvider();

  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    listaProductosSucursal.clear();
  }

  void _seleccionarSucursal(int? value) async {
    sucursalSeleccionado = listaSucursales.firstWhere(
      (sucursal) => sucursal.id == value,
      orElse: () => Sucursal(id: null),
    );

    if (sucursalSeleccionado.id == null) return;

    setState(() {
      isLoading = true;
      textLoading = 'Cargando productos de la sucursal';
    });

    Resultado resultado =
        await provider.listarProductosSucursal(sucursalSeleccionado.id!);

    setState(() {
      isLoading = false;
      textLoading = '';
    });

    if (resultado.status != 1) {
      mostrarAlerta(context, 'Error', resultado.mensaje!);
      return;
    }

    setState(() {
      _selectedSucursal = sucursalSeleccionado.id;
      _selectedProduct = null;
      _producto = null;
      cantidad = '0';
    });
  }

  void _seleccionarProducto(String? value, {bool show = true}) async {
    if (_selectedSucursal == null && show) {
      mostrarAlerta(context, 'Error', 'Selecciona una sucursal primero');
      return;
    }

    Producto producto = listaProductosSucursal.firstWhere(
      (producto) => producto.producto == value,
      orElse: () => Producto(id: null),
    );

    if (producto.id == null) return;

    setState(() {
      _selectedProduct = value;
      _producto = producto;
      cantidad = producto.disponibleInv.toString();
      _valuePieza = _producto?.unidad == "0"
          ? true
          : false; // Determinar si es pieza o fracción
      controller.clear(); // Limpiar el campo de cantidad al cambiar de producto
    });
  }

  void _quitar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_producto == null) {
      mostrarAlerta(context, 'Error',
          'Primero seleccione una sucursal y producto de la sucursal seleccionada');
      return;
    }

    // Verificar que la cantidad a retirar no sea mayor que la disponible
    double cantidadRetirar = double.parse(controller.text);
    double cantidadDisponible = double.parse(cantidad ?? '0');

    if (cantidadRetirar > cantidadDisponible) {
      mostrarAlerta(context, 'Error',
          'La cantidad a retirar no puede ser mayor que la disponible ($cantidadDisponible)');
      return;
    }

    // Mostrar confirmación antes de proceder
    bool confirmar = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Confirmar Operación',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text(
                '¿Está seguro que desea retirar ${controller.text} ${_valuePieza ? 'Kg/m' : 'piezas'} de ${_producto!.producto} de la sucursal?',
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  child: const Text('Cancelar',
                      style: TextStyle(color: Colors.grey)),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Confirmar',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmar) return;

    setState(() {
      isLoading = true;
      textLoading = 'Retirando producto de la sucursal';
    });

    Resultado resultado = await provider.inventarioSucQuitar(
        _producto!.idInv.toString(), controller.text);

    setState(() {
      isLoading = false;
      textLoading = '';
    });

    if (resultado.status != 1) {
      mostrarAlerta(context, 'Error', resultado.mensaje!);
      return;
    }

    setState(() {
      _selectedSucursal = null;
      _selectedProduct = null;
      _producto = null;
      controller.clear();
      cantidad = '0';
    });

    mostrarAlerta(context, 'Éxito', resultado.mensaje!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eliminar Producto de Sucursal'),
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
            _buildSeleccionSucursalCard(),
            const SizedBox(height: 20),
            _buildSeleccionProductoCard(),
            const SizedBox(height: 20),
            _buildCantidadCard(),
            const SizedBox(height: 32),
            _buildActionButton(),
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
              Colors.blue,
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'Sucursal origen *',
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
              onChanged: _seleccionarSucursal,
            ),
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
              Colors.green,
            ),
            const SizedBox(height: 24),
            CustomDropdownSearch(
              items: listaProductosSucursal
                  .map((producto) => producto.producto!)
                  .toList(),
              selectedItem: _selectedProduct,
              onChanged: (String? newValue) {
                _seleccionarProducto(newValue);
              },
              labelText: 'Nombre del producto *',
              emptyMessage: 'Primero seleccione una sucursal',
            ),
            const SizedBox(height: 16),
            _buildInfoField(
              labelText: 'Existencia en sucursal:',
              value: cantidad ?? '0',
              icon: Icons.shopping_bag_outlined,
              suffix: _producto != null
                  ? Text(
                      _valuePieza ? 'Kg/m' : 'Piezas',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    )
                  : null,
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
              'Cantidad a Retirar',
              Icons.remove_circle_outline,
              Colors.red,
            ),
            const SizedBox(height: 24),
            _buildFormField(
              labelText: 'Cantidad a retirar:',
              keyboardType:
                  TextInputType.numberWithOptions(decimal: _valuePieza),
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
                double cantidadDisponible = double.parse(cantidad ?? '0');
                if (double.parse(value) > cantidadDisponible) {
                  return 'La cantidad no puede ser mayor a la disponible';
                }
                return null;
              },
              suffix: _producto != null
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
    Widget? suffix,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labelText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (suffix != null) suffix,
                  ],
                ),
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
        onPressed: _quitar,
        icon: const Icon(Icons.remove_circle_outline),
        label: const Text('Retirar de Sucursal'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
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
