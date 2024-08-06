import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

class RegistroEmpleadoScreen extends StatefulWidget {
  const RegistroEmpleadoScreen({super.key});

  @override
  State<RegistroEmpleadoScreen> createState() => _RegistroEmpleadoScreenState();
}

class _RegistroEmpleadoScreenState extends State<RegistroEmpleadoScreen> {
  final usuariosProvider = UsuarioProvider();
  final controllerNombre = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerTelefono = TextEditingController();
  final controllerPassword1 = TextEditingController();
  final controllerPassword2 = TextEditingController();
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  bool isLoading = false;
  String textLoading = '';
  bool passOculto1 = true;
  bool passOculto2 = true;

  _registrarEmpleado() {
    if (controllerNombre.text.isEmpty ||
        controllerEmail.text.isEmpty ||
        controllerTelefono.text.isEmpty ||
        controllerPassword1.text.isEmpty ||
        controllerPassword2.text.isEmpty) {
      mostrarAlerta(context, 'ERROR', 'Todos los campos son requeridos');
    } else {
      if (controllerPassword1.text != controllerPassword2.text) {
        mostrarAlerta(context, 'ERROR', 'Las contraseñas no coinciden');
      } else {
        setState(() {
          textLoading = 'Guardando información';
          isLoading = true;
        });
        Usuario newUser = Usuario();
        newUser.nombre = controllerNombre.text;
        newUser.email = controllerEmail.text;
        newUser.telefono = controllerTelefono.text;
        usuariosProvider
            .nuevoEmpleado(newUser, controllerPassword1.text)
            .then((value) {
          if (value.status == 1) {
            usuariosProvider.obtenerEmpleados().then((value) {
              setState(() {
                isLoading = false;
                textLoading = '';
                globals.actualizaEmpleados = true;
              });
              Navigator.pushReplacementNamed(context, 'menu-negocio');

              mostrarAlerta(context, '', 'Empleado registrado correctamente.');
            });
          } else {
            setState(() {
              isLoading = false;
              textLoading = '';
            });
            mostrarAlerta(context, 'ERROR', value.mensaje!);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    controllerNombre.dispose();
    controllerEmail.dispose();
    controllerTelefono.dispose();
    controllerPassword1.dispose();
    controllerPassword2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo empleado'),
      ),
      body: (isLoading)
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.05),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: windowHeight * 0.10,
                    ),
                    InputField(
                        textCapitalization: TextCapitalization.words,
                        icon: Icons.person,
                        labelText: 'Nombre completo',
                        controller: controllerNombre),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    InputField(
                        textCapitalization: TextCapitalization.none,
                        keyboardType: TextInputType.emailAddress,
                        icon: Icons.email,
                        labelText: 'e-mail',
                        controller: controllerEmail),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    InputField(
                        keyboardType: TextInputType.phone,
                        icon: Icons.smartphone,
                        labelText: 'Telefono',
                        controller: controllerTelefono),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    InputField(
                        textCapitalization: TextCapitalization.none,
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
                        icon: Icons.password,
                        labelText: 'Contraseña',
                        controller: controllerPassword1),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    InputField(
                        textCapitalization: TextCapitalization.none,
                        obscureText: passOculto2,
                        suffixIcon: IconButton(
                          icon: (passOculto2)
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                          onPressed: () {
                            passOculto2 = !passOculto2;
                            setState(() {});
                          },
                        ),
                        icon: Icons.password,
                        labelText: 'Confirmar contraseña',
                        controller: controllerPassword2),
                    SizedBox(
                      height: windowHeight * 0.06,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          _registrarEmpleado();
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save),
                            SizedBox(
                              width: 10,
                            ),
                            Text('Registrarse'),
                          ],
                        ))
                  ],
                ),
              ),
            ),
    );
  }
}
