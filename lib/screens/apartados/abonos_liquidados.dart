import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/apartado_provider.dart';
import 'package:vende_facil/widgets/widgets.dart';

class AbonosLiquidados extends StatelessWidget {
  static final apartadoProvider = ApartadoProvider();

  const AbonosLiquidados({super.key});

  @override
  Widget build(BuildContext context) {
    final TextStyle? subtitleStyle = Theme.of(context).textTheme.titleMedium;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Abonos Liquidados'),
      ),
      body: Center(
        child: apartadosPagados.isEmpty 
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Opacity(
                    opacity: 0.2,
                    child: Icon(Icons.filter_alt_off, size: 130,),
                  ),
                  const SizedBox(height: 15,),
                  Text('No hay abonos liquidados por completo.', style: subtitleStyle,),
                ],
              )
            : ListView.builder(
              itemCount: apartadosPagados.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(apartadosPagados[index].folio!),
                trailing: Text('\$${apartadosPagados[index].total}'),
                subtitle: Text('Nombre Cliente: ${listaClientesApartadosLiquidados[index].nombre} \n${DateFormat('yyyy-MM-dd').format(apartadosPagados[index].fechaPagoTotal!)}'),
                onTap: () async {
                  Resultado resultado = await apartadoProvider.detallesApartado(apartadosPagados[index].id!);
                  if(resultado.status != 1) {
                    mostrarAlerta(context, 'Error', resultado.mensaje ?? 'Intentalo mas tarde');
                    return;
                  }
                  Navigator.pushNamed(context, 'abono-liquidado-detalle');
                },
              ),
            ),
      ),
    );
  }
}
