import 'package:flutter/material.dart';
import 'package:vende_facil/models/cuenta_sesion_modelo.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/util/limpia_datos.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final limpiaDatos = LimpiaDatos();
  final usuariosProvider = UsuarioProvider();
  final categoriasProvider = CategoriaProvider();
  final articulosProvider = ArticuloProvider();
  final clientesProvider = ClienteProvider();
  final descuentosProvider = DescuentoProvider();
  final apartadoProvider = ApartadoProvider();
  final variablesprovider = VariablesProvider();
  final negocios = NegocioProvider();
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
        limpiaDatos.limpiaDatos();
        setState(() {
          isLoading = false;
          textLoading = '';
        });
        Navigator.pushReplacementNamed(context, 'login');
        return;
      } else {
        if (sesion.tipoUsuario == 'P') {
          setState(() {
            textLoading = 'Leyendo información de empleados';
          });
          await usuariosProvider.obtenerUsuarios();
          await usuariosProvider.obtenerEmpleados();
        }
        setState(() {
          textLoading = 'Leyendo categorias';
        });
        await categoriasProvider.listarCategorias();

        setState(() {
          textLoading = 'Leyendo información adicional';
        });
        await variablesprovider.variablesConfiguracion();
        setState(() {
          textLoading = '';
          isLoading = false;
        });

        if (sesion.idNegocio == 0) {
          Navigator.pushReplacementNamed(context, 'menu');
          mostrarAlerta(context, 'Bienvenido',
              '¡Bienvenido de vuelta!. Registre los datos de su negocio en la opción Empresa del menú, para que pueda acceder a todas las opciones de la aplicación.');
        } else {
          if (sesion.tipoUsuario == 'E') {
            Navigator.pushReplacementNamed(context, 'menu');
            mostrarAlerta(context, 'Bienvenido',
                'Hola ${sesion.nombreUsuario}, estas en la sucursal ${sesion.sucursal}');
          } else {
            Navigator.pushReplacementNamed(context, 'menu');
          }
        }
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
