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
    await Future.delayed(const Duration(milliseconds: 100));

    // Realizar la operación de filtrado
    resultadosFiltrados = listasucursalEmpleado
        .where((element) => element.sucursalId == sucursalSeleccionado.id)
        .toList();

    // Llamar a setState si esto afecta la interfaz de usuario para actualizarla
    setState(() {});
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
                            _validarAntesDeAgregar();
                          } else {
                            _validarAntesDeEditar();
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
                    if (estatus == false)
                      SizedBox(
                        height: windowHeight * 0.05,
                      ),
                    if (estatus == false) const Divider(),
                    if (estatus == false)
                      SizedBox(
                        height: windowHeight * 0.01,
                      ),
                    if (estatus == false)
                      const Text(
                        'Empleados asiganados:',
                        style: TextStyle(fontSize: 20),
                      ),
                    if (estatus == false)
                      SizedBox(
                        height: windowHeight * 0.01,
                      ),
                    if (estatus == false)
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
                                                _eliminarUsuario(context, user);
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
                    if (estatus == false)
                      SizedBox(
                        height: windowHeight * 0.1,
                      ),
                    if (estatus == false)
                      const Text(
                        'Asignar empleado:',
                        style: TextStyle(fontSize: 20),
                      ),
                    if (estatus == false)
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
                    if (estatus == false)
                      SizedBox(
                        height: windowHeight * 0.05,
                      ),
                    if (estatus == false)
                      ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              textLoading = 'Empleado asignado a la sucursal';
                              isLoading = true;
                            });
                            if (_valueIdEmpleado == "0") {
                              mostrarAlerta(context, "Alerta",
                                  "Debe seleccionar un empleado");
                              setState(() {
                                isLoading = false;
                              });
                            } else {
                              SucursalEmpleado sucursal = SucursalEmpleado();
                              sucursal.empleadoId = int.parse(_valueIdEmpleado);
                              sucursal.sucursalId = sucursalSeleccionado.id;
                              sucursal.negocioId = sesion.idNegocio;
                              sucursal.propietarioId = sesion.idUsuario;
                              await negocio
                                  .addSucursalEmpleado(sucursal)
                                  .then((value) {
                                setState(() {
                                  textLoading =
                                      'Empleado asignado a la sucursal';
                                  isLoading = false;
                                });
                                if (value.status == 1) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  setState(() {
                                    Navigator.pushReplacementNamed(
                                        context, 'lista-sucursales');
                                  });
                                  mostrarAlerta(context, '', value.mensaje!);
                                } else {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  mostrarAlerta(
                                      context, 'ERROR', value.mensaje!);
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
                    SizedBox(
                      height: windowHeight * 0.05,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _validarAntesDeEditar() {
    if (controllerNombre.text.isEmpty) {
      mostrarAlerta(context, 'Error', 'El nombre de la sucursal es requerido.');
      return;
    }
    if (controllerEmail.text.isEmpty) {
      mostrarAlerta(context, 'Error', 'La dirección es requerida.');
      return;
    }
    if (controllerTelefono.text.isEmpty) {
      mostrarAlerta(context, 'Error', 'El teléfono es requerido.');
      return;
    }
    // Si pasa las validaciones, procedemos a editar
    _editar();
  }

  void _validarAntesDeAgregar() {
    if (controllerNombre.text.isEmpty) {
      mostrarAlerta(context, 'Error', 'El nombre de la sucursal es requerido.');
      return;
    }
    if (controllerEmail.text.isEmpty) {
      mostrarAlerta(context, 'Error', 'La dirección es requerida.');
      return;
    }
    if (controllerTelefono.text.isEmpty) {
      mostrarAlerta(context, 'Error', 'El teléfono es requerido.');
      return;
    }
    // Si pasa las validaciones, procedemos a agregar
    _agregar(sesion.idNegocio, controllerNombre.text, controllerEmail.text,
        controllerTelefono.text);
  }

  void _eliminarUsuario(BuildContext parentContext, SucursalEmpleado user) {
    showDialog(
      context: parentContext, // Asegúrate de pasar un contexto superior
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar Usuario'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [Text("¿Quieres eliminar este usuario?")],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Usa dialogContext aquí
              },
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Usa dialogContext aquí

                // Usa el parentContext para operaciones asíncronas.
                setState(() {
                  textLoading = 'Eliminando usuario';
                  isLoading = true;
                });

                try {
                  await negocio
                      .deleteEmpleadoSUcursal(user.usuarioId, user.sucursalId)
                      .then((value) {
                    if (value.status == 1) {
                      setState(() {
                        textLoading = '';
                        isLoading = false;
                      });
                      Navigator.pushReplacementNamed(
                          context, 'lista-sucursales');
                      mostrarAlerta(context, '', value.mensaje!);
                    } else {
                      mostrarAlerta(context, 'ERROR', value.mensaje!);
                    }
                  });
                } catch (e) {
                  if (mounted) {
                    setState(() {
                      textLoading = '';
                      isLoading = false;
                    });
                  }
                  mostrarAlerta(parentContext, 'ERROR', 'Ocurrió un error');
                }
              },
            ),
          ],
        );
      },
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
