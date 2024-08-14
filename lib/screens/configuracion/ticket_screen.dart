// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/ticket_provider.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final TextEditingController _ticketFooterController = TextEditingController();
  File? _image;
  String? _webImage;
  final TicketProvider ticketProvider = TicketProvider();

  String message = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();    
    _loadData();
  }

  void _loadData() async {
    try {
      final TicketModel model = await ticketProvider.getData(sesion.idNegocio.toString());
      setState(() {
        ticketModel.id = model.id;
        ticketModel.negocioId = model.negocioId;
        ticketModel.logo = model.logo;
        ticketModel.message = model.message;

        // Si hay un logo existente en el modelo, lo asignamos
        if (kIsWeb) {
          _webImage = ticketModel.logo;
        } else {
          _image = null; // En este caso, no trabajamos directamente con el archivo local
        }
      });
    } catch(e) {
      setState(() {
        message = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        if (kIsWeb) {
          _webImage = pickedFile.path;
        } else {
          _image = File(pickedFile.path);
        }
      }
    });
  }

  void _saveTicket() async {
    String message = '';

    if (_ticketFooterController.text.isEmpty && _image == null && _webImage == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('No has seleccionado una imagen ni ingresado un pie de ticket.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    if (_image != null || _webImage != null) {
      final respuesta = await ticketProvider.saveLogo(_image!);
      message += '${respuesta.mensaje}\n';
    }

    if (_ticketFooterController.text.isNotEmpty) {
      final respuesta = await ticketProvider.saveMessage(sesion.idNegocio!, _ticketFooterController.text);
      message += '${respuesta.mensaje}\n';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Estatus'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Ticket'),
      ),
      body: isLoading
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Espere...'),
              SizedBox(height: screenHeight * 0.01,),
              const CircularProgressIndicator(),
            ]),
          )
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text('Seleccione su logo: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Seleccionar Imagen'),
                  ),
                  const SizedBox(height: 20),
                  if ((_image != null || _webImage != null || ticketModel.logo != null) )
                    const Text(
                      'Imagen Seleccionada:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  if (_image != null || _webImage != null || ticketModel.logo != null)
                    Container(
                      height: 450,
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: _image != null 
                          ? Image.file(
                              _image!,
                              fit: BoxFit.cover,
                            )
                          : FadeInImage.assetNetwork(
                              placeholder: 'assets/loading.gif',
                              image: _webImage ?? ticketModel.logo!,
                              fit: BoxFit.cover,
                            ),
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    'Introduzca pie de ticket',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: _ticketFooterController,
                    decoration:  InputDecoration(
                      labelText: ticketModel.message ?? 'Mensaje',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveTicket,
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ),
        ),
    );
  }
}
