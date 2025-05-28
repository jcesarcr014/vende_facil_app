// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/models/models.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final usuariosProvider = UsuarioProvider();
  final categoriasProvider = CategoriaProvider();
  final articulosProvider = ArticuloProvider();
  final clientesProvider = ClienteProvider();
  final descuentosProvider = DescuentoProvider();
  final variablesprovider = VariablesProvider();
  final apartadoProvider = ApartadoProvider();
  final controllerUser = TextEditingController();
  final controllerPass = TextEditingController();
  bool isLoading = false;
  bool passOculto1 = true;
  String textLoading = '';
  String? _userErrorText;
  String? _passwordErrorText;

  _inicioSesion() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        textLoading = 'Iniciando sesión';
        isLoading = true;
      });
      usuariosProvider
          .login(controllerUser.text, controllerPass.text)
          .then((value) async {
        if (value.status == 1) {
          if (sesion.tipoUsuario == 'P') {
            setState(() {
              textLoading = 'Cargando información de empleados';
            });
            await usuariosProvider.obtenerUsuarios();
            await usuariosProvider.obtenerEmpleados();
          }

          setState(() {
            textLoading = 'Cargando categorías';
          });
          await categoriasProvider.listarCategorias();
          setState(() {
            textLoading = 'Cargando configuración';
          });
          await variablesprovider.variablesConfiguracion();
          setState(() {
            textLoading = '';
            isLoading = false;
          });

          if (sesion.idNegocio == 0) {
            Navigator.pushReplacementNamed(context, 'menu');
            mostrarAlerta(context, 'Bienvenido',
                '¡Bienvenido de vuelta! Registre los datos de su negocio en la opción Empresa del menú para acceder a todas las funcionalidades de la aplicación.');
          } else {
            if (sesion.tipoUsuario == 'E') {
              Navigator.pushReplacementNamed(context, 'menu');
              mostrarAlerta(context, 'Bienvenido',
                  'Hola ${sesion.nombreUsuario}, estás en la sucursal ${sesion.sucursal}');
            } else {
              Navigator.pushReplacementNamed(context, 'menu');
            }
          }
        } else {
          setState(() {
            textLoading = '';
            isLoading = false;
          });
          mostrarAlerta(context, 'ERROR', value.mensaje!);
        }
      }).catchError((error) {
        setState(() {
          textLoading = '';
          isLoading = false;
        });
        mostrarAlerta(context, 'ERROR', 'Error de conexión. Intente de nuevo.');
      });
    } else {
      mostrarAlerta(context, 'ERROR', 'Complete todos los campos requeridos');
    }
  }

  @override
  void dispose() {
    controllerUser.dispose();
    controllerPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: isLoading ? _buildLoadingIndicator(size) : _buildLoginForm(size),
      ),
    );
  }

  Widget _buildLoadingIndicator(Size size) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size.width * 0.4,
            child: const Image(image: AssetImage('assets/logo.png')),
          ),
          SizedBox(height: size.height * 0.08),
          Text(
            'Espere... $textLoading',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: size.height * 0.04),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildLoginForm(Size size) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo y encabezado
                SizedBox(height: size.height * 0.04),
                SizedBox(
                  width: size.width * 0.4,
                  child: const Image(image: AssetImage('assets/logo.png')),
                ),
                SizedBox(height: size.height * 0.06),

                // Título
                const Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                const Text(
                  'Ingrese sus credenciales para continuar',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: size.height * 0.06),

                // Tarjeta de formulario
                _buildFormCard(size),

                SizedBox(height: size.height * 0.04),

                // Enlaces adicionales
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿No tienes cuenta?',
                      style: TextStyle(fontSize: 15),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'registro');
                      },
                      child: const Text(
                        'Registrarse',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, 'recupera');
                  },
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(Size size) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormField(
              labelText: 'Correo electrónico',
              hintText: 'Ingrese su correo electrónico',
              controller: controllerUser,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El correo es obligatorio';
                }
                // Validación básica de formato de email
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Ingrese un correo electrónico válido';
                }
                return null;
              },
              errorText: _userErrorText,
            ),
            SizedBox(height: size.height * 0.02),
            _buildPasswordField(
              labelText: 'Contraseña',
              hintText: 'Ingrese su contraseña',
              controller: controllerPass,
              obscureText: passOculto1,
              toggleVisibility: () {
                setState(() {
                  passOculto1 = !passOculto1;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La contraseña es obligatoria';
                }
                return null;
              },
              errorText: _passwordErrorText,
            ),
            SizedBox(height: size.height * 0.04),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _inicioSesion,
                icon: const Icon(Icons.login_outlined),
                label: const Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String labelText,
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon, size: 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        errorText: errorText,
      ),
    );
  }

  Widget _buildPasswordField({
    required String labelText,
    required String hintText,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggleVisibility,
    String? Function(String?)? validator,
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: const Icon(Icons.lock_outline, size: 22),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 22,
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
        errorText: errorText,
      ),
    );
  }
}
