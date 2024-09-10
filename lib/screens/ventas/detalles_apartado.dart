import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

class DetallesApartadoScreen extends StatefulWidget {
  const DetallesApartadoScreen({super.key});

  @override
  State<DetallesApartadoScreen> createState() => _DetallesApartadoScreenState();
}

class _DetallesApartadoScreenState extends State<DetallesApartadoScreen> {
  final negocioProvider = NegocioProvider();

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apartado: ${apartadoSeleccionado.folio}'),
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
                  Text('Teléfono: ${listaSucursales.first.telefono}'),
                  const SizedBox(height: 5,),
                  Text('Cliente: ${apartadoSeleccionado.nombreCliente}',),
                  const SizedBox(height: 5,),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const Divider(),
                SizedBox(
                  height: 250, // Define una altura fija para la tabla
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
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
                        rows: detalleApartado
                            .map((detalle) => DataRow(cells: [
                                  DataCell(Text(detalle.producto.toString())),
                                  DataCell(Text(detalle.cantidad.toString())),
                                  DataCell(Text(detalle.descuento.toString())),
                                  DataCell(Text(detalle.total.toString())),
                                ]))
                            .toList(),
                      ),
                    ),
                  ),
                ),
                const Divider(),
                SizedBox(
                  height: 200, // Define una altura fija
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: DataTable(
                        columnSpacing: 20, // Espacio entre columnas
                        columns: const [
                          DataColumn(label: Text('Anterior',)),
                          DataColumn(label: Text('Efectivo',)),
                          DataColumn(label: Text('Tarjeta',)),
                          DataColumn(label: Text('Actual',)),
                          DataColumn(label: Text('Fecha',)),
                        ],
                        rows: listaAbonos
                            .map((abono) => DataRow(cells: [
                                  DataCell(Text(abono.saldoAnterior!.toStringAsFixed(2))),
                                  DataCell(Text(abono.cantidadEfectivo!.toStringAsFixed(2))),
                                  DataCell(Text(abono.cantidadTarjeta!.toStringAsFixed(2))),
                                  DataCell(Text(abono.saldoActual!.toStringAsFixed(2))),
                                  DataCell(Text(abono.fechaAbono.toString())),
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
                            Text('${apartadoSeleccionado.subtotal}')
                          ],
                        ),
                        const SizedBox(height: 5,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('Total: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                            Text('${apartadoSeleccionado.total}')
                          ],
                        ),
                        const SizedBox(height: 5,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('Descuento: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                            Text('${apartadoSeleccionado.descuento}')
                          ],
                        )
                      ],
                    ),
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
