import 'package:flutter/material.dart';
import 'package:vende_facil/widgets/widgets.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      drawer: const Menu(),
      body: const Text('HomeScreen'),
    );
  }
}
