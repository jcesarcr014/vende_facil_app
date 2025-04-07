// ignore_for_file: avoid_unnecessary_containers, unused_element

import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
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
  final _formKey = GlobalKey<FormState>();

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
    return Scaffold(
      appBar: AppBar(
        title: Text(text.text),
        automaticallyImplyLeading: false,
        elevation: 2,
        actions: [
          if (!estatus)
            IconButton(
              onPressed: () => _alertaEliminar(),
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Eliminar sucursal',
            ),
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, 'lista-sucursales');
            },
            icon: const Icon(Icons.close),
            tooltip: 'Cancelar',
          ),
        ],
      ),
      body: isLoading ? _buildLoadingIndicator() : _buildContent(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Espere... $textLoading',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection(),
            if (!estatus) const SizedBox(height: 32),
            if (!estatus) _buildEmpleadosSection(),
            if (!estatus) const SizedBox(height: 32),
            if (!estatus) _buildAsignarEmpleadoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              'Información de la Sucursal',
              Icons.store_outlined,
              Colors.blue,
            ),
            const SizedBox(height: 24),
            _buildFormField(
              labelText: 'Nombre de la sucursal:',
              textCapitalization: TextCapitalization.words,
              controller: controllerNombre,
              icon: Icons.storefront_outlined,
              required: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre de la sucursal es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildFormField(
              labelText: 'Dirección:',
              textCapitalization: TextCapitalization.sentences,
              controller: controllerEmail,
              icon: Icons.location_on_outlined,
              required: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La dirección es requerida';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildFormField(
              labelText: 'Teléfono:',
              keyboardType: TextInputType.phone,
              controller: controllerTelefono,
              icon: Icons.phone_outlined,
              required: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El teléfono es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpleadosSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              'Empleados Asignados',
              Icons.people_outline,
              Colors.green,
            ),
            const SizedBox(height: 16),
            resultadosFiltrados.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No hay empleados asignados a esta sucursal',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                : _buildEmpleadosTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpleadosTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
            columns: const [
              DataColumn(
                label: Text(
                  'Nombre',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Acciones',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: resultadosFiltrados.map((user) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      "${user.name}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  DataCell(
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () {
                        _eliminarUsuario(context, user);
                      },
                      tooltip: 'Eliminar empleado',
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildAsignarEmpleadoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              'Asignar Empleado',
              Icons.person_add_outlined,
              Colors.orange,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Seleccione Empleado:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _buildEmpleadoDropdown(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _agregarEmpleado,
                icon: const Icon(Icons.add),
                label: const Text("Asignar Empleado"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpleadoDropdown() {
    var listades = [
      const DropdownMenuItem(
        value: '0',
        child: Text('Seleccione un empleado'),
      )
    ];

    for (Usuario empleado in listaEmpleados) {
      listades.add(DropdownMenuItem(
        value: empleado.id.toString(),
        child: Text(empleado.nombre!, overflow: TextOverflow.ellipsis),
      ));
    }

    if (_valueIdEmpleado.isEmpty) {
      _valueIdEmpleado = '0';
    }

    return DropdownButton(
      items: listades,
      isExpanded: true,
      value: _valueIdEmpleado,
      underline: Container(),
      onChanged: (value) {
        setState(() {
          _valueIdEmpleado = value!;
          if (value != "0") {
            Usuario empleadoSeleccionado = listaEmpleados.firstWhere(
                (empleado) => empleado.id.toString() == value,
                orElse: () => Usuario(id: 0));

            if (empleadoSeleccionado.id == 0) {
              _valueIdEmpleado = '0';
            } else {
              _valueIdEmpleado = empleadoSeleccionado.id.toString();
            }
          }
        });
      },
    );
  }

  _agregarEmpleado() async {
    if (_valueIdEmpleado == "0") {
      mostrarAlerta(context, "Alerta", "Debe seleccionar un empleado");
      return;
    }

    setState(() {
      textLoading = 'Asignando empleado a la sucursal';
      isLoading = true;
    });

    SucursalEmpleado sucursal = SucursalEmpleado();
    sucursal.empleadoId = int.parse(_valueIdEmpleado);
    sucursal.sucursalId = sucursalSeleccionado.id;
    sucursal.negocioId = sesion.idNegocio;
    sucursal.propietarioId = sesion.idUsuario;

    try {
      var response = await negocio.addSucursalEmpleado(sucursal);
      setState(() {
        textLoading = '';
        isLoading = false;
      });

      if (response.status == 1) {
        Navigator.pushReplacementNamed(context, 'lista-sucursales');
        mostrarAlerta(context, '', response.mensaje!);
      } else {
        mostrarAlerta(context, 'ERROR', response.mensaje!);
      }
    } catch (e) {
      setState(() {
        textLoading = '';
        isLoading = false;
      });
      mostrarAlerta(context, 'ERROR', 'Ocurrió un error inesperado');
    }
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String labelText,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    bool required = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      readOnly: readOnly,
      validator: validator,
      decoration: InputDecoration(
        labelText: required ? '$labelText *' : labelText,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey[100] : null,
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          if (estatus) {
            _validarAntesDeAgregar();
          } else {
            _validarAntesDeEditar();
          }
        },
        icon: const Icon(Icons.save_outlined),
        label: Text(funcion.text),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _validarAntesDeEditar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _editar();
  }

  void _validarAntesDeAgregar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _agregar(
      sesion.idNegocio,
      controllerNombre.text,
      controllerEmail.text,
      controllerTelefono.text,
    );
  }

  _alertaEliminar() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'ATENCIÓN',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Desea eliminar la sucursal ${sucursalSeleccionado.nombreSucursal}? Esta acción no podrá revertirse.',
                textAlign: TextAlign.center,
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _eliminarSucursal();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child:
                  const Text('Eliminar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  _eliminarSucursal() {
    setState(() {
      textLoading = 'Eliminando sucursal';
      isLoading = true;
    });

    negocio.deleteSUcursal(sucursalSeleccionado).then((value) {
      setState(() {
        textLoading = '';
        isLoading = false;
      });
      if (value.status == 1) {
        Navigator.pushReplacementNamed(context, 'lista-sucursales');
        mostrarAlerta(context, '', value.mensaje!);
      } else {
        mostrarAlerta(context, 'ERROR', value.mensaje!);
      }
    });
  }

  void _eliminarUsuario(BuildContext parentContext, SucursalEmpleado user) {
    showDialog(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Eliminar Empleado',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "¿Está seguro que desea eliminar a ${user.name} de esta sucursal?",
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child:
                  const Text('Eliminar', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                setState(() {
                  textLoading = 'Eliminando empleado de la sucursal';
                  isLoading = true;
                });

                try {
                  await negocio
                      .deleteEmpleadoSUcursal(user.usuarioId, user.sucursalId)
                      .then((value) {
                    setState(() {
                      textLoading = '';
                      isLoading = false;
                    });
                    if (value.status == 1) {
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
    setState(() {
      textLoading = 'Actualizando sucursal';
      isLoading = true;
    });

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
        Navigator.pushReplacementNamed(context, 'lista-sucursales');
        mostrarAlerta(context, '', value.mensaje!);
      } else {
        mostrarAlerta(context, 'ERROR', value.mensaje!);
      }
    });
  }

  _agregar(seccion, nombre, direcion, telefono) {
    setState(() {
      textLoading = 'Registrando nueva sucursal';
      isLoading = true;
    });

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
        Navigator.pushReplacementNamed(context, 'lista-sucursales');
        mostrarAlerta(context, '', value.mensaje!);
      } else {
        mostrarAlerta(context, 'ERROR', value.mensaje!);
      }
    });
  }
}
