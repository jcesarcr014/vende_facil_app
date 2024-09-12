import 'package:flutter/material.dart';
import 'package:vende_facil/models/abono_model.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/models/sucursales_model.dart';

class DetallesAbonoScreen extends StatelessWidget {
  const DetallesAbonoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Abono: ${abonoSeleccionado.fechaAbono}'),
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
                  const SizedBox(height: 20,),
                ],
              ),
            ),
          ),
          // Tabla de 2 columnas y 3 filas usando DataTable
          Expanded(
            child: Column(
              children: [
                const Divider(),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Fecha')),
                      DataColumn(label: Text('Efectivo')),
                      DataColumn(label: Text('Tarjeta'))
                    ],
                    rows: [
                      DataRow(cells: [
                        DataCell(Text(abonoSeleccionado.fechaAbono ?? 'Desconocido')),
                        DataCell(Text(abonoSeleccionado.cantidadEfectivo.toString())),
                        DataCell(Text(abonoSeleccionado.cantidadTarjeta.toString()))
                      ])
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
