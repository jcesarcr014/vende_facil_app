import 'package:flutter/material.dart';

class VariablesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes de variables de venta '),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Input 1',
              ),
            ),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Input 2',
              ),
            ),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Input 3',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Add your button logic here
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}