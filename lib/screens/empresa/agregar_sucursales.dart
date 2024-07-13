import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';

class RegistroSucursalesScreen extends StatefulWidget {
  const RegistroSucursalesScreen({super.key});

  @override
  State<RegistroSucursalesScreen> createState() =>
      _RegistroSucursalesScreenState();
}

class _RegistroSucursalesScreenState extends State<RegistroSucursalesScreen> {
  final negocio = NegocioProvider();
  final text = TextEditingController();
  final funcion = TextEditingController();
  final controllerNombre = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerTelefono = TextEditingController();
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  bool estatus = (sucursalSeleccionado.nombreSucursal == null) ? true : false;
  bool isLoading = false;
  String textLoading = '';
  @override
  void initState() {
    if (estatus) {
      text.text = "Nueva Sucursal";
      funcion.text = "Registrarse";
      setState(() {});
    } else {
      controllerNombre.text = sucursalSeleccionado.nombreSucursal!;
      controllerEmail.text = sucursalSeleccionado.direccion!;
      controllerTelefono.text = sucursalSeleccionado.telefono!;
      text.text = "Editar Sucursal";
      funcion.text = "Editar";
      setState(() {});
    }
    super.initState();
  }

  @override
  void dispose() {
    controllerNombre.dispose();
    controllerEmail.dispose();
    controllerTelefono.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(text.text),
        actions: [
          if (!estatus)
            IconButton(
                onPressed: () {
                  negocio.deleteSUcursal(sucursalSeleccionado).then((value) {
                              setState(() {
                                textLoading = '';
                                isLoading = false;
                                actualizaSucursales = true;
                              });
                              if (value.status == 1) {
                                setState(() {
                                  Navigator.pushReplacementNamed(
                                      context, 'lista-sucursales');
                                });

                                mostrarAlerta(context, '', value.mensaje!);
                              } else {
                                mostrarAlerta(context, 'ERROR', value.mensaje!);
                              }
                  });
                },
                icon: const Icon(Icons.delete))
        ],
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
                          if (estatus) {
                            Sucursale nueva = Sucursale();
                            nueva.negocioId = sesion.idNegocio;
                            nueva.nombreSucursal = controllerNombre.text;
                            nueva.direccion = controllerEmail.text;
                            nueva.telefono = controllerTelefono.text;
                            negocio.addSucursal(nueva).then((value) {
                              setState(() {
                                textLoading = '';
                                isLoading = false;
                                actualizaSucursales = true;
                              });
                              if (value.status == 1) {
                                setState(() {
                                  Navigator.pushReplacementNamed(
                                      context, 'lista-sucursales');
                                });

                                mostrarAlerta(context, '', value.mensaje!);
                              } else {
                                mostrarAlerta(context, 'ERROR', value.mensaje!);
                              }
                            });
                          } else {
                            Sucursale nueva = Sucursale();
                            nueva.id = sucursalSeleccionado.id;
                            nueva.negocioId = sucursalSeleccionado.negocioId;
                            nueva.nombreSucursal = controllerNombre.text;
                            nueva.direccion = controllerEmail.text;
                            nueva.telefono = controllerTelefono.text;
                            negocio.editarSUcursal(nueva).then((value) {
                              setState(() {
                                textLoading = '';
                                isLoading = false;
                                actualizaSucursales = true;
                              });
                              if (value.status == 1) {
                                setState(() {
                                  Navigator.pushReplacementNamed(
                                      context, 'lista-sucursales');
                                });

                                mostrarAlerta(context, '', value.mensaje!);
                              } else {
                                mostrarAlerta(context, 'ERROR', value.mensaje!);
                              }
                            });
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.save),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(funcion.text),
                          ],
                        ))
                  ],
                ),
              ),
            ),
    );
  }
}
