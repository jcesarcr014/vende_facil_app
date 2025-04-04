import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/util/actualiza_venta.dart' as totales;

class VentaDetalleScreen extends StatefulWidget {
  const VentaDetalleScreen({super.key});

  @override
  State<VentaDetalleScreen> createState() => _VentaDetalleScreenState();
}

class _VentaDetalleScreenState extends State<VentaDetalleScreen> {
  bool isLoading = false;
  String textLoading = '';
  final cantidadController = TextEditingController();
  final _actualizaMontos = totales.ActualizaMontos();
  final sinDescuento = Descuento(id: 0, nombre: 'Sin descuento', valor: 0.0);

  int _descuentoId = 0;
  int _clienteId = listaClientes
      .firstWhere((cliente) => cliente.nombre == 'Público en general')
      .id!;

  bool _ventaDomicilio = false;

  @override
  void initState() {
    super.initState();

    _actualizaMontos.actualizaTotalVenta();
  }

  @override
  void dispose() {
    cantidadController.dispose();
    super.dispose();
  }

  void _actualizarEstado() {
    setState(() {
      _actualizaMontos.actualizaTotalVenta();
    });
  }

  void _removerItemTemporal(ItemVenta item) {
    setState(() {
      ventaTemporal.remove(item);
      _actualizaMontos.actualizaTotalVenta();
    });
  }

  void _mostrarDialogCantidad(ItemVenta item, Producto producto) {
    cantidadController.text = item.cantidad.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Cantidad'),
        content: TextField(
          controller: cantidadController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Cantidad'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final nuevaCantidad = double.tryParse(cantidadController.text);
              if (nuevaCantidad != null && nuevaCantidad > 0) {
                if (nuevaCantidad <= producto.disponibleInv!) {
                  setState(() {
                    item.cantidad = nuevaCantidad;
                    _actualizaMontos.actualizaTotalVenta();
                  });
                  Navigator.pop(context);
                } else {
                  mostrarAlerta(context, 'AVISO',
                      'No hay suficiente inventario. Disponibles: ${producto.disponibleInv}');
                }
              } else {
                mostrarAlerta(context, 'AVISO', 'Cantidad inválida');
              }
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _validarYProcederApartado() {
    double numArticulos = 0;

    for (ItemVenta articuloTemporal in ventaTemporal) {
      if (!articuloTemporal.apartado) {
        mostrarAlerta(context, 'ERROR',
            'Algunos artículos no pueden apartarse. Revise los productos.');
        return;
      }
      numArticulos += articuloTemporal.cantidad;
    }

    if (double.parse(listaVariables[1].valor!) < numArticulos) {
      mostrarAlerta(context, 'ERROR',
          'Supera la cantidad máxima de artículos para apartar.');
      return;
    }

    ApartadoCabecera apartado = ApartadoCabecera(
      clienteId: clienteVentaActual.id,
      subtotal: subtotalVT,
      descuentoId: _descuentoId,
      descuento: descuentoVT,
      total: totalVT,
    );

    Navigator.pushNamed(context, 'apartado', arguments: apartado);
  }

  void _procederCobro() {
    VentaCabecera venta = VentaCabecera(
      idCliente: _clienteId,
      subtotal: subtotalVT,
      idDescuento: _descuentoId,
      descuento: descuentoVT,
      total: totalVT,
      tipoVenta: _ventaDomicilio ? 1 : 0,
      nombreCliente: clienteVentaActual.nombre,
    );

    Navigator.pushNamed(context, 'venta', arguments: venta);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Venta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Ayuda'),
                  content: const Text('• Deslice un producto para eliminarlo\n'
                      '• Toque el ícono de edición para cambiar cantidad\n'
                      '• Seleccione descuentos y cliente según necesite'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Entendido'),
                    )
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProductList(),
          const SizedBox(height: 16),
          _buildSalesSummary(),
          const SizedBox(height: 16),
          _buildDiscountSection(),
          const SizedBox(height: 16),
          _buildClientSection(),
          const SizedBox(height: 16),
          _buildSaleTypeToggle(),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Productos (${ventaTemporal.length})',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ventaTemporal.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = ventaTemporal[index];
              final producto = listaProductosSucursal
                  .firstWhere((p) => p.id == item.idArticulo);

              return Dismissible(
                key: Key(item.idArticulo.toString()),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                ),
                onDismissed: (_) => _removerItemTemporal(item),
                child: ListTile(
                  title: Text('${producto.producto}'),
                  subtitle: Text(
                      'Precio: \$${item.precioPublico.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${item.cantidad}',
                          style: const TextStyle(fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _mostrarDialogCantidad(item, producto),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSalesSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryRow('Subtotal', subtotalVT),
            _buildSummaryRow('Descuento', descuentoVT),
            _buildSummaryRow('Total', totalVT, isTotal: true),
            _buildSummaryRow('Ahorro', ahorroVT),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: isTotal ? Theme.of(context).textTheme.titleMedium : null),
          Text('\$${value.toStringAsFixed(2)}',
              style: isTotal
                  ? Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)
                  : null),
        ],
      ),
    );
  }

  Widget _buildDiscountSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Descuento', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildDiscountDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountDropdown() {
    _descuentoId = sinDescuento.id!;
    List<DropdownMenuItem<int>> discountItems = [
      DropdownMenuItem(
          value: sinDescuento.id, child: Text('${sinDescuento.nombre}')),
      ...listaDescuentos.map((descuento) => DropdownMenuItem(
          value: descuento.id, child: Text(descuento.nombre ?? 'Sin nombre')))
    ];

    return DropdownButtonFormField<int>(
      value: _descuentoId,
      items: discountItems,
      onChanged: (value) {
        setState(() {
          _descuentoId = value!;
          if (value != 0) {
            descuentoVentaActual = listaDescuentos
                .firstWhere((descuento) => descuento.id == value);
          } else {
            descuentoVentaActual = sinDescuento;
            // descuentoVentaActual.id = 0;
          }
          _actualizarEstado();
        });
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildClientSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildClientDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildClientDropdown() {
    Cliente defaultClient = listaClientes
        .firstWhere((cliente) => cliente.nombre == 'Público en general');

    List<DropdownMenuItem<int>> clientItems = [
      DropdownMenuItem(
          value: defaultClient.id, child: Text('${defaultClient.nombre}')),
      ...listaClientes
          .where((cliente) => cliente.nombre != 'Público en general')
          .map((cliente) => DropdownMenuItem(
              value: cliente.id, child: Text('${cliente.nombre}')))
    ];

    return DropdownButtonFormField<int>(
      value: _clienteId,
      items: clientItems,
      onChanged: (value) {
        setState(() {
          _clienteId = value ?? defaultClient.id!;
          clienteVentaActual =
              listaClientes.firstWhere((cliente) => cliente.id == _clienteId);
          _actualizarEstado();
        });
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildSaleTypeToggle() {
    return Card(
      child: SwitchListTile(
        title: const Text('Tipo de Venta'),
        subtitle: Text(_ventaDomicilio ? 'Domicilio' : 'Tienda'),
        value: _ventaDomicilio,
        onChanged: (value) {
          setState(() {
            _ventaDomicilio = value;
            ventaDomicilio = value;
            _actualizarEstado();
          });
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: ventaTemporal.isNotEmpty ? _procederCobro : null,
          icon: const Icon(Icons.point_of_sale),
          label: Text('Cobrar \$${totalVT.toStringAsFixed(2)}'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed:
              ventaTemporal.isNotEmpty ? _validarYProcederApartado : null,
          icon: const Icon(Icons.archive),
          label: const Text('Apartar'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}
