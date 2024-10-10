// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final usuariosProvider = UsuarioProvider();
  final categoriasProvider = CategoriaProvider();
  final articulosProvider = ArticuloProvider();
  final clientesProvider = ClienteProvider();
  final descuentosProvider = DescuentoProvider();
  final variablesprovider = VariablesProvider();
  final apartadoProvider = ApartadoProvider();
  final controllerUser = TextEditingController();
  final controllerPass = TextEditingController();
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  bool isLoading = false;
  bool passOculto1 = true;
  String textLoading = '';
  String? _userErrorText;
  String? _passwordErrorText;

  _inicioSesion() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        textLoading = 'Iniciando sesión.';
        isLoading = true;
      });
      usuariosProvider
          .login(controllerUser.text, controllerPass.text)
          .then((value) async {
        if (value.status == 1) {
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
          await articulosProvider.listarProductosCotizaciones().then((value) {
            if (value.status == 1) {
              globals.actualizaArticulosCotizaciones = false;
            } else {
              globals.actualizaArticulosCotizaciones = true;
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
          await variablesprovider.variablesApartado().then((value) {
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

          if (sesion.idNegocio == 0) {
            Navigator.pushReplacementNamed(context, 'menu');
            mostrarAlerta(context, 'Bienvenido',
                '¡Bienvenido de vuelta!. Registre los datos de su negocio en la opción Empresa del menú, para que pueda acceder a todas las opciones de la aplicación.');
          } else {
            // ignore: duplicate_ignore
            // ignore: use_build_context_synchronously
            Navigator.pushReplacementNamed(context, 'menu');
          }
        } else {
          setState(() {
            textLoading = '';
            isLoading = false;
          });
          mostrarAlerta(context, 'ERROR', value.mensaje!);
        }
      });
    } else {
      mostrarAlerta(context, 'ERROR', 'Complete todos los campos');
    }
  }

  @override
  void dispose() {
    controllerUser.dispose();
    controllerPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      child: Scaffold(
          body: (isLoading)
              ? Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: windowHeight * 0.15,
                      ),
                      SizedBox(
                          width: windowWidth * 0.4,
                          child: const Image(
                              image: AssetImage('assets/logo.png'))),
                      SizedBox(
                        height: windowHeight * 0.1,
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
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.05),
                  child: Form(
                    key: _formKey,
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(
                            height: windowHeight * 0.15,
                          ),
                          SizedBox(
                              width: windowWidth * 0.4,
                              child: const Image(
                                  image: AssetImage('assets/logo.png'))),
                          SizedBox(
                            height: windowHeight * 0.1,
                          ),
                          InputField(
                              icon: Icons.person,
                              labelText: 'Usuario',
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'El usuario es obligatorio';
                                }
                                return null;
                              },
                              errorText: _userErrorText,
                              controller: controllerUser),
                          SizedBox(
                            height: windowHeight * 0.03,
                          ),
                          InputField(
                              icon: Icons.password,
                              obscureText: passOculto1,
                              suffixIcon: IconButton(
                                icon: (passOculto1)
                                    ? const Icon(Icons.visibility_off)
                                    : const Icon(Icons.visibility),
                                onPressed: () {
                                  passOculto1 = !passOculto1;
                                  setState(() {});
                                },
                              ),
                              labelText: 'Contraseña',
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'La contraseña es obligatoria';
                                }
                                return null;
                              },
                              errorText: _passwordErrorText,
                              controller: controllerPass),
                          SizedBox(
                            height: windowHeight * 0.06,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                _inicioSesion();
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.login),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text('Iniciar Sesión'),
                                ],
                              )),
                          SizedBox(
                            height: windowHeight * 0.05,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('¿No tienes cuenta?'),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, 'registro');
                                  },
                                  child: const Text('Registrarse'))
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                )),
    );
  }
}
