import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';

class RegistroEmpleadoScreen extends StatefulWidget {
  const RegistroEmpleadoScreen({super.key});

  @override
  State<RegistroEmpleadoScreen> createState() => _RegistroEmpleadoScreenState();
}

class _RegistroEmpleadoScreenState extends State<RegistroEmpleadoScreen> {
  final usuariosProvider = UsuarioProvider();
  final controllerNombre = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerTelefono = TextEditingController();
  final controllerPassword1 = TextEditingController();
  final controllerPassword2 = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String textLoading = '';
  bool passOculto1 = true;
  bool passOculto2 = true;

  _registrarEmpleado() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      textLoading = 'Registrando nuevo empleado';
      isLoading = true;
    });

    Usuario newUser = Usuario();
    newUser.nombre = controllerNombre.text;
    newUser.email = controllerEmail.text;
    newUser.telefono = controllerTelefono.text;

    usuariosProvider
        .nuevoEmpleado(newUser, controllerPassword1.text)
        .then((value) {
      if (value.status == 1) {
        usuariosProvider.obtenerEmpleados().then((value) {
          setState(() {
            isLoading = false;
            textLoading = '';
          });
          Navigator.pushReplacementNamed(context, 'menu-negocio');
          mostrarAlerta(context, '', 'Empleado registrado correctamente.');
        });
      } else {
        setState(() {
          isLoading = false;
          textLoading = '';
        });
        mostrarAlerta(context, 'ERROR', value.mensaje!);
      }
    });
  }

  @override
  void dispose() {
    controllerNombre.dispose();
    controllerEmail.dispose();
    controllerTelefono.dispose();
    controllerPassword1.dispose();
    controllerPassword2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo empleado'),
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
                  'Información del Empleado',
                  Icons.person_outline,
                  Colors.blue,
                ),
                const SizedBox(height: 24),
                _buildFormField(
                  labelText: 'Nombre completo:',
                  textCapitalization: TextCapitalization.words,
                  controller: controllerNombre,
                  icon: Icons.person_outline,
                  required: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  labelText: 'Correo electrónico:',
                  keyboardType: TextInputType.emailAddress,
                  controller: controllerEmail,
                  icon: Icons.email_outlined,
                  required: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El correo electrónico es requerido';
                    }
                    // Validación simple de formato de email
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Ingrese un correo electrónico válido';
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
                _buildSectionTitle(
                  'Credenciales de Acceso',
                  Icons.security_outlined,
                  Colors.green,
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  labelText: 'Contraseña:',
                  controller: controllerPassword1,
                  obscureText: passOculto1,
                  toggleVisibility: () {
                    setState(() {
                      passOculto1 = !passOculto1;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La contraseña es requerida';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  labelText: 'Confirmar contraseña:',
                  controller: controllerPassword2,
                  obscureText: passOculto2,
                  toggleVisibility: () {
                    setState(() {
                      passOculto2 = !passOculto2;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Debe confirmar la contraseña';
                    }
                    if (value != controllerPassword1.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 36),
                _buildActionButton(),
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

  Widget _buildPasswordField({
    required String labelText,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggleVisibility,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: '$labelText *',
        prefixIcon: const Icon(Icons.lock_outline, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 20,
          ),
          onPressed: toggleVisibility,
          tooltip: obscureText ? 'Mostrar contraseña' : 'Ocultar contraseña',
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _registrarEmpleado,
        icon: const Icon(Icons.save_outlined),
        label: const Text('Registrar Empleado'),
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
}
