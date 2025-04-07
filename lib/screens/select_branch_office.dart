import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/mostrar_alerta_ok.dart';

class SucursalesScreen extends StatefulWidget {
  const SucursalesScreen({super.key});

  @override
  State<SucursalesScreen> createState() => _SucursalesScreenState();
}

class _SucursalesScreenState extends State<SucursalesScreen> {
  String? _valueIdSucursal = '0';
  final articulosProvider = ArticuloProvider();
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

  _seleccionarSucursal() async {
    if (_valueIdSucursal == '0') {
      mostrarAlerta(context, 'Error', 'Debe seleccionar una sucursal');
      return;
    }

    setState(() {
      isLoading = true;
      textLoading = 'Cargando datos de la sucursal';
    });

    final sucursalSeleccionada = listaSucursales
        .firstWhere((sucursal) => sucursal.id.toString() == _valueIdSucursal);

    sesion.idSucursal = sucursalSeleccionada.id;
    sesion.sucursal = sucursalSeleccionada.nombreSucursal;

    try {
      var result = await articulosProvider
          .listarProductosSucursal(sucursalSeleccionada.id!);

      setState(() {
        isLoading = false;
        textLoading = '';
      });

      if (result.status == 1) {
        sesion.cotizar = false;
        Navigator.pushReplacementNamed(context, 'home');
      } else {
        mostrarAlerta(context, "Error", "No se pudieron cargar los productos");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        textLoading = '';
      });
      mostrarAlerta(
          context, "Error", "Ocurrió un problema al cargar los productos");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Sucursal'),
        automaticallyImplyLeading: false,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushReplacementNamed(context, 'menu'),
            icon: const Icon(Icons.menu),
            tooltip: 'Ir al menú principal',
          ),
        ],
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
            const Text(
              'Elija la sucursal con la que desea trabajar:',
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

    if (_valueIdSucursal == null || _valueIdSucursal!.isEmpty) {
      _valueIdSucursal = '0';
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
        onPressed: sucursalSeleccionada ? _seleccionarSucursal : null,
        icon: const Icon(Icons.check_circle_outline),
        label: const Text(
          'Continuar',
          style: TextStyle(fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
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
