import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void mostrarAlerta(BuildContext context, String titulo, String mensaje,
    {Color? tituloColor, Color? mensajeColor}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      // Determinar el color según el título para hacer las alertas más intuitivas
      Color iconColor;
      IconData iconData;

      if (titulo.toLowerCase() == 'error' ||
          titulo.toLowerCase() == 'atención') {
        iconColor = tituloColor ?? Colors.red;
        iconData = Icons.error_outline;
      } else if (titulo.toLowerCase() == 'éxito' ||
          titulo.toLowerCase() == 'exito') {
        iconColor = tituloColor ?? Colors.green;
        iconData = Icons.check_circle_outline;
      } else {
        iconColor = tituloColor ?? Colors.blue;
        iconData = Icons.info_outline;
      }

      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Icon(
              iconData,
              color: iconColor,
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: iconColor, // Mismo color que el icono
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(color: mensajeColor ?? Colors.black),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: iconColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

Future<String?> mostrarAlertaConInput(
    BuildContext context, String titulo) async {
  final TextEditingController inputController = TextEditingController();
  final Color themeColor = Colors.blue;

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Icon(
              Icons.edit_outlined,
              color: themeColor,
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: themeColor, // Mismo color que el icono
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: inputController,
          decoration: InputDecoration(
            labelText: 'Ingrese el valor',
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: themeColor, width: 2),
            ),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,4}')),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(null);
            },
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(inputController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Aceptar'),
          ),
        ],
      );
    },
  );
}
