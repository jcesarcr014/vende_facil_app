import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart'; // Asegúrate que Sucursal, listaSucursales y sucursalSeleccionado estén aquí
import 'package:vende_facil/providers/providers.dart'; // Asegúrate que NegocioProvider esté aquí
import 'package:vende_facil/widgets/widgets.dart'; // Asegúrate que mostrarAlerta esté aquí

class ListaSucursalesScreen extends StatefulWidget {
  const ListaSucursalesScreen({super.key});

  @override
  State<ListaSucursalesScreen> createState() => _ListaSucursalesScreenState();
}

class _ListaSucursalesScreenState extends State<ListaSucursalesScreen> {
  final negociosProvider = NegocioProvider();
  final _busquedaController = TextEditingController();
  bool isLoading = true; // Inicia en true para mostrar loading al principio
  String textLoading = '';
  List<Sucursal> _sucursalesFiltradas = [];

  @override
  void initState() {
    super.initState();
    // Llama a _cargarDatos sin esperar aquí, setState manejará la UI
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    if (!mounted) return;
    setState(() {
      textLoading = 'Cargando sucursales...';
      // isLoading ya debería ser true si es la carga inicial,
      // o si es un refresh, el RefreshIndicator lo maneja.
      // Pero podemos asegurarlo aquí por si acaso.
      isLoading = true;
    });

    final respSuc = await negociosProvider.getlistaSucursales();
    if (!mounted) return;

    if (respSuc.status == 1) {
      // Asumiendo que getlistaSucursales() actualiza 'listaSucursales'
      // y luego getlistaempleadosEnsucursales() podría actualizar otra lista relacionada.
      // Si la segunda llamada no es crítica para mostrar las sucursales,
      // podrías incluso actualizar la UI después de la primera.
      setState(() {
        textLoading = 'Actualizando datos adicionales...';
      });
      final respEmpleados =
          await negociosProvider.getlistaempleadosEnsucursales(null);
      if (!mounted) return;

      setState(() {
        _sucursalesFiltradas = List.from(listaSucursales);
        isLoading = false;
        textLoading = '';
      });

      if (respEmpleados.status != 1) {
        // Considera cómo manejar este caso. ¿Es un error bloqueante?
        // Por ahora, solo una posible alerta (descomentar si es necesario)
        // mostrarAlerta(context, 'Advertencia', 'No se pudieron cargar todos los datos complementarios: ${respEmpleados.mensaje}');
      }
    } else {
      setState(() {
        isLoading = false;
        textLoading = '';
        _sucursalesFiltradas = []; // Limpiar en caso de error
      });
      mostrarAlerta(
          context, 'ERROR', respSuc.mensaje ?? 'Error al cargar sucursales.');
    }
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  void _filtrarSucursales(String query) {
    setState(() {
      _sucursalesFiltradas = query.isEmpty
          ? List.from(listaSucursales) // Fuente original de datos
          : listaSucursales // Fuente original de datos
              .where((sucursal) =>
                  (sucursal.nombreSucursal
                          ?.toLowerCase()
                          .contains(query.toLowerCase()) ??
                      false) ||
                  (sucursal.direccion
                          ?.toLowerCase()
                          .contains(query.toLowerCase()) ??
                      false) ||
                  (sucursal.telefono
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
          Navigator.pushReplacementNamed(context, 'menu-negocio');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sucursales'),
          automaticallyImplyLeading:
              false, // Ya que se maneja con PopScope y el botón de home
          elevation: 2,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'menu-negocio');
              },
              icon: const Icon(Icons.close),
              tooltip: 'Cancelar',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            sucursalSeleccionado.limpiar();
            // El pushNamed a 'nva-sucursal' podría potencialmente disparar una recarga
            // de la lista al volver, si 'nva-sucursal' modifica 'listaSucursales'
            // y esta pantalla se reconstruye o tiene un listener.
            // O puedes hacer un .then((_) => _cargarDatos()) si la navegación lo permite.
            Navigator.pushNamed(context, 'nva-sucursal').then((value) {
              // Si 'nva-sucursal' puede modificar la lista, recargarla al volver.
              if (value == true) {
                // Asumiendo que 'nva-sucursal' retorna true si hubo cambios
                _cargarDatos();
              }
            });
          },
          icon: const Icon(Icons.add_business_outlined),
          label: const Text('Nueva Sucursal'),
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
                      child: _sucursalesFiltradas.isEmpty
                          ? _buildEmptyState(
                              _busquedaController.text.isNotEmpty)
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              itemCount: _sucursalesFiltradas.length,
                              itemBuilder: (context, index) {
                                final sucursal = _sucursalesFiltradas[index];
                                return _buildSingleSucursalCard(sucursal);
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
          hintText: 'Buscar sucursal...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _busquedaController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _busquedaController.clear();
                    _filtrarSucursales('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          enabledBorder: OutlineInputBorder(
            // Borde cuando no está enfocado
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            // Borde cuando está enfocado
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
        ),
        onChanged: _filtrarSucursales,
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    return LayoutBuilder(// Para centrar correctamente en el espacio disponible
        builder: (context, constraints) {
      return SingleChildScrollView(
        // Para evitar overflow si el contenido es grande
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
                        ? Icons.search_off_outlined
                        : Icons.store_mall_directory_outlined,
                    size: 80, // Ajustado para que no sea tan grande
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isSearching
                        ? 'No se encontraron sucursales'
                        : 'Aún no hay sucursales',
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
                        ? 'Intenta con otros términos de búsqueda.'
                        : 'Agrega una nueva sucursal usando el botón "+ Nueva Sucursal".',
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

  Widget _buildSingleSucursalCard(Sucursal sucursal) {
    return Card(
      elevation: 2.5,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // side: BorderSide(color: Colors.grey.shade300, width: 0.5), // Borde sutil opcional
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          sucursalSeleccionado.asignarValores(
            id: sucursal.id!,
            negocioId: sucursal.negocioId,
            nombreSucursal: sucursal.nombreSucursal,
            direccion: sucursal.direccion,
            telefono: sucursal.telefono,
          );
          Navigator.pushNamed(context, 'nva-sucursal').then((value) {
            if (value == true) {
              _cargarDatos();
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.store_outlined,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 22, // Un poco más pequeño
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sucursal.nombreSucursal ?? 'Nombre no disponible',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.5, // Ligeramente más grande
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (sucursal.direccion != null &&
                            sucursal.direccion!.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            sucursal.direccion!,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 13.5),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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
              if (sucursal.telefono != null &&
                  sucursal.telefono!.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.phone_outlined,
                        size: 15, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      sucursal.telefono!,
                      style: TextStyle(color: Colors.grey[700], fontSize: 13.5),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
