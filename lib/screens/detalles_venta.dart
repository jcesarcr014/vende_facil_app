import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';

class VentaDetallesScreen extends StatefulWidget {
  const VentaDetallesScreen({Key? key}) : super(key: key);

  @override
  State<VentaDetallesScreen> createState() => _VentaDetallesScreenState();
}

class _VentaDetallesScreenState extends State<VentaDetallesScreen> {
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;

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
        title: const Text('Detalles de Venta'),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'folio: ${listaVentaCabecera[0].folio}',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'cliente: ${sesion.nombreUsuario}',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'fecha de compra: ${listaVentaCabecera[0].fecha_venta}',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Total: ${listaVentaCabecera[0].total}',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Descuento: ${listaVentaCabecera[0].descuento}',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const Center(
            child: Text(
              'Productos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          (isLoading)
              ? Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Espere...$textLoading'),
                        const SizedBox(
                          height: 10,
                        ),
                        const CircularProgressIndicator(),
                      ]),
                )
          : Expanded(
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: SizedBox(
      width: MediaQuery.of(context).size.width,
      child: DataTable(
        columnSpacing: 20, // Espacio entre columnas
        columns: const [
          DataColumn(label: Text('Producto')),
          DataColumn(label: Text('Cantidad')),
          DataColumn(label: Text('Descuento')),
          DataColumn(label: Text('Total')),
        ],
        rows: listaVentadetalles.map((detalle) => DataRow(cells: [
          DataCell(Text(detalle.idProd.toString())),
          DataCell(Text(detalle.cantidad.toString())),
          DataCell(Text(detalle.cantidadDescuento.toString())),
          DataCell(Text(detalle.total.toString())),
        ])).toList(),
      ),
    ),
  ),
),

        ],
      ),
    );
  }
}
