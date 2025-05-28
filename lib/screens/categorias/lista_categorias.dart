import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';

class CategoriasScreens extends StatefulWidget {
  const CategoriasScreens({super.key});

  @override
  State<CategoriasScreens> createState() => _CategoriasScreensState();
}

class _CategoriasScreensState extends State<CategoriasScreens> {
  final categoriasProvider = CategoriaProvider();
  final _busquedaController = TextEditingController();
  bool isLoading = false;
  String textLoading = '';
  List<Categoria> _categoriasFiltradas = [];

  @override
  void initState() {
    setState(() {
      textLoading = 'Cargando categorías';
      isLoading = true;
    });
    categoriasProvider.listarCategorias().then((value) {
      setState(() {
        _categoriasFiltradas = List.from(listaCategorias);
        textLoading = '';
        isLoading = false;
      });
      if (value.status != 1) {
        Navigator.pop(context);
        mostrarAlerta(context, 'ERROR', value.mensaje!);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  void _filtrarCategorias(String query) {
    setState(() {
      _categoriasFiltradas = query.isEmpty
          ? List.from(listaCategorias)
          : listaCategorias
              .where((categoria) => (categoria.categoria
                      ?.toLowerCase()
                      .contains(query.toLowerCase()) ??
                  false))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, 'menu');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categorías'),
          automaticallyImplyLeading: false,
          elevation: 2,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'menu');
              },
              icon: const Icon(Icons.home),
              tooltip: 'Ir al menú principal',
            ),
          ],
        ),
        floatingActionButton: sesion.tipoUsuario == 'P'
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pushNamed(context, 'nva-categoria');
                },
                icon: const Icon(Icons.add_circle),
                label: const Text('Nueva categoría'),
                backgroundColor: Theme.of(context).primaryColor,
              )
            : null,
        body: isLoading ? _buildLoadingIndicator() : _buildCategoriasList(),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Espere... $textLoading',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildCategoriasList() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 16.0),
                  child: Text(
                    'Lista de Categorías',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_categoriasFiltradas.isEmpty) _buildEmptyState(),
                if (_categoriasFiltradas.isNotEmpty) ..._buildCategoriaCards(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _busquedaController,
        decoration: InputDecoration(
          hintText: 'Buscar categoría por nombre',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _busquedaController.clear();
              _filtrarCategorias('');
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: _filtrarCategorias,
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool isSearching = _busquedaController.text.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Opacity(
            opacity: 0.2,
            child: Icon(
              isSearching ? Icons.search_off : Icons.category,
              size: 120,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isSearching
                ? 'No se encontraron categorías'
                : 'No hay categorías guardadas',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Intenta con otra búsqueda'
                : sesion.tipoUsuario == 'P'
                    ? 'Agrega una nueva categoría usando el botón de abajo'
                    : 'No hay categorías disponibles en este momento',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoriaCards() {
    List<Widget> categoriaCards = [];

    for (Categoria categoria in _categoriasFiltradas) {
      // Buscar el color asociado con esta categoría
      Color colorCategoria = Colors.grey; // Color por defecto
      for (ColorCategoria color in listaColores) {
        if (color.id == categoria.idColor) {
          colorCategoria = color.color!;
          break;
        }
      }

      categoriaCards.add(
        Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (sesion.tipoUsuario == 'P') {
                Navigator.pushNamed(context, 'nva-categoria',
                    arguments: categoria);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorCategoria.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.category,
                          color: colorCategoria,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          categoria.categoria ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: colorCategoria,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      if (sesion.tipoUsuario == 'P') const SizedBox(width: 8),
                      if (sesion.tipoUsuario == 'P')
                        const Icon(
                          Icons.edit,
                          size: 18,
                          color: Colors.grey,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return categoriaCards;
  }
}
