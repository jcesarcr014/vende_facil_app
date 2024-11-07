import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void mostrarAlerta(BuildContext context, String titulo, String mensaje, {Color? tituloColor, Color? mensajeColor}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          titulo,
          textAlign: TextAlign.center,
          style: TextStyle(color: tituloColor ?? Colors.red), // Color del título
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mensaje,
              style: TextStyle(color: mensajeColor ?? Colors.black), // Color del mensaje
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

Future<String?> mostrarAlertaConInput(BuildContext context, String titulo) async {
  final TextEditingController inputController = TextEditingController();

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(titulo),
        content: TextField(
          controller: inputController,
          decoration: const InputDecoration(
            labelText: 'Ingrese el valor',
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,4}')), // Permite solo números positivos y hasta 4 decimales
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(null);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(inputController.text);
            },
            child: const Text('Aceptar'),
          ),
        ],
      );
    },
  );
}