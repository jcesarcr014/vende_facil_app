import 'package:flutter/material.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/screens/search_screenProductos.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

enum Filtros { sortAZ, sortZA, categories }

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final articulosProvider = ArticuloProvider();
  final categoriasProvider = CategoriaProvider();
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;

  Filtros selectedFilter = Filtros.categories;
  List<Producto> _filteredProductos = [];
  bool isExpanded = false;

  @override
  void initState() {
    setState(() {
      textLoading = 'Leyendo articulos';
      isLoading = true;
    });
    articulosProvider.listarProductos().then((respProd) {
      setState(() {
        textLoading = '';
        isLoading = false;
        _filteredProductos = listaProductos;
      });
    });
    super.initState();
  }

  void _applyFilter() {
    setState(() {
      _filteredProductos = List.from(listaProductos);
      isExpanded = false;

      if (selectedFilter == Filtros.sortAZ) {
        // Ordenar los productos de A-Z por su nombre
        _filteredProductos.sort((a, b) => a.producto!.compareTo(b.producto!));
      } else if (selectedFilter == Filtros.sortZA) {
        // Ordenar los productos de Z-A por su nombre
        _filteredProductos.sort((a, b) => b.producto!.compareTo(a.producto!));
      } else if (selectedFilter == Filtros.categories) {
        _filteredProductos
            .sort((a, b) => a.idCategoria!.compareTo(b.idCategoria!));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      onPopInvoked: (didpop) {
        if (!didpop) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: const Text('Lista de productos'),
          actions: [
            IconButton(
                onPressed: () {
                  showSearch(context: context, delegate: Searchproductos());
                },
                icon: const Icon(Icons.search)),
          ],
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
                    ]),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: windowHeight * 0.02,
                    ),
                    ExpansionTile(
                      key: UniqueKey(),
                      title: const Text('Ordenar'),
                      initiallyExpanded: isExpanded,
                      subtitle: const Text(
                          'Selecciona una forma para ordenar tus productos'),
                      children: [
                        RadioListTile(
                          title: const Text('Nombre de A-Z'),
                          subtitle: const Text(
                              'Ordenara tus productos desde la letra "A" hasta la letra "Z"'),
                          value: Filtros.sortAZ,
                          groupValue: selectedFilter,
                          onChanged: (value) => setState(() {
                            selectedFilter = Filtros.sortAZ;
                            _applyFilter();
                          }),
                        ),
                        RadioListTile(
                          title: const Text('Nombre de Z-A'),
                          subtitle: const Text(
                              'Ordenara tus productos desde la letra "Z" hasta la letra "A"'),
                          value: Filtros.sortZA,
                          groupValue: selectedFilter,
                          onChanged: (value) => setState(() {
                            selectedFilter = Filtros.sortZA;
                            _applyFilter();
                          }),
                        ),
                        RadioListTile(
                          title: const Text('Categorias'),
                          subtitle: const Text(
                              'Ordenara tus productos de acuerdo a tus categorias'),
                          value: Filtros.categories,
                          groupValue: selectedFilter,
                          onChanged: (value) => setState(() {
                            selectedFilter = Filtros.categories;
                            _applyFilter();
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Column(children: _productos())
                  ],
                ),
              ),
      ),
    );
  }

  _productos() {
    List<Widget> listaProd = [];
    if (_filteredProductos.isNotEmpty) {
      for (Producto producto in _filteredProductos) {
        for (Categoria categoria in listaCategorias) {
          if (producto.idCategoria == categoria.id) {
            final ColorCategoria color = listaColores.firstWhere(
                (color) => color.id == categoria.idColor,
                orElse: () => ColorCategoria(
                    id: categoria.idColor,
                    color: Colors.grey) // Color por defecto
                );

            listaProd.add(ListTile(
              leading: Icon(
                Icons.category,
                color: color
                    .color, // Asegúrate de que este valor siempre tenga un color válido
              ),
              onTap: (() {
                setState(() {
                  textLoading = 'Leyendo producto';
                  isLoading = true;
                });

                articulosProvider.consultaProducto(producto.id!).then((value) {
                  setState(() {
                    textLoading = '';
                    isLoading = false;
                  });
                  if (value.id != 0) {
                    Navigator.pushNamed(context, 'nvo-producto',
                        arguments: value);
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
                      producto.producto!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              subtitle: Text(categoria.categoria!),
            ));
          }
        }
      }
    } else {
      final TextTheme textTheme = Theme.of(context).textTheme;

      listaProd.add(Center(
        child: Column(
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
              'No hay productos guardados.',
              style: textTheme.titleMedium,
            )
          ],
        ),
      ));
    }

    return listaProd;
  }
}
