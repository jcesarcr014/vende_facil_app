import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/usuario_provider.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:vende_facil/widgets/widgets.dart';

class PerfilEmpleadosScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const PerfilEmpleadosScreen({Key? key}) : super(key: key);

  @override
  State<PerfilEmpleadosScreen> createState() => _PerfilEmpleadosScreenState();
}

class _PerfilEmpleadosScreenState extends State<PerfilEmpleadosScreen> {
  bool cambiaPass = false;
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  bool estatus = (empleadoSeleccionado.estatus == '1') ? true : false;
  final newPassword = TextEditingController();
  final confirmarPassword = TextEditingController();
  final usuarioProvider = UsuarioProvider();

  _cambiaEstatus() {
    setState(() {
      isLoading = true;
      textLoading = 'Actualizando estatus';
    });
    if (estatus) {
      empleadoSeleccionado.estatus = '1';
    } else {
      empleadoSeleccionado.estatus = '0';
    }

    usuarioProvider
        .estatusEmpleado(
            empleadoSeleccionado.id!, empleadoSeleccionado.estatus!)
        .then((value) {
      setState(() {
        isLoading = false;
        textLoading = '';
      });
      if (value.status != 1) {
        mostrarAlerta(context, 'ERROR', 'value.mensaje!');
      } else {
        globals.actualizaEmpleados = true;
      }
    });
  }

  _cambiaPassword() {
    if (newPassword.text.isEmpty || confirmarPassword.text.isEmpty) {
      mostrarAlerta(context, 'ERROR', 'Las contraseñas no pueden estar vacias');
      return;
    }
    if (newPassword.text != confirmarPassword.text) {
      mostrarAlerta(context, 'ERROR', 'Las contraseñas no coinciden');
      return;
    }
    setState(() {
      isLoading = true;
      textLoading = 'Actualizando contraseña';
    });

    usuarioProvider
        .cambiaPasswordEmpleado(empleadoSeleccionado.id!, newPassword.text)
        .then((value) {
      setState(() {
        isLoading = false;
        textLoading = '';
      });
      if (value.status != 1) {
        mostrarAlerta(context, 'ERROR', value.mensaje!);
      } else {
        mostrarAlerta(context, 'Éxito', 'Contraseña actualizada correctamente');
      }
    });
  }

  _mostarAlertaEliminar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar empleado'),
          content: const Text('¿Está seguro de eliminar este empleado?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _eliminarEmpleado();
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  _eliminarEmpleado() {
    setState(() {
      isLoading = true;
      textLoading = 'Eliminando empleado';
    });

    usuarioProvider.eliminaEmpleado(empleadoSeleccionado.id!).then((value) {
      setState(() {
        isLoading = false;
        textLoading = '';
      });
      if (value.status != 1) {
        mostrarAlerta(context, 'ERROR', value.mensaje!);
      } else {
        globals.actualizaEmpleados = true;

        Navigator.pushReplacementNamed(context, 'config');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de empleado'),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _mostarAlertaEliminar();
            },
          )
        ],
      ),
      body: (isLoading)
          ? Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Espere...$textLoading'),
                    const SizedBox(
                      height: 10,
                    ),
                    const CircularProgressIndicator(),
                  ]),
            )
          : SingleChildScrollView(
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
                        Text("Nombre : ${empleadoSeleccionado.nombre}",
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text("email : ${empleadoSeleccionado.email}",
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text("Telefono : ${empleadoSeleccionado.telefono}",
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  SwitchListTile.adaptive(
                      title: const Text('Estatus de empleado'),
                      subtitle: (empleadoSeleccionado.estatus == '1')
                          ? const Text('Puede iniciar sesión')
                          : const Text('No puede iniciar sesión'),
                      value: estatus,
                      onChanged: (value) {
                        estatus = value;
                        _cambiaEstatus();
                      }),
                  const SizedBox(height: 20),
                  (!cambiaPass)
                      ? ListTile(
                          leading: const Icon(Icons.lock),
                          title: const Text(
                            'Restaurar contraseña',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle:
                              const Text('Cambiar contraseña del empleado'),
                          trailing: const Icon(Icons.arrow_right),
                          onTap: () {
                            setState(() {
                              cambiaPass = true;
                            });
                          },
                        )
                      : Container(),
                  const SizedBox(height: 20),
                  (cambiaPass)
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              InputField(
                                  controller: newPassword,
                                  labelText: 'Nueva contraseña'),
                              const SizedBox(height: 10),
                              InputField(
                                  controller: confirmarPassword,
                                  labelText: 'Confirmar contraseña'),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _cambiaPassword();
                                    },
                                    child: const Text('Cambiar contraseña'),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        cambiaPass = false;
                                      });
                                    },
                                    child: const Text('Cancelar'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
    );
  }
}
