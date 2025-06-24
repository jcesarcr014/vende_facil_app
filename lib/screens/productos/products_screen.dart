import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart'; // Asegúrate que 'sesion' y otras dependencias estén aquí
import 'package:vende_facil/providers/providers.dart'; // Asumo CategoriaProvider está aquí
import 'package:vende_facil/widgets/mostrar_alerta_ok.dart'; // Para mostrarAlerta

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categoriasProvider = CategoriaProvider();

    void addProduct() async {
      // Asumo que listaCategorias es una variable global o accesible
      await categoriasProvider.listarCategorias();
      if (listaCategorias.isEmpty) {
        if (context.mounted) {
          // Verificar si el widget está montado antes de usar context
          mostrarAlerta(context, 'Error', 'Primero crea una categoría');
        }
        return;
      }
      if (context.mounted) {
        Navigator.pushNamed(context, 'nvo-producto');
      }
    }

    final bool esPropietario = sesion.tipoUsuario == 'P';
    final bool esMonoSucursal = suscripcionActual.unisucursal;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, 'menu');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading:
              false, // Ya que se maneja con PopScope y el botón de home
          title: const Text('Productos'),
          elevation: 2,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'menu');
              },
              icon:
                  const Icon(Icons.home_filled), // Icono más estándar para home
              tooltip: 'Ir al menú principal',
            ),
          ],
        ),
        body: _buildMenuOptions(
            context, addProduct, esPropietario, esMonoSucursal),
      ),
    );
  }

  Widget _buildMenuOptions(
    BuildContext context,
    VoidCallback addProduct,
    bool esPropietario,
    bool esMonoSucursal,
  ) {
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

          // --- Opciones Comunes o para Propietario ---
          if (esPropietario) ...[
            _buildMenuCard(
              context: context,
              title: 'Nuevo Producto',
              subtitle: 'Crea un nuevo producto en tu catálogo',
              icon: Icons.add_box_outlined,
              iconColor: Colors.green.shade600,
              onTap: addProduct,
            ),
            const SizedBox(height: 16),
          ],

          if (esPropietario && esMonoSucursal) ...[
            _buildMenuCard(
              context: context,
              title: 'Inventario (Mi Tienda)',
              subtitle: 'Gestiona el stock de tu tienda',
              icon: Icons.storefront_outlined,
              iconColor: Colors.deepPurple.shade500,
              onTap: () =>
                  Navigator.pushNamed(context, 'inventarioUnisucursal'),
            ),
            const SizedBox(height: 16),
          ],

          if (esPropietario && !esMonoSucursal) ...[
            _buildMenuCard(
              context: context,
              title: 'Listado de Productos', // Catálogo General / Almacén
              subtitle: 'Visualiza tu catálogo de productos',
              icon: Icons.list_alt_outlined,
              iconColor: Colors.blue.shade700,
              onTap: () => Navigator.pushNamed(
                  context, 'productos'), // Pantalla de listado de almacén
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context: context,
              title: 'Inventario Almacén',
              subtitle: 'Stock general antes de asignar',
              icon: Icons.inventory_2_outlined,
              iconColor: Colors.orange.shade700,
              onTap: () => Navigator.pushNamed(context, 'iventario-almacen'),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              // Mover "Inventario por Sucursal" aquí, ya que es para multi-sucursal
              context: context,
              title: 'Inventario por Sucursal',
              subtitle: 'Selecciona y visualiza stock por sucursal',
              icon: Icons.warehouse_outlined,
              iconColor: Colors.amber.shade700,
              onTap: () => Navigator.pushNamed(context, 'InventoryPage'),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context: context,
              title: 'Asignar Productos a Sucursal',
              subtitle: 'Mueve stock del almacén a una sucursal',
              icon: Icons.add_circle_outline,
              iconColor: Colors.teal.shade600,
              onTap: () =>
                  Navigator.pushNamed(context, 'agregar-producto-sucursal'),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context: context,
              title: 'Retirar Productos de Sucursal',
              subtitle: 'Devuelve stock de sucursal al almacén',
              icon: Icons.remove_circle_outline,
              iconColor: Colors.red.shade600,
              onTap: () =>
                  Navigator.pushNamed(context, 'eliminar-producto-sucursal'),
            ),
            const SizedBox(height: 16),
          ],
          if (sesion.tipoUsuario == 'E' &&
              varEmpleadoInventario &&
              (esPropietario ? !esMonoSucursal : true)) ...[
            _buildMenuCard(
              context: context,
              title:
                  'Inventario de Mi Sucursal', // Más específico para empleado
              subtitle: 'Visualiza el stock de tu sucursal asignada',
              icon: Icons.store_mall_directory_outlined, // Icono diferente
              iconColor: Colors.cyan.shade700,
              onTap: () => Navigator.pushNamed(context,
                  'InventoryPage'), // Asumo que InventoryPage maneja la sucursal del empleado
            ),
            const SizedBox(height: 16),
          ],

          _buildMenuCard(
            context: context,
            title: 'Cotizar',
            subtitle: 'Crear cotización de productos',
            icon: Icons.request_quote_outlined,
            iconColor: Colors.purple.shade600,
            onTap: () {
              sesion.cotizar = true;
              if (sesion.tipoUsuario == 'P') {
                // Si es mono-sucursal, no necesita seleccionar sucursal.
                // Si es multi-sucursal, sí.
                // Esto podría requerir que 'seleccionar-sucursal-cotizacion' sepa si es mono.
                // O tener una ruta directa para cotizar si es mono.
                // Por ahora, mantenemos tu lógica original, pero es un punto a revisar.
                if (esPropietario && esMonoSucursal) {
                  // Para mono-sucursal, ¿a dónde va? ¿Directo a 'HomerCotizar' asumiendo la única sucursal?
                  // Necesitarías asegurar que sesion.idSucursal esté seteado para la única sucursal.
                  Navigator.pushNamed(context, 'HomerCotizar'); // Ejemplo
                } else {
                  Navigator.pushNamed(
                      context, 'seleccionar-sucursal-cotizacion');
                }
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
            icon: Icons.description_outlined,
            iconColor: Colors.indigo.shade600,
            onTap: () => Navigator.pushNamed(context, 'listaCotizaciones'),
          ),
        ],
      ),
    );
  }

  // _buildMenuCard se mantiene igual, no necesita cambios aquí
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
