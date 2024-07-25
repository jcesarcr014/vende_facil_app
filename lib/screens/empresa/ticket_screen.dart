// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final TextEditingController _nameController = TextEditingController();
  File? _image;
  String? _webImage;

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

  @override
  Widget build(BuildContext context) {
    double windowWidth = MediaQuery.of(context).size.width;
    double windowHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
                            ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Seleccionar Imagen'),
              ),
              const SizedBox(height: 20),
              if (_image != null || _webImage != null)
                const Text(
                  'Imagen Seleccionada:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              if (_image != null || _webImage != null)
                Container(
                  height: 200,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: kIsWeb
                      ? Image.network(
                          _webImage!,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        ),
                ),
              const SizedBox(height: 20),
              const Text(
                  'INTRODUZCA UN  TITULO:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
               ElevatedButton(
                onPressed:() {
                  
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
