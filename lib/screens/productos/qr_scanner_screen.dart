import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isScanning = true; // Controla si se está escaneando o no

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Escáner de Código / QR"),
      ),
      body: Center(
        child: _isScanning
            ? MobileScanner(
                // Opcional: Si quieres que sea más rápido, puedes decirle que
                // busque solo códigos de barras y QR, pero por defecto lee todo muy bien.
                onDetect: (BarcodeCapture capture) {
                  // Prevenimos que se ejecute múltiples veces
                  if (!_isScanning) return;

                  // capture.barcodes trae una lista de códigos detectados
                  final List<Barcode> barcodes = capture.barcodes;

                  if (barcodes.isNotEmpty) {
                    // Tomamos el primer código que encuentre
                    final String? code = barcodes.first.rawValue;

                    if (code != null) {
                      setState(() {
                        _isScanning = false; // Detenemos el escaneo visualmente
                      });

                      // Devolvemos el código y cerramos la pantalla
                      Navigator.pop(context, code);
                    }
                  }
                },
              )
            : const CircularProgressIndicator(), // Indicador de carga al leer el código
      ),
    );
  }
}
