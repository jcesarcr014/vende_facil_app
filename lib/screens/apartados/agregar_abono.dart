import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vende_facil/models/apartado_cab_model.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/screens/screens.dart';

class AgregarAbonoScreen extends StatefulWidget {
  const AgregarAbonoScreen({super.key});
  @override
  State<AgregarAbonoScreen> createState() => _AgregarAbonoScreenState();
}

class _AgregarAbonoScreenState extends State<AgregarAbonoScreen> {
  final apartadosProvider = ApartadoProvider();

  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;

  @override
  void initState() {
    super.initState();

    setState(() {
      textLoading = 'Leyendo apartados pendientes.';
      isLoading = true;
    });

    apartadosProvider.apartadosPendientesNegocio().then((value) {
      setState(() {
        textLoading = '';
        isLoading = false;
      });
    });
  }

  Widget getStatusIcon(ApartadoCabecera apartado) {
    if (apartado.cancelado == 1) {
      return const SizedBox(
        width: 150, // Ajusta el tamaño según sea necesario
        child: Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 8),
            Text('Cancelado', style: TextStyle(color: Colors.red)),
          ],
        ),
      );
    } else if (apartado.entregado == 1) {
      return const SizedBox(
        width: 150,
        child: Row(
          children: [
            Icon(Icons.local_shipping, color: Colors.green),
            SizedBox(width: 8),
            Text('Entregado', style: TextStyle(color: Colors.green)),
          ],
        ),
      );
    } else if (apartado.pagado == 1) {
      return const SizedBox(
        width: 150,
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.amber),
            SizedBox(width: 8),
            Text('Pagado', style: TextStyle(color: Colors.amber)),
          ],
        ),
      );
    } else {
      return const SizedBox(
        width: 150,
        child: Row(
          children: [
            Icon(Icons.info, color: Colors.grey),
            SizedBox(width: 8),
            Text('En proceso', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) Navigator.pushReplacementNamed(context, 'menuAbonos');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Abono a venta'),
          automaticallyImplyLeading: true,
          // actions: [
          //   // ignore: sized_box_for_whitespace
          //   Container(
          //     width: 150,
          //     child: TextField(
          //       onTap: () {
          //         showSearch(context: context, delegate: SearchAbonos());
          //       },
          //       decoration: const InputDecoration(
          //         prefixIcon: Icon(Icons.search),
          //         hintText: 'Buscar...',
          //         hintStyle: TextStyle(color: Colors.white),
          //         prefixIconColor: Colors.white,
          //         iconColor: Colors.white,
          //       ),
          //     ),
          //   ),
          // ],
        ),
        // drawer: const Menu(),
        body: (isLoading)
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: listaApartadosPendientes.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(listaApartadosPendientes[index].nombreCliente!),
                    subtitle: Text(
                        '${listaApartadosPendientes[index].folio} - ${DateFormat('yyyy-MM-dd').format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(listaApartadosPendientes[index].fechaVencimiento!))}'),
                    trailing: getStatusIcon(listaApartadosPendientes[index]),
                    onTap: () {
                      apartadosProvider
                          .detallesApartado(listaApartadosPendientes[index].id!)
                          .then((value) {
                        setState(() {
                          textLoading = '';
                          isLoading = true;
                        });
                        if (value.id != 0) {
                          Navigator.pushNamed(context, 'abono_detalle',
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
                    },
                  );
                },
              ),
      ),
    );
  }
}
