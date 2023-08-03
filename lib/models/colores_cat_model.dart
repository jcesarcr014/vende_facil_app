import 'package:flutter/material.dart';

class ColorCategoria {
  int? id;
  String? nombreColor;
  int? idColor;
  Color? color;
  ColorCategoria({this.id, this.nombreColor, this.color});
}

List<ColorCategoria> listaColores = [
  ColorCategoria(id: 1, nombreColor: 'Blanco', color: Colors.white),
  ColorCategoria(id: 2, nombreColor: 'Rojo', color: Colors.red),
  ColorCategoria(id: 3, nombreColor: 'Amarillo', color: Colors.yellow),
  ColorCategoria(id: 4, nombreColor: 'Azul', color: Colors.blue),
  ColorCategoria(id: 5, nombreColor: 'Verde', color: Colors.green),
  ColorCategoria(id: 6, nombreColor: 'Purpura', color: Colors.purple),
  ColorCategoria(id: 7, nombreColor: 'Anaranjado', color: Colors.orange),
];
