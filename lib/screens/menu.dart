import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> menuItems = [];
    List<String> menuRoutes = [];
    List<String> menuIcons = [];

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

      menuIcons = [
        'assets/i_inicio.png',
        'assets/i_abonos.png',
        'assets/i_historial.png',
        'assets/i_productos.png',
        'assets/i_categorias.png',
        'assets/i_descuentos.png',
        'assets/i_clientes.png',
        'assets/i_empresa.png',
        'assets/i_ajustes.png',
        'assets/i_suscripcion.png',
        'assets/i_salir.png',
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

      menuIcons = [
        'assets/i_inicio.png',
        'assets/i_empresa.png',
        'assets/i_ajustes.png',
        'assets/i_suscripcion.png',
        'assets/i_salir.png',
      ];
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
                  menuIcons[index],
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
