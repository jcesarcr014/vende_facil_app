import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/util/imprime_tickets.dart';
import 'package:vende_facil/widgets/widgets.dart';

class HistorialEmpleadoScreen extends StatefulWidget {
  const HistorialEmpleadoScreen({super.key});

  @override
  State<HistorialEmpleadoScreen> createState() =>
      _HistorialEmpleadoScreenState();
}

class _HistorialEmpleadoScreenState extends State<HistorialEmpleadoScreen> {
  final corteProvider = CorteProvider();
  final efectivoController = TextEditingController();
  final comentariosController = TextEditingController();
  final impresionesTickets = ImpresionesTickets();
  int body = 1;
  bool isLoading = false;
  String textLoading = '';
  String comentarios = 'Sin comentarios';
  double windowWidth = 0.0;
  double windowHeight = 0.0;

  @override
  void initState() {
    body = 1;
    super.initState();
  }

  @override
  void dispose() {
    efectivoController.dispose();
    comentariosController.dispose();
    super.dispose();
  }

  _solicitaCorte() {
    setState(() {
      isLoading = true;
      textLoading = 'Solicitando corte...';
    });
    if (comentariosController.text.isNotEmpty) {
      comentarios = comentariosController.text;
    }
    corteProvider
        .solicitarCorte(efectivoController.text, comentarios)
        .then((value) {
      setState(() {
        isLoading = false;
        textLoading = '';
      });
      if (value.status == 1) {
        if (varEmpleadoCorte) {
          setState(() {
            body = 2;
          });
        } else {
          Navigator.pushReplacementNamed(context, 'menu');
          mostrarAlerta(context, '', 'Corte generado correctamente');
        }
      } else {
        mostrarAlerta(context, 'ERROR',
            'Ocurrio un error al solicitar el corte ${value.mensaje}');
      }
    });
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
          title: const Text('Corte de Caja'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'menu');
              },
              icon: const Icon(Icons.home),
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
                child: (body == 1) ? _body1() : _body2(),
              ),
      ),
    );
  }

  _body1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: windowHeight * 0.02,
        ),
        Text('Ingresa el efectivo de caja:'),
        SizedBox(
          height: windowHeight * 0.03,
        ),
        InputFieldMoney(controller: efectivoController, labelText: 'Efectivo'),
        SizedBox(
          height: windowHeight * 0.03,
        ),
        InputField(
          maxLines: 4,
          icon: Icons.comment,
          controller: comentariosController,
          labelText: 'Comentarios',
        ),
        SizedBox(
          height: windowHeight * 0.03,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                if (efectivoController.text.isEmpty) {
                  mostrarAlerta(context, 'ERROR', 'Ingrese el efectivo');
                  return;
                }

                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: ((context) {
                      return AlertDialog(
                        title: const Text('Confirmar'),
                        content:
                            Text('¿Desea confirmar el efectivo ingresado? \n'
                                'Efectivo: \$${efectivoController.text}'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Cancelar',
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _solicitaCorte();
                            },
                            child: const Text('Generar Corte'),
                          ),
                        ],
                      );
                    }));
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ],
    );
  }

  _body2() {
    return Column(
      children: [
        SizedBox(height: windowHeight * 0.02),
        Text(
          'Corte Generado ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: windowHeight * 0.02),
        Text(
          'Efectivo en caja:  \$${corteActual.efectivoInicial}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: windowHeight * 0.02),
        Expanded(
          child: ListView.builder(
            itemCount: listaMovimientosCorte.length,
            itemBuilder: (context, index) {
              final movimiento = listaMovimientosCorte[index];
              String tipoMovimiento = '';
              switch (movimiento.tipoMovimiento) {
                case 'VD':
                  tipoMovimiento = 'Venta domicilio';
                  break;
                case 'VT':
                  tipoMovimiento = 'Venta Tienda';
                  break;
                case 'P':
                  tipoMovimiento = 'Apartado';
                  break;
                case 'A':
                  tipoMovimiento = 'Abono';
                  break;
                case 'E':
                  tipoMovimiento = 'Entrega apartado';
                  break;
                case 'CV':
                  tipoMovimiento = 'Cancelacion venta';
                  break;
                case 'CA':
                  tipoMovimiento = 'Cancelacion apartado';
                  break;
              }

              return ListTile(
                title: Text(
                  '$tipoMovimiento - Folio: ${movimiento.folio}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Efectivo: \$${movimiento.montoEfectivo ?? '0.00'} | '
                  'Tarjeta: \$${movimiento.montoTarjeta ?? '0.00'}',
                ),
                trailing: Text(
                  '\$${movimiento.total ?? '0.00'}',
                  style: TextStyle(color: Colors.green),
                ),
              );
            },
          ),
        ),
        Divider(),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: windowWidth * 0.04, vertical: 10),
          child: Column(
            children: [
              _buildTotalRow(
                  'Ventas en Efectivo', corteActual.ventasEfectivo ?? '0.0'),
              _buildTotalRow(
                  'Ventas con Tarjeta', corteActual.ventasTarjeta ?? '0.0'),
              _buildTotalRow(
                  'Total Ingresos', corteActual.totalIngresos ?? '0.0'),
              if (corteActual.diferencia != null && corteActual.diferencia != 0)
                _buildDiferenciaRow(corteActual.diferencia ?? '0.0',
                    corteActual.tipoDiferencia ?? ''),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            await impresionesTickets.imprimirCorte(1);
          },
          child: Text('Imprimir Corte'),
        ),
        SizedBox(height: windowHeight * 0.02),
      ],
    );
  }

  _buildTotalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            '\$$value',
            style: TextStyle(color: Colors.green),
          ),
        ],
      ),
    );
  }

  _buildDiferenciaRow(String diferencia, String tipoDiferencia) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Diferencia ($tipoDiferencia)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '\$${double.parse(diferencia).toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
