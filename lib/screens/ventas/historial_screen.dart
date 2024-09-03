// ignore_for_file: unnecessary_import

import 'package:flutter/material.dart';
import 'package:vende_facil/models/cuenta_sesion_modelo.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/negocio_provider.dart';
import 'package:vende_facil/providers/reportes_provider.dart';
import 'package:vende_facil/providers/venta_provider.dart';
import 'package:intl/intl.dart';
import 'package:vende_facil/widgets/mostrar_alerta_ok.dart';

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


  bool? _allBranchOffice = true;
  String? _selectedBranchOffice = '0';
  String? _selectedEmployees = '0';

  NegocioProvider provider = NegocioProvider();
  ReportesProvider reportesProvider = ReportesProvider();

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
    listaVentas.clear();
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
                    SizedBox(height: windowHeight * 0.05,),
                    _sucursales(),
                    SizedBox(height: windowHeight * 0.05,),
                    _empleados(),
                    SizedBox(height: windowHeight * 0.05,),
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

  _setEmpleados(String? value) async {
    isLoading = true;
    setState(() {});
    _selectedEmployees = value;

    //* Aca entra
    if(value == '0') {
      // * Aca se hace uso del reporteSucursal
      final resultado = await reportesProvider.reporteSucursal(formattedStartDate, formattedEndDate, sesion.idNegocio.toString());
      isLoading = false;
      setState(() {});
      if(resultado.status != 1) {
        mostrarAlerta(context, 'Error', resultado.mensaje!);
        return;
      }
      return;
    }

    final resultado = await reportesProvider.reporteEmpleado(formattedStartDate, formattedEndDate, _selectedBranchOffice!, value!);
    isLoading = false;
    setState(() {});
    if(resultado.status != 1) {
      mostrarAlerta(context, 'Error', resultado.mensaje!);
      return;
    }
  }

  _empleados() {
    var lista = [
      const DropdownMenuItem(value: '0', child: SizedBox(child: Text('Todos')),),
    ];
    lista.addAll(
      listasucursalEmpleado.map((empleado) => DropdownMenuItem(value: empleado.id.toString(), child: SizedBox(child: Text(empleado.name!),),))
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('EMPLEADOS', style: TextStyle(fontSize: 13),),
        DropdownButton(
          value: _selectedEmployees,
          isExpanded: true,
          items: lista,
          onChanged: _allBranchOffice != null ? _setEmpleados : null
        )
      ],
    );
  }

  _sucursales() {
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Seleccione una opción', style: TextStyle(fontSize: 13),),
          DropdownButton(
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
          ),
        ],
      );
    } else {
      var listades = [
        const DropdownMenuItem(
          value: '0',
          child: SizedBox(child: Text('Todos')),
        ),
      ];
      listades.addAll(
        listaSucursales.map((sucursal) {
          return DropdownMenuItem(
            value: sucursal.id.toString(),
            child: SizedBox(child: Text(sucursal.nombreSucursal ?? '')),
          );
        }).toList(),
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SUCURSALES', style: TextStyle(fontSize: 13),),
          DropdownButton(
            items: listades,
            isExpanded: true,
            value: _selectedBranchOffice,
            onChanged: (value) async {
              //* Aca se selecciono todas las sucursales
              isLoading = true;
              setState(() {});

              if(value == '0') {
                _allBranchOffice = null;
                _selectedBranchOffice = value;
                final resultado = await reportesProvider.reporteGeneral(formattedStartDate, formattedEndDate);
                isLoading = false;
                setState(() {});
                if(resultado.status != 1) {
                  mostrarAlerta(context, 'Error', resultado.mensaje!);
                  return;
                }
                return;
              }


              isLoading = true;
              _allBranchOffice = true;
              _selectedBranchOffice = value;
              final resultado = await provider.getlistaempleadosEnsucursales();
              if(resultado.status == 1) {
                isLoading = false;
                setState(() {});
                return;
              }
              isLoading = false;
              setState(() {});
              mostrarAlerta(context, 'Selecciona otra sucursal', resultado.mensaje!);
              /*
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
              */
            },
          ),
        ],
      );
    }
  }

  _listaVentas() {
    if (listaVentas.isEmpty) {
      return const Center(
        child: Text(
            'No hay ventas realizadas en el rango de fechas seleccionado.'),
      );
    } else {
      return Column(
        children: listaVentas.map((venta) {
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
