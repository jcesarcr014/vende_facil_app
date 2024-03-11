import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';

class VentaDetallesScreen extends StatefulWidget {
  const VentaDetallesScreen({super.key});

  @override
  State<VentaDetallesScreen> createState() => _ventadsDScreenState();
}

// ignore: camel_case_types
class _ventadsDScreenState extends State<VentaDetallesScreen> {
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  @override
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
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        Text(
          'cliente: ${sesion.nombreUsuario}',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        Text(
          'fecha de compra: ${listaVentaCabecera[0].fecha_venta}',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        Text(
          'Total: ${listaVentaCabecera[0].total}',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        Text(
          'Descuento: ${listaVentaCabecera[0].descuento}',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Espere..'),
                    ],
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: listaVentadetalles.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(
                            "producto ${listaVentadetalles[index].idProd!}"),
                        subtitle: Text(
                            'Cantidad: ${listaVentadetalles[index].cantidad}'),
                        trailing:
                            Text('Total: ${listaVentadetalles[index].total}'),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
