// ignore_for_file: unnecessary_import

import 'package:flutter/material.dart';
import 'package:vende_facil/models/cuenta_sesion_modelo.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:intl/intl.dart';
import 'package:vende_facil/widgets/mostrar_alerta_ok.dart';

class HistorialCotizacionesScreen extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const HistorialCotizacionesScreen({Key? key});

  @override
  State<HistorialCotizacionesScreen> createState() =>
      _HistorialCotizacionesScreenState();
}

class _HistorialCotizacionesScreenState
    extends State<HistorialCotizacionesScreen> {
  bool isLoading = false;
  String textLoading = '';
  String formattedEndDate = "";
  String formattedStartDate = "";
  DateTime now = DateTime.now();

  late DateTime _startDate;
  late DateTime _endDate;
  double totalVentas = 0.0;
  late DateFormat dateFormatter;
  final _dateController = TextEditingController();

  bool? _allBranchOffice = true;
  String? _sucursalSeleccionada = '-1';
  String? _empleadoSeleccionado = '0';

  final cotizaciones = CotizarProvider();

  final List<Cotizacion> cotizacionesCopia = [];

  @override
  void initState() {
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = _startDate.add(const Duration(days: 30));
    dateFormatter = DateFormat('yyyy-MM-dd');
    formattedStartDate = dateFormatter.format(_startDate);
    formattedEndDate = dateFormatter.format(_endDate);
    _dateController.text = '$formattedStartDate - $formattedEndDate';
    _cargar();
    super.initState();
  }

  _cargar() async {
    await cotizaciones.listarCotizaciones(sesion.idNegocio!);
  }

  @override
  Widget build(BuildContext context) {
    final windowWidth = MediaQuery.of(context).size.width;
    final windowHeight = MediaQuery.of(context).size.height;
    return PopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Historial de Cotizaciones'),
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
                                  //_consultarVentas();
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
                                      //_consultarVentas();
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
                    _sucursales(),
                    SizedBox(
                      height: windowHeight * 0.05,
                    ),
                    _empleados(),
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
      ),
    );
  }

  _setEmpleados(String? value) async {
    _empleadoSeleccionado = value;
    setState(() {});
    if (value == '-1') return;
    
    listacotizacion = cotizacionesCopia;

    if(value != '0') {
      listacotizacion = listacotizacion.where((cotizacion) => cotizacion.usuarioId.toString() == value).toList();
    }
    setState(() {});
  }

  _empleados() {
    var lista = [
      const DropdownMenuItem(
        value: '-1',
        child: SizedBox(child: Text('Seleccione un Empleado')),
      ),
      const DropdownMenuItem(
        value: '0',
        child: SizedBox(child: Text('Todos')),
      ),
    ];
    lista.addAll(listasucursalEmpleado.map((empleado) => DropdownMenuItem(
          value: empleado.usuarioId.toString(),
          child: SizedBox(
            child: Text(empleado.name!),
          ),
        )));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EMPLEADOS',
          style: TextStyle(fontSize: 13),
        ),
        DropdownButton(
            value: _empleadoSeleccionado,
            isExpanded: true,
            items: lista,
            onChanged: _allBranchOffice != null ? _setEmpleados : null)
      ],
    );
  }

  _sucursales() {
    if (sesion.tipoUsuario == "P") {
      var listades = [
        const DropdownMenuItem(
          value: '-1',
          child: SizedBox(child: Text('Seleccione una Sucursal')),
        ),
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
          const Text(
            'SUCURSALES',
            style: TextStyle(fontSize: 13),
          ),
          DropdownButton(
            items: listades,
            isExpanded: true,
            value: _sucursalSeleccionada,
            onChanged: (value) async {
              if (value == '-1') return;
              cotizacionesCopia.clear();
              isLoading = true;
              _sucursalSeleccionada = value;
              setState(() {});
              if (value == '0') {
                _allBranchOffice = null;
                final resultado = await cotizaciones.listarCotizaciones(sesion.idNegocio!);
                cotizacionesCopia.addAll(listacotizacion);
                isLoading = false;
                setState(() {});
                if (resultado.status != 1) {
                  mostrarAlerta(context, 'Error', resultado.mensaje!);
                  return;
                }
                return;
              }
              isLoading = true;
              _allBranchOffice = true;
              final resultado = await cotizaciones.listarCotizaciones(int.parse(value!));
              isLoading = false;
              cotizacionesCopia.addAll(listacotizacion);
              setState(() {});

              if (resultado.status != 1) {
                mostrarAlerta(context, 'Selecciona otra sucursal', resultado.mensaje!);
                return;
              }
            },
          ),
        ],
      );
    }
  }


  _listaVentas() {
    if (listacotizacion.isEmpty) {
      return const Center(
        child: Text(
            'No hay cotizaciones realizadas en el rango de fechas seleccionado.'),
      );
    } else {
      return Column(
        children: listacotizacion.map((cotizar) {
          return ListTile(
            title: Text(cotizar.folio!),
            subtitle: Text('${cotizar.venta_realizada!}'),
            trailing: Text('\$${cotizar.subtotal}'),
            onTap: () async {
              await cotizaciones.consultarcotizacion(cotizar.id!);
              Navigator.pushNamed(context, 'detalleCotizacions');
            },
          );
        }).toList(),
      );
    }
  }
}
