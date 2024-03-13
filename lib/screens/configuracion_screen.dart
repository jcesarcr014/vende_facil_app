import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double windowWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'menu');
              },
              icon: const Icon(Icons.menu)),
        ],
      ),
      body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.0),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.credit_card),
                title: const Text(
                  'Mis tarjetas',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: const Text('Tarjetas bancarias guardadas'),
                trailing: const Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.pushNamed(context, 'tarjetas');
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_circle_rounded),
                title: const Text(
                  'Mi cuenta',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: const Text('Edita tus datos personales'),
                trailing: const Icon(Icons.arrow_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.tag),
                title: const Text(
                  'Apartdados',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: const Text('Edita importe minimo requerido para apartar'),
                trailing: const Icon(Icons.arrow_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.ticket),
                title: const Text(
                  'Ticket',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: const Text('Generacion de ticket de compra'),
                trailing: const Icon(Icons.arrow_right),
                onTap: () {},
              )
            ],
          )),
    );
  }
}
