import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/mostrar_alerta_ok.dart';

class SucursalesAbonoScreen extends StatefulWidget {
  final int? indice;
  const SucursalesAbonoScreen({this.indice, super.key});

  @override
  State<SucursalesAbonoScreen> createState() => _SucursalesAbonoScreenState();
}

class _SucursalesAbonoScreenState extends State<SucursalesAbonoScreen> {
  late int indiceRecibido;
  String _valueIdSucursal = '0';
  final apartadoProvider = ApartadoProvider();
  final sucursalProvider = NegocioProvider();
  bool isLoading = false;
  double windowHeight = 0.0;
  String textLoading = '';

  @override
  initState() {
    super.initState();
    setState(() {
      textLoading = 'Cargar Sucursales';
      isLoading = true;
    });
    sucursalProvider.getlistaSucursales().then((resp) {
      setState(() {
        textLoading = '';
        isLoading = false;
      });
    });
    indiceRecibido = widget.indice ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leyendo sucursales'),
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
                      height: 70,
                      child: ElevatedButton(
                        onPressed: _buscarApartados,
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

  void _buscarApartados() {
    if (_valueIdSucursal == '0') {
      mostrarAlerta(context, 'Atención', 'Debe seleccionar una sucursal');
    } else {
      setState(() {
        isLoading = true;
        textLoading = 'Leyendo movimientos';
      });
      sesion.idSucursal = int.parse(_valueIdSucursal);
      if (indiceRecibido == 1) {
        apartadoProvider.apartadosPendientesSucursal().then((resp) {
          setState(() {
            isLoading = false;
            textLoading = '';
          });
          if (resp.status == 1) {
            Navigator.pushNamed(context, 'lista-apartados', arguments: 1);
          } else {
            mostrarAlerta(context, 'ERROR', 'Ocurrio un error ${resp.mensaje}');
          }
        });
      } else {
        apartadoProvider.apartadosPagadosSucursal().then((resp) {
          setState(() {
            isLoading = false;
            textLoading = '';
          });
          if (resp.status == 1) {
            Navigator.pushNamed(context, 'lista-apartados', arguments: 1);
          } else {
            mostrarAlerta(context, 'ERROR', 'Ocurrio un error ${resp.mensaje}');
          }
        });
      }
    }
  }
}
