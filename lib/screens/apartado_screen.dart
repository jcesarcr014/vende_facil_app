import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vende_facil/widgets/widgets.dart';

class ApartadoDetalleScreen extends StatefulWidget {
  const ApartadoDetalleScreen({super.key});
  @override
  State<ApartadoDetalleScreen> createState() => _ApartadoDetalleScreenState();
}

class _ApartadoDetalleScreenState extends State<ApartadoDetalleScreen> {
      double windowWidth = 0.0;
      double windowHeight = 0.0;
      double efectivo = 0.0;
      double tarjeta = 0.0;
      double total = 0.0;
      final ApartadoConttoller = TextEditingController();
      final TotalConttroller = TextEditingController();
      final EfectivoController = TextEditingController();
      final CambioController = TextEditingController();
      final TarjetaController = TextEditingController();
      final _dateController = TextEditingController();
      String formattedEndDate = "";
      String formattedStartDate = "";
      DateTime now = DateTime.now();
      late DateTime _startDate;
      late DateTime _endDate;
      late DateFormat dateFormatter;
      void initState() {
            _startDate = DateTime(now.year, now.month, now.day);
            _endDate = _startDate.add(const Duration(days: 30));
            dateFormatter = DateFormat('yyyy-MM-dd');
            formattedStartDate = dateFormatter.format(_startDate);
            formattedEndDate = dateFormatter.format(_endDate);
            _dateController.text = '$formattedStartDate - $formattedEndDate';
        super.initState();
      }
    @override
    Widget build(BuildContext context) {
      windowWidth = MediaQuery.of(context).size.width;
      windowHeight = MediaQuery.of(context).size.height;

      return Scaffold(
        appBar: AppBar(
          title: const Text('Apartado'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // ignore: avoid_unnecessary_containers
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Flexible(child: Text("Fecha:")),
                    SizedBox(
                      width: windowWidth * 0.01,
                    ),
                    Flexible(
                                  child: TextFormField(
                                    controller: _dateController,
                                    onTap: () async {
                                      final picked = await showDateRangePicker(
                                        context: context,
                                        firstDate: DateTime(2015),
                                        lastDate: DateTime(2100),
                                        initialDateRange: DateTimeRange(
                                          start: formattedStartDate.isEmpty ? DateTime.now() : _startDate,
                                          end: formattedEndDate.isEmpty ? _startDate.add(const Duration(days: 30)) : _endDate,
                                        ),
                                      );
                                      if (picked != null &&
                                          picked != DateTimeRange(
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
                                          _dateController.text = '$formattedStartDate - $formattedEndDate';
                                        });
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
                                              start: formattedStartDate.isEmpty ? DateTime.now() : _startDate,
                                              end: formattedEndDate.isEmpty ? _startDate.add(const Duration(days: 30)) : _endDate,
                                            ),
                                          );
                                          if (picked != null &&
                                              picked != DateTimeRange(
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
                                              _dateController.text = '$formattedStartDate - $formattedEndDate';
                                            });
                                          }
                                        },
                                        icon: Icon(Icons.calendar_today),
                                      ),
                                    ),
                                  ),
                               ),

                  ],
                  ) ,
              ),
              SizedBox(
                height: windowHeight * 0.05,
              ),
              // ignore: avoid_unnecessary_containers
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    
                    const Flexible(child: Text("Apartado:")),
                    SizedBox(
                      width: windowWidth * 0.01,
                    ),
                    Flexible(
                      child: TextFormField(
                        controller: ApartadoConttoller ,
                        enabled: false,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Apartado',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: windowHeight * 0.05,
              ),
              // ignore: avoid_unnecessary_containers
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Flexible(child: Text("Total:")),
                    SizedBox(
                      width: windowWidth * 0.01,
                    ),
                    Flexible(
                      child: TextFormField(
                        controller: TotalConttroller,
                        enabled: false,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Total',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: windowHeight * 0.05,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Flexible(child: Text("Efectivo:")),
                    SizedBox(
                      width: windowWidth * 0.01,
                    ),
                    Flexible(
                      child: InputFieldMoney(
                        controller: EfectivoController,
                        onChanged: (value) {
                          tuFuncion();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: windowHeight * 0.05,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Flexible(child: Text("Tarjeta:")),
                    SizedBox(
                      width: windowWidth * 0.01,
                    ),
                    Flexible(
                      child: InputFieldMoney(
                        controller: TarjetaController,
                        onChanged: (value) {
                          tuFuncion();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: windowHeight * 0.05,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Flexible(child: Text("Cambio:")),
                    SizedBox(
                      width: windowWidth * 0.01,
                    ),
                    Flexible(
                      child: TextFormField(
                        controller: CambioController,
                        enabled: false,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Cambio',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: windowHeight * 0.05,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        
                      },
                      child: const Text('Aceptar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                      },
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    tuFuncion() {
    try {
      if (EfectivoController.text.contains(',')) {
        efectivo = double.parse(EfectivoController.text.replaceAll(',', ''));
      } else {
        efectivo = double.parse(EfectivoController.text);
      }
      if (TarjetaController.text.contains(',')) {
        tarjeta = double.parse(TarjetaController.text.replaceAll(',', ''));
      } else {
        tarjeta = double.parse(TarjetaController.text);
      }
      total = double.parse(TotalConttroller.text);

      var suma = efectivo + tarjeta;
      var cambio = suma - total;
      if (cambio < 0) {
        CambioController.text = "0.00";
        setState(() {});
      } else {
        CambioController.text = cambio.toStringAsFixed(2);
        setState(() {});
      }

      // ignore: empty_catches
    } catch (e) {
      // ignore: avoid_print
      print('Error: $e');
    }
  }

}

