import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';

class AgregaDescuentoScreen extends StatefulWidget {
  const AgregaDescuentoScreen({super.key});

  @override
  State<AgregaDescuentoScreen> createState() => _AgregaDescuentoScreenState();
}

class _AgregaDescuentoScreenState extends State<AgregaDescuentoScreen> {
  final descuentosProvider = DescuentoProvider();
  final controllerNombre = TextEditingController();
  final controllerValor = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool firstLoad = true;

  bool isLoading = false;
  String textLoading = '';
  Descuento args = Descuento(id: 0);

  _guardaDescuento() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      textLoading = (args.id == 0)
          ? 'Registrando nuevo descuento'
          : 'Actualizando descuento';
      isLoading = true;
    });

    Descuento descuento = Descuento();
    descuento.nombre = controllerNombre.text;
    descuento.valor = double.parse(controllerValor.text);

    if (args.id == 0) {
      descuentosProvider.nuevoDescuento(descuento).then((value) {
        setState(() {
          isLoading = false;
          textLoading = '';
        });
        if (value.status == 1) {
          Navigator.pushReplacementNamed(context, 'descuentos');
          mostrarAlerta(context, '', value.mensaje!);
        } else {
          mostrarAlerta(context, '', value.mensaje!);
        }
      });
    } else {
      descuento.id = args.id;
      descuentosProvider.editaDescuento(descuento).then((value) {
        setState(() {
          isLoading = false;
          textLoading = '';
        });
        if (value.status == 1) {
          Navigator.pushReplacementNamed(context, 'descuentos');
          mostrarAlerta(context, '', value.mensaje!);
        } else {
          mostrarAlerta(context, '', value.mensaje!);
        }
      });
    }
  }

  @override
  void dispose() {
    controllerNombre.dispose();
    controllerValor.dispose();
    super.dispose();
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
                  '¿Desea eliminar el descuento ${args.nombre}? Esta acción no podrá revertirse.',
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
                  _eliminarDescuento();
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

  _eliminarDescuento() {
    setState(() {
      textLoading = 'Eliminando descuento';
      isLoading = true;
    });

    descuentosProvider.eliminaDescuento(args.id!).then((value) {
      setState(() {
        textLoading = '';
        isLoading = false;
      });
      if (value.status == 1) {
        Navigator.pushReplacementNamed(context, 'descuentos');
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
      args = ModalRoute.of(context)?.settings.arguments as Descuento;
      controllerNombre.text = args.nombre ?? '';
      controllerValor.text =
          args.valor != null ? args.valor!.toStringAsFixed(2) : '';
    }

    final title = (args.id == 0) ? 'Nuevo descuento' : 'Editar descuento';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, 'descuentos');
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
                tooltip: 'Eliminar descuento',
              ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'descuentos');
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
                  'Información del Descuento',
                  Icons.discount_outlined,
                  Colors.purple,
                ),
                const SizedBox(height: 24),
                _buildFormField(
                  labelText: 'Nombre del descuento:',
                  textCapitalization: TextCapitalization.words,
                  controller: controllerNombre,
                  icon: Icons.label_outline,
                  required: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre del descuento es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildFormField(
                  labelText: 'Porcentaje de descuento:',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: controllerValor,
                  icon: Icons.percent_outlined,
                  required: true,
                  suffixIcon: const Icon(Icons.percent),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El porcentaje de descuento es obligatorio';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Por favor ingrese un número válido';
                    }
                    return null;
                  },
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
    Widget? suffixIcon,
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
        suffixIcon: suffixIcon,
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
            onPressed: _guardaDescuento,
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
              Navigator.pushReplacementNamed(context, 'descuentos');
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
