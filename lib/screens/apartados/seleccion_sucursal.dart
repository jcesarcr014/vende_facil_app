import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/mostrar_alerta_ok.dart';

class SucursalesAbonoScreen extends StatefulWidget {
  final int? indice;
  const SucursalesAbonoScreen({this.indice, super.key});

  @override
  State<SucursalesAbonoScreen> createState() => _SucursalesAbonoScreenState();
}

class _SucursalesAbonoScreenState extends State<SucursalesAbonoScreen> {
  late int indiceRecibido;
  String _valueIdSucursal = '0';
  final apartadoProvider = ApartadoProvider();
  final sucursalProvider = NegocioProvider();
  bool isLoading = false;
  String textLoading = '';

  @override
  initState() {
    super.initState();
    setState(() {
      textLoading = 'Cargando sucursales';
      isLoading = true;
    });
    sucursalProvider.getlistaSucursales().then((resp) {
      setState(() {
        textLoading = '';
        isLoading = false;
      });
    });
    indiceRecibido = widget.indice ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    String title =
        indiceRecibido == 1 ? 'Apartados Pendientes' : 'Apartados Pagados';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: true,
        elevation: 2,
      ),
      body: isLoading ? _buildLoadingIndicator() : _buildContent(),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSeleccionSucursalCard(),
          const SizedBox(height: 40),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildSeleccionSucursalCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              'Selección de Sucursal',
              Icons.store_outlined,
              Colors.blue,
            ),
            const SizedBox(height: 24),
            Text(
              indiceRecibido == 1
                  ? 'Elija la sucursal para ver apartados pendientes:'
                  : 'Elija la sucursal para ver apartados pagados:',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            _buildSucursalDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildSucursalDropdown() {
    List<DropdownMenuItem<String>> listaSucursalesItems = [
      const DropdownMenuItem(
        value: '0',
        child: Text('Seleccione sucursal'),
      )
    ];

    for (Sucursal sucursal in listaSucursales) {
      listaSucursalesItems.add(DropdownMenuItem(
        value: sucursal.id.toString(),
        child: Text(
          sucursal.nombreSucursal!,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ));

      if (sucursal.id.toString() == _valueIdSucursal) {
        _valueIdSucursal = sucursal.id.toString();
      }
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.storefront_outlined, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<String>(
              items: listaSucursalesItems,
              isExpanded: true,
              value: _valueIdSucursal,
              underline: Container(), // Quitar la línea inferior del dropdown
              onChanged: (value) {
                setState(() {
                  _valueIdSucursal = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    bool sucursalSeleccionada = _valueIdSucursal != '0';

    return SizedBox(
      width: 300,
      child: ElevatedButton.icon(
        onPressed: sucursalSeleccionada ? _buscarApartados : null,
        icon: Icon(
          indiceRecibido == 1
              ? Icons.pending_actions_outlined
              : Icons.payments_outlined,
        ),
        label: const Text(
          'Consultar',
          style: TextStyle(fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: indiceRecibido == 1 ? Colors.orange : Colors.green,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _buscarApartados() {
    if (_valueIdSucursal == '0') {
      mostrarAlerta(context, 'Atención', 'Debe seleccionar una sucursal');
      return;
    }

    setState(() {
      isLoading = true;
      textLoading = indiceRecibido == 1
          ? 'Cargando apartados pendientes'
          : 'Cargando apartados pagados';
    });

    sesion.idSucursal = int.parse(_valueIdSucursal);

    if (indiceRecibido == 1) {
      apartadoProvider.apartadosPendientesSucursal().then((resp) {
        setState(() {
          isLoading = false;
          textLoading = '';
        });

        if (resp.status == 1) {
          Navigator.pushNamed(context, 'lista-apartados', arguments: 1);
        } else {
          mostrarAlerta(context, 'ERROR', 'Ocurrió un error: ${resp.mensaje}');
        }
      }).catchError((error) {
        setState(() {
          isLoading = false;
          textLoading = '';
        });
        mostrarAlerta(
            context, 'ERROR', 'Error de conexión. Intente nuevamente.');
      });
    } else {
      apartadoProvider.apartadosPagadosSucursal().then((resp) {
        setState(() {
          isLoading = false;
          textLoading = '';
        });

        if (resp.status == 1) {
          Navigator.pushNamed(context, 'lista-apartados', arguments: 1);
        } else {
          mostrarAlerta(context, 'ERROR', 'Ocurrió un error: ${resp.mensaje}');
        }
      }).catchError((error) {
        setState(() {
          isLoading = false;
          textLoading = '';
        });
        mostrarAlerta(
            context, 'ERROR', 'Error de conexión. Intente nuevamente.');
      });
    }
  }
}
