import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

class ListaSucursalesScreen extends StatefulWidget {
  const ListaSucursalesScreen({super.key});

  @override
  State<ListaSucursalesScreen> createState() => _ListaEmpleadosScreenState();
}

class _ListaEmpleadosScreenState extends State<ListaSucursalesScreen> {
  final negocios = NegocioProvider();
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;

  @override
  void initState() {
    if (globals.actualizaSucursales) {
      setState(() {
        textLoading = 'Leyendo Surcursales';
        isLoading = true;
      });
      negocios.getlistaSucursales().then((value) {
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
          title: const Text('Sucursales'),
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
                        sucursalSeleccionado.limpiar();
                        Navigator.pushNamed(context, 'registro-sucursale');
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add),
                          SizedBox(
                            width: 5,
                          ),
                          Text('Nueva sucursal'),
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
    for (int i = 0; i < listaSucursales.length; i++) {
      Sucursale sucursale = listaSucursales[i];
      empleados.add(
        ListTile(
          leading: const Icon(Icons.home),
          title: Text(
            sucursale.nombreSucursal!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(sucursale.direccion!),
          trailing: const Icon(Icons.arrow_right),
          onTap: () {
            sucursalSeleccionado.asignarValores(
              id: sucursale.id!,
              negocioId: sucursale.negocioId,
              nombreSucursal: sucursale.nombreSucursal,
              direccion: sucursale.direccion,
              telefono: sucursale.telefono,
            );
            Navigator.pushNamed(context, 'registro-sucursale');
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
              Icons.do_not_disturb_alt_rounded,
              size: 130,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            'No hay sucursales guardados.',
            style: textTheme.titleMedium,
          )
        ],
      ));
    }
    return empleados;
  }
}
