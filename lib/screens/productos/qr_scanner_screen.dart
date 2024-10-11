import 'package:flutter/material.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isScanning = true; // Controla si se está escaneando o no

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Escáner de Código QR"),
      ),
      body: Center(
        child: _isScanning
            ? QrCamera(
                onError: (context, error) => Center(
                  child: Text(
                    error.toString(),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                qrCodeCallback: (code) {
                  if (code != null && _isScanning) {
                    setState(() {
                      _isScanning = false; // Detenemos el escaneo
                    });
                    Navigator.pop(context, code); // Devolvemos el código y cerramos la pantalla
                  }
                },
                child: Container(
                  width: 300,
                  height: 300,
                  color: Colors.transparent,
                ),
              )
            : const Center(child: CircularProgressIndicator()), // Indicador de carga si el escaneo se detiene
      ),
    );
  }
}
