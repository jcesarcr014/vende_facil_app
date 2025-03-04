import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/apartado_provider.dart';
import 'package:vende_facil/widgets/widgets.dart';

class AbonosLiquidados extends StatefulWidget {
  const AbonosLiquidados({super.key});

  @override
  State<AbonosLiquidados> createState() => _AbonosLiquidadosState();
}

class _AbonosLiquidadosState extends State<AbonosLiquidados> {
  bool isLoading = false;
  double windowHeight = 0.0;
  String textLoading = '';
  final apartadoProvider = ApartadoProvider();
  List<ApartadoCabecera> lista = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle? subtitleStyle = Theme.of(context).textTheme.titleMedium;
    final int indiceRecibido =
        ModalRoute.of(context)?.settings.arguments as int;

    if (indiceRecibido == 1) {
      lista = listaApartadosPendientes;
    } else {
      lista = listaApartadosPagados;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text((indiceRecibido == 1)
            ? 'Apartados pendientes'
            : 'Apartados liquidados'),
      ),
      body: (isLoading)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Espere...$textLoading'),
                  SizedBox(
                    height: windowHeight * 0.01,
                  ),
                  const CircularProgressIndicator(),
                ],
              ),
            )
          : Center(
              child: lista.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Opacity(
                          opacity: 0.2,
                          child: Icon(
                            Icons.filter_alt_off,
                            size: 130,
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          'No apartados para mostrar.',
                          style: subtitleStyle,
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: lista.length,
                      itemBuilder: (context, index) {
                        var reversedIndex = lista.length - 1 - index;
                        return ListTile(
                          title: Text(lista[reversedIndex].folio!),
                          trailing: Text('\$${lista[reversedIndex].total}'),
                          subtitle: Text(
                              'Cliente: ${lista[reversedIndex].nombreCliente} \n${lista[reversedIndex].fechaApartado}'),
                          onTap: () {
                            _detalles(reversedIndex);
                          },
                        );
                      },
                    ),
            ),
    );
  }

  _detalles(int i) {
    setState(() {
      isLoading = true;
      textLoading = 'Cargando información';
    });
    apartadoProvider.detallesApartado(lista[i].id!).then((resp) {
      setState(() {
        isLoading = false;
        textLoading = '';
      });
      if (resp.status == 1) {
        Navigator.pushNamed(context, 'abono_detalle');
      } else {
        mostrarAlerta(context, 'ERROR',
            'No se pudieron cargar detalles: ${resp.mensaje}');
      }
    });
  }
}
