import 'package:flutter/material.dart';

class MenuHistorialScreen extends StatelessWidget {
  const MenuHistorialScreen({super.key});

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
          title: const Text('Historial de ventas y cortes'),
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
              'Gestión de Historial',
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
            title: 'Historial de ventas',
            subtitle: 'Consultas de ventas por fecha',
            icon: Icons.receipt_long,
            iconColor: Colors.indigo,
            onTap: () => Navigator.pushNamed(context, 'historial'),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            context: context,
            title: 'Cortes empleados',
            subtitle: 'Historial de cortes por fechas',
            icon: Icons.account_balance_wallet,
            iconColor: Colors.amber,
            onTap: () => Navigator.pushNamed(context, 'cortes-empleados'),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            context: context,
            title: 'Ventas del día',
            subtitle: 'Detalle de las ventas realizadas en el día',
            icon: Icons.today,
            iconColor: Colors.green,
            onTap: () => Navigator.pushNamed(context, 'ventas-dia'),
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
