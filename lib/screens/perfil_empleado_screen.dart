import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/usuario_provider.dart';

class PerfilEmpleadosScreen extends StatelessWidget {
  // ignore: use_super_parameters
  const PerfilEmpleadosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double windowWidth = MediaQuery.of(context).size.width;
    double windowHeight = MediaQuery.of(context).size.height;
    final newPassword = TextEditingController();
    // ignore: non_constant_identifier_names
    final  ConfirmarPassword = TextEditingController();
    final usuario = UsuarioProvider();
    final String empleadoId = ModalRoute.of(context)!.settings.arguments.toString();

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
                  child: Icon(
                    CupertinoIcons.person_solid, 
                    size: 70, 
                    color: Colors.black, 
                  ),
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
                  Text("Nombre : ${listaEmpleados[int.parse(empleadoId)].nombre}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("email : ${listaEmpleados[int.parse(empleadoId)].email}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("Telefono : ${listaEmpleados[int.parse(empleadoId)].telefono}",
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
                            // ignore: sized_box_for_whitespace
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                children: [
                                  const Flexible(
                                    child: Text(
                                      'Confirmar Contraseña nueva',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  SizedBox(width: windowWidth * 0.05),
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: TextFormField(
                                      textCapitalization:
                                          TextCapitalization.words,
                                      controller: ConfirmarPassword,
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
                          ],
                        ),
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            usuario
                                .editaPassword(ConfirmarPassword.text,
                                    newPassword.text, sesion.idUsuario!)
                                .then((value) {
                              if (value.status == 1) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('Contraseña actualizada'),
                                ));
                                Navigator.pushReplacementNamed(
                                    context, 'login');
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(value.mensaje!),
                                ));
                              }
                            });
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
          ],
        ),
      ),
    );
  }
}
