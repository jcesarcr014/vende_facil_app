import 'package:flutter/material.dart';
import 'package:vende_facil/models/apartado_pagado_model.dart';
import 'package:vende_facil/providers/apartado_provider.dart';
import 'package:vende_facil/widgets/widgets.dart';

class MenuAbonoScreen extends StatelessWidget {
  static final apartadoProvider =ApartadoProvider();

  const MenuAbonoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvoked: (didpop) {
        if (!didpop) Navigator.pushReplacementNamed(context, 'menu');
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Abonos'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, 'menu');
                },
                icon: const Icon(Icons.menu)),
          ],
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.0),
            child: Column(
              children: [
                ListTile(
                    leading: const Icon(Icons.list_alt),
                    title: const Text('Agregar abonos',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    subtitle: const Text('Visualiza  lista de apartados'),
                    trailing: const Icon(Icons.arrow_right),
                    onTap: () {
                      Navigator.pushNamed(context, 'selecionarSA');
                    }),
                ListTile(
                  leading: const Icon(Icons.check),
                  title: const Text('Abonos Liquidados', style: TextStyle(fontWeight: FontWeight.bold),),
                  subtitle: const Text('Visualiza una lista de tus abonos liquidados'),
                  trailing: const Icon(Icons.arrow_right),
                  onTap: () async {
                    final resultado = await apartadoProvider.listaApartadosApagados();
                    if(resultado.status != 1) {
                      mostrarAlerta(context, 'Error', resultado.mensaje ?? 'Intentalo mas tarde');
                      return;
                    }
                    print(apartadosPagados.isEmpty);
                    Navigator.pushNamed(context, 'abonos-liquidados');
                  }
                )
              ],
            )),
      ),
    );
  }
}
