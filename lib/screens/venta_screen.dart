import 'dart:math';

import 'package:flutter/material.dart';

class VentaScreen extends StatefulWidget {
  const VentaScreen({super.key});
  @override
  State<VentaScreen> createState() => _ventaScreenState();
}
// ignore: camel_case_types
class _ventaScreenState extends State<VentaScreen> {
  final TotalConttroller = TextEditingController();
  final EfectivoController = TextEditingController();
  final CambioController = TextEditingController();
  final TarjetaController = TextEditingController();
   double windowWidth = 0.0;
   double windowHeight = 0.0;
  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Venta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
          
            // ignore: avoid_unnecessary_containers
            Container(
              child:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Flexible(child: Text("Total:")),
                SizedBox(width: windowWidth * 0.01,),
                Flexible(child: TextField(
                  controller: TotalConttroller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Total',
                    border: OutlineInputBorder(),
                  ),
                ))
              ],
            ),),
            SizedBox(height: windowHeight * 0.05,),
            // ignore: avoid_unnecessary_containers
            Container(
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Flexible(child: Text("Efectivo:")),
                SizedBox(width: windowWidth * 0.01,),
                 Flexible(child: TextField(
                  controller: EfectivoController,
                  decoration: const InputDecoration(
                    labelText: 'Efectivo',
                    border: OutlineInputBorder(),
                  ),
                ))
              ],
            ),),
            SizedBox(height: windowHeight * 0.05,),
            // ignore: avoid_unnecessary_containers
            Container(
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Flexible(child: Text("Tarjeta:")),
                SizedBox(width: windowWidth * 0.01,),
                Flexible(child: TextField(
                  controller: TarjetaController,
                  decoration: const InputDecoration(
                    labelText: 'Tarjeta',
                    border: OutlineInputBorder(),
                  ),
                ))
              ],
            ),),
            SizedBox(height: windowHeight * 0.05,),
            // ignore: avoid_unnecessary_containers
            Container(
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Flexible(child: Text("Cambio:")),
                SizedBox(width: windowWidth * 0.01,),
                Flexible(child: TextField(
                  controller: CambioController,
                  decoration: const InputDecoration(
                    labelText: 'Cambio',
                    border: OutlineInputBorder(),
                  ),
                ))
              ],
            ),),
            SizedBox(height: windowHeight * 0.05,),
             // ignore: avoid_unnecessary_containers
            Container(child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Lógica para el botón Aceptar
                  },
                  child: Text('Aceptar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Lógica para el botón Cancelar
                  },
                  child: Text('Cancelar'),
                ),
              ],
            ),),

            
          ],
        ),
      ),
    );
  }
}