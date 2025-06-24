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
  final negocioProvider = NegocioProvider(); // Renombrado para consistencia
  final controllerNombre = TextEditingController();
  final controllerDireccion =
      TextEditingController(); // Renombrado desde controllerEmail
  final controllerTelefono = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _esNuevaSucursal = true; // Para determinar si es modo nuevo o edición
  bool _isLoading = false;
  String _textLoading = '';
  String _tituloPantalla = "Nueva Sucursal";
  String _textoBotonGuardar = "Guardar";

  String _valueIdEmpleado = '0';
  List<SucursalEmpleado> _empleadosAsignadosFiltrados = [];

  @override
  void initState() {
    super.initState();
    // Determinar si es nuevo o edición basado en sucursalSeleccionado
    if (sucursalSeleccionado.id != null && sucursalSeleccionado.id != 0) {
      _esNuevaSucursal = false;
      _tituloPantalla = "Editar Sucursal";
      _textoBotonGuardar = "Actualizar";
      controllerNombre.text = sucursalSeleccionado.nombreSucursal ?? "";
      controllerDireccion.text = sucursalSeleccionado.direccion ?? "";
      controllerTelefono.text = sucursalSeleccionado.telefono ?? "";
      _cargarEmpleadosAsignados(); // Cargar empleados solo si estamos editando
    } else {
      _esNuevaSucursal = true;
      sucursalSeleccionado
          .limpiar(); // Asegurar que esté limpio para nueva sucursal
    }
  }

  Future<void> _cargarEmpleadosAsignados() async {
    _filtrarEmpleadosActuales();
  }

  void _filtrarEmpleadosActuales() {
    // Renombrada desde filtrarResultados
    if (!mounted) return;
    setState(() {
      _empleadosAsignadosFiltrados =
          listasucursalEmpleado // Asume que listasucursalEmpleado está actualizada
              .where((element) => element.sucursalId == sucursalSeleccionado.id)
              .toList();
    });
  }

  @override
  void dispose() {
    controllerNombre.dispose();
    controllerDireccion.dispose();
    controllerTelefono.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool mostrarSeccionEmpleados =
        (suscripcionActual.limiteEmpleados ?? 0) > 0;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.pop(
              context, false); // Indicar que no hubo cambios (o cancelado)
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_tituloPantalla),
          automaticallyImplyLeading: false,
          elevation: 2,
          actions: [
            if (!_esNuevaSucursal) // Solo mostrar eliminar si estamos editando
              IconButton(
                onPressed: _alertaEliminar,
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Eliminar sucursal',
              ),
            IconButton(
              onPressed: () {
                // Al cerrar, siempre hacemos pop, la pantalla anterior decidirá si recarga.
                Navigator.pop(context,
                    false); // false indica que no se guardaron cambios aquí
              },
              icon: const Icon(Icons.close),
              tooltip: 'Cancelar',
            ),
          ],
        ),
        body: _isLoading
            ? _buildLoadingIndicator()
            : _buildContent(mostrarSeccionEmpleados),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Espere... $_textLoading',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildContent(bool mostrarSeccionEmpleados) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection(), // Contiene el botón de guardar/actualizar
            if (!_esNuevaSucursal && mostrarSeccionEmpleados) ...[
              // Solo si edita y puede tener empleados
              const SizedBox(height: 24),
              _buildEmpleadosSection(),
              const SizedBox(height: 24),
              _buildAsignarEmpleadoSection(),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Información de la Sucursal',
                Icons.store_outlined, Colors.blue),
            const SizedBox(height: 24),
            _buildFormField(
                labelText: 'Nombre de la sucursal:',
                textCapitalization: TextCapitalization.words,
                controller: controllerNombre,
                icon: Icons.storefront_outlined,
                required: true,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nombre requerido' : null),
            const SizedBox(height: 16),
            _buildFormField(
                labelText: 'Dirección:',
                textCapitalization: TextCapitalization.sentences,
                controller: controllerDireccion,
                icon: Icons.location_on_outlined,
                required: true,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Dirección requerida' : null),
            const SizedBox(height: 16),
            _buildFormField(
                labelText: 'Teléfono:',
                keyboardType: TextInputType.phone,
                controller: controllerTelefono,
                icon: Icons.phone_outlined,
                required: true,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Teléfono requerido' : null),
            const SizedBox(height: 24),
            SizedBox(
              // Botón de Guardar / Actualizar
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _guardarOEditarSucursal,
                icon: const Icon(Icons.save_outlined),
                label: Text(_textoBotonGuardar),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarOEditarSucursal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _textLoading = _esNuevaSucursal
          ? 'Registrando sucursal...'
          : 'Actualizando sucursal...';
    });

    Sucursal sucursalParaGuardar = Sucursal(
      id: _esNuevaSucursal ? null : sucursalSeleccionado.id,
      negocioId: sesion.idNegocio, // Siempre el negocio actual
      nombreSucursal: controllerNombre.text,
      direccion: controllerDireccion.text,
      telefono: controllerTelefono.text,
    );

    Resultado resultadoApi;
    if (_esNuevaSucursal) {
      resultadoApi = await negocioProvider.addSucursal(sucursalParaGuardar);
    } else {
      resultadoApi = await negocioProvider.editarSUcursal(sucursalParaGuardar);
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _textLoading = '';
    });

    if (resultadoApi.status == 1) {
      mostrarAlerta(context, 'Éxito', resultadoApi.mensaje!);
      Navigator.pop(context,
          true); // true para indicar que la lista anterior debe recargar
    } else {
      mostrarAlerta(context, 'Error',
          resultadoApi.mensaje ?? 'No se pudo guardar la sucursal.');
    }
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
            _empleadosAsignadosFiltrados.isEmpty
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
            headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
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
            rows: _empleadosAsignadosFiltrados.map((user) {
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
      _textLoading = 'Asignando empleado a la sucursal';
      _isLoading = true;
    });

    SucursalEmpleado sucursal = SucursalEmpleado();
    sucursal.empleadoId = int.parse(_valueIdEmpleado);
    sucursal.sucursalId = sucursalSeleccionado.id;
    sucursal.negocioId = sesion.idNegocio;
    sucursal.propietarioId = sesion.idUsuario;

    try {
      var response = await negocioProvider.addSucursalEmpleado(sucursal);
      setState(() {
        _textLoading = '';
        _isLoading = false;
      });

      if (response.status == 1) {
        Navigator.pushReplacementNamed(context, 'lista-sucursales');
        mostrarAlerta(context, '', response.mensaje!);
      } else {
        mostrarAlerta(context, 'ERROR', response.mensaje!);
      }
    } catch (e) {
      setState(() {
        _textLoading = '';
        _isLoading = false;
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
            color: color.withValues(alpha: 0.1),
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
          if (_esNuevaSucursal) {
            _validarAntesDeAgregar();
          } else {
            _validarAntesDeEditar();
          }
        },
        icon: const Icon(Icons.save_outlined),
        label: Text(_esNuevaSucursal ? 'Agregar' : 'Editar'),
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
      controllerDireccion.text,
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
      _textLoading = 'Eliminando sucursal';
      _isLoading = true;
    });

    negocioProvider.deleteSUcursal(sucursalSeleccionado).then((value) {
      setState(() {
        _textLoading = '';
        _isLoading = false;
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
                  _textLoading = 'Eliminando empleado de la sucursal';
                  _isLoading = true;
                });

                try {
                  await negocioProvider
                      .deleteEmpleadoSUcursal(user.usuarioId, user.sucursalId)
                      .then((value) {
                    setState(() {
                      _textLoading = '';
                      _isLoading = false;
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
                      _textLoading = '';
                      _isLoading = false;
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
      _textLoading = 'Actualizando sucursal';
      _isLoading = true;
    });

    Sucursal nueva = Sucursal();
    nueva.id = sucursalSeleccionado.id;
    nueva.negocioId = sucursalSeleccionado.negocioId;
    nueva.nombreSucursal = controllerNombre.text;
    nueva.direccion = controllerDireccion.text;
    nueva.telefono = controllerTelefono.text;

    negocioProvider.editarSUcursal(nueva).then((value) {
      setState(() {
        _textLoading = '';
        _isLoading = false;
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
      _textLoading = 'Registrando nueva sucursal';
      _isLoading = true;
    });

    Sucursal nueva = Sucursal();
    nueva.negocioId = seccion;
    nueva.nombreSucursal = nombre;
    nueva.direccion = direcion;
    nueva.telefono = telefono;

    negocioProvider.addSucursal(nueva).then((value) {
      setState(() {
        _textLoading = '';
        _isLoading = false;
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
