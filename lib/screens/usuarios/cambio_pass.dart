import 'package:flutter/material.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/providers/providers.dart';

class CambioPassScreen extends StatefulWidget {
  const CambioPassScreen({super.key});

  @override
  State<CambioPassScreen> createState() => _CambioPassScreenState();
}

class _CambioPassScreenState extends State<CambioPassScreen> {
  final GlobalKey<FormState> _formPassKey = GlobalKey<FormState>();
  final usuarioProvider = UsuarioProvider();
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  bool isLoading = false;
  String textLoading = '';
  final oldPassController = TextEditingController();
  final newPass1Controller = TextEditingController();
  final newPass2Controller = TextEditingController();
  bool oldPassView = true;
  bool newPass1View = true;
  bool newPass2View = true;
  String? _oldPassError;
  String? _newPass1Error;
  String? _newPass2Error;

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Cambio de contraseña'),
      ),
      body: (isLoading)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Espere...$textLoading'),
                  SizedBox(
                    height: windowHeight * 0.01,
                  ),
                  const CircularProgressIndicator(),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.03),
              child: Form(
                key: _formPassKey,
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(height: windowHeight * 0.08),
                      InputField(
                        icon: Icons.password,
                        obscureText: oldPassView,
                        controller: oldPassController,
                        labelText: 'Contraseña anterior',
                        suffixIcon: IconButton(
                          icon: (oldPassView)
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                          onPressed: () {
                            oldPassView = !oldPassView;
                            setState(() {});
                          },
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Campo obligatorio';
                          }
                          return null;
                        },
                        errorText: _oldPassError,
                      ),
                      SizedBox(height: windowHeight * 0.05),
                      InputField(
                        icon: Icons.password,
                        obscureText: newPass1View,
                        controller: newPass1Controller,
                        labelText: 'Nueva contraseña',
                        suffixIcon: IconButton(
                          icon: (newPass1View)
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                          onPressed: () {
                            newPass1View = !newPass1View;
                            setState(() {});
                          },
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Campo obligatorio';
                          }
                          return null;
                        },
                        errorText: _newPass1Error,
                      ),
                      SizedBox(height: windowHeight * 0.05),
                      InputField(
                        icon: Icons.password,
                        obscureText: newPass2View,
                        controller: newPass2Controller,
                        labelText: 'Confirmar contraseña',
                        suffixIcon: IconButton(
                          icon: (newPass2View)
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                          onPressed: () {
                            newPass2View = !newPass2View;
                            setState(() {});
                          },
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Campo obligatorio';
                          }
                          if (value != newPass1Controller.text) {
                            return 'Contraseñas no coinciden';
                          }
                          return null;
                        },
                        errorText: _newPass2Error,
                      ),
                      SizedBox(
                        height: windowHeight * 0.09,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            cambiarPass();
                          },
                          child: const Text('Guardar'))
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  cambiarPass() {
    if (_formPassKey.currentState!.validate()) {
      setState(() {
        textLoading = 'Actualizando contraseña';
        isLoading = true;
      });
      usuarioProvider
          .editaPassword(oldPassController.text, newPass1Controller.text)
          .then((respuesta) {
        setState(() {
          textLoading = '';
          isLoading = false;
        });
        if (respuesta.status == 1) {
          Navigator.pop(context);
          mostrarAlerta(context, '', 'Contraseña actualziada');
        } else {
          mostrarAlerta(context, 'ERROR',
              'Ocurrio un error al realizar el cambio. ${respuesta.mensaje}');
        }
      });
    }
  }
}
