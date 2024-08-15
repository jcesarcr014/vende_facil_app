import 'package:flutter/material.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/widgets/mostrar_alerta_ok.dart';

class Search extends SearchDelegate {
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
      onPressed: () => Navigator.pushReplacementNamed(context, 'home'),
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
            if (resultados[index].unidad == "0") {
            } else {
              _agregaProductoVenta(resultados[index], 1, context);
            }
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

  _agregaProductoVenta(Producto producto, cantidad, BuildContext context) {
    bool existe = false;
    if (producto.unidad == "1") {
      for (ItemVenta item in ventaTemporal) {
        if (item.idArticulo == producto.id) {
          existe = true;
          item.cantidad++;
          item.subTotalItem = item.precio * item.cantidad;
          item.totalItem = item.subTotalItem - item.descuento;
        }
      }
      if (!existe) {
        ventaTemporal.add(ItemVenta(
            idArticulo: producto.id!,
            cantidad: 1,
            precio: producto.precioPublico!,
            idDescuento: 0,
            descuento: 0,
            subTotalItem: producto.precioPublico!,
            totalItem: producto.precioPublico!,
            apartado: (producto.apartado == 1) ? true : false));
      }
      _actualizaTotalTemporal();
      Navigator.pushReplacementNamed(context, 'home');
      mostrarAlerta(context, '', 'Producto añadido');
    } else {
      if (producto.unidad == "0") {
        for (ItemVenta item in ventaTemporal) {
          if (item.idArticulo == producto.id) {
            existe = true;
            item.cantidad++;
            item.subTotalItem = item.precio * cantidad;
            item.totalItem = item.subTotalItem - item.descuento;
          }
        }
        if (!existe) {
          ventaTemporal.add(ItemVenta(
              idArticulo: producto.id!,
              cantidad: cantidad,
              precio: producto.precioPublico!,
              idDescuento: 0,
              descuento: 0,
              subTotalItem: producto.precioPublico!,
              totalItem: producto.precioPublico! * cantidad,
              apartado: (producto.apartado == 1) ? true : false));
        }
        _actualizaTotalTemporal();
        mostrarAlerta(context, '', 'Producto añadido');
        Navigator.pushReplacementNamed(context, 'home');
      } else {}
      _actualizaTotalTemporal();
    }
  }

  _actualizaTotalTemporal() {
    totalVentaTemporal = 0;
    for (ItemVenta item in ventaTemporal) {
      totalVentaTemporal += item.totalItem;
    }
  }
}
