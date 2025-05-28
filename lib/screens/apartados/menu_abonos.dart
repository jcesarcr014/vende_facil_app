import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';

class MenuAbonoScreen extends StatefulWidget {
  const MenuAbonoScreen({super.key});

  @override
  State<MenuAbonoScreen> createState() => _MenuAbonoScreenState();
}

class _MenuAbonoScreenState extends State<MenuAbonoScreen> {
  final _apartadoProvider = ApartadoProvider();
  bool _isLoading = false;
  String _textLoading = '';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, 'menu');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Sistema de Apartados'),
          elevation: 2,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'menu');
              },
              icon: const Icon(Icons.home),
              tooltip: 'Ir al menú principal',
            ),
          ],
        ),
        body: _isLoading ? _buildLoadingScreen() : _buildMenuOptions(),
      ),
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

  Widget _buildMenuOptions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Gestión de Apartados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            title: 'Abonar a Apartados',
            subtitle: 'Visualiza la lista de apartados pendientes de liquidar',
            icon: Icons.payment,
            iconColor: Colors.green,
            onTap: () => _navegarAListaApartados(1),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            title: 'Entregar Productos',
            subtitle: 'Visualiza la lista de apartados pagados',
            icon: Icons.local_shipping,
            iconColor: Colors.blue,
            onTap: () => _navegarAListaApartados(2),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navegarAListaApartados(int opcion) async {
    if (sesion.tipoUsuario == 'P') {
      Navigator.pushNamed(context, 'selecionarSA', arguments: 1);
      return;
    }

    setState(() {
      _isLoading = true;
      _textLoading = 'Cargando información';
    });

    try {
      final resp = opcion == 1
          ? await _apartadoProvider.apartadosPendientesSucursal()
          : await _apartadoProvider.apartadosPagadosSucursal();

      setState(() {
        _isLoading = false;
        _textLoading = '';
      });

      if (resp.status == 1) {
        Navigator.pushNamed(context, 'lista-apartados', arguments: opcion);
      } else {
        mostrarAlerta(context, 'ERROR', 'Ocurrió un error: ${resp.mensaje}');
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
