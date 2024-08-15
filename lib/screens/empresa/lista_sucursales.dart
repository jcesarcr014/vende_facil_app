import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

class ListaSucursalesScreen extends StatefulWidget {
  const ListaSucursalesScreen({super.key});

  @override
  State<ListaSucursalesScreen> createState() => _ListaSucursalesScreenState();
}

class _ListaSucursalesScreenState extends State<ListaSucursalesScreen> {
  final negocios = NegocioProvider();
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;

  @override
  void initState() {
    if (globals.actualizaSucursales || globals.actualizarEmpleadoSucursales) {
      setState(() {
        textLoading = 'Leyendo Surcursales';
        isLoading = true;
      });
      negocios.getlistaSucursales().then((respSuc) {
        if (respSuc.status == 1) {
          setState(() {
            textLoading = 'Leyendo Empleados';
          });
          negocios.getlistaempleadosEnsucursales().then((value) {
            setState(() {
              textLoading = '';
              isLoading = false;
            });
            if (value.status == 1) {
              globals.actualizaSucursales = false;
              globals.actualizarEmpleadoSucursales = false;
            } else {
              Navigator.pop(context);
              mostrarAlerta(context, 'ERROR', value.mensaje!);
            }
          });
        } else {
          Navigator.pop(context);
          mostrarAlerta(context, 'ERROR', respSuc.mensaje!);
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
                        Navigator.pushNamed(context, 'nva-sucursal');
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
                  Column(children: _sucursales())
                ]),
              ));
  }

  _sucursales() {
    List<Widget> sucursales = [];
    for (int i = 0; i < listaSucursales.length; i++) {
      Sucursal sucursal = listaSucursales[i];
      sucursales.add(
        ListTile(
          leading: const Icon(Icons.home),
          title: Text(
            sucursal.nombreSucursal!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(sucursal.direccion!),
          trailing: const Icon(Icons.arrow_right),
          onTap: () {
            sucursalSeleccionado.asignarValores(
              id: sucursal.id!,
              negocioId: sucursal.negocioId,
              nombreSucursal: sucursal.nombreSucursal,
              direccion: sucursal.direccion,
              telefono: sucursal.telefono,
            );
            Navigator.pushNamed(context, 'nva-sucursal');
          },
        ),
      );
    }
    if (sucursales.isEmpty) {
      final TextTheme textTheme = Theme.of(context).textTheme;

      sucursales.add(Column(
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
    return sucursales;
  }
}
