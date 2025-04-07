import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/apartado_provider.dart';
import 'package:vende_facil/widgets/widgets.dart';

class AbonosLiquidados extends StatefulWidget {
  const AbonosLiquidados({super.key});

  @override
  State<AbonosLiquidados> createState() => _AbonosLiquidadosState();
}

class _AbonosLiquidadosState extends State<AbonosLiquidados> {
  bool _isLoading = false;
  String _textLoading = '';
  final _apartadoProvider = ApartadoProvider();
  List<ApartadoCabecera> _lista = [];

  @override
  Widget build(BuildContext context) {
    final int indiceRecibido =
        ModalRoute.of(context)?.settings.arguments as int;

    // Determinar qué lista mostrar según el índice recibido
    _lista = (indiceRecibido == 1)
        ? listaApartadosPendientes
        : listaApartadosPagados;

    final String titulo =
        (indiceRecibido == 1) ? 'Apartados pendientes' : 'Apartados liquidados';

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        elevation: 2,
      ),
      body: _isLoading
          ? _buildLoadingScreen()
          : _buildApartadosList(indiceRecibido),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Espere...$_textLoading',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildApartadosList(int indiceRecibido) {
    if (_lista.isEmpty) {
      return _buildEmptyListView();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: _lista.length,
      itemBuilder: (context, index) {
        // Mostrar en orden inverso (más recientes primero)
        final reversedIndex = _lista.length - 1 - index;
        return _buildApartadoCard(
            _lista[reversedIndex], reversedIndex, indiceRecibido);
      },
    );
  }

  Widget _buildEmptyListView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Opacity(
            opacity: 0.2,
            child: Icon(
              Icons.filter_alt_off,
              size: 130,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No hay apartados para mostrar',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApartadoCard(
      ApartadoCabecera apartado, int index, int tipoLista) {
    final bool esPendiente = tipoLista == 1;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: esPendiente
              ? Colors.amber.withOpacity(0.3)
              : Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _detalles(index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Círculo con ícono según el tipo de apartado
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: esPendiente
                      ? Colors.amber.withOpacity(0.2)
                      : Colors.green.withOpacity(0.2),
                ),
                child: Center(
                  child: Icon(
                    esPendiente ? Icons.pending_actions : Icons.check_circle,
                    color: esPendiente ? Colors.amber[700] : Colors.green[700],
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Información del apartado
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Folio: ${apartado.folio ?? ""}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total:\$${apartado.total?.toStringAsFixed(2) ?? "0.00"}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: esPendiente ? Colors.red : Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cliente: ${apartado.nombreCliente ?? ""}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          apartado.fechaApartado ?? "",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (esPendiente && apartado.saldoPendiente != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            const Text(
                              'Saldo pendiente: ',
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              '\$${apartado.saldoPendiente?.toStringAsFixed(2) ?? "0.00"}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // Icono para indicar que se puede ver más detalles
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _detalles(int i) async {
    setState(() {
      _isLoading = true;
      _textLoading = 'Cargando información';
    });

    try {
      final resp = await _apartadoProvider.detallesApartado(_lista[i].id!);

      setState(() {
        _isLoading = false;
        _textLoading = '';
      });

      if (resp.status == 1) {
        Navigator.pushNamed(context, 'abono_detalle');
      } else {
        mostrarAlerta(context, 'ERROR',
            'No se pudieron cargar los detalles: ${resp.mensaje}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _textLoading = '';
      });
      mostrarAlerta(context, 'ERROR', 'Error inesperado: $e');
    }
  }
}
