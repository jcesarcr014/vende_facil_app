// ignore_for_file: unnecessary_import

import 'package:flutter/material.dart';
import 'package:vende_facil/models/cuenta_sesion_modelo.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/apartado_provider.dart';
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

  late DateTime _startDate;
  late DateTime _endDate;
  double totalVentas = 0.0;
  late DateFormat dateFormatter;
  final _dateController = TextEditingController();


  bool? _allBranchOffice = true;
  String? _sucursalSeleccionada = '-1';
  String? _empleadoSeleccionado = '0';

  final provider = NegocioProvider();
  final reportesProvider = ReportesProvider();

  final ventasProvider = VentasProvider();
  final apartadoProvider = ApartadoProvider();

  final negocioProvider = NegocioProvider();


  @override
  void initState() {
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = _startDate.add(const Duration(days: 30));
    dateFormatter = DateFormat('yyyy-MM-dd');
    formattedStartDate = dateFormatter.format(_startDate);
    formattedEndDate = dateFormatter.format(_endDate);
    _dateController.text = '$formattedStartDate - $formattedEndDate';
    listaVentas.clear();
    listasucursalEmpleado.clear();
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

  _setEmpleados(String? value) async {
    if(value == '-1') return;
    isLoading = true;
    setState(() {});
    _empleadoSeleccionado = value;
    if(value == '0') {
      final resultado = await reportesProvider.reporteSucursal(formattedStartDate, formattedEndDate, _sucursalSeleccionada!);
      isLoading = false;
      setState(() {});
      if(resultado.status != 1) {
        mostrarAlerta(context, 'Error', resultado.mensaje!);
        return;
      }
      return;
    }


    final resultado = await reportesProvider.reporteEmpleado(formattedStartDate, formattedEndDate, _sucursalSeleccionada!, value!);
    isLoading = false;
    setState(() {});
    if(resultado.status != 1) {
      mostrarAlerta(context, 'Error', resultado.mensaje!);
      return;
    }
  }

  _empleados() {
    var lista = [
      const DropdownMenuItem(value: '-1', child: SizedBox(child: Text('Seleccione un Empleado')),),
      const DropdownMenuItem(value: '0', child: SizedBox(child: Text('Todos')),),
    ];
    lista.addAll(
      listasucursalEmpleado.map((empleado) => DropdownMenuItem(value: empleado.usuarioId.toString(), child: SizedBox(child: Text(empleado.name!),),))
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('EMPLEADOS', style: TextStyle(fontSize: 13),),
        DropdownButton(
          value: _empleadoSeleccionado,
          isExpanded: true,
          items: lista,
          onChanged: _allBranchOffice != null ? _setEmpleados : null
        )
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
          const Text('SUCURSALES', style: TextStyle(fontSize: 13),),
          DropdownButton(
            items: listades,
            isExpanded: true,
            value: _sucursalSeleccionada,
            onChanged: (value) async {
              if(value == '-1') return;
              isLoading = true;
              _sucursalSeleccionada = value;
              setState(() {});

              if(value == '0') {
                _allBranchOffice = null;
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
              final resultado = await provider.getlistaempleadosEnsucursales(value!);
              if(resultado.status == 1) {
                isLoading = false;
                setState(() {});
                return;
              }
              isLoading = false;
              setState(() {});
              mostrarAlerta(context, 'Selecciona otra sucursal', resultado.mensaje!);
            },
          ),
        ],
      );
    }
  }

  void _getDetails(VentaCabecera venta) async {
    await negocioProvider.getlistaSucursales();

    if(venta.tipo_movimiento == "V") {
      final resultado = await ventaProvider.consultarventa(venta.idMovimiento!);
      if(resultado.status != 1) {
        mostrarAlerta(context, 'Error', resultado.mensaje ?? 'Intentalo mas tarde');
        return;
      }
      Navigator.pushNamed(context, 'ventasD');
      return;
    }

    if(venta.tipo_movimiento == "P") {
      final resultado = await apartadoProvider.detallesApartado(venta.idMovimiento!);
      if(resultado.status != 1) {
        mostrarAlerta(context, 'Error', resultado.mensaje ?? 'Intentalo mas tarde');
        return;
      }
      Navigator.pushNamed(context, 'apartadosD');
      return;
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
            onTap: () => _getDetails(venta)
          );
        }).toList(),
      );
    }
  }
}
