import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/negocio_provider.dart';

class VentaDetallesScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const VentaDetallesScreen({Key? key}) : super(key: key);

  @override
  State<VentaDetallesScreen> createState() => _VentaDetallesScreenState();
}

class _VentaDetallesScreenState extends State<VentaDetallesScreen> {
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;

  final negocioProvider = NegocioProvider();

  @override  
  void initState() {
    _loadData();
    super.initState();
  }

  void _loadData() async {
    await negocioProvider.getlistaSucursales();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Venta: ${listaVentaCabecera2[0].folio}'),
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
                  const Center(
                    child: Text('Datos de la Sucursal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                  ),
                  const Divider(),
                  Text('Nombre de la Sucursal: ${listaSucursales.first.nombreSucursal}'),
                  const SizedBox(height: 5,),
                  Text('Dirección de la Sucursal: ${listaSucursales.first.direccion}'),
                  const SizedBox(height: 5,),
                  Text('Telefono: ${listaSucursales.first.telefono}'),
                  const SizedBox(height: 5,),
                  Text('Cliente: ${listaVentaCabecera2[0].nombreCliente}',),

                  const SizedBox(height: 15,),

                  const Center(
                    child: Text('Detalles de la Venta', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                  ),
                  const Divider(),
                  Text('Fecha de compra: ${listaVentaCabecera2[0].fecha_venta}'),
                ],
              ),
            ),
          ),
          const Center(
            child: Text('Productos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 350, // Define una altura fija
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
                              rows: listaVentadetalles
                                  .map((detalle) => DataRow(cells: [
                                        DataCell(Text(detalle.nombreProducto.toString())),
                                        DataCell(Text(detalle.cantidad.toString())),
                                        DataCell(Text(detalle.cantidadDescuento.toString())),
                                        DataCell(Text(detalle.total.toString())),
                                      ]))
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('Subtotal: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                  Text('${listaVentaCabecera2.first.subtotal}')
                                ],
                              ),
                              const SizedBox(height: 5,),
                              Row(
                                children: [
                                  const Text('Total: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                  Text('${listaVentaCabecera2.first.total}')
                                ],
                              ),
                              const SizedBox(height: 5,),
                              Row(
                                children: [
                                  const Text('Descuento: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                  Text('${listaVentaCabecera2.first.descuento}')
                                ],
                              )
                          ],),
                        ),
                      )
                    ],
                  ),
                ),

        ],
      ),
    );
  }
}
