import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';

class MenuEmpresaScreen extends StatelessWidget {
  const MenuEmpresaScreen({super.key});

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
          automaticallyImplyLeading: false,
          title: const Text('Configuración negocio'),
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
        body: _buildMenuOptions(context),
      ),
    );
  }

  Widget _buildMenuOptions(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Gestión de Negocio',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            context: context,
            title: 'Mi negocio',
            subtitle: 'Datos de tu negocio (Matriz)',
            icon: Icons.business,
            iconColor: Colors.blue,
            onTap: () => Navigator.pushNamed(context, 'negocio'),
          ),
          if (sesion.idNegocio != 0) ...[
            const SizedBox(height: 16),
            _buildMenuCard(
              context: context,
              title: 'Sucursales',
              subtitle: 'Agrega o edita sucursales',
              icon: Icons.store,
              iconColor: Colors.green,
              onTap: () => Navigator.pushNamed(context, 'lista-sucursales'),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context: context,
              title: 'Empleados',
              subtitle: 'Agrega o asigna empleados',
              icon: Icons.people,
              iconColor: Colors.orange,
              onTap: () => Navigator.pushNamed(context, 'empleados'),
            ),
          ],
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
