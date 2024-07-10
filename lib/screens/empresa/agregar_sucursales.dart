import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

class RegistroSucursalesScreen extends StatefulWidget {
  const RegistroSucursalesScreen({super.key});

  @override
  State<RegistroSucursalesScreen> createState() => _RegistroEmpleadoScreenState();
}

class _RegistroEmpleadoScreenState extends State<RegistroSucursalesScreen> {
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
              Navigator.pushReplacementNamed(context, 'config');

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
                        icon: Icons.holiday_village,
                        labelText: 'Nombre de la surcursal',
                        controller: controllerNombre),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    InputField(
                        textCapitalization: TextCapitalization.none,
                        keyboardType: TextInputType.emailAddress,
                        icon: Icons.gps_fixed_outlined,
                        labelText: 'Dirrecion',
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
                      height: windowHeight * 0.10,
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
