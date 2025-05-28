import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';

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
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String textLoading = '';
  Negocio args = Negocio(id: 0, nombreNegocio: '');
  bool firstLoad = false;

  void loadClientes() async {
    await clientesProvider.listarClientes();
  }

  _guardaNegocio() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Negocio nuevoNegocio = Negocio();
    nuevoNegocio.idUsuario = sesion.idUsuario;
    nuevoNegocio.nombreNegocio = controllerNombre.text;
    nuevoNegocio.telefono = controllerTelefono.text;
    nuevoNegocio.direccion = controllerDireccion.text;
    nuevoNegocio.razonSocial = controllerRS.text;
    nuevoNegocio.rfc = controllerRFC.text;

    if (mounted) {
      setState(() {
        textLoading = (args.id == 0)
            ? 'Registrando nueva empresa'
            : 'Actualizando información de empresa';
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
      nuevoNegocio.id = args.id;
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
              Navigator.pushReplacementNamed(context, 'menu-negocio');
            });
          }
          mostrarAlerta(context, '', value.mensaje!);
        } else {
          mostrarAlerta(context, 'ERROR', value.mensaje!);
        }
      });
    }
  }

  @override
  void initState() {
    if (sesion.idNegocio != 0) {
      if (mounted) {
        setState(() {
          isLoading = true;
          textLoading = 'Cargando información de la empresa';
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
          automaticallyImplyLeading: false,
          elevation: 2,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'menu-negocio');
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
      child: Form(
        key: _formKey,
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
                  'Información de la Empresa',
                  Icons.business_outlined,
                  Colors.blue,
                ),
                const SizedBox(height: 24),
                _buildFormField(
                  labelText: 'Nombre de la empresa:',
                  textCapitalization: TextCapitalization.words,
                  controller: controllerNombre,
                  icon: Icons.business_center_outlined,
                  required: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre de la empresa es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  labelText: 'Dirección:',
                  textCapitalization: TextCapitalization.sentences,
                  controller: controllerDireccion,
                  icon: Icons.location_on_outlined,
                  required: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La dirección es obligatoria';
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
                ),
                const SizedBox(height: 24),
                _buildSectionTitle(
                  'Información Fiscal',
                  Icons.receipt_long_outlined,
                  Colors.green,
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  labelText: 'Razón Social:',
                  textCapitalization: TextCapitalization.words,
                  controller: controllerRS,
                  icon: Icons.business_outlined,
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  labelText: 'R.F.C.:',
                  textCapitalization: TextCapitalization.characters,
                  controller: controllerRFC,
                  icon: Icons.article_outlined,
                ),
                const SizedBox(height: 36),
                _buildActionButtons(),
                const SizedBox(height: 16),
              ],
            ),
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _guardaNegocio,
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
        // const SizedBox(width: 16),
        // Expanded(
        //   child: OutlinedButton.icon(
        //     onPressed: () {
        //       Navigator.pushReplacementNamed(context, 'menu-negocio');
        //     },
        //     icon: const Icon(Icons.cancel_outlined),
        //     label: const Text('Cancelar'),
        //     style: OutlinedButton.styleFrom(
        //       padding: const EdgeInsets.symmetric(vertical: 16),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  _cargar() async {
    if (mounted) {
      setState(() {
        textLoading = 'Leyendo datos de sesión';
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
        setState(() {});
      }
    });

    if (mounted) {
      setState(() {
        textLoading = 'Leyendo información de empleados';
      });
    }

    await negocioProvider.getlistaempleadosEnsucursales(null).then((value) {
      if (mounted) {
        setState(() {});
      }
    });

    await usuariosProvider.obtenerEmpleados().then((value) {
      if (mounted) {
        setState(() {});
      }
    });

    if (mounted) {
      setState(() {
        textLoading = 'Leyendo categorías';
      });
    }

    await categoriasProvider.listarCategorias().then((value) {
      if (mounted) {
        setState(() {});
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
