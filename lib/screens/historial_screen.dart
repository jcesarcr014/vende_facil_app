import 'package:flutter/material.dart';
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

  late DateTime _startDate;
  late DateTime _endDate;
  double totalVentas = 0.0;
  late DateFormat dateFormatter;

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
            : SingleChildScrollView(
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
                  ],
                ),
              ),
      ),
    );
  }
}
