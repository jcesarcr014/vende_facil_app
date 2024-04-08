import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';

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
      body: (isLoading)
          ? Center(
              child: Column(
                children: [
                  SizedBox(
                    height: windowHeight * 0.15,
                  ),
                  Text('Espere...$textLoading',
                      style: const TextStyle(fontSize: 20)),
                  SizedBox(
                    height: windowHeight * 0.05,
                  ),
                  const CircularProgressIndicator(),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: menuItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    if (menuRoutes[index] == 'login') {
                      setState(() {
                        isLoading = true;
                        textLoading = 'Cerrando sesion...';
                      });
                      usuarioProvider.logout().then((value) {
                        setState(() {
                          isLoading = false;
                          textLoading = '';
                        });
                        if (value.status == 1) {
                          Navigator.pushReplacementNamed(context, 'login');
                        } else {
                          mostrarAlerta(context, 'ERROR',
                              'Ocurrio el sigiente error: ${value.mensaje}');
                        }
                      });
                    } else {
                      Navigator.pushReplacementNamed(
                          context, menuRoutes[index]);
                    }
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
