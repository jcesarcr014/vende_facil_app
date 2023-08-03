import 'package:flutter/material.dart';

class AgregarAbonoScreen extends StatelessWidget {
  const AgregarAbonoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Abono a venta'),
        actions: [],
      ),
      // drawer: const Menu(),
      body: const Text('HomeScreen'),
    );
  }
}
