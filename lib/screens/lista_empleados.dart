import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/models/usuario_model.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

class ListaEmpleadosScreen extends StatefulWidget {
  const ListaEmpleadosScreen({super.key});

  @override
  State<ListaEmpleadosScreen> createState() => _ListaEmpleadosScreenState();
}

class _ListaEmpleadosScreenState extends State<ListaEmpleadosScreen> {
  final usuarioProvider = UsuarioProvider();
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;

  @override
  void initState() {
    if (globals.actualizaEmpleados) {
      setState(() {
      textLoading = 'Leyendo empleados';
      isLoading = true;
    });
    usuarioProvider.obtenerEmpleados().then((value) {
      setState(() {
        textLoading = '';
        isLoading = false;
      });
      if (value.status != 1) {
        Navigator.pop(context);
        mostrarAlerta(context, 'ERROR', value.mensaje!);
      }
    });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Empleados'),
          automaticallyImplyLeading: true,
        ),
        body: (isLoading)
            ? Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Espere...$textLoading'),
                      SizedBox(
                        height: windowHeight * 0.01,
                      ),
                      const CircularProgressIndicator(),
                    ]),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.01),
                child: Column(children: [
                  SizedBox(
                    height: windowHeight * 0.02,
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: windowWidth * 0.05),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'nvo-empleado');
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add),
                          SizedBox(
                            width: 5,
                          ),
                          Text('Nuevo empleado'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: windowHeight * 0.02,
                  ),
                  const Divider(),
                  SizedBox(
                    height: windowHeight * 0.01,
                  ),
                  Column(children: _empleados())
                ]),
              ));
  }

  _empleados() {
    List<Widget> empleados = [];
    for (int i = 0; i < listaEmpleados.length; i++) {
      Usuario empleado = listaEmpleados[i];
      empleados.add(
        ListTile(
          leading: const Icon(Icons.account_circle_rounded),
          title: Text(
            empleado.nombre!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(empleado.email!),
          trailing: const Icon(Icons.arrow_right),
          onTap: () {
            Navigator.pushNamed(context, 'perfil-empleado', arguments: i);
          },
        ),
      );
    }
    if (empleados.isEmpty) {
      final TextTheme textTheme = Theme.of(context).textTheme;

      empleados.add(Column(
        children: [
          const Opacity(
            opacity: 0.2,
            child: Icon(
              Icons.no_accounts,
              size: 130,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            'No hay empleados guardados.',
            style: textTheme.titleMedium,
          )
        ],
      ));
    }
    return empleados;
  }
}
