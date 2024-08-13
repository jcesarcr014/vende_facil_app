// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final usuarioProvider = UsuarioProvider();
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    List<String> menuItems = [];
    List<String> menuRoutes = [];
    List<String> menuIcons = [];
    if (sesion.idNegocio != 0) {
      if (sesion.tipoUsuario == "E") {
        menuItems = [
          'Inicio',
          'Abonos',
          'Historial',
          'Productos',
          'Categorias',
          'Clientes',
          'Configuracion',
          'Cerrar Sesión'
        ];
        menuRoutes = [
          'home',
          'nvo-abono',
          'historial',
          'productos',
          'categorias',
          'clientes',
          'config',
          'login'
        ];
        menuIcons = [
          'assets/i_inicio.png',
          'assets/i_abonos.png',
          'assets/i_historial.png',
          'assets/i_productos.png',
          'assets/i_categorias.png',
          'assets/i_clientes.png',
          'assets/i_ajustes.png',
          'assets/i_salir.png',
        ];
      } else {
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
          'Mi suscripción',
          'Cerrar Sesión'
        ];

        menuRoutes = [
          'home',
          'nvo-abono',
          'historial',
          'productos',
          'categorias',
          'descuentos',
          'clientes',
          'menu-negocio',
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
      }
    } else {
      menuItems = [
        'Empresa',
        'Configuracion',
        'Mi suscripción',
        'Cerrar Sesión'
      ];

      menuRoutes = ['menu-negocio', 'config', 'suscripcion', 'login'];

      menuIcons = [
        'assets/i_empresa.png',
        'assets/i_ajustes.png',
        'assets/i_suscripcion.png',
        'assets/i_salir.png',
      ];
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didpop) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: ((context) {
              return AlertDialog(
                title: const Text('Salir'),
                content: const Text('¿Desea salir de la aplicación?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'No',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      SystemNavigator.pop();
                    },
                    child: const Text('Si'),
                  ),
                ],
              );
            }));
      },
      child: Scaffold(
        body: GridView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: menuItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () async {
                if (menuRoutes[index] == 'login') {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString('token', '');
                }

                if( menuRoutes[index] == 'home' && sesion.tipoUsuario == "P" ) {
                  Navigator.pushNamed(context, 'select-branch-office');
                  return;
                }

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
      ),
    );
  }
}
