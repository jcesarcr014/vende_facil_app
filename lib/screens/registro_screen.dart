import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final usuariosProvider = UsuarioProvider();
  final location = Location();
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

  _registraUsuario() async {
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
          isLoading = true;
        });
        String latitud = '0.0';
        String longitud = '0.0';
        String municipio = '';
        try {
          final ubicacion = await location.determinePosition();
          latitud = ubicacion.latitude.toString();
          longitud = ubicacion.longitude.toString();
          final datos = await location.getPosData(
              ubicacion.latitude, ubicacion.longitude);
          municipio = (datos[0].locality) ?? '';
        } catch (e) {
          mostrarAlerta(context, 'ERROR',
              'Ocurrio el siguiente error: $e, se registrará sin guardar su ubicación.');
        }

        Usuario newUser = Usuario();
        newUser.nombre = controllerNombre.text;
        newUser.email = controllerEmail.text;
        newUser.telefono = controllerTelefono.text;
        newUser.tipoUsuario = globals.tipoUserPropiertario;
        usuariosProvider
            .nuevoUsuario(
                newUser, controllerPassword1.text, latitud, longitud, municipio)
            .then((value) {
          setState(() {
            isLoading = false;
          });
          if (value.status == 1) {
            Navigator.pushReplacementNamed(context, 'login');
            mostrarAlerta(context, 'Bienvenido',
                'Sus datos se han registrado correctamente. Inicie sesión y vaya a configuración para dar de alta su negocio.');
          } else {
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
        title: const Text('Nuevo usuario'),
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
                        sufixIcon: IconButton(
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
                        sufixIcon: IconButton(
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
                          _registraUsuario();
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save),
                            SizedBox(
                              width: 10,
                            ),
                            Text('Registrase'),
                          ],
                        ))
                  ],
                ),
              ),
            ),
    );
  }
}
