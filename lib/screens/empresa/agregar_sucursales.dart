import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/widgets/widgets.dart';

class RegistroSucursalesScreen extends StatefulWidget {
  const RegistroSucursalesScreen({super.key});

  @override
  State<RegistroSucursalesScreen> createState() =>
      _RegistroEmpleadoScreenState();
}

class _RegistroEmpleadoScreenState extends State<RegistroSucursalesScreen> {
  final text = TextEditingController();
  final controllerNombre = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerTelefono = TextEditingController();
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  bool estatus = (sucursalSeleccionado.nombreSucursal == null) ? true : false;
  bool isLoading = false;
  String textLoading = '';
  @override
  void initState() {
    if (estatus) {
      text.text = "Nueva Sucursal";
      setState(() {});
    } else {
      controllerNombre.text = sucursalSeleccionado.nombreSucursal!;
      controllerEmail.text = sucursalSeleccionado.direccion!;
      controllerTelefono.text = sucursalSeleccionado.telefono!;
      text.text = "Editar Sucursal";
      setState(() {});
    }
    super.initState();
  }

  @override
  void dispose() {
    controllerNombre.dispose();
    controllerEmail.dispose();
    controllerTelefono.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(text.text)
      ),
      body: (isLoading)
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.05),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: windowHeight * 0.10,
                    ),
                    InputField(
                        textCapitalization: TextCapitalization.words,
                        icon: Icons.holiday_village,
                        labelText: 'Nombre de la surcursal',
                        controller: controllerNombre),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    InputField(
                        textCapitalization: TextCapitalization.none,
                        keyboardType: TextInputType.emailAddress,
                        icon: Icons.gps_fixed_outlined,
                        labelText: 'Dirrecion',
                        controller: controllerEmail),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    InputField(
                        keyboardType: TextInputType.phone,
                        icon: Icons.smartphone,
                        labelText: 'Telefono',
                        controller: controllerTelefono),
                    SizedBox(
                      height: windowHeight * 0.10,
                    ),
                    ElevatedButton(
                        onPressed: () {},
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save),
                            SizedBox(
                              width: 10,
                            ),
                            Text('Registrarse'),
                          ],
                        ))
                  ],
                ),
              ),
            ),
    );
  }
}
