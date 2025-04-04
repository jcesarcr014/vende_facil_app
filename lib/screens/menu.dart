import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vende_facil/util/limpia_datos.dart';
import 'package:vende_facil/widgets/widgets.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final usuarioProvider = UsuarioProvider();
  final limpiaDatos = LimpiaDatos();
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
          'menuAbonos',
          'historial_empleado',
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
          // 'Mi suscripción',
          'Cerrar Sesión'
        ];
        menuRoutes = [
          'home',
          'menuAbonos',
          'menu-historial',
          'productos',
          'categorias',
          'descuentos',
          'clientes',
          'menu-negocio',
          'config',
          // 'suscripcion',
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
          // 'assets/i_suscripcion.png',
          'assets/i_salir.png',
        ];
      }
    } else {
      menuItems = [
        'Empresa',
        'Configuracion',
        // 'Mi suscripción',
        'Cerrar Sesión'
      ];

      menuRoutes = [
        'menu-negocio',
        'config',
        //  'suscripcion',
        'login'
      ];

      menuIcons = [
        'assets/i_empresa.png',
        'assets/i_ajustes.png',
        // 'assets/i_suscripcion.png',
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
                if (!mounted) return;
                if (menuRoutes[index] == 'login') {
                  UsuarioProvider().logout().then((value) async {
                    if (!mounted) return;
                    if (value.status == 1) {
                      limpiaDatos.limpiaDatos();
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString('token', '');
                      Navigator.pushReplacementNamed(context, 'login');
                    } else {
                      mostrarAlerta(context, "Alerta", value.mensaje!);
                    }
                  });
                }

                if (menuRoutes[index] == 'home' && sesion.tipoUsuario == "P") {
                  Navigator.pushNamed(context, 'select-branch-office');
                  return;
                }

                if (menuRoutes[index] == 'productos') {
                  Navigator.pushNamed(context, 'products-menu');
                  return;
                }

                if (sesion.tipoUsuario == 'E' &&
                    menuRoutes[index] == 'historial_empleado') {
                  Navigator.pushReplacementNamed(context, menuRoutes[index]);
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
