import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vende_facil/models/cuenta_sesion_modelo.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) Navigator.pushReplacementNamed(context, 'menu');
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Configuración'),
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
              'Opciones de Configuración',
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
            title: 'Mi cuenta',
            subtitle: 'Edita tus datos personales',
            icon: Icons.account_circle_rounded,
            iconColor: Colors.blue,
            onTap: () => Navigator.pushNamed(context, 'perfil'),
          ),
          if (sesion.tipoUsuario == "P" && sesion.idNegocio != 0) ...[
            const SizedBox(height: 16),
            _buildMenuCard(
              context: context,
              title: 'Ajustes de ventas',
              subtitle: 'Edita importe mínimo requerido para apartar',
              icon: CupertinoIcons.tag,
              iconColor: Colors.purple,
              onTap: () => Navigator.pushNamed(context, 'config-apartado'),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context: context,
              title: 'Ticket',
              subtitle: 'Configura tu ticket de compra',
              icon: CupertinoIcons.ticket,
              iconColor: Colors.amber,
              onTap: () => Navigator.pushNamed(context, 'ticket'),
            ),
          ],
          const SizedBox(height: 16),
          _buildMenuCard(
            context: context,
            title: 'Impresora',
            subtitle: 'Configura tu impresora de tickets',
            icon: CupertinoIcons.printer,
            iconColor: Colors.teal,
            onTap: () => Navigator.pushNamed(context, 'config-impresora'),
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
