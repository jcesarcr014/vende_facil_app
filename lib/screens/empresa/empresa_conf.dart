import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';

class MenuEmpresaScreen extends StatelessWidget {
  const MenuEmpresaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración negocio'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'menu');
              },
              icon: const Icon(Icons.menu)),
        ],
      ),
      body: SingleChildScrollView(
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
            (sesion.idNegocio != 0)
                ? ListTile(
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
                      Navigator.pushNamed(context, 'lista-sucursales');
                    },
                  )
                : Container(),
            (sesion.idNegocio != 0)
                ? ListTile(
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
                      Navigator.pushNamed(context, 'empleados');
                    },
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
