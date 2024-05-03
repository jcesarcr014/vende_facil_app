import 'package:flutter/material.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/providers/providers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final usuariosProvider = UsuarioProvider();
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
          .then((value) {
        setState(() {
          isLoading = false;
        });
        if (value.status == 1) {
          Navigator.pushReplacementNamed(context, 'home');
        } else {
          mostrarAlerta(context, 'ERROR', value.mensaje!);
        }
      });
    } else {
      mostrarAlerta(context, 'ERROR', 'Complete todos los campos');
    }
  }

  @override
  void initState() {
    setState(() {
      textLoading = 'Leyendo datos de sesión.';
      isLoading = true;
    });
    usuariosProvider.userInfo().then((value) {
      setState(() {
        isLoading = false;
        textLoading = '';
      });
      if (value.status == 1) {
        Navigator.pushReplacementNamed(context, 'home');
      }
    });
    super.initState();
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
                              sufixIcon: IconButton(
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
                                  return 'El la contraseña es obligatoria';
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
