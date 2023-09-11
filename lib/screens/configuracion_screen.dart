import 'package:flutter/material.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double windowWidth = MediaQuery.of(context).size.width;
    double windowHeight = MediaQuery.of(context).size.height;
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
              )
            ],
          )),
    );
  }
}
