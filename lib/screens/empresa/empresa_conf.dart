import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart'; // Asegúrate que 'sesion' y 'suscripcionActual', 'listaSucursales' estén aquí

class MenuEmpresaScreen extends StatelessWidget {
  const MenuEmpresaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool esMonoSucursal = suscripcionActual.unisucursal;
    final int limiteEmpleados = suscripcionActual.limiteEmpleados ?? 0;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        // Cambiado de onPopInvokedWithResult a onPopInvoked
        if (!didPop) {
          Navigator.pushReplacementNamed(context, 'menu');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Configuración Negocio'),
          elevation: 2,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'menu');
              },
              icon: const Icon(Icons.home_filled),
              tooltip: 'Ir al menú principal',
            ),
          ],
        ),
        body: _buildMenuOptions(context, esMonoSucursal, limiteEmpleados),
      ),
    );
  }

  Widget _buildMenuOptions(
      BuildContext context, bool esMonoSucursal, int limiteEmpleados) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Gestión de Negocio',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),

          // 1. "Mi negocio" - Siempre visible
          _buildMenuCard(
            context: context,
            title: 'Mi Negocio',
            subtitle: 'Datos generales de tu empresa',
            icon: Icons.business_center_outlined,
            iconColor: Colors.blue.shade700,
            onTap: () => Navigator.pushNamed(context, 'negocio'),
          ),
          const SizedBox(height: 16),

          // 2. "Sucursal(es)"
          if (esMonoSucursal) ...[
            _buildMenuCard(
              context: context,
              title: 'Mi Sucursal',
              subtitle: 'Datos de tu única sucursal',
              icon: Icons.storefront_outlined,
              iconColor: Colors.green.shade600,
              onTap: () {
                // Si es mono-sucursal, y 'listaSucursales' está cargada y tiene un elemento
                if (listaSucursales.isNotEmpty) {
                  // Asignar la primera (y única) sucursal a 'sucursalSeleccionado'
                  // para que RegistroSucursalesScreen la cargue para edición.
                  // Tu lógica en RegistroSucursalesScreen ya usa 'sucursalSeleccionado'.
                  sucursalSeleccionado.asignarValores(
                    id: listaSucursales.first.id!,
                    negocioId: listaSucursales.first.negocioId,
                    nombreSucursal: listaSucursales.first.nombreSucursal,
                    direccion: listaSucursales.first.direccion,
                    telefono: listaSucursales.first.telefono,
                  );
                  // Navegar directamente a la pantalla de edición/detalle de sucursal
                  Navigator.pushNamed(context, 'nva-sucursal');
                } else {
                  // Caso borde: mono-sucursal pero listaSucursales está vacía.
                  // Esto no debería pasar si la sucursal se crea con el negocio.
                  // Como fallback, ir a la lista (que mostrará "vacío" o error).
                  Navigator.pushNamed(context, 'lista-sucursales');
                }
              },
            ),
          ] else ...[
            // Multi-Sucursal
            _buildMenuCard(
              context: context,
              title: 'Sucursales',
              subtitle: 'Agrega o edita tus sucursales',
              icon: Icons.store_mall_directory_outlined,
              iconColor: Colors.green.shade600,
              onTap: () => Navigator.pushNamed(context, 'lista-sucursales'),
            ),
          ],
          const SizedBox(height: 16),

          // 3. "Empleados" - Visible solo si limiteEmpleados > 0
          if (limiteEmpleados > 0) ...[
            _buildMenuCard(
              context: context,
              title: 'Empleados',
              subtitle: 'Agrega o gestiona tus empleados',
              icon: Icons.people_alt_outlined,
              iconColor: Colors.orange.shade700,
              onTap: () => Navigator.pushNamed(context, 'empleados'),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  // _buildMenuCard se mantiene igual que tu original
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
