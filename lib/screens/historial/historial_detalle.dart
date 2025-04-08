import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';

class VentasDiaScreen extends StatefulWidget {
  const VentasDiaScreen({super.key});

  @override
  State<VentasDiaScreen> createState() => _VentasDiaScreenState();
}

class _VentasDiaScreenState extends State<VentasDiaScreen> {
  bool isLoading = false;
  String textLoading = '';
  final ventasProvider = VentasProvider();

  @override
  void initState() {
    setState(() {
      isLoading = true;
      textLoading = 'Leyendo movimientos del dia de hoy';
    });
    ventasProvider.ventasDia().then((resp) {
      setState(() {
        isLoading = false;
        textLoading = '';
      });
      if (resp.status != 1) {
        mostrarAlerta(context, 'ERROR',
            'Ocurrio un error al realizar la consulta: ${resp.mensaje}');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<VentaDia>> ventasAgrupadas = {};
    for (var venta in listaVentasDia) {
      if (!ventasAgrupadas.containsKey(venta.folio)) {
        ventasAgrupadas[venta.folio] = [];
      }
      ventasAgrupadas[venta.folio]!.add(venta);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas del Día'),
      ),
      body: (isLoading)
          ? Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Espere...$textLoading'),
                    const SizedBox(
                      height: 10,
                    ),
                    const CircularProgressIndicator(),
                  ]),
            )
          : Column(
              children: [
                // Encabezado con la fecha
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.shade50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fecha: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total ventas: ${ventasAgrupadas.length}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),

                // Lista de ventas
                Expanded(
                  child: listaVentasDia.isEmpty
                      ? const Center(
                          child: Text('No hay ventas registradas hoy'))
                      : ListView.builder(
                          itemCount: ventasAgrupadas.length,
                          itemBuilder: (context, index) {
                            String folio =
                                ventasAgrupadas.keys.elementAt(index);
                            List<VentaDia> items = ventasAgrupadas[folio]!;
                            VentaDia primeraVenta = items.first;

                            // Calcular el total de la venta
                            double totalVenta = 0;
                            for (var item in items) {
                              totalVenta += double.parse(item.total);
                            }

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Folio: $folio',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          primeraVenta.fechaVenta.substring(
                                              11, 16), // Mostrar solo la hora
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Empleado: ${primeraVenta.empleado}'),
                                    Text('Sucursal: ${primeraVenta.sucursal}'),
                                    const SizedBox(height: 8),
                                    const Divider(),
                                    const SizedBox(height: 8),

                                    // Productos
                                    Column(
                                      children: items
                                          .map((item) => Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 30,
                                                      child: Text(
                                                        item.cantidad,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child:
                                                          Text(item.producto),
                                                    ),
                                                    SizedBox(
                                                      width: 80,
                                                      child: Text(
                                                        '\$${item.precio}',
                                                        textAlign:
                                                            TextAlign.right,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 80,
                                                      child: Text(
                                                        '\$${item.total}',
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ))
                                          .toList(),
                                    ),

                                    const Divider(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'Total:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '\$${totalVenta.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // Botones en la parte inferior
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Función para exportar a PDF (sin implementar)
                        },
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Exportar PDF'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Función para imprimir (sin implementar)
                        },
                        icon: const Icon(Icons.print),
                        label: const Text('Imprimir'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
