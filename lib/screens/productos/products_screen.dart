import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/mostrar_alerta_ok.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categoriasProvider = CategoriaProvider();

    void addProduct() async {
      await categoriasProvider.listarCategorias();
      if (listaCategorias.isEmpty) {
        mostrarAlerta(context, 'Error', 'Primero crea una categoría');
        return;
      }
      Navigator.pushNamed(context, 'nvo-producto');
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, 'menu');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Productos'),
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
        body: _buildMenuOptions(context, addProduct),
      ),
    );
  }

  Widget _buildMenuOptions(BuildContext context, VoidCallback addProduct) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Gestión de Productos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),

          // Mostrar opciones según el tipo de usuario
          if (sesion.tipoUsuario == 'P') ...[
            _buildMenuCard(
              context: context,
              title: 'Listado de Productos',
              subtitle: 'Visualiza tus productos',
              icon: Icons.list_alt,
              iconColor: Colors.blue,
              onTap: () => Navigator.pushNamed(context, 'productos'),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context: context,
              title: 'Nuevo Producto',
              subtitle: 'Crea un nuevo producto',
              icon: Icons.add_box,
              iconColor: Colors.green,
              onTap: addProduct,
            ),
            const SizedBox(height: 16),
          ],

          if (sesion.tipoUsuario == 'P') ...[
            _buildMenuCard(
              context: context,
              title: 'Inventario almacen',
              subtitle: 'Visualiza tus productos en alamcen',
              icon: Icons.warehouse,
              iconColor: Colors.amber,
              onTap: () => Navigator.pushNamed(context, 'iventario-almacen'),
            ),
            const SizedBox(height: 16),
          ],

          if (sesion.tipoUsuario == 'P' ||
              (sesion.tipoUsuario == 'E' && varEmpleadoInventario)) ...[
            _buildMenuCard(
              context: context,
              title: 'Inventario sucursal',
              subtitle: 'Selecciona tu sucursal y visualiza tus productos',
              icon: Icons.warehouse,
              iconColor: Colors.amber,
              onTap: () => Navigator.pushNamed(context, 'InventoryPage'),
            ),
            const SizedBox(height: 16),
          ],

          if (sesion.tipoUsuario == 'P') ...[
            _buildMenuCard(
              context: context,
              title: 'Asignar Productos Sucursal',
              subtitle: 'Agrega inventario a una sucursal',
              icon: Icons.add_circle,
              iconColor: Colors.teal,
              onTap: () =>
                  Navigator.pushNamed(context, 'agregar-producto-sucursal'),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context: context,
              title: 'Retirar Productos Sucursal',
              subtitle: 'Retira inventario de una sucursal',
              icon: Icons.remove_circle,
              iconColor: Colors.red,
              onTap: () =>
                  Navigator.pushNamed(context, 'eliminar-producto-sucursal'),
            ),
            const SizedBox(height: 16),
          ],

          _buildMenuCard(
            context: context,
            title: 'Cotizar',
            subtitle: 'Crear cotización de productos',
            icon: Icons.request_quote,
            iconColor: Colors.purple,
            onTap: () {
              sesion.cotizar = true;
              if (sesion.tipoUsuario == 'P') {
                Navigator.pushNamed(context, 'seleccionar-sucursal-cotizacion');
                return;
              }
              Navigator.pushNamed(context, 'HomerCotizar');
            },
          ),
          const SizedBox(height: 16),

          _buildMenuCard(
            context: context,
            title: 'Cotizaciones',
            subtitle: 'Visualización de cotizaciones',
            icon: Icons.description,
            iconColor: Colors.indigo,
            onTap: () => Navigator.pushNamed(context, 'listaCotizaciones'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
