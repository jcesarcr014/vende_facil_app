// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';

class Searchproductos extends SearchDelegate {
  final articulosProvider = ArticuloProvider();
  double windowWidth = 0.0;
  double windowHeight = 0.0;
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
    List<Producto> resultados = listaProductos
        .where((producto) =>
            producto.producto?.toLowerCase().contains(query.toLowerCase()) ??
            false)
        .toList();
    // Muestra los resultad
    return ListView.builder(
      itemCount: resultados.length,
      itemBuilder: (context, index) {
        Producto producto = resultados[index]; // Obtén el producto actual

        Categoria categoria = listaCategorias.firstWhere(
            (categoria) => categoria.id == producto.idCategoria,
            orElse: () =>
                Categoria(id: resultados[index].idCategoria, categoria: ""));

        ColorCategoria color = listaColores.firstWhere(
            (color) => color.id == categoria.idColor,
            orElse: () => ColorCategoria(
                id: categoria.idColor, nombreColor: "", color: Colors.grey));
        return ListTile(
          leading: Icon(Icons.category, color: color.color),
          onTap: (() {
            articulosProvider
                .consultaProducto(resultados[index].id!)
                .then((value) {
              if (value.id != 0) {
                Navigator.pushNamed(context, 'nvo-producto', arguments: value);
              } else {
                mostrarAlerta(context, 'ERROR',
                    'Error en la consulta: ${value.producto}');
              }
            });
          }),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: windowWidth * 0.45,
                child: Text(
                  producto.producto ?? 'Nombre no disponible',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          subtitle: Text(categoria.categoria ?? 'Categoría no disponible'),
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
