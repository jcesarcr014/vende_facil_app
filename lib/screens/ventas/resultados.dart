import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/widgets/mostrar_alerta_ok.dart';

class Resultados extends StatelessWidget {
  final List<Producto> resultados;

  const Resultados({super.key, required this.resultados});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona un producto'),
      ),
      body: ListView.builder(
        itemCount: resultados.length,
        itemBuilder: (context, index) {
          Producto producto = resultados[index];

          // Buscamos la categoría y color para el ícono
          Categoria categoria = listaCategorias.firstWhere(
              (categoria) => categoria.id == producto.idCategoria,
              orElse: () => Categoria(
                  id: producto.idCategoria, categoria: "Sin categoría"));

          ColorCategoria color = listaColores.firstWhere(
              (color) => color.id == categoria.idColor,
              orElse: () => ColorCategoria(
                  id: categoria.idColor, nombreColor: "", color: Colors.grey));

          return ListTile(
            leading: Icon(Icons.category, color: color.color),
            title: SizedBox(
              width: screenWidth * 0.45,
              child: Text(
                producto.producto ?? 'Nombre no disponible',
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            subtitle: Text(categoria.categoria ?? 'Categoría no disponible'),
            trailing: Text(
                '\$${producto.precioPublico?.toStringAsFixed(2) ?? '0.00'}'),
            onTap: () {
              // Validamos rápido si hay inventario antes de mandarlo de regreso
              if (!varAplicaInventario || (producto.disponibleInv ?? 0) > 0) {
                // MAGIA: Simplemente devolvemos el producto a la pantalla anterior
                Navigator.pop(context, producto);
              } else {
                mostrarAlerta(
                    context, "AVISO", "Producto agotado en inventario");
              }
            },
          );
        },
      ),
    );
  }
}
