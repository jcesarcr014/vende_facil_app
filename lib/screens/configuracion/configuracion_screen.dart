import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vende_facil/models/cuenta_sesion_modelo.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

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
                  onTap: () {
                    Navigator.pushNamed(context, 'perfil');
                  },
                ),
                (sesion.tipoUsuario=="P")
                ?ListTile(
                  leading: const Icon(Icons.person_add),
                  title: const Text(
                    'Empleados',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: const Text('Lista de empleados'),
                  trailing: const Icon(Icons.arrow_right),
                  onTap: () {
                    Navigator.pushNamed(context, 'empleados');
                  },
                ):Container(),
                (sesion.tipoUsuario=="P")?
                ListTile(
                  leading: const Icon(CupertinoIcons.tag),
                  title: const Text(
                    'Ajustes de apartado',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle:
                      const Text('Edita importe minimo requerido para apartar'),
                  trailing: const Icon(Icons.arrow_right),
                  onTap: () {
                    Navigator.pushNamed(context, 'config-apartado');
                  },
                ):Container(),
                (sesion.tipoUsuario=="P")?
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
                  subtitle: const Text('Configura tu ticket de compra'),
                  trailing: const Icon(Icons.arrow_right),
                  onTap: () {
                    Navigator.pushNamed(context, 'ticket');
                  },
                )
                :Container(),
              ],
            )),
      ),
    );
  }
}
