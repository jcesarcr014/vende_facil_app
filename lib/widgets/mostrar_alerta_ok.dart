import 'package:flutter/material.dart';

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
