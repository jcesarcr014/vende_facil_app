import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

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
  double windowWidth = 0.0;
  double windowHeight = 0.0;
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
    if (controllerNombre.text.isNotEmpty) {
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
            globals.actualizaClientes = true;
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
            globals.actualizaClientes = true;
          } else {
            mostrarAlerta(context, '', value.mensaje!);
          }
        });
      }
    } else {
      mostrarAlerta(context, 'ERROR', 'El campo nombre es obligatorio');
    }
  }

  _alertaEliminar() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              'ATENCIÓN',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '¿Desea eliminar el cliente ${args.nombre} - ${args.codigoCliente}? Esta acción no podrá revertirse.',
                )
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _eliminarCliente();
                  },
                  child: const Text('Eliminar')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'))
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
        globals.actualizaClientes = true;
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
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          globals.actualizaClientes = true;
          Navigator.pushReplacementNamed(context, 'clientes');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          automaticallyImplyLeading: false,
          actions: [
            if (args.id != 0)
              IconButton(
                  onPressed: () {
                    _alertaEliminar();
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
                padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.03),
                child: Column(
                  children: [
                    SizedBox(
                      height: windowHeight * 0.05,
                    ),
                    InputField(
                        labelText: 'Nombre:',
                        textCapitalization: TextCapitalization.words,
                        controller: controllerNombre),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    InputField(
                        labelText: 'e-mail:',
                        keyboardType: TextInputType.emailAddress,
                        textCapitalization: TextCapitalization.words,
                        controller: controllerCorreo),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    InputField(
                        labelText: 'Telefono:',
                        keyboardType: TextInputType.number,
                        controller: controllerTelefono),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    InputField(
                        labelText: 'Dirección:',
                        textCapitalization: TextCapitalization.words,
                        controller: controllerDireccion),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    InputField(
                        labelText: 'Ciudad:',
                        textCapitalization: TextCapitalization.words,
                        controller: controllerCiudad),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    InputField(
                        labelText: 'Estado:',
                        textCapitalization: TextCapitalization.words,
                        controller: controllerEstado),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    InputField(
                        labelText: 'C.P.:',
                        keyboardType: TextInputType.number,
                        controller: controllerCP),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    InputField(
                        labelText: 'Pais:',
                        textCapitalization: TextCapitalization.words,
                        controller: controllerPais),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    InputField(
                        readOnly: true,
                        labelText: 'Codigo:',
                        textCapitalization: TextCapitalization.words,
                        controller: controllerCodigo),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    InputField(
                        labelText: 'Nota:',
                        textCapitalization: TextCapitalization.sentences,
                        controller: controllerNota),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    if (sesion.tipoUsuario == 'P')
                      SwitchListTile.adaptive(
                          title: const Text('Tipo de cliente: '),
                          subtitle:
                              Text((_valuecliente) ? 'Distribuidor' : 'Normal'),
                          value: _valuecliente,
                          onChanged: (value) {
                            _valuecliente = value;
                            setState(() {});
                          }),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () => _guardaCliente(),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Guardar',
                                ),
                              ],
                            )),
                        SizedBox(
                          width: windowWidth * 0.05,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              globals.actualizaArticulos = true;
                              globals.actualizaArticulosCotizaciones = true;
                              Navigator.pushReplacementNamed(
                                  context, 'clientes');
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cancel_outlined),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Cancelar',
                                ),
                              ],
                            )),
                      ],
                    ),
                    SizedBox(
                      height: windowHeight * 0.08,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
