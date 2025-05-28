import 'package:flutter/material.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/providers/providers.dart';

class RecuperaPassScreen extends StatefulWidget {
  const RecuperaPassScreen({super.key});

  @override
  State<RecuperaPassScreen> createState() => _RecuperaPassScreenState();
}

class _RecuperaPassScreenState extends State<RecuperaPassScreen> {
  final usuariosProvider = UsuarioProvider();
  final controllerUser = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String textLoading = '';

  @override
  void dispose() {
    controllerUser.dispose();
    super.dispose();
  }

  _recuperar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
      textLoading = 'Enviando solicitud de recuperación';
    });

    usuariosProvider.recuperaPass(controllerUser.text).then((resp) {
      setState(() {
        isLoading = false;
        textLoading = '';
      });

      Navigator.pop(context);

      if (resp.status == 1) {
        mostrarAlerta(context, 'Solicitud enviada',
            'Se ha enviado un correo a ${controllerUser.text} con las instrucciones para recuperar su contraseña');
      } else {
        mostrarAlerta(context, 'Error',
            'Ocurrió un error al enviar el correo: ${resp.mensaje}');
      }
    }).catchError((error) {
      setState(() {
        isLoading = false;
        textLoading = '';
      });

      mostrarAlerta(context, 'Error',
          'No se pudo procesar la solicitud. Intente de nuevo más tarde.');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar contraseña'),
        automaticallyImplyLeading: true,
        elevation: 2,
      ),
      body: isLoading ? _buildLoadingIndicator() : _buildContent(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: const Image(image: AssetImage('assets/logo.png')),
          ),
          const SizedBox(height: 30),
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
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Logo
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: const Image(
                  image: AssetImage('assets/logo.png'),
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),

              // Tarjeta de formulario
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(
                        'Recuperación de Contraseña',
                        Icons.lock_reset_outlined,
                        Colors.blue,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Ingrese su correo electrónico y le enviaremos instrucciones para restablecer su contraseña.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildFormField(
                        labelText: 'Correo electrónico:',
                        keyboardType: TextInputType.emailAddress,
                        controller: controllerUser,
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
                      const SizedBox(height: 32),
                      _buildActionButton(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Enlace para volver a iniciar sesión
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿Recordó su contraseña?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, 'login');
                    },
                    child: const Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
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
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String labelText,
    TextInputType? keyboardType,
    required TextEditingController controller,
    required IconData icon,
    bool required = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _recuperar,
        icon: const Icon(Icons.send_outlined),
        label: const Text(
          'Enviar Instrucciones',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
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
