import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';

class AgregaCategoriaScreen extends StatefulWidget {
  const AgregaCategoriaScreen({super.key});

  @override
  State<AgregaCategoriaScreen> createState() => _AgregaCategoriaScreenState();
}

class _AgregaCategoriaScreenState extends State<AgregaCategoriaScreen> {
  final controllerCategoria = TextEditingController();
  final categoriasProvider = CategoriaProvider();
  final _formKey = GlobalKey<FormState>();
  bool firstLoad = true;
  bool isLoading = false;
  String textLoading = '';
  int _valueCat = 0;
  Categoria args = Categoria(id: 0, categoria: '', idColor: 1);

  _guardaCategoria() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_valueCat == 0) {
      mostrarAlerta(
          context, 'Error', 'Debe seleccionar un color para la categoría');
      return;
    }

    setState(() {
      textLoading = (args.id == 0)
          ? 'Registrando nueva categoría'
          : 'Actualizando categoría';
      isLoading = true;
    });

    Categoria nvaCat = Categoria();
    nvaCat.categoria = controllerCategoria.text;
    nvaCat.idColor = _valueCat;

    if (args.id == 0) {
      categoriasProvider.nuevaCategoria(nvaCat).then((value) {
        setState(() {
          isLoading = false;
          textLoading = '';
        });
        if (value.status == 1) {
          Navigator.pushReplacementNamed(context, 'categorias');
          mostrarAlerta(context, '', value.mensaje!);
        } else {
          mostrarAlerta(context, '', value.mensaje!);
        }
      });
    } else {
      nvaCat.id = args.id;
      categoriasProvider.editaCategoria(nvaCat).then((value) {
        setState(() {
          isLoading = false;
          textLoading = '';
        });
        if (value.status == 1) {
          Navigator.pushReplacementNamed(context, 'categorias');
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
                  '¿Desea eliminar la categoría ${args.categoria}? Esta acción no podrá revertirse.',
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
                  _eliminarCategoria();
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

  _eliminarCategoria() {
    setState(() {
      textLoading = 'Eliminando categoría';
      isLoading = true;
    });

    categoriasProvider.eliminaCategoria(args.id!).then((value) {
      setState(() {
        textLoading = '';
        isLoading = false;
      });
      if (value.status == 1) {
        Navigator.pushReplacementNamed(context, 'categorias');
        mostrarAlerta(context, '', value.mensaje!);
      } else {
        mostrarAlerta(context, '', value.mensaje!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)?.settings.arguments != null && firstLoad) {
      firstLoad = false;
      args = ModalRoute.of(context)?.settings.arguments as Categoria;
      for (var color in listaColores) {
        if (color.id == args.idColor) {
          _valueCat = color.id!;
        }
      }
      controllerCategoria.text = args.categoria!;
    }

    final title = (args.id == 0) ? 'Nueva categoría' : 'Editar categoría';

    return PopScope(
      canPop: false,
      onPopInvoked: (didpop) {
        if (!didpop) Navigator.pushReplacementNamed(context, 'categorias');
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
                tooltip: 'Eliminar categoría',
              ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'categorias');
              },
              icon: const Icon(Icons.close),
              tooltip: 'Cancelar',
            ),
          ],
        ),
        body: isLoading ? _buildLoadingIndicator() : _buildForm(context),
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

  Widget _buildForm(BuildContext context) {
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
                  'Información de la Categoría',
                  Icons.category_outlined,
                  Colors.orange,
                ),
                const SizedBox(height: 24),
                _buildFormField(
                  labelText: 'Nombre de la categoría:',
                  textCapitalization: TextCapitalization.words,
                  controller: controllerCategoria,
                  icon: Icons.bookmark_outline,
                  required: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre de la categoría es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildColorSelector(context),
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

  Widget _buildColorSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color de la categoría: *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.palette_outlined, size: 20, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: _buildColorDropdown(
                    MediaQuery.of(context).size.width * 0.5),
              ),
            ],
          ),
        ),
        if (_valueCat == 0)
          const Padding(
            padding: EdgeInsets.only(left: 12, top: 8),
            child: Text(
              'Debe seleccionar un color',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildColorDropdown(double width) {
    var lista = [
      DropdownMenuItem(
          value: 0,
          child: SizedBox(
            width: width,
            child: const Row(
              children: [
                Icon(Icons.not_interested_outlined, size: 20),
                SizedBox(width: 8),
                Text('Seleccione un color'),
              ],
            ),
          ))
    ];

    for (var color in listaColores) {
      lista.add(DropdownMenuItem(
        value: color.id,
        child: Container(
          width: width,
          height: 30,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: color.color,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
      ));
    }

    return DropdownButton(
      isExpanded: true,
      items: lista,
      value: _valueCat,
      onChanged: (value) {
        setState(() {
          _valueCat = value ?? 0;
        });
      },
      underline: Container(),
      icon: const Icon(Icons.arrow_drop_down),
      hint: const Text('Seleccione un color'),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _guardaCategoria,
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
              Navigator.pushReplacementNamed(context, 'categorias');
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
