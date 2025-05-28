import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';

class SeleccionarSucursal extends StatefulWidget {
  const SeleccionarSucursal({super.key});

  @override
  State<SeleccionarSucursal> createState() => _SeleccionarSucursalState();
}

class _SeleccionarSucursalState extends State<SeleccionarSucursal> {
  int _valueIdSucursal = 0;
  final sucursal = NegocioProvider();
  bool isLoading = false;
  String textLoading = '';

  @override
  initState() {
    setState(() {
      textLoading = 'Cargando sucursales';
      isLoading = true;
    });
    cargar();
    super.initState();
  }

  cargar() async {
    await sucursal.getlistaSucursales().then(
      (value) {
        setState(() {
          textLoading = '';
          isLoading = false;
        });
      },
    );
  }

  _seleccionarSucursal() {
    if (_valueIdSucursal == 0) {
      mostrarAlerta(context, 'Atención', 'Debe seleccionar una sucursal');
      return;
    }

    final sucursalSeleccionada = listaSucursales
        .firstWhere((sucursal) => sucursal.id == _valueIdSucursal);
    sesion.idSucursal = sucursalSeleccionada.id;
    Navigator.pushNamed(context, 'HomerCotizar');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Sucursal'),
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
              'Cotización por Sucursal',
              Icons.store_outlined,
              Colors.orange,
            ),
            const SizedBox(height: 24),
            const Text(
              'Elija la sucursal para la que desea realizar la cotización:',
              style: TextStyle(
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
    List<DropdownMenuItem<int>> listaSucursalesItems = [
      const DropdownMenuItem(
        value: 0,
        child: Text('Seleccione sucursal para cotizar'),
      )
    ];

    for (Sucursal sucursal in listaSucursales) {
      listaSucursalesItems.add(DropdownMenuItem(
        value: sucursal.id,
        child: Text(
          sucursal.nombreSucursal!,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ));
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
            child: DropdownButton<int>(
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
    bool sucursalSeleccionada = _valueIdSucursal != 0;

    return SizedBox(
      width: 300,
      child: ElevatedButton.icon(
        onPressed: sucursalSeleccionada ? _seleccionarSucursal : null,
        icon: const Icon(Icons.shopping_cart_checkout_outlined),
        label: const Text(
          'Continuar',
          style: TextStyle(fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
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
}
