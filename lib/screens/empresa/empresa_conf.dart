import 'package:flutter/material.dart';

class MenuEmpresaScreen extends StatelessWidget {
  const MenuEmpresaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Configuración negocio'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.business_sharp),
              title: const Text(
                'Mi negocio',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: const Text('Datos de tu negocio (Matriz)'),
              trailing: const Icon(Icons.arrow_right),
              onTap: () {
                Navigator.pushNamed(context, 'negocio');
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_business_outlined),
              title: const Text(
                'Sucursales',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: const Text('Agrega o edita sucursales'),
              trailing: const Icon(Icons.arrow_right),
              onTap: () {
                Navigator.pushNamed(context, 'empleados');
              },
            ),
            ListTile(
              leading: const Icon(Icons.supervised_user_circle),
              title: const Text(
                'Empleados',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: const Text('Agrega o asigna empleados'),
              trailing: const Icon(Icons.arrow_right),
              onTap: () {
                Navigator.pushNamed(context, 'negocio');
              },
            )
          ],
        ),
      ),
    );
  }
}
