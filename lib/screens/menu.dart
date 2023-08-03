import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  static const List<String> menuItems = [
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

  static const List<String> menuRoutes = [
    'home',
    'nvo-abono',
    'historial',
    'productos',
    'categorias',
    'descuentos',
    'clientes',
    'negocio',
    'config',
    'negocio',
    'login'
  ];
  @override
  Widget build(BuildContext context) {
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
