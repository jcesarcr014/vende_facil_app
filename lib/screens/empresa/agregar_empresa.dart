import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

class AgregarEmpresa extends StatefulWidget {
  const AgregarEmpresa({super.key});

  @override
  State<AgregarEmpresa> createState() => _AgregarEmpresaState();
}

class _AgregarEmpresaState extends State<AgregarEmpresa> {
  final negocioProvider = NegocioProvider();
  final usuariosProvider = UsuarioProvider();
  final categoriasProvider = CategoriaProvider();
  final articulosProvider = ArticuloProvider();
  final clientesProvider = ClienteProvider();
  final descuentosProvider = DescuentoProvider();
  final apartadoProvider = ApartadoProvider();
  final variablesprovider = VariablesProvider();
  final controllerNombre = TextEditingController();
  final controllerTelefono = TextEditingController();
  final controllerDireccion = TextEditingController();
  final controllerRFC = TextEditingController();
  final controllerRS = TextEditingController();
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  Negocio args = Negocio(id: 0, nombreNegocio: '');
  bool firstLoad = false;

  void loadClientes() async {
    await clientesProvider.listarClientes().then((value) {
      if (value.status == 1) {
        globals.actualizaClientes = false;
      } else {
        globals.actualizaClientes = true;
      }
    });
  }

  _guardaNegocio() {
    if (controllerNombre.text.isNotEmpty && controllerDireccion.text.isNotEmpty) {
      Negocio nuevoNegocio = Negocio();
      nuevoNegocio.idUsuario = sesion.idUsuario;
      nuevoNegocio.nombreNegocio = controllerNombre.text;
      nuevoNegocio.telefono = (controllerTelefono.text.isNotEmpty) ? controllerTelefono.text : '';
      nuevoNegocio.direccion = controllerDireccion.text;
      nuevoNegocio.razonSocial = (controllerRS.text.isNotEmpty) ? controllerRS.text : '';
      nuevoNegocio.rfc = (controllerRFC.text.isNotEmpty) ? controllerRFC.text : '';

      if (mounted) {
        setState(() {
          textLoading = 'Enviando información';
          isLoading = true;
        });
      }

      if (args.id == 0) {
        negocioProvider.nuevoNegocio(nuevoNegocio).then((value) {
          if (mounted) {
            setState(() {
              textLoading = '';
              isLoading = false;
            });
          }
          if (value.status == 1) { 
            loadClientes();
            if (mounted) {
              setState(() {
                globals.actualizaSucursales = true;
                _cargar();
                
                Navigator.pushReplacementNamed(context, 'menu');
              });
            }
            mostrarAlerta(context, '', value.mensaje!);
          } else {
            mostrarAlerta(context, 'ERROR', value.mensaje!);
          }
        });
      } else {
        negocioProvider.editaNegocio(nuevoNegocio).then((value) {
          if (mounted) {
            setState(() {
              textLoading = '';
              isLoading = false;
            });
          }
          if (value.status == 1) {
            if (mounted) {
              setState(() {
                Navigator.pushReplacementNamed(context, 'home');
              });
            }
            mostrarAlerta(context, '', value.mensaje!);
          } else {
            mostrarAlerta(context, 'ERROR', value.mensaje!);
          }
        });
      }
    } else {
      mostrarAlerta(context, 'ERROR', 'Los campos Nombre y Dirección son obligatorios.');
    }
  }

  @override
  void initState() {
    if (sesion.idNegocio != 0) {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      negocioProvider.consultaNegocio().then((value) {
        args = value;
        if (mounted) {
          setState(() {
            isLoading = false;
            firstLoad = true;
          });
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    controllerNombre.dispose();
    controllerTelefono.dispose();
    controllerDireccion.dispose();
    controllerRFC.dispose();
    controllerRS.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (sesion.idNegocio != 0 && firstLoad) {
      firstLoad = false;
      controllerNombre.text = args.nombreNegocio ?? '';
      controllerDireccion.text = args.direccion ?? '';
      controllerTelefono.text = args.telefono ?? '';
      controllerRS.text = args.razonSocial ?? '';
      controllerRFC.text = args.rfc ?? '';
    }
    final title = (args.id == 0) ? 'Nueva empresa' : 'Editar empresa';
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      onPopInvoked: (didpop) {
        if (!didpop) {
          Navigator.pushReplacementNamed(context, 'menu-negocio');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          automaticallyImplyLeading: true,
        ),
        body: (isLoading)
            ? Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Espere...$textLoading'),
                      const SizedBox(height: 10),
                      const CircularProgressIndicator(),
                    ]),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.03),
                child: Column(
                  children: [
                    SizedBox(height: windowHeight * 0.05),
                    InputField(
                        labelText: 'Nombre empresa:',
                        textCapitalization: TextCapitalization.words,
                        controller: controllerNombre),
                    SizedBox(height: windowHeight * 0.03),
                    InputField(
                        labelText: 'Dirección:',
                        textCapitalization: TextCapitalization.sentences,
                        controller: controllerDireccion),
                    SizedBox(height: windowHeight * 0.03),
                    InputField(
                        labelText: 'Telefono:',
                        keyboardType: TextInputType.phone,
                        controller: controllerTelefono),
                    SizedBox(height: windowHeight * 0.03),
                    InputField(
                        labelText: 'Razón Social:',
                        textCapitalization: TextCapitalization.words,
                        controller: controllerRS),
                    SizedBox(height: windowHeight * 0.03),
                    InputField(
                        labelText: 'R.F.C.:',
                        textCapitalization: TextCapitalization.words,
                        controller: controllerRFC),
                    SizedBox(height: windowHeight * 0.05),
                    ElevatedButton(
                        onPressed: () => _guardaNegocio(),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save),
                            SizedBox(width: 5),
                            Text('Guardar'),
                          ],
                        ))
                  ],
                ),
              ),
      ),
    );
  }

  _cargar() async {
    if (mounted) {
      setState(() {
        textLoading = 'Leyendo datos de sesión.';
        isLoading = true;
      });
    }

    if (mounted) {
      setState(() {
        textLoading = 'Leyendo información de usuarios';
      });
    }

    await usuariosProvider.obtenerUsuarios().then((value) {
      if (mounted) {
        setState(() {
          globals.actualizaUsuarios = value.status != 1;
        });
      }
    });

    if (mounted) {
      setState(() {
        textLoading = 'Leyendo información de empleados';
      });
    }

    await negocioProvider.getlistaempleadosEnsucursales(null).then((value) {
      if (mounted) {
        setState(() {
          globals.actualizarEmpleadoSucursales = value.status != 1;
        });
      }
    });

    await usuariosProvider.obtenerEmpleados().then((value) {
      if (mounted) {
        setState(() {
          globals.actualizaEmpleados = value.status != 1;
        });
      }
    });

    if (mounted) {
      setState(() {
        textLoading = 'Leyendo categorías';
      });
    }

    await categoriasProvider.listarCategorias().then((value) {
      if (mounted) {
        setState(() {
          globals.actualizaCategorias = value.status != 1;
        });
      }
    });

    if (mounted) {
      setState(() {
        textLoading = '';
        isLoading = false;
      });
    }
  }
}
