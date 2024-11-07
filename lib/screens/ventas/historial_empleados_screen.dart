// ignore_for_file: unnecessary_import, unused_field

import 'package:flutter/material.dart';
import 'package:vende_facil/models/cuenta_sesion_modelo.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/abono_provider.dart';
import 'package:vende_facil/providers/apartado_provider.dart';
import 'package:vende_facil/providers/negocio_provider.dart';
import 'package:vende_facil/providers/reportes_provider.dart';
import 'package:vende_facil/providers/venta_provider.dart';
import 'package:intl/intl.dart';
import 'package:vende_facil/widgets/mostrar_alerta_ok.dart';

class HistorialEmpleadoScreen extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const HistorialEmpleadoScreen({Key? key});

  @override
  State<HistorialEmpleadoScreen> createState() =>
      _HistorialEmpleadoScreenState();
}

class _HistorialEmpleadoScreenState extends State<HistorialEmpleadoScreen> {
  final ventaProvider = VentasProvider();
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  String formattedEndDate = "";
  String formattedStartDate = "";
  bool _valueInformacion = false;
  DateTime now = DateTime.now();

  late DateTime _startDate;
  double totalVentas = 0.0;
  late DateFormat dateFormatter;

  final provider = NegocioProvider();
  final reportesProvider = ReportesProvider();

  final ventasProvider = VentasProvider();
  final apartadoProvider = ApartadoProvider();
  final abonoProvider = AbonoProvider();

  final negocioProvider = NegocioProvider();

  @override
  void initState() {
    _startDate = DateTime(now.year, now.month, now.day);
    dateFormatter = DateFormat('yyyy-MM-dd');
    formattedStartDate = dateFormatter.format(_startDate);
        _cargar();
            for (VariableConf varTemp in listaVariables) {                   
              if (varTemp.nombre == "empleado_cantidades") {
                if (varTemp.valor == null) {
                } else {
                  _valueInformacion = (varTemp.valor == "1") ? true : false;

                }
          }
        }
    super.initState();
  }

  _cargar() async {
    await reportesProvider.reporteEmpleado(formattedStartDate, formattedStartDate, sesion.idSucursal.toString(), sesion.idUsuario.toString());
    for (final venta in listaVentas) {
      totalVentas += venta.total!;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;

    final double? valorIngresado = ModalRoute.of(context)?.settings.arguments as double?;
    final diferencia = valorIngresado! - totalVentas;


    return PopScope(
      canPop: false,
      onPopInvoked: (didpop) {
        if (!didpop) {
          Navigator.pushReplacementNamed(context, 'menu');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ventas del dia1'),
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
                      const Text('Espere...'),
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
                child: Column(
                  children: [
                    Text('Total de ventas : \$ ${totalVentas.toStringAsFixed(2)}'),

                    Text('Diferencia: : \$ ${diferencia.toStringAsFixed(2)}')
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _getDetails(VentaCabecera venta) async {
    isLoading = true;
    setState(() {});

    await negocioProvider.getlistaSucursales();

    if (venta.tipo_movimiento == "V") {
      final resultado = await ventaProvider.consultarventa(venta.idMovimiento!);
      isLoading = false;
      setState(() {});
      if (resultado.status != 1) {
        mostrarAlerta(
            context, 'Error', resultado.mensaje ?? 'Intentalo mas tarde');
        return;
      }
      Navigator.pushNamed(context, 'ventasD');
      return;
    }

    if (venta.tipo_movimiento == "P") {
      final resultado =
          await apartadoProvider.detallesApartado(venta.idMovimiento!);
      isLoading = false;
      setState(() {});
      if (resultado.status != 1) {
        mostrarAlerta(
            context, 'Error', resultado.mensaje ?? 'Intentalo mas tarde');
        return;
      }
      Navigator.pushNamed(context, 'apartadosD');
      return;
    }

    if (venta.tipo_movimiento == "A") {
      final resultado =
          await abonoProvider.obtenerAbono(venta.idMovimiento.toString());
      isLoading = false;
      setState(() {});
      if (resultado.status != 1) {
        mostrarAlerta(
            context, 'Error', resultado.mensaje ?? 'Intentalo mas tarde');
        return;
      }
      Navigator.pushNamed(context, 'abonoD');
      return;
    }

    isLoading = false;
    setState(() {});
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
          String text;
          if (venta.tipo_movimiento! == 'V') {
            text = 'Venta';
          } else if (venta.tipo_movimiento! == 'P') {
            text = 'Apartado';
          } else {
            text = 'Abono';
          }
          return ListTile(
              title: Text(
                  '${venta.name} \n${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(venta.fecha_venta!))}'),
              subtitle: Text(text),
               trailing: _valueInformacion  ? Text('\$${venta.total}') : null, // ignore: avoid_returning_null
              onTap: () => _getDetails(venta)
              );
        }).toList(),
      );
    }
  }
}