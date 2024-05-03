// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:vende_facil/models/cuenta_sesion_modelo.dart';
import 'package:vende_facil/providers/usuario_provider.dart';
import 'package:vende_facil/widgets/input_field.dart';
import 'package:vende_facil/widgets/mostrar_alerta_ok.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({Key? key}) : super(key: key);
  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {

  @override
  Widget build(BuildContext context) {
    double windowWidth = MediaQuery.of(context).size.width;
    double windowHeight = MediaQuery.of(context).size.height;
    final oldPassword = TextEditingController();
    final newPassword = TextEditingController();
    final confirmarpassword = TextEditingController();
    bool passOculto1 = true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi cuenta'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                      'https://thumbs.dreamstime.com/b/l%C3%ADnea-icono-del-negro-avatar-perfil-de-usuario-121102131.jpg'),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: windowWidth * 0.8,
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nombre : ${sesion.nombreUsuario}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("email : ${sesion.email}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("Telefono : ${sesion.telefono}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text(
                'Cambiar contraseña',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: const Text('Cambia tu contraseña de acceso'),
              trailing: const Icon(Icons.arrow_right),
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: windowHeight * 0.05),
                            // ignore: sized_box_for_whitespace
                            Container(
                              width: MediaQuery.of(context).size.width * 1,
                              child: Row(
                                children: [
                                  const Flexible(
                                    child: Text(
                                      'Contraseña Anterior',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  SizedBox(width: windowWidth * 0.05),
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: TextFormField(
                                      textCapitalization:
                                          TextCapitalization.words,
                                      controller: oldPassword,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 15.0,
                                                horizontal: 1.0),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: windowHeight * 0.05),
                            // ignore: sized_box_for_whitespace
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                children: [
                                  const Flexible(
                                    child: Text(
                                      'Contraseña nueva',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  SizedBox(width: windowWidth * 0.05),
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: TextFormField(
                                      textCapitalization:
                                          TextCapitalization.words,
                                      controller: newPassword,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 15.0,
                                                horizontal: 1.0),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: windowHeight * 0.05),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                children: [
                                  const Flexible(
                                    child: Text(
                                      'Confirmar Contraseña',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  SizedBox(width: windowWidth * 0.05),
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: InputField(
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
                                      textCapitalization:
                                          TextCapitalization.words,
                                      controller: confirmarpassword,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            verificar(context, oldPassword, newPassword,
                                confirmarpassword);
                          },
                          child: const Text('Aceptar '),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: const Text('Salir de la aplicación'),
              trailing: const Icon(Icons.arrow_right),
              onTap: () {
                Navigator.pushReplacementNamed(context, 'login');
              },
            ),
          ],
        ),
      ),
    );
  }

  void verificar(
      BuildContext context,
      TextEditingController oldPassword,
      TextEditingController newPassword,
      TextEditingController confirmarpassword) {
    if (oldPassword.text.isEmpty || newPassword.text.isEmpty) {
      mostrarAlerta(context, "error", "Llene todos los campos");
    } else {
      if (confirmarpassword.text == newPassword.text) {
        cambiarContrasena(context, oldPassword, newPassword);
      } else {
        mostrarAlerta(context, "error", "Las contraseñas no coinciden");
      }
    }
  }

  void cambiarContrasena(BuildContext context,
      TextEditingController oldPassword, TextEditingController newPassword) {
    final usuario = UsuarioProvider();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Modificado Contraseña..."),
            ],
          ),
        );
      },
    );
    usuario
        .editaPassword(oldPassword.text, newPassword.text, sesion.idUsuario!)
        .then((value) {
      Navigator.pop(context);
      if (value.status == 1) {
        mostrarAlerta(context, "ok", value.mensaje!);
        Navigator.pushReplacementNamed(context, 'login');
      } else {
        mostrarAlerta(context, "error", value.mensaje!);
        return;
        
      }
    });
  }
}
