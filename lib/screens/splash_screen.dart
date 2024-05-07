import 'package:flutter/material.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final usuariosProvider = UsuarioProvider();
  final categoriasProvider = CategoriaProvider();
  final articulosProvider = ArticuloProvider();
  final clientesProvider = ClienteProvider();
  final descuentosProvider = DescuentoProvider();
  final apartadoProvider = ApartadoProvider();
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  String textLoading = '';
  bool isLoading = false;

  @override
  void initState() {
    setState(() {
      textLoading = 'Leyendo datos de sesión.';
      isLoading = true;
    });
    usuariosProvider.userInfo().then((value) async {
      if (value.status != 1) {
        setState(() {
          isLoading = false;
          textLoading = '';
        });
        Navigator.pushReplacementNamed(context, 'login');
        return;
      } else {
        setState(() {
          textLoading = 'Leyendo información de empleados';
        });
        await usuariosProvider.obtenerUsuarios().then((value) {
          if (value.status == 1) {
            globals.actualizaUsuarios = false;
          } else {
            globals.actualizaUsuarios = true;
          }
        });
        await usuariosProvider.obtenerEmpleados().then((value) {
          if (value.status == 1) {
            globals.actualizaEmpleados = false;
          } else {
            globals.actualizaEmpleados = true;
          }
        });
        setState(() {
          textLoading = 'Leyendo categorias';
        });
        await categoriasProvider.listarCategorias().then((value) {
          if (value.status == 1) {
            globals.actualizaCategorias = false;
          } else {
            globals.actualizaCategorias = true;
          }
        });
        setState(() {
          textLoading = 'Leyendo productos';
        });
        await articulosProvider.listarProductos().then((value) {
          if (value.status == 1) {
            globals.actualizaArticulos = false;
          } else {
            globals.actualizaArticulos = true;
          }
        });
        setState(() {
          textLoading = 'Leyendo información adicional';
        });
        await clientesProvider.listarClientes().then((value) {
          if (value.status == 1) {
            globals.actualizaClientes = false;
          } else {
            globals.actualizaClientes = true;
          }
        });
        await descuentosProvider.listarDescuentos().then((value) {
          if (value.status == 1) {
            globals.actualizaDescuentos = false;
          } else {
            globals.actualizaDescuentos = true;
          }
        });
        await apartadoProvider.variablesApartado().then((value) {
          if (value.status == 1) {
            globals.actualizaVariables = false;
          } else {
            globals.actualizaVariables = true;
          }
        });
        setState(() {
          textLoading = '';
          isLoading = false;
        });
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, 'home');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.05),
          child: Column(
            children: [
              SizedBox(
                height: windowHeight * 0.15,
              ),
              SizedBox(
                  width: windowWidth * 0.4,
                  child: const Image(image: AssetImage('assets/logo.png'))),
              SizedBox(
                height: windowHeight * 0.1,
              ),
              const Text(
                'Bienvenido a Vendo Facil',
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              (isLoading)
                  ? Column(
                      children: [
                        Text('Espere...$textLoading',
                            style: const TextStyle(fontSize: 20)),
                        SizedBox(
                          height: windowHeight * 0.05,
                        ),
                        const CircularProgressIndicator()
                      ],
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
