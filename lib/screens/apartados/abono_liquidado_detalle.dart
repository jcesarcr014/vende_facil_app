import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vende_facil/providers/apartado_provider.dart';
import 'package:vende_facil/widgets/widgets.dart';
import '../../models/models.dart';

class AbonoLiquidadoDetalle extends StatelessWidget {
  static final ApartadoProvider provider = ApartadoProvider();

  const AbonoLiquidadoDetalle({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    TextStyle? style = const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles Abono Liquidado'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Padding(
              padding: const EdgeInsets.only(left: 20, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Folio: ${listaApartados2[0].folio}', style: style,),
                  Text('Cliente: ${listaApartados2[0].nombreCliente}', style: style,),
                  Text('Fecha de Abono: ${listaApartados2[0].fechaPagoTotal}', style: style,),
                  Text('Saldo Pediente: ${listaApartados2[0].saldoPendiente}', style: style,),
                  Text('Descuento: ${listaApartados2[0].descuento}', style: style),
                  Text('Total: \$${listaApartados2[0].total}', style: style,),
                ],
              ),
            ),
            
            const SizedBox(height: 15,),
            const Divider(),
            const SizedBox(height: 15,),

            const Center(
              child: Text('Productos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 15,
                columns: const [
                  DataColumn(label: Text('Producto')),
                  DataColumn(label: Text('Cantidad')),
                  DataColumn(label: Text('Descuento')),
                  DataColumn(label: Text('Subtotal')),
                  DataColumn(label: Text('Total')),
                ],
                rows: detalleApartado.map(
                  (detalle) => DataRow(cells: [
                    DataCell(Center(child: Text('${detalle.producto}'))),
                    DataCell(Center(child: Text('${detalle.cantidad}'))),
                    DataCell(Center(child: Text('${detalle.descuento}'))),
                    DataCell(Center(child: Text('${detalle.subtotal}'))),
                    DataCell(Center(child: Text('${detalle.total}')))
                  ]) 
                ).toList()
              ),
            ),

            const SizedBox(height: 15,),
            const Divider(),
            const SizedBox(height: 15,),

            const Center(
              child: Text('Abonos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            ),
            
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 12,
                columns: const [
                  DataColumn(label: Text('Fecha')),
                  DataColumn(label: Text('Saldo Anterior')),
                  DataColumn(label: Text('Abonado')),
                  DataColumn(label: Text('Saldo Actual')),
                
                ],
                rows: listaAbonos.map(
                  (abono) => DataRow(cells: [
                    DataCell(Center(child: Text(DateFormat('yyyy-MM-dd').format(DateTime.parse(abono.fechaAbono!))))),
                    DataCell(Center(child: Text('${abono.saldoAnterior}'))),
                    DataCell(Center(child: Text('\$${(abono.cantidadEfectivo! + abono.cantidadTarjeta!).toString()}'))),
                    DataCell(Center(child: Text('${abono.saldoActual}'))),
                  ]) 
                ).toList()
              ),
            ),

            SizedBox(height: screenHeight * 0.1,),

            Center(
              child: SizedBox(
                height: screenHeight * 0.1,
                child: ElevatedButton(
                  onPressed: () async {
                    final resultado = await provider.entregarProducto(listaApartados2[0].id!);
                    if(resultado.status == 0) {
                      mostrarAlerta(context, 'Error', resultado.mensaje!);
                      return;
                    }
                    Navigator.pop(context);
                    Navigator.pop(context);
                    mostrarAlerta(context, 'Exitoso', resultado.mensaje ?? 'Producto Entregado Correctamente');
                  }, 
                  child: const Text('Entregar producto(s)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}