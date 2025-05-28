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
  String formattedStartDate = "";
  final fechaController = TextEditingController();
  DateTime now = DateTime.now();
  late DateTime _startDate;
  late DateFormat dateFormatter;

  cargarCortes() {
    setState(() {
      isLoading = true;
      textLoading = 'Cargando cortes';
    });

    corteProvider.cortesFecha(formattedStartDate).then((value) {
      setState(() {
        isLoading = false;
        textLoading = '';
      });
      if (value.status != 1) {
        mostrarAlerta(context, 'Error',
            'Ocurrió un error al consultar: ${value.mensaje}');
      }
    }).catchError((error) {
      setState(() {
        isLoading = false;
        textLoading = '';
      });
      mostrarAlerta(context, 'Error',
          'No se pudieron cargar los cortes. Intente nuevamente.');
    });
  }

  @override
  void initState() {
    _startDate = DateTime(now.year, now.month, now.day);
    dateFormatter = DateFormat('yyyy-MM-dd');
    formattedStartDate = dateFormatter.format(_startDate);
    fechaController.text = formattedStartDate;
    super.initState();

    // Cargar cortes al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cargarCortes();
    });
  }

  @override
  Widget build(BuildContext context) {
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
          automaticallyImplyLeading: false,
          elevation: 2,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'menu-historial');
              },
              icon: const Icon(Icons.close),
              tooltip: 'Volver',
            ),
          ],
        ),
        body: isLoading ? _buildLoadingIndicator() : _buildContent(),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Espere... $textLoading',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFechaCard(),
          const SizedBox(height: 20),
          _buildResultadosCard(),
        ],
      ),
    );
  }

  Widget _buildFechaCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              'Seleccionar Fecha',
              Icons.calendar_today_outlined,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Seleccione la fecha que desea consultar para ver los cortes realizados por los empleados:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Campo de fecha
            TextFormField(
              readOnly: true,
              controller: fechaController,
              decoration: InputDecoration(
                labelText: 'Fecha de consulta',
                prefixIcon: const Icon(Icons.calendar_month_outlined, size: 20),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.edit_calendar_outlined),
                  onPressed: _selectDate,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
              onTap: _selectDate,
            ),
            const SizedBox(height: 20),

            // Botón de búsqueda
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: cargarCortes,
                icon: const Icon(Icons.search_outlined),
                label: const Text('Buscar Cortes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        formattedStartDate = dateFormatter.format(_startDate);
        fechaController.text = formattedStartDate;
      });
    }
  }

  Widget _buildResultadosCard() {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(
                'Resultados',
                Icons.receipt_long_outlined,
                Colors.green,
              ),
              const SizedBox(height: 16),
              _buildFechaSeleccionada(),
              const SizedBox(height: 16),
              Expanded(
                child: _buildListaCortes(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFechaSeleccionada() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.date_range, size: 18, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            'Fecha: $formattedStartDate',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaCortes() {
    if (listaCortes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay cortes registrados para esta fecha',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Intente seleccionar otra fecha o verifique que haya cortes realizados',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    } else {
      return ListView.separated(
        itemCount: listaCortes.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final corte = listaCortes[index];
          return _buildCorteItem(corte);
        },
      );
    }
  }

  Widget _buildCorteItem(Corte corte) {
    final currencyFormat =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    // Convertir el valor de totalIngresos a double de manera segura
    double totalIngresos = 0.0;
    if (corte.totalIngresos != null) {
      try {
        if (corte.totalIngresos is String) {
          totalIngresos =
              double.tryParse(corte.totalIngresos.toString()) ?? 0.0;
        } else if (corte.totalIngresos is num) {
          totalIngresos = (corte.totalIngresos as num).toDouble();
        }
      } catch (e) {
        // En caso de error, usar 0.0 como valor predeterminado
        totalIngresos = 0.0;
      }
    }

    return InkWell(
      onTap: () => _verDetalleCorte(corte),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                color: Colors.green,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    corte.empleado ?? 'Empleado',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fecha: ${corte.fecha ?? ''}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(totalIngresos),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Ver detalle',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue[700],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.blue[700],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _verDetalleCorte(Corte corte) {
    setState(() {
      isLoading = true;
      textLoading = 'Cargando detalle del corte';
    });

    corteProvider.corteDetalle(corte.id!).then((value) {
      setState(() {
        isLoading = false;
        textLoading = '';
      });

      if (value.status != 1) {
        mostrarAlerta(context, 'Error',
            'Ocurrió un error al consultar el detalle del corte: ${value.mensaje}');
      } else {
        Navigator.pushNamed(context, 'corte-detalle');
      }
    }).catchError((error) {
      setState(() {
        isLoading = false;
        textLoading = '';
      });
      mostrarAlerta(context, 'Error',
          'No se pudo cargar el detalle del corte. Intente nuevamente.');
    });
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
