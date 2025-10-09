import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart'; // Asegúrate que listaEmpleados y empleadoSeleccionado estén aquí
import 'package:vende_facil/models/usuario_model.dart'; // Asegúrate que la clase Usuario esté aquí
import 'package:vende_facil/providers/providers.dart'; // Asegúrate que UsuarioProvider esté aquí
import 'package:vende_facil/widgets/widgets.dart'; // Asegúrate que mostrarAlerta esté aquí

class ListaEmpleadosScreen extends StatefulWidget {
  const ListaEmpleadosScreen({super.key});

  @override
  State<ListaEmpleadosScreen> createState() => _ListaEmpleadosScreenState();
}

class _ListaEmpleadosScreenState extends State<ListaEmpleadosScreen> {
  final usuarioProvider = UsuarioProvider();
  final _busquedaController = TextEditingController();
  bool isLoading = true; // Inicia en true
  String textLoading = '';
  List<Usuario> _empleadosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    if (!mounted) return;
    setState(() {
      textLoading = 'Cargando empleados...';
      isLoading = true;
    });

    final resp = await usuarioProvider.obtenerEmpleados();
    if (!mounted) return;

    if (resp.status == 1) {
      setState(() {
        // Usamos 'listaEmpleados' (la que es llenada por el provider)
        _empleadosFiltrados = List.from(listaEmpleados);
        isLoading = false;
        textLoading = '';
      });
    } else {
      setState(() {
        isLoading = false;
        textLoading = '';
        _empleadosFiltrados = []; // Limpiar en caso de error
      });
      // Evitamos el Navigator.pop(context) si esta es la pantalla que debe mostrar el error.
      mostrarAlerta(
          context, 'ERROR', resp.mensaje ?? 'Error al cargar empleados.');
    }
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  void _filtrarEmpleados(String query) {
    setState(() {
      _empleadosFiltrados = query.isEmpty
          ? List.from(listaEmpleados) // Fuente original de datos
          : listaEmpleados // Fuente original de datos
              .where((empleado) =>
                      (empleado.nombre
                              ?.toLowerCase()
                              .contains(query.toLowerCase()) ??
                          false) ||
                      (empleado.email
                              ?.toLowerCase()
                              .contains(query.toLowerCase()) ??
                          false)
                  // Puedes añadir más campos de búsqueda si es necesario, ej. puesto, teléfono, etc.
                  )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // No necesitas windowWidth y windowHeight si usas Paddings y Expanded bien.
    return PopScope(
      canPop: false, // Para forzar el uso del botón de acción en AppBar
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, 'menu-negocio');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Empleados'),
          automaticallyImplyLeading:
              false, // Desactivado para usar el PopScope y el action button
          elevation: 2,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'menu-negocio');
              },
              icon: const Icon(Icons.close), // Icono de cerrar o "cancelar"
              tooltip: 'Volver', // Tooltip descriptivo
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // Limpiar el empleado seleccionado si tienes una variable global para ello antes de ir a "nuevo"
            // empleadoSeleccionado = null; o empleadoSeleccionado.limpiar();
            Navigator.pushNamed(context, 'nvo-empleado').then((value) {
              // Si 'nvo-empleado' puede modificar la lista, recargarla al volver.
              if (value == true) {
                // Asumiendo que 'nvo-empleado' retorna true si hubo cambios
                _cargarDatos();
              }
            });
          },
          icon: const Icon(Icons.person_add_alt_1_outlined),
          label: const Text('Nuevo Empleado'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: isLoading
                  ? _buildLoadingIndicator()
                  : RefreshIndicator(
                      onRefresh: _cargarDatos,
                      child: _empleadosFiltrados.isEmpty
                          ? _buildEmptyState(
                              _busquedaController.text.isNotEmpty)
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              itemCount: _empleadosFiltrados.length,
                              itemBuilder: (context, index) {
                                final empleado = _empleadosFiltrados[index];
                                return _buildSingleEmpleadoCard(empleado);
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            textLoading.isNotEmpty ? textLoading : 'Cargando...',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: TextField(
        controller: _busquedaController,
        decoration: InputDecoration(
          hintText: 'Buscar empleado por nombre o correo',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _busquedaController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _busquedaController.clear();
                    _filtrarEmpleados('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
        ),
        onChanged: _filtrarEmpleados,
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSearching
                        ? Icons.person_search_outlined
                        : Icons.people_outline_rounded,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isSearching
                        ? 'No se encontraron empleados'
                        : 'Aún no hay empleados registrados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSearching
                        ? 'Verifica los términos de búsqueda.'
                        : 'Agrega un nuevo empleado usando el botón "+ Nuevo Empleado".',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSingleEmpleadoCard(Usuario empleado) {
    return Card(
      elevation: 2.5,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          empleadoSeleccionado = empleado; // Asigna el empleado seleccionado
          Navigator.pushNamed(context, 'perfil-empleado').then((value) {
            // Si la pantalla de perfil puede modificar datos del empleado que se reflejan en la lista
            if (value == true) {
              _cargarDatos();
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment
                .center, // Para alinear verticalmente el icono y el texto
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .primaryColor
                      .withOpacity(0.1), // Usar color primario
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_outline, // Icono de persona
                  color: Theme.of(context).primaryColor, // Usar color primario
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      empleado.nombre ?? 'Nombre no disponible',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (empleado.email != null &&
                        empleado.email!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        empleado.email!,
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 13.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    // Podrías añadir más info aquí si es relevante (ej. puesto)
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
