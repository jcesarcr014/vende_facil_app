import 'package:flutter/material.dart';
import 'package:vende_facil/models/apartado_cab_model.dart';
import 'package:vende_facil/providers/apartado_provider.dart';

class SearchAbonos extends SearchDelegate {
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  final apartados =  ApartadoProvider();
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = "",
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

@override
Widget buildResults(BuildContext context) {
  windowWidth = MediaQuery.of(context).size.width;
  windowHeight = MediaQuery.of(context).size.height;
  List<ApartadoCabecera> resultados = listaApartados
      .where((apartado) =>
          apartado.folio?.toLowerCase().contains(query.toLowerCase()) ??
          false)
      .toList();
  return ListView.builder(
    itemCount: resultados.length,
    itemBuilder: (context, index) {
      ApartadoCabecera apartado = resultados[index];
      return ListTile(
        onTap: (() {
                      apartados.detallesApartado(listaApartados[index].id!).then((value) {
                      if (value.id != 0) {
                              Navigator.pushNamed(context, 'abono_detalle',
                                  arguments: value);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(value.mensaje!),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                    });
        }),
        title: Text(
          apartado.folio ?? 'Folio no disponible',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Cliente: ${apartado.clienteId}',
        ),
      );
    },
  );
}


  @override
  Widget buildSuggestions(BuildContext context) {
    return const ListTile(
      title: Text('historial'),
    );
  }
}
