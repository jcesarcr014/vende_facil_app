import 'package:flutter/material.dart';

class SuscripcionScreen extends StatelessWidget {
  const SuscripcionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double windowWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvoked: (didpop) {
        if (!didpop) Navigator.pushReplacementNamed(context, 'menu');
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Suscripción y método de pago'),
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
                leading: const Icon(Icons.add_chart),
                title: const Text(
                  'Planes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: const Text('Suscripción actual y planes disponibles'),
                trailing: const Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.pushNamed(context, 'planes');
                },
              ),
              ListTile(
                leading: const Icon(Icons.credit_card),
                title: const Text(
                  'Método de pago',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: const Text('Actualiza tu método de pago'),
                trailing: const Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.pushNamed(context, 'tarjetas');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
