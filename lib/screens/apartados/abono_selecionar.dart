import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/mostrar_alerta_ok.dart';

class SucursalesAbonoScreen extends StatefulWidget {
  const SucursalesAbonoScreen({super.key});

  @override
  State<SucursalesAbonoScreen> createState() => _SucursalesAbonoScreenState();
}

class _SucursalesAbonoScreenState extends State<SucursalesAbonoScreen> {
  String? _valueIdSucursal = '0'; 
  final articulosProvider = ArticuloProvider();
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

  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Sucursal'),
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
                        onPressed: () async {
                          final sucursalSeleccionada =
                              listaSucursales.firstWhere((sucursal) =>
                                  sucursal.id.toString() == _valueIdSucursal);
                          sesion.idSucursal = sucursalSeleccionada.id;
                          await articulosProvider
                              .listarProductosSucursal(sucursalSeleccionada.id!)
                              .then((value) {
                            if (value.status == 1) {
                              sesion.cotizar = false;
                              Navigator.pushReplacementNamed(context,'nvo-abono');
                            } else {
                              mostrarAlerta(context, "Error ",
                                  "Nose pudo cargar  los productos");
                            }
                          });
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

  Widget _sucursalesDropdown() {
    List<DropdownMenuItem<String>> listaSucursalesItems = [
      const DropdownMenuItem(
          value: '0', child: SizedBox(child: Text('Seleccione sucursal')))
    ];

    for (Sucursal sucursal in listaSucursales) {
      listaSucursalesItems.add(DropdownMenuItem(
        value: sucursal.id.toString(),
        child: Text(sucursal.nombreSucursal!),
      ));

      if (sucursal.id.toString() == _valueIdSucursal) {
        _valueIdSucursal = sucursal.id.toString();
      }
    }

    if (_valueIdSucursal == null || _valueIdSucursal!.isEmpty) {
      _valueIdSucursal = '0';
    }

    return DropdownButton<String>(
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
}
