import 'package:flutter/material.dart';
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
  final apartados = ApartadoProvider();

  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;

  @override
  void initState() {
    setState(() {
      textLoading = 'Leyendo apartados';
      isLoading = true;
    });
    apartados.listarApartados().then((value) {
      setState(() {
        textLoading = '';
        isLoading = false;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Abono a venta'),
        actions: [
          SizedBox(
            width: 150,
            child: TextField(
              onTap: () {
                showSearch(context: context, delegate: SearchAbonos());
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar...',
                hintStyle: TextStyle(color: Colors.white),
                prefixIconColor: Colors.white,
                iconColor: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, 'menu');
            },
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
      // drawer: const Menu(),
      body: (isLoading)
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: listaApartados.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(listaApartados[index].folio.toString()),
                  subtitle:
                      Text(listaApartados[index].fechaVencimiento.toString()),
                  trailing: Text(listaApartados[index].total.toString()),
                  onTap: () {
                    apartados
                        .detallesApartado(listaApartados[index].id!)
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
    );
  }
}
