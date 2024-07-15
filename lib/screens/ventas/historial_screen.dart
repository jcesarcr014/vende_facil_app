// ignore_for_file: unnecessary_import

import 'package:flutter/material.dart';
import 'package:vende_facil/models/cuenta_sesion_modelo.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/venta_provider.dart';
import 'package:intl/intl.dart';

class HistorialScreen extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const HistorialScreen({Key? key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final ventaProvider = VentasProvider();
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  String formattedEndDate = "";
  String formattedStartDate = "";
  DateTime now = DateTime.now();
  String _valueIdEmpleado = '0';

  late DateTime _startDate;
  late DateTime _endDate;
  double totalVentas = 0.0;
  late DateFormat dateFormatter;
  final _dateController = TextEditingController();

  @override
  void initState() {
    if (sesion.tipoUsuario == "p") {
      _valueIdEmpleado = '0';
    } else {
      _valueIdEmpleado = sesion.idUsuario.toString();
    }
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = _startDate.add(const Duration(days: 30));
    dateFormatter = DateFormat('yyyy-MM-dd');
    formattedStartDate = dateFormatter.format(_startDate);
    formattedEndDate = dateFormatter.format(_endDate);
    _dateController.text = '$formattedStartDate - $formattedEndDate';
    super.initState();
    _consultarVentas();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      onPopInvoked: (didpop) {
        if (!didpop) {
          Navigator.pushReplacementNamed(context, 'menu');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Historial de Ventas'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'menu');
              },
              icon: const Icon(Icons.menu),
            ),
          ],
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
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.04),
                child: Column(
                  children: [
                    SizedBox(
                      height: windowHeight * 0.02,
                    ),
                    const Text(
                      'Seleccione el rango de fechas y los usuarios para realizar la consulta.',
                      maxLines: 2,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(
                      height: windowHeight * 0.02,
                    ),
                    // ignore: avoid_unnecessary_containers
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            child: TextFormField(
                              controller: _dateController,
                              onTap: () async {
                                final picked = await showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime(2015),
                                  lastDate: DateTime(2100),
                                  initialDateRange: DateTimeRange(
                                    start: formattedStartDate.isEmpty
                                        ? DateTime.now()
                                        : _startDate,
                                    end: formattedEndDate.isEmpty
                                        ? _startDate
                                            .add(const Duration(days: 30))
                                        : _endDate,
                                  ),
                                );
                                if (picked != null &&
                                    picked !=
                                        DateTimeRange(
                                            start: _startDate,
                                            end: formattedEndDate.isEmpty
                                                ? _startDate.add(
                                                    const Duration(days: 30))
                                                : _endDate)) {
                                  setState(() {
                                    _startDate = picked.start;
                                    _endDate = picked.end;
                                    dateFormatter = DateFormat('yyyy-MM-dd');
                                    formattedStartDate =
                                        dateFormatter.format(_startDate);
                                    formattedEndDate =
                                        dateFormatter.format(_endDate);
                                    _dateController.text =
                                        '$formattedStartDate - $formattedEndDate';
                                  });
                                  _consultarVentas();
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Seleccionar fecha',
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    final picked = await showDateRangePicker(
                                      context: context,
                                      firstDate: DateTime(2015),
                                      lastDate: DateTime(2100),
                                      initialDateRange: DateTimeRange(
                                        start: formattedStartDate.isEmpty
                                            ? DateTime.now()
                                            : _startDate,
                                        end: formattedEndDate.isEmpty
                                            ? _startDate
                                                .add(const Duration(days: 30))
                                            : _endDate,
                                      ),
                                    );
                                    if (picked != null &&
                                        picked !=
                                            DateTimeRange(
                                                start: _startDate,
                                                end: formattedEndDate.isEmpty
                                                    ? _startDate.add(
                                                        const Duration(
                                                            days: 30))
                                                    : _endDate)) {
                                      setState(() {
                                        _startDate = picked.start;
                                        _endDate = picked.end;
                                        dateFormatter =
                                            DateFormat('yyyy-MM-dd');
                                        formattedStartDate =
                                            dateFormatter.format(_startDate);
                                        formattedEndDate =
                                            dateFormatter.format(_endDate);
                                        _dateController.text =
                                            '$formattedStartDate - $formattedEndDate';
                                      });
                                      _consultarVentas();
                                    }
                                  },
                                  icon: const Icon(Icons.calendar_today),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: windowHeight * 0.05,
                    ),
                    _empleado(),
                    SizedBox(
                      height: windowHeight * 0.05,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _listaVentas(),
                      ),
                    ),
                  ],
                ),
              ),
        persistentFooterButtons: [
          BottomAppBar(
            child: SizedBox(
              height: 50,
              child: Center(
                child: Text(
                    'Total de ventas : \$ ${totalVentas.toStringAsFixed(2)}'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _consultarVentas() async {
    setState(() {
      isLoading = true;
    });
    if (_valueIdEmpleado == '0') {
      // ignore: unused_local_variable
      final result = await ventaProvider.consultarVentasFecha(
        formattedStartDate,
        formattedEndDate,
      );
    } else {
      // ignore: unused_local_variable
      final result = await ventaProvider.consultarVentasFechaUsuario(
        formattedStartDate,
        formattedEndDate,
        _valueIdEmpleado,
      );
      setState(() {});
    }
    setState(() {
      isLoading = false;
      for (VentaCabecera venta in listaVentaCabecera) {
        totalVentas += venta.total!;
      }
    });
  }

  _empleado() {
    print(sesion.tipoUsuario);
    if (sesion.tipoUsuario == "p") {
      var listades = [
        const DropdownMenuItem(
          value: '0',
          child: SizedBox(child: Text('Todos')),
        )
      ];
      for (Usuario empleado in listaEmpleados) {
        listades.add(DropdownMenuItem(
            value: empleado.id.toString(), child: Text(empleado.nombre!)));
      }
      if (_valueIdEmpleado.isEmpty) {
        _valueIdEmpleado = '0';
      }
      return DropdownButton(
        items: listades,
        isExpanded: true,
        value: _valueIdEmpleado,
        onChanged: (value) {
          _valueIdEmpleado = value!;
          if (value == "0") {
            setState(() {});
            _consultarVentas();
          } else {
            Usuario empleadoSeleccionado = listaEmpleados
                .firstWhere((empleado) => empleado.id.toString() == value);
            if (empleadoSeleccionado.id == 0) {
              _valueIdEmpleado = '0';
              setState(() {});
              _consultarVentas();
            } else {
              _valueIdEmpleado = empleadoSeleccionado.id.toString();
              setState(() {});
              _consultarVentas();
            }
          }
        },
      );
    } else {
      var listades = [
        DropdownMenuItem(
          value: sesion.idUsuario.toString(),
          child: SizedBox(child: Text(sesion.nombreUsuario!)),
        )
      ];
      return DropdownButton(
        items: listades,
        isExpanded: true,
        value: sesion.idUsuario.toString(),
        onChanged: (value) {
          _valueIdEmpleado = value.toString();
          if (value == sesion.idUsuario.toString()) {
            _valueIdEmpleado = sesion.idUsuario.toString();
            setState(() {});
            _consultarVentas();
          } else {
            Usuario empleadoSeleccionado = listaEmpleados
                .firstWhere((empleado) => empleado.id.toString() == value);
            if (empleadoSeleccionado.id == 0) {
              _valueIdEmpleado = '0';
              setState(() {});
              _consultarVentas();
            } else {
              _valueIdEmpleado = empleadoSeleccionado.id.toString();
              setState(() {});
              _consultarVentas();
            }
          }
        },
      );
    }
  }

  _listaVentas() {
    if (listaVentaCabecera.isEmpty) {
      return const Center(
        child: Text(
            'No hay ventas realizadas en el rango de fechas seleccionado.'),
      );
    } else {
      return Column(
        children: listaVentaCabecera.map((venta) {
          return ListTile(
            title: Text(venta.name!),
            subtitle: Text(venta.tipo_movimiento!),
            trailing: Text('\$${venta.total}'),
          );
        }).toList(),
      );
    }
  }
}
