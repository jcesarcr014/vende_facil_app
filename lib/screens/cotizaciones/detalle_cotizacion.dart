import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/negocio_provider.dart';

class CotizacionDetallesScreen extends StatefulWidget {
  // ignore: use_super_parameters
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nombre de la Sucursal: ${listaSucursales.first.nombreSucursal}'),
                  const SizedBox(height: 5,),
                  Text('Dirección de la Sucursal: ${listaSucursales.first.direccion}'),
                  const SizedBox(height: 5,),
                  Text('Telefono: ${listaSucursales.first.telefono}'),
                  const SizedBox(height: 5,),
                  // // Text('Cliente: ${listacotizacionCabecera[0].nombreCliente}',),
                  const SizedBox(height: 5,),
                  Text('Fecha de Cotizacion: ${listacotizacionCabecera[0].fecha_cotizacion}'),
                ],
              ),
            ),
          ),
          Expanded(
                  child: Column(
                    children: [
                      const Divider(),
                      SizedBox(
                        height: 400, // Define una altura fija
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
                          padding: const EdgeInsets.only(right: 25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Divider(),
                              const SizedBox(height: 25,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text('Subtotal: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                  Text('${listaVentaCabecera2.first.subtotal}')
                                ],
                              ),
                              const SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text('Total: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                  Text('${listaVentaCabecera2.first.total}')
                                ],
                              ),
                              const SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
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
