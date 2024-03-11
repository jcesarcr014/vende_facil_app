import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/venta_provider.dart';
import 'package:intl/intl.dart';

class HistorialScreen extends StatefulWidget {
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
  void initState() {
    super.initState();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = _startDate.add(const Duration(days: 30));
    dateFormatter = DateFormat('yyyy-MM-dd');
    formattedStartDate = dateFormatter.format(_startDate);
    formattedEndDate = dateFormatter.format(_endDate);
    _fetchData();
    calcularTotalVentas();
  }

  void calcularTotalVentas() {
    totalVentas = 0.0;
    for (VentaCabecera venta in listaVentaCabecera) {
      totalVentas += venta.total ?? 0.0;
    }
  }

  void _fetchData() {
    setState(() {
      textLoading = 'Leyendo registros de ventas';
      isLoading = true;
    });
    ventaProvider
        .consultarVentasFecha(formattedStartDate, formattedEndDate)
        .then((value) {
      setState(() {
        textLoading = '';
        isLoading = false;
        calcularTotalVentas();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 20.0,
          ),
          Padding(
            padding: const EdgeInsetsDirectional.all(5.0),
            child: Row(
              children: [
                TextButton(
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
                            ? _startDate.add(const Duration(days: 30))
                            : _endDate,
                      ),
                    );
                    if (picked != null &&
                        picked !=
                            DateTimeRange(
                                start: _startDate,
                                end: formattedEndDate.isEmpty
                                    ? _startDate.add(const Duration(days: 30))
                                    : _endDate)) {
                      setState(() {
                        _startDate = picked.start;
                        _endDate = picked.end;
                        dateFormatter = DateFormat('yyyy-MM-dd');
                        formattedStartDate = dateFormatter.format(_startDate);
                        formattedEndDate = dateFormatter.format(_endDate);
                        _fetchData();
                      });
                    }
                  },
                  child: Text(
                    '$formattedStartDate - $formattedEndDate',
                    style: const TextStyle(fontSize: 15.0),
                  ),
                ),
                const Icon(Icons.calendar_today, size: 15.0),
              ],
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Expanded(
            child: (isLoading)
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
                : ListView.builder(
                    itemCount: listaVentaCabecera.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(listaVentaCabecera[index].folio!),
                        subtitle: Text(listaVentaCabecera[index].fecha_venta!),
                        trailing:
                            Text(listaVentaCabecera[index].total.toString()),
                        onTap: () {
                          ventaProvider
                              .consultarventa(listaVentaCabecera[index].id!)
                              .then((value) {
                                                      setState(() {
                                                        textLoading = 'cargado detalle de venta';
                                                        isLoading = false;
                                                      });
                            if (value.id != 0) {
                              Navigator.pushNamed(context, 'ventasD',
                                  arguments: value);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(value.mensaje!),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
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
}
