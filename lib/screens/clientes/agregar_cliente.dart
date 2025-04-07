import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';

class AgregaClienteScreen extends StatefulWidget {
  const AgregaClienteScreen({super.key});

  @override
  State<AgregaClienteScreen> createState() => _AgregaClienteScreenState();
}

class _AgregaClienteScreenState extends State<AgregaClienteScreen> {
  final clienteProvider = ClienteProvider();
  final controllerNombre = TextEditingController();
  final controllerCorreo = TextEditingController();
  final controllerTelefono = TextEditingController();
  final controllerDireccion = TextEditingController();
  final controllerCiudad = TextEditingController();
  final controllerEstado = TextEditingController();
  final controllerCP = TextEditingController();
  final controllerPais = TextEditingController();
  final controllerCodigo = TextEditingController();
  final controllerNota = TextEditingController();
  bool firstLoad = true;
  bool isLoading = false;
  String textLoading = '';
  Cliente args = Cliente(id: 0, nombre: '', correo: '');
  bool _valuecliente = false;

  String _generaCodigo() {
    final numClientes = (listaClientes.length + 1).toString();
    final numEmpresa = sesion.idNegocio.toString();
    final numUsuario = sesion.idUsuario.toString();
    final tipoUSer = sesion.tipoUsuario.toString();
    final codigo = '${numEmpresa}0$numUsuario${tipoUSer}000$numClientes';

    return codigo;
  }

  _guardaCliente() {
    if (controllerNombre.text.isEmpty) {
      mostrarAlerta(context, 'Error', 'El campo nombre es obligatorio');
      return;
    }

    setState(() {
      textLoading =
          (args.id == 0) ? 'Registrando cliente' : 'Actualizando cliente';
      isLoading = true;
    });

    Cliente cliente = Cliente();
    cliente.nombre = controllerNombre.text;
    cliente.correo = controllerCorreo.text;
    cliente.telefono = controllerTelefono.text;
    cliente.direccion = controllerDireccion.text;
    cliente.ciudad = controllerCiudad.text;
    cliente.estado = controllerEstado.text;
    cliente.cp = controllerCP.text;
    cliente.pais = controllerPais.text;
    cliente.codigoCliente = controllerCodigo.text;
    cliente.nota = controllerNota.text;
    cliente.distribuidor = (_valuecliente) ? 1 : 0;

    if (args.id == 0) {
      clienteProvider.nuevoCliente(cliente).then((value) {
        setState(() {
          isLoading = false;
          textLoading = '';
        });
        if (value.status == 1) {
          Navigator.pushReplacementNamed(context, 'clientes');
          mostrarAlerta(context, '', value.mensaje!);
        } else {
          mostrarAlerta(context, '', value.mensaje!);
        }
      });
    } else {
      cliente.id = args.id;
      clienteProvider.editaCliente(cliente).then((value) {
        setState(() {
          isLoading = false;
          textLoading = '';
        });
        if (value.status == 1) {
          Navigator.pushReplacementNamed(context, 'clientes');
          mostrarAlerta(context, '', value.mensaje!);
        } else {
          mostrarAlerta(context, '', value.mensaje!);
        }
      });
    }
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
                  '¿Desea eliminar el cliente ${args.nombre} - ${args.codigoCliente}? Esta acción no podrá revertirse.',
                  textAlign: TextAlign.center,
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar',
                    style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _eliminarCliente();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Eliminar',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
  }

  _eliminarCliente() {
    setState(() {
      textLoading = 'Eliminando cliente';
      isLoading = true;
    });

    clienteProvider.eliminaCliente(args.id!).then((value) {
      setState(() {
        textLoading = '';
        isLoading = false;
      });
      if (value.status == 1) {
        Navigator.pushReplacementNamed(context, 'clientes');
        mostrarAlerta(context, '', value.mensaje!);
      } else {
        mostrarAlerta(context, '', value.mensaje!);
      }
    });
  }

