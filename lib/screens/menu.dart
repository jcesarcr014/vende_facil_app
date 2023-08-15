import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> menuItems = [];
    List<String> menuRoutes = [];

    if (sesion.idNegocio != 0) {
      menuItems = [
        'Inicio',
        'Abonos',
        'Historial',
        'Productos',
        'Categorias',
        'Descuentos',
        'Clientes',
        'Empresa',
        'Configuracion',
        'Suscripcion',
        'Salir'
      ];

      menuRoutes = [
        'home',
        'nvo-abono',
        'historial',
        'productos',
        'categorias',
        'descuentos',
        'clientes',
        'negocio',
        'config',
        'suscripcion',
        'login'
      ];
    } else {
      menuItems = [
        'Inicio',
        'Empresa',
        'Configuracion',
        'Suscripcion',
        'Salir'
      ];

      menuRoutes = ['home', 'negocio', 'config', 'suscripcion', 'login'];
    }

    return Scaffold(
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: menuItems.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, menuRoutes[index]);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logoVF.png',
                  width: 64,
                  height: 64,
                ),
                const SizedBox(height: 8),
                Text(
                  menuItems[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
