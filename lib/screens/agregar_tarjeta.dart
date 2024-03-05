import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';

class AgregaTarjetaScreen extends StatefulWidget {
  const AgregaTarjetaScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AgregaTarjetaScreenState createState() => _AgregaTarjetaScreenState();
}

class _AgregaTarjetaScreenState extends State<AgregaTarjetaScreen> {
  final articulosProvider = ArticuloProvider();
  final inventarioProvider = InventarioProvider();
  final categoriasProvider = CategoriaProvider();
  final controllerProducto = TextEditingController();
  final controllerPrecio = TextEditingController();
  final controllercosto = TextEditingController();
  final controllerClave = TextEditingController();
  final controllerCodigoB = TextEditingController();
  final controllerCantidad = TextEditingController();
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  bool firstLoad = true;
  final picker = ImagePicker();
  late File imagenProducto;

  Producto args = Producto(id: 0);

  @override
  void dispose() {
    controllerProducto.dispose();
    controllerClave.dispose();
    controllerCodigoB.dispose();
    controllerCantidad.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)?.settings.arguments != null && firstLoad) {
      firstLoad = false;
      args = ModalRoute.of(context)!.settings.arguments as Producto;
    }

    final title = (args.id == 0) ? 'Nuevo tarjeta' : 'Editar tarjeta';
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, 'tarjetas');
                },
                icon: const Icon(Icons.arrow_back)),
            if (args.id != 0)
              IconButton(onPressed: () {}, icon: const Icon(Icons.delete))
          ],
        ),
        body: (isLoading)
            ? Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Espere...$textLoading'),
                      const SizedBox(
                        height: 10,
                      ),
                      const CircularProgressIndicator(),
                    ]),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.03),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: windowHeight * 0.05,
                    ),
                    InputField(
                        labelText: 'nombre del titular',
                        textCapitalization: TextCapitalization.sentences,
                        controller: controllerProducto),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    InputField(
                      labelText: 'numero de cuenta',
                      textCapitalization: TextCapitalization.sentences,
                      controller: controllerPrecio,
                    ),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    InputField(
                      labelText: 'caducidad',
                      textCapitalization: TextCapitalization.sentences,
                      controller: controllerPrecio,
                    ),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    InputField(
                        readOnly: true,
                        labelText: 'numero de seguridad:',
                        textCapitalization: TextCapitalization.none,
                        controller: controllerClave),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    ElevatedButton(
                        onPressed: () {},
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Guardar',
                            ),
                          ],
                        ))
                  ],
                ),
              ));
  }
}
