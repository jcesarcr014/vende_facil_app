import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';

class AbonoDetallesScreen extends StatefulWidget {
  const AbonoDetallesScreen({Key? key}) : super(key: key);

  @override
  State<AbonoDetallesScreen> createState() => _VentaDetallesScreenState();
}

class _VentaDetallesScreenState extends State<AbonoDetallesScreen> {
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
        title: const Text('Detalles de Abono'),
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
                    'folio: ${ listaApartados[0].folio}',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'cliente: ${sesion.nombreUsuario}',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'fecha de Abono: ${listaApartados[0].fechaApartado}',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Saldo Pediente: ${ listaApartados[0].saldoPendiente}',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Descuento: ${ listaApartados[0].descuento}',
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
        rows: detalleApartado.map((detalle) => DataRow(cells: [
          DataCell(Text(detalle.productoId.toString())),
          DataCell(Text(detalle.cantidad.toString())),
          DataCell(Text(detalle.descuento.toString())),
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
