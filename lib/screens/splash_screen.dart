import 'package:flutter/material.dart';
import 'package:vende_facil/models/cuenta_sesion_modelo.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/util/limpia_datos.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final limpiaDatos = LimpiaDatos();
  final usuariosProvider = UsuarioProvider();
  final categoriasProvider = CategoriaProvider();
  final articulosProvider = ArticuloProvider();
  final clientesProvider = ClienteProvider();
  final descuentosProvider = DescuentoProvider();
  final apartadoProvider = ApartadoProvider();
  final variablesprovider = VariablesProvider();
  final negocios = NegocioProvider();

  String textLoading = '';
  bool isLoading = false;

  // Controlador para la animación
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Configuramos la animación
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Iniciamos la animación
    _controller.forward();

    // Verificamos la sesión
    _checkSession();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkSession() async {
    setState(() {
      textLoading = 'Verificando sesión';
      isLoading = true;
    });

    try {
      var value = await usuariosProvider.userInfo();

      if (value.status != 1) {
        limpiaDatos.limpiaDatos();
        setState(() {
          isLoading = false;
          textLoading = '';
        });

        Navigator.pushReplacementNamed(context, 'login');
        return;
      }

      // Si hay sesión activa, cargamos los datos necesarios
      if (sesion.tipoUsuario == 'P') {
        setState(() {
          textLoading = 'Cargando información de empleados';
        });
        await usuariosProvider.obtenerUsuarios();
        await usuariosProvider.obtenerEmpleados();
      }

      setState(() {
        textLoading = 'Cargando categorías';
      });
      await categoriasProvider.listarCategorias();

      setState(() {
        textLoading = 'Cargando configuración';
      });
      await variablesprovider.variablesConfiguracion();

      setState(() {
        textLoading = '';
        isLoading = false;
      });

      // Navegamos a la pantalla correspondiente
      if (sesion.idNegocio == 0) {
        Navigator.pushReplacementNamed(context, 'menu');
        mostrarAlerta(context, 'Bienvenido',
            '¡Bienvenido de vuelta! Registre los datos de su negocio en la opción Empresa del menú para acceder a todas las funcionalidades de la aplicación.');
      } else {
        if (sesion.tipoUsuario == 'E') {
          Navigator.pushReplacementNamed(context, 'menu');
          mostrarAlerta(context, 'Bienvenido',
              'Hola ${sesion.nombreUsuario}, estás en la sucursal ${sesion.sucursal}');
        } else {
          Navigator.pushReplacementNamed(context, 'menu');
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        textLoading = '';
      });

      // Si hay algún error, enviamos al login
      Navigator.pushReplacementNamed(context, 'login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  SizedBox(
                    width: size.width * 0.5,
                    child: const Image(
                      image: AssetImage('assets/logo.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: size.height * 0.04),

                  // Título de la aplicación
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 20.0),
                      child: Column(
                        children: [
                          const Text(
                            'Vendo Fácil',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tu solución para ventas y control de inventario',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (isLoading) ...[
                            SizedBox(height: size.height * 0.04),
                            Text(
                              textLoading,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const CircularProgressIndicator(),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Versión de la aplicación
                  SizedBox(height: size.height * 0.06),
                  Text(
                    'Versión 1.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
