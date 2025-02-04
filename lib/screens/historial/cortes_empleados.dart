import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/mostrar_alerta_ok.dart';

class CortesEmpleadosScreen extends StatefulWidget {
  const CortesEmpleadosScreen({super.key});

  @override
  State<CortesEmpleadosScreen> createState() => _CortesEmpleadosScreenState();
}

class _CortesEmpleadosScreenState extends State<CortesEmpleadosScreen> {
  final corteProvider = CorteProvider();
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  String formattedStartDate = "";
  final fechaController = TextEditingController();
  DateTime now = DateTime.now();
  late DateTime _startDate;
  late DateFormat dateFormatter;

  cargarCortes() {
    setState(() {
      isLoading = true;
      textLoading = 'Cargando cortes...';
    });

    corteProvider.cortesFecha(formattedStartDate).then((value) {
      setState(() {
        isLoading = false;
        textLoading = '';
      });
      if (value.status != 1) {
        mostrarAlerta(context, 'ERROR',
            'Ocurrio un error al consultar: ${value.mensaje}');
      }
    });
  }

  @override
  void initState() {
    _startDate = DateTime(now.year, now.month, now.day);
    dateFormatter = DateFormat('yyyy-MM-dd');
    formattedStartDate = dateFormatter.format(_startDate);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return PopScope(
        canPop: false,
        onPopInvoked: (didpop) {
          if (!didpop) {
            Navigator.pushReplacementNamed(context, 'menu-historial');
          }
        },
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Historial de Cortes'),
            ),
            body: (isLoading)
                ? Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Espere...'),
                          SizedBox(
                            height: windowHeight * 0.01,
                          ),
                          const CircularProgressIndicator(),
                        ]),
                  )
                : Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: windowWidth * 0.04),
                    child: Column(
                      children: [
                        SizedBox(
                          height: windowHeight * 0.02,
                        ),
                        const Text(
                          'Seleccione la fecha que desea consultar:',
                          maxLines: 2,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(
                          height: windowHeight * 0.02,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                readOnly: true,
                                controller: fechaController
                                  ..text = formattedStartDate,
                                decoration: const InputDecoration(
                                  labelText: 'Fecha',
                                  icon: Icon(Icons.calendar_today),
                                ),
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: _startDate,
                                    firstDate: DateTime(2015, 8),
                                    lastDate: DateTime(2101),
                                  );
                                  if (picked != null && picked != _startDate) {
                                    setState(() {
                                      _startDate = picked;
                                      formattedStartDate =
                                          dateFormatter.format(_startDate);

                                      fechaController.text = formattedStartDate;
                                    });
                                  }
                                },
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: windowHeight * 0.02,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            cargarCortes();
                          },
                          child: const Text(
                            'Buscar',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: windowHeight * 0.05,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: _listaCortes(),
                          ),
                        ),
                      ],
                    ),
                  )));
  }

  _listaCortes() {
    if (listaCortes.isEmpty) {
      return const Text('No hay cortes registrados');
    } else {
      return Column(
        children: listaCortes.map((corte) {
          return ListTile(
            title: Text('Corte del ${corte.fecha}'),
            subtitle: Text('Ventas en efectivo: ${corte.ventasEfectivo}'),
            trailing: Text('Total ingresos: ${corte.totalIngresos}'),
          );
        }).toList(),
      );
    }
  }
}
