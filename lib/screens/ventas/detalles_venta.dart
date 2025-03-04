import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';

class VentaDetallesScreen extends StatelessWidget {
  const VentaDetallesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Venta: ${listaVentaCabecera2[0].folio}'),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Detalles de la sucursal
              Text(
                  'Nombre de la Sucursal: ${listaSucursales.first.nombreSucursal}'),
              const SizedBox(height: 5),
              Text(
                  'Dirección de la Sucursal: ${listaSucursales.first.direccion}'),
              const SizedBox(height: 5),
              Text('Telefono: ${listaSucursales.first.telefono}'),
              const SizedBox(height: 5),
              Text('Cliente: ${listaVentaCabecera2[0].nombreCliente}'),
              const SizedBox(height: 5),
              Text('Fecha de compra: ${listaVentaCabecera2[0].fecha_venta}'),

              const Divider(height: 20),

              // Tabla de detalles de venta
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  columns: const [
                    DataColumn(label: Text('Producto')),
                    DataColumn(label: Text('Cantidad')),
                    DataColumn(label: Text('Descuento')),
                    DataColumn(label: Text('Total')),
                  ],
                  rows: listaVentadetalles
                      .map((detalle) => DataRow(cells: [
                            DataCell(Text(detalle.nombreProducto.toString())),
                            DataCell(Text(detalle.cantidad.toString())),
                            DataCell(
                                Text(detalle.cantidadDescuento.toString())),
                            DataCell(Text(detalle.total.toString())),
                          ]))
                      .toList(),
                ),
              ),

              const Divider(height: 20),

              // Resumen de la venta
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildSummaryRow(
                      'Subtotal', '${listaVentaCabecera2.first.subtotal}'),
                  _buildSummaryRow(
                      'Descuento', '${listaVentaCabecera2.first.descuento}'),
                  _buildSummaryRow(
                      'Total', '${listaVentaCabecera2.first.total}'),
                  _buildSummaryRow(
                      'Cambio', '${listaVentaCabecera2.first.cambio}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(value)
        ],
      ),
    );
  }
}
