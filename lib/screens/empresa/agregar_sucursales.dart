// ignore_for_file: avoid_unnecessary_containers, unused_element

import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

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
  String _valueIdEmpleado = '0';
  List<SucursalEmpleado> resultadosFiltrados = [];

  @override
  void initState() {
    if (estatus) {
      text.text = "Nueva Sucursal";
      funcion.text = "Guardar";
      setState(() {});
    } else {
      filtrarResultados();
      controllerNombre.text = sucursalSeleccionado.nombreSucursal!;
      controllerEmail.text = sucursalSeleccionado.direccion ?? "";
      controllerTelefono.text = sucursalSeleccionado.telefono ?? "";
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

  Future<void> filtrarResultados() async {
    resultadosFiltrados.clear();
    // Simular un retraso si es necesario
    await Future.delayed(Duration(milliseconds: 100));

    // Realizar la operación de filtrado
    resultadosFiltrados = listasucursalEmpleado
        .where((element) => element.sucursalId == sucursalSeleccionado.id)
        .toList();

    // Llamar a setState si esto afecta la interfaz de usuario para actualizarla
    setState(() {});
  }

/*
  _guardarSucursal() {
    if (estatus) {
      Sucursal nueva = Sucursal();
      nueva.negocioId = sesion.idNegocio;
      nueva.nombreSucursal = controllerNombre.text;
      nueva.direccion = controllerEmail.text;
      nueva.telefono = controllerTelefono.text;
      negocio.addSucursal(nueva).then((value) {
        setState(() {
          textLoading = '';
          isLoading = false;
          globals.actualizaSucursales = true;
        });
        if (value.status == 1) {
          setState(() {
            Navigator.pushReplacementNamed(context, 'lista-sucursales');
          });
          mostrarAlerta(context, '', value.mensaje!);
        } else {
          mostrarAlerta(context, 'ERROR', value.mensaje!);
        }
      });
    } else {
      Sucursal nueva = Sucursal();
      nueva.id = sucursalSeleccionado.id;
      nueva.negocioId = sucursalSeleccionado.negocioId;
      nueva.nombreSucursal = controllerNombre.text;
      nueva.direccion = controllerEmail.text;
      nueva.telefono = controllerTelefono.text;
      negocio.editarSUcursal(nueva).then((value) {
        setState(() {
          textLoading = '';
          isLoading = false;
          globals.actualizaSucursales = true;
        });
        if (value.status == 1) {
          setState(() {
            Navigator.pushReplacementNamed(context, 'lista-sucursales');
          });
          mostrarAlerta(context, '', value.mensaje!);
        } else {
          mostrarAlerta(context, 'ERROR', value.mensaje!);
        }
      });
    }
  }
*/

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
                      globals.actualizaSucursales = true;
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
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.05),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: windowHeight * 0.05,
                    ),
                    InputField(
                        textCapitalization: TextCapitalization.words,
                        icon: Icons.holiday_village,
                        labelText: 'Nombre de la sucursal',
                        controller: controllerNombre),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    InputField(
                        textCapitalization: TextCapitalization.none,
                        keyboardType: TextInputType.emailAddress,
                        icon: Icons.gps_fixed_outlined,
                        labelText: 'Dirección',
                        controller: controllerEmail),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    InputField(
                        keyboardType: TextInputType.phone,
                        icon: Icons.smartphone,
                        labelText: 'Teléfono',
                        controller: controllerTelefono),
                    SizedBox(
                      height: windowHeight * 0.05,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          if (estatus) {
                            _agregar(sesion.idNegocio, controllerNombre.text,
                                controllerEmail.text, controllerTelefono.text);
                          } else {
                            _editar();
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
                        )),
                    SizedBox(
                      height: windowHeight * 0.05,
                    ),
                    const Divider(),
                    SizedBox(
                      height: windowHeight * 0.01,
                    ),
                    const Text(
                      'Empleados asiganados:',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      height: windowHeight * 0.01,
                    ),
                    Container(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final screenWidth =
                                MediaQuery.of(context).size.width;
                            final columnSpacing = screenWidth * 0.30;
                            return DataTable(
                              columnSpacing: columnSpacing,
                              columns: const [
                                DataColumn(label: Text('Nombre')),
                                DataColumn(label: Text('Acciones')),
                              ],
                              rows: resultadosFiltrados.map((user) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text("${user.name}"),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Eliminar Usuario'),
                                                    content: const Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                            "Quieres eliminar este usuario")
                                                      ],
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: const Text(
                                                            'Cancelar'),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: const Text(
                                                            'Confirmar'),
                                                        onPressed: () async {
                                                          showDialog(
                                                            context: context,
                                                            barrierDismissible:
                                                                false,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return const Center(
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              );
                                                            },
                                                          );
                                                          await negocio
                                                              .deleteEmpleadoSUcursal(
                                                                  user.usuarioId,
                                                                  user.sucursalId)
                                                              .then(
                                                            (value) {
                                                              setState(() {
                                                                textLoading =
                                                                    '';
                                                                isLoading =
                                                                    false;
                                                                globals.actualizarEmpleadoSucursales =
                                                                    true;
                                                              });
                                                              if (value
                                                                      .status ==
                                                                  1) {
                                                                setState(() {
                                                                  Navigator.pushReplacementNamed(
                                                                      context,
                                                                      'lista-sucursales');
                                                                });
                                                                mostrarAlerta(
                                                                    context,
                                                                    '',
                                                                    value
                                                                        .mensaje!);
                                                              } else {
                                                                Navigator.pop(
                                                                    context);
                                                                Navigator.pop(
                                                                    context);
                                                                mostrarAlerta(
                                                                    context,
                                                                    'ERROR',
                                                                    value
                                                                        .mensaje!);
                                                              }
                                                            },
                                                          );
                                                        },
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
                                  ],
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: windowHeight * 0.1,
                    ),
                    const Text(
                      'Asignar empleado:',
                      style: TextStyle(fontSize: 20),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: windowWidth * 0.2,
                          child: const Text(
                            'Seleccione Empleado',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: windowWidth * 0.1),
                        Expanded(
                          child: _empleado(),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: windowHeight * 0.05,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          if (_valueIdEmpleado == "0") {
                            mostrarAlerta(context, "Alerta",
                                "Debe seleccionar un empleado");
                          } else {
                            SucursalEmpleado sucursal = SucursalEmpleado();
                            sucursal.empleadoId = int.parse(_valueIdEmpleado);
                            sucursal.sucursalId = sucursalSeleccionado.id;
                            sucursal.negocioId = sesion.idNegocio;
                            sucursal.propietarioId = sesion.idUsuario;
                            negocio.addSucursalEmpleado(sucursal).then((value) {
                              setState(() {
                                textLoading = '';
                                isLoading = false;
                                globals.actualizarEmpleadoSucursales = true;
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
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add),
                            SizedBox(
                              width: 10,
                            ),
                            Text("Agregar"),
                          ],
                        )),
                  ],
                ),
              ),
            ),
    );
  }

  _editar() {
    Sucursal nueva = Sucursal();
    nueva.id = sucursalSeleccionado.id;
    nueva.negocioId = sucursalSeleccionado.negocioId;
    nueva.nombreSucursal = controllerNombre.text;
    nueva.direccion = controllerEmail.text;
    nueva.telefono = controllerTelefono.text;
    negocio.editarSUcursal(nueva).then((value) {
      setState(() {
        textLoading = '';
        isLoading = false;
        globals.actualizaSucursales = true;
      });
      if (value.status == 1) {
        setState(() {
          Navigator.pushReplacementNamed(context, 'lista-sucursales');
        });
        mostrarAlerta(context, '', value.mensaje!);
      } else {
        mostrarAlerta(context, 'ERROR', value.mensaje!);
      }
    });
  }

  _agregar(seccion, nombre, direcion, telefono) {
    Sucursal nueva = Sucursal();
    nueva.negocioId = seccion;
    nueva.nombreSucursal = nombre;
    nueva.direccion = direcion;
    nueva.telefono = telefono;
    negocio.addSucursal(nueva).then((value) {
      setState(() {
        textLoading = '';
        isLoading = false;
        globals.actualizaSucursales = true;
      });
      if (value.status == 1) {
        setState(() {
          Navigator.pushReplacementNamed(context, 'lista-sucursales');
        });
        mostrarAlerta(context, '', value.mensaje!);
      } else {
        mostrarAlerta(context, 'ERROR', value.mensaje!);
      }
    });
  }

  _empleado() {
    var listades = [
      const DropdownMenuItem(
        value: '0',
        child: SizedBox(child: Text('Todos')),
      )
    ];
    for (Usuario empleado in listaEmpleados) {
      listades.add(DropdownMenuItem(
          value: empleado.id.toString(), child: Text(empleado.nombre!)));
    }
    if (_valueIdEmpleado.isEmpty) {
      _valueIdEmpleado = '0';
    }
    return DropdownButton(
      items: listades,
      isExpanded: true,
      value: _valueIdEmpleado,
      onChanged: (value) {
        _valueIdEmpleado = value!;
        if (value == "0") {
        } else {
          Usuario empleadoSeleccionado = listaEmpleados
              .firstWhere((empleado) => empleado.id.toString() == value);
          if (empleadoSeleccionado.id == 0) {
            _valueIdEmpleado = '0';
            setState(() {});
          } else {
            _valueIdEmpleado = empleadoSeleccionado.id.toString();
            setState(() {});
          }
        }
      },
    );
  }
}
