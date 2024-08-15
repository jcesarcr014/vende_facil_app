// ignore_for_file: use_super_parameters, use_build_context_synchronously, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:vende_facil/models/cuenta_sesion_modelo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/mostrar_alerta_ok.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});
  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  double windowWidth = 0.0;
  double windowHeight = 0.0;

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;

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
                  Text("Correo : ${sesion.email}",
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
                Navigator.pushNamed(context, 'nvo-pass');
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
              subtitle: const Text('Salir de la sesión actual'),
              trailing: const Icon(Icons.arrow_right),
              onTap: () {
                _showPasswordDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  final String email = sesion.email!;

  void _showPasswordDialog(BuildContext context) {
    TextEditingController _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agrega tu contraseña'),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Contraseña',
            ),
          ),
          actions: [
            TextButton(
              onPressed: (){
                if (_passwordController.text.isEmpty) {
                   Navigator.of(context).pop();
                  mostrarAlerta(
                      context, "alerta", "Por favor ingresa una contraseña.");
                } else {
                  
                  UsuarioProvider()
                      .logout(email, _passwordController.text)
                      .then((value)  {
                    print(value.status);
                    print(value.mensaje);
                    if (value.status == 1) {
                      Navigator.pushReplacementNamed(context, 'login');
                    } else {
                      mostrarAlerta(context, "alerta", value.mensaje!);
                      Navigator.of(context).pop();
                    }
                  });
                }
              },
              child: const Text('Aceptar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}