  @override
  void dispose() {
    controllerNombre.dispose();
    controllerCorreo.dispose();
    controllerTelefono.dispose();
    controllerDireccion.dispose();
    controllerCiudad.dispose();
    controllerEstado.dispose();
    controllerCP.dispose();
    controllerPais.dispose();
    controllerCodigo.dispose();
    controllerNota.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (args.id == 0) {
      controllerCodigo.text = _generaCodigo();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)?.settings.arguments != null && firstLoad) {
      firstLoad = false;
      args = ModalRoute.of(context)?.settings.arguments as Cliente;
      controllerNombre.text = args.nombre ?? '';
      controllerCorreo.text = args.correo ?? '';
      controllerTelefono.text = args.telefono ?? '';
      controllerDireccion.text = args.direccion ?? '';
      controllerCiudad.text = args.ciudad ?? '';
      controllerEstado.text = args.estado ?? '';
      controllerCP.text = args.cp ?? '';
      controllerPais.text = args.pais ?? '';
      controllerCodigo.text = args.codigoCliente ?? '';
      controllerNota.text = args.nota ?? '';
      _valuecliente = (args.distribuidor == 1) ? true : false;
    }

    final title = (args.id == 0) ? 'Nuevo cliente' : 'Editar cliente';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, 'clientes');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          automaticallyImplyLeading: false,
          elevation: 2,
          actions: [
            if (args.id != 0)
              IconButton(
                onPressed: _alertaEliminar,
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Eliminar cliente',
              ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'clientes');
              },
              icon: const Icon(Icons.close),
              tooltip: 'Cancelar',
            ),
          ],
        ),
        body: isLoading ? _buildLoadingIndicator() : _buildForm(),
      ),
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

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
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
                'Información Personal',
                Icons.person,
                Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                labelText: 'Nombre:',
                textCapitalization: TextCapitalization.words,
                controller: controllerNombre,
                icon: Icons.person_outline,
                required: true,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                labelText: 'E-mail:',
                keyboardType: TextInputType.emailAddress,
                controller: controllerCorreo,
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                labelText: 'Teléfono:',
                keyboardType: TextInputType.phone,
                controller: controllerTelefono,
                icon: Icons.phone_outlined,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(
                'Dirección',
                Icons.location_on,
                Colors.green,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                labelText: 'Dirección:',
                textCapitalization: TextCapitalization.words,
                controller: controllerDireccion,
                icon: Icons.home_outlined,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildFormField(
                      labelText: 'Ciudad:',
                      textCapitalization: TextCapitalization.words,
                      controller: controllerCiudad,
                      icon: Icons.location_city_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFormField(
                      labelText: 'Estado:',
                      textCapitalization: TextCapitalization.words,
                      controller: controllerEstado,
                      icon: Icons.map_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildFormField(
                      labelText: 'C.P.:',
                      keyboardType: TextInputType.number,
                      controller: controllerCP,
                      icon: Icons.pin_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFormField(
                      labelText: 'País:',
                      textCapitalization: TextCapitalization.words,
                      controller: controllerPais,
                      icon: Icons.public_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(
                'Información Adicional',
                Icons.info_outline,
                Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                labelText: 'Código:',
                textCapitalization: TextCapitalization.none,
                controller: controllerCodigo,
                icon: Icons.qr_code_outlined,
                readOnly: true,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                labelText: 'Nota:',
                textCapitalization: TextCapitalization.sentences,
                controller: controllerNota,
                icon: Icons.note_outlined,
                maxLines: 3,
              ),
              if (sesion.tipoUsuario == 'P') ...[
                const SizedBox(height: 16),
                _buildClientTypeSelector(),
              ],
              const SizedBox(height: 32),
              _buildActionButtons(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
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
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      readOnly: readOnly,
      maxLines: maxLines,
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

  Widget _buildClientTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile.adaptive(
        title: const Text(
          'Tipo de cliente:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _valuecliente ? 'Distribuidor' : 'Normal',
          style: TextStyle(
            color: _valuecliente ? Colors.blue : Colors.grey[700],
          ),
        ),
        value: _valuecliente,
        onChanged: (value) {
          setState(() {
            _valuecliente = value;
          });
        },
        activeColor: Colors.blue,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _guardaCliente,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Guardar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushReplacementNamed(context, 'clientes');
            },
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancelar'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
