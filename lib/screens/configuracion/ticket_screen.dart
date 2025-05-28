// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/ticket_provider.dart';
import 'package:vende_facil/widgets/mostrar_alerta_ok.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final TextEditingController _ticketFooterController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _image;
  String? _webImage;
  final TicketProvider ticketProvider = TicketProvider();

  String message = '';
  bool isLoading = true;
  String textLoading = 'Cargando configuración';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      final TicketModel? model =
          await ticketProvider.getData(sesion.idNegocio.toString(), null);
      setState(() {
        ticketModel.id = model!.id;
        ticketModel.negocioId = model.negocioId;
        ticketModel.logo = model.logo;
        ticketModel.message = model.message;

        if (ticketModel.message != null && ticketModel.message!.isNotEmpty) {
          _ticketFooterController.text = ticketModel.message!;
        }

        // Si hay un logo existente en el modelo, lo asignamos
        if (kIsWeb) {
          _webImage = ticketModel.logo;
        } else {
          _image =
              null; // En este caso, no trabajamos directamente con el archivo local
        }
      });
    } catch (e) {
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
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Optimiza la calidad
      );

      setState(() {
        if (pickedFile != null) {
          if (kIsWeb) {
            _webImage = pickedFile.path;
          } else {
            _image = File(pickedFile.path);
          }
        }
      });
    } catch (e) {
      mostrarAlerta(context, 'Error',
          'No se pudo seleccionar la imagen: ${e.toString()}');
    }
  }

  void _saveTicket() async {
    if (!_formKey.currentState!.validate() &&
        _image == null &&
        _webImage == null &&
        ticketModel.logo == null) {
      mostrarAlerta(context, 'Información incompleta',
          'Debe seleccionar un logo o ingresar un mensaje para el pie del ticket.');
      return;
    }

    setState(() {
      isLoading = true;
      textLoading = 'Guardando configuración del ticket';
    });

    try {
      String resultMessage = '';

      // Guardar logo si se seleccionó una nueva imagen
      if (_image != null) {
        final respuesta = await ticketProvider.saveLogo(_image!);
        resultMessage += '${respuesta.mensaje}\n';
      }

      // Guardar mensaje de pie de ticket
      if (_ticketFooterController.text.isNotEmpty) {
        final respuesta = await ticketProvider.saveMessage(
            sesion.idNegocio!, _ticketFooterController.text);
        resultMessage += respuesta.mensaje!;
      }

      setState(() {
        isLoading = false;
      });

      mostrarAlerta(context, 'Éxito', resultMessage);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      mostrarAlerta(context, 'Error',
          'No se pudo guardar la configuración: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Ticket'),
        automaticallyImplyLeading: true,
        elevation: 2,
      ),
      body: isLoading ? _buildLoadingIndicator() : _buildContent(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Espere... $textLoading',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLogoCard(),
            const SizedBox(height: 20),
            _buildTicketMessageCard(),
            const SizedBox(height: 32),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              'Logo del Negocio',
              Icons.insert_photo_outlined,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'El logo aparecerá en la parte superior de todos los tickets. Se recomienda una imagen simple con buen contraste.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Mostrar la imagen actual o seleccionada
            if (_image != null || _webImage != null || ticketModel.logo != null)
              _buildImagePreview(),

            const SizedBox(height: 20),

            // Botón para seleccionar imagen
            Center(
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_outlined),
                label: Text(
                  (_image != null ||
                          _webImage != null ||
                          ticketModel.logo != null)
                      ? 'Cambiar logo'
                      : 'Seleccionar logo',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 300,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _image != null
            ? Image.file(
                _image!,
                fit: BoxFit.contain,
              )
            : FadeInImage.assetNetwork(
                placeholder: 'assets/loading.gif',
                image: _webImage ?? ticketModel.logo!,
                fit: BoxFit.contain,
              ),
      ),
    );
  }

  Widget _buildTicketMessageCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              'Mensaje de Pie de Ticket',
              Icons.message_outlined,
              Colors.green,
            ),
            const SizedBox(height: 16),
            const Text(
              'Este mensaje aparecerá al final de todos los tickets. Puede incluir información de contacto, redes sociales o agradecimientos.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            _buildFormField(
              labelText: 'Mensaje para el pie del ticket',
              controller: _ticketFooterController,
              icon: Icons.text_fields_outlined,
              maxLines: 3,
              validator: (value) {
                // Hacer la validación opcional si hay una imagen
                if ((value == null || value.isEmpty) &&
                    (_image == null &&
                        _webImage == null &&
                        ticketModel.logo == null)) {
                  return 'Ingrese un mensaje o seleccione un logo';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String labelText,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _saveTicket,
        icon: const Icon(Icons.save_outlined),
        label: const Text(
          'Guardar Configuración',
          style: TextStyle(fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
