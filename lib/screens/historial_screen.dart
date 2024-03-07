import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/venta_provider.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final ventaProvider = VentasProvider();
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  @override
    void initState() {
    setState(() {
      textLoading = 'Leyendo registros de ventas';
      isLoading = true;
    });
      ventaProvider.listarventas().then((value) {
        setState(() {
          textLoading = '';
          isLoading = false;
        });
      });

    super.initState();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ventas'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'menu');
              },
              icon: const Icon(Icons.menu)),
        ],
      ),
      body: (isLoading)? Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Espere...$textLoading'),
                    SizedBox(
                      height: windowHeight * 0.01,
                    ),
                    const CircularProgressIndicator(),
                  ]),
            )
          : ListView.builder(
              itemCount: listaVentaCabecera.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(listaVentaCabecera[index].folio!),
                  subtitle: Text(listaVentaCabecera[index].fecha_venta!),
                  trailing: Text(listaVentaCabecera[index].total.toString()),
                  onTap: () {
                    ventaProvider.consultarventa(listaVentaCabecera[index].id!)
                    .then((value) {
                      if (value.id != 0) {
                          Navigator.pushNamed(context, 'ventasD',
                            arguments: value);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(value.mensaje!),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    });
                  }
                );
              },
            ),
    );
    
    }
}
