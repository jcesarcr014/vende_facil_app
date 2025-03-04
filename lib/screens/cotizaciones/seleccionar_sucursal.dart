import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';

class SeleccionarSucursal extends StatefulWidget {
  const SeleccionarSucursal({super.key});

  @override
  State<SeleccionarSucursal> createState() => _SeleccionarSucursalState();
}

class _SeleccionarSucursalState extends State<SeleccionarSucursal> {
  int _valueIdSucursal = 0;
  final sucursal = NegocioProvider();
  bool isLoading = false;
  double windowHeight = 0.0;
  String textLoading = '';
  @override
  initState() {
    setState(() {
      textLoading = 'Cargar Sucursales';
      isLoading = true;
    });
    cargar();
    super.initState();
  }

  cargar() async {
    await sucursal.getlistaSucursales().then(
      (value) {
        setState(() {
          textLoading = '';
          isLoading = false;
        });
      },
    );
  }

  Widget _sucursalesDropdown() {
    List<DropdownMenuItem<int>> listaSucursalesItems = [
      const DropdownMenuItem(
          value: 0,
          child: SizedBox(child: Text('Seleccione sucursal para cotizar')))
    ];

    for (Sucursal sucursal in listaSucursales) {
      listaSucursalesItems.add(DropdownMenuItem(
        value: sucursal.id,
        child: Text(sucursal.nombreSucursal!),
      ));
    }

    return DropdownButton<int>(
      items: listaSucursalesItems,
      isExpanded: true,
      value: _valueIdSucursal,
      onChanged: (value) {
        setState(() {
          _valueIdSucursal = value!;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Sucursal'),
        automaticallyImplyLeading: true,
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Espere...$textLoading'),
                  SizedBox(
                    height: windowHeight * 0.01,
                  ),
                  const CircularProgressIndicator(),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sucursalesDropdown(),
                  const SizedBox(height: 40),
                  Center(
                    child: SizedBox(
                      width: 300,
                      height: 70, // Aumentar la altura del botón
                      child: ElevatedButton(
                        onPressed: () {
                          if (_valueIdSucursal == 0) {
                            mostrarAlerta(context, 'Atención',
                                'Debes seleccionar una sucursal');
                          } else {
                            final sucursalSeleccionada =
                                listaSucursales.firstWhere((sucursal) =>
                                    sucursal.id == _valueIdSucursal);
                            sesion.idSucursal = sucursalSeleccionada.id;
                            Navigator.pushNamed(context, 'HomerCotizar');
                          }
                        },
                        child: const Text(
                          'Aceptar',
                          style: TextStyle(
                              fontSize: 22), // Aumentar el tamaño del texto
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
