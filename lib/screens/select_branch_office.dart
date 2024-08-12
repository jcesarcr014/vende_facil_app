import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';

class SucursalesScreen extends StatefulWidget {
  const SucursalesScreen({super.key});

  @override
  State<SucursalesScreen> createState() => _SucursalesScreenState();
}

class _SucursalesScreenState extends State<SucursalesScreen> {
  String? _valueIdSucursal = '0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Sucursal'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushReplacementNamed(context, 'menu'),
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sucursalesDropdown(),
            const SizedBox(height: 40),
            Center(
              child: SizedBox(
                width: 300,
                height: 70, // Aumentar la altura del botón
                child: ElevatedButton(
                  onPressed: () {
                    final sucursalSeleccionada = listaSucursales.firstWhere(
                        (sucursal) => sucursal.id.toString() == _valueIdSucursal);
                    sesion.idSucursal = sucursalSeleccionada.id;
                    Navigator.pushNamed(context, 'home');
                  },
                  child: const Text(
                    'Aceptar',
                    style: TextStyle(fontSize: 22), // Aumentar el tamaño del texto
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sucursalesDropdown() {
    List<DropdownMenuItem<String>> listaSucursalesItems = [
      const DropdownMenuItem(
          value: '0', child: SizedBox(child: Text('Seleccione sucursal')))
    ];

    for (Sucursale sucursal in listaSucursales) {
      listaSucursalesItems.add(DropdownMenuItem(
        value: sucursal.id.toString(),
        child: Text(sucursal.nombreSucursal!),
      ));

      if (sucursal.id.toString() == _valueIdSucursal) {
        _valueIdSucursal = sucursal.id.toString();
      }
    }

    if (_valueIdSucursal == null || _valueIdSucursal!.isEmpty) {
      _valueIdSucursal = '0';
    }

    return DropdownButton<String>(
      items: listaSucursalesItems,
      isExpanded: true,
      value: _valueIdSucursal,
      onChanged: (value) {
        setState(() {
          _valueIdSucursal = value!;
        });
      },
    );
  }
}
