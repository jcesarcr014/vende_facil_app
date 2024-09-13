// ignore_for_file: unnecessary_import

import 'package:flutter/material.dart';
import 'package:vende_facil/models/cuenta_sesion_modelo.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/negocio_provider.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/providers/reportes_provider.dart';
import 'package:vende_facil/providers/venta_provider.dart';
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
  final ventaProvider = VentasProvider();
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;
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

  NegocioProvider provider = NegocioProvider();
  final cotizaciones = CotizarProvider();
  ReportesProvider reportesProvider = ReportesProvider();

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
    await cotizaciones.listarCotizaciones();
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
          title: const Text('Historial de Cotizaciones'),
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
    if (value == '-1') return;
    isLoading = true;
    setState(() {});
    _empleadoSeleccionado = value;
    if (value == '0') {
      final resultado = await reportesProvider.reporteSucursal(
          formattedStartDate, formattedEndDate, _sucursalSeleccionada!);
      isLoading = false;
      setState(() {
        _busqueda();
      });
      if (resultado.status != 1) {
        mostrarAlerta(context, 'Error', resultado.mensaje!);
        return;
      }
      return;
    }

    final resultado = await reportesProvider.reporteEmpleado(
        formattedStartDate, formattedEndDate, _sucursalSeleccionada!, value!);
    isLoading = false;
    setState(() {});
    if (resultado.status != 1) {
      mostrarAlerta(context, 'Error', resultado.mensaje!);
      return;
    }
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
              isLoading = true;
              _sucursalSeleccionada = value;
              setState(() {});
              _busqueda();
              if (value == '0') {
                _allBranchOffice = null;
                final resultado = await reportesProvider.reporteGeneral(
                    formattedStartDate, formattedEndDate);
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
              final resultado =
                  await provider.getlistaempleadosEnsucursales(value!);
              if (resultado.status == 1) {
                isLoading = false;
                setState(() {});
                return;
              }
              isLoading = false;
              setState(() {});
              mostrarAlerta(
                  context, 'Selecciona otra sucursal', resultado.mensaje!);
            },
          ),
        ],
      );
    }
  }

  _busqueda() {
    int empleado = 0;
    int sucursals = 0;
    if (_empleadoSeleccionado == '0') {
      empleado = sesion.idUsuario!;
    } else {
      empleado = int.parse(_empleadoSeleccionado!);
    }
    if (_sucursalSeleccionada == '0') {
      sucursals = sesion.idNegocio!;
    } else {
      sucursals = int.parse(_sucursalSeleccionada!);
    }
    var resultado = listacotizacion
        .where(
          (element) =>
              element.id_sucursal == sucursals && element.usuarioId == empleado,
        )
        .toList();
    return resultado;
  }

  _listaVentas() {
    List<Cotizacion> resultadoCotizaciones = _busqueda();
    if (resultadoCotizaciones.isEmpty) {
      return const Center(
        child: Text(
            'No hay cotizaciones realizadas en el rango de fechas seleccionado.'),
      );
    } else {
      return Column(
        children: resultadoCotizaciones.map((venta) {
          return ListTile(
            title: Text(venta.folio!),
            subtitle: Text(venta.folio!),
            trailing: Text('\$${venta.subtotal}'),
            onTap: () async {
              await ventaProvider.consultarventa(
                  venta.id!); // se cambiara  cuando  se tenga la ruta
              Navigator.pushReplacementNamed(context, "ventasD");
            },
          );
        }).toList(),
      );
    }
  }
}
