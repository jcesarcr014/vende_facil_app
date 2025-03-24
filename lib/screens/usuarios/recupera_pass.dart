import 'package:flutter/material.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/providers/providers.dart';

class RecuperaPassScreen extends StatefulWidget {
  const RecuperaPassScreen({super.key});

  @override
  State<RecuperaPassScreen> createState() => _RecuperaPassScreenState();
}

class _RecuperaPassScreenState extends State<RecuperaPassScreen> {
  final usuariosProvider = UsuarioProvider();
  final controllerUser = TextEditingController();
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  bool isLoading = false;
  bool passOculto1 = true;
  String textLoading = '';

  @override
  void dispose() {
    controllerUser.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        body: (isLoading)
            ? Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: windowHeight * 0.15,
                    ),
                    SizedBox(
                        width: windowWidth * 0.4,
                        child:
                            const Image(image: AssetImage('assets/logo.png'))),
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
                child: Column(
                  children: [
                    SizedBox(
                      height: windowHeight * 0.15,
                    ),
                    SizedBox(
                        width: windowWidth * 0.4,
                        child:
                            const Image(image: AssetImage('assets/logo.png'))),
                    SizedBox(
                      height: windowHeight * 0.05,
                    ),
                    Text('Recuperar Contraseña',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: windowHeight * 0.05,
                    ),
                    InputField(
                        icon: Icons.email,
                        labelText: 'Correo electrónico',
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'El correo es obligatorio';
                          }
                          return null;
                        },
                        controller: controllerUser),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    SizedBox(
                      height: windowHeight * 0.06,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          _recuperar();
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send),
                            SizedBox(
                              width: 10,
                            ),
                            Text('Enviar'),
                          ],
                        )),
                  ],
                ),
              ));
  }

  _recuperar() {
    setState(() {
      isLoading = true;
      textLoading = 'Enviando correo...';
    });
    usuariosProvider.recuperaPass(controllerUser.text).then((resp) {
      setState(() {
        isLoading = false;
        textLoading = '';
      });
      Navigator.pop(context);
      if (resp.status == 1) {
        mostrarAlerta(context, 'Atención',
            'Se ha enviado un correo a ${controllerUser.text} con las instrucciones para recuperar su contraseña');
      } else {
        mostrarAlerta(context, 'Error',
            'Ocurrio un error al enviar el correo, ${resp.mensaje}');
      }
    });
  }
}
