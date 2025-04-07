import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';

class DescuentosScreen extends StatefulWidget {
  const DescuentosScreen({super.key});

  @override
  State<DescuentosScreen> createState() => _DescuentosScreenState();
}

class _DescuentosScreenState extends State<DescuentosScreen> {
  final descuentosProvider = DescuentoProvider();
  final _busquedaController = TextEditingController();
  bool isLoading = false;
  String textLoading = '';
  List<Descuento> _descuentosFiltrados = [];

  @override
  void initState() {
    setState(() {
      textLoading = 'Cargando descuentos';
      isLoading = true;
    });
    descuentosProvider.listarDescuentos().then((value) {
      setState(() {
        _descuentosFiltrados = List.from(listaDescuentos);
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

  void _filtrarDescuentos(String query) {
    setState(() {
      _descuentosFiltrados = query.isEmpty
          ? List.from(listaDescuentos)
          : listaDescuentos
              .where((descuento) =>
                  (descuento.nombre
                          ?.toLowerCase()
                          .contains(query.toLowerCase()) ??
                      false) ||
                  (descuento.valor.toString().contains(query)))
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
          title: const Text('Descuentos'),
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, 'nvo-descuento');
          },
          icon: const Icon(Icons.add_circle),
          label: const Text('Nuevo descuento'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: isLoading ? _buildLoadingIndicator() : _buildDescuentosList(),
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

  Widget _buildDescuentosList() {
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
                    'Lista de Descuentos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_descuentosFiltrados.isEmpty) _buildEmptyState(),
                if (_descuentosFiltrados.isNotEmpty) ..._buildDescuentoCards(),
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
          hintText: 'Buscar descuento por nombre o valor',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _busquedaController.clear();
              _filtrarDescuentos('');
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: _filtrarDescuentos,
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
              isSearching ? Icons.search_off : Icons.percent,
              size: 120,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isSearching
                ? 'No se encontraron descuentos'
                : 'No hay descuentos guardados',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Intenta con otra búsqueda'
                : 'Agrega un nuevo descuento usando el botón de abajo',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDescuentoCards() {
    List<Widget> descuentoCards = [];

    for (Descuento descuento in _descuentosFiltrados) {
      descuentoCards.add(
        Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.pushNamed(context, 'nvo-descuento',
                  arguments: descuento);
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
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.percent,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          descuento.nombre ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${descuento.valor!.toStringAsFixed(2)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
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

    return descuentoCards;
  }
}
