// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/negocio_provider.dart';

class CotizacionDetallesScreen extends StatefulWidget {
  const CotizacionDetallesScreen({Key? key}) : super(key: key);

  @override
  State<CotizacionDetallesScreen> createState() => _CotizacionDetallesScreenState();
}

class _CotizacionDetallesScreenState extends State<CotizacionDetallesScreen> {
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;

  final negocioProvider = NegocioProvider();

  @override  
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Cotizacion: ${listacotizacionCabecera[0].folio}'),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView( // Envolver en SingleChildScrollView para que sea desplazable
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nombre de la Sucursal: ${listaSucursales.first.nombreSucursal}'),
              const SizedBox(height: 5),
              Text('Dirección de la Sucursal: ${listaSucursales.first.direccion}'),
              const SizedBox(height: 5),
              Text('Teléfono: ${listaSucursales.first.telefono}'),
              const SizedBox(height: 5),
              Text('Fecha de Cotizacion: ${listacotizacionCabecera[0].fecha_cotizacion}'),
              const Divider(),
              
              // Usamos Expanded para que la tabla ocupe el espacio disponible
              SizedBox(
                height: 400, // Puedes ajustar esta altura
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Hacemos que la tabla sea desplazable horizontalmente si es necesario
                  child: DataTable(
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(label: Text('Producto')),
                      DataColumn(label: Text('Cantidad')),
                      DataColumn(label: Text('Descuento')),
                      DataColumn(label: Text('Total')),
                    ],
                    rows: listacotizaciondetalles2.map((detalle) {
                      return DataRow(cells: [
                        DataCell(Text(detalle.nombreProducto.toString())),
                        DataCell(Text(detalle.cantidad.toString())),
                        DataCell(Text(detalle.cantidadDescuento.toString())),
                        DataCell(Text(detalle.total.toString())),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Divider(),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Subtotal: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('${listacotizacionCabecera.first.subtotal}')
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Total: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('${listacotizacionCabecera.first.total}')
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Descuento: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('${listacotizacionCabecera.first.descuento}')
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
