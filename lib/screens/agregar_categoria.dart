import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';

class AgregaCategoriaScreen extends StatefulWidget {
  const AgregaCategoriaScreen({super.key});

  @override
  State<AgregaCategoriaScreen> createState() => _AgregaCategoriaScreenState();
}

class _AgregaCategoriaScreenState extends State<AgregaCategoriaScreen> {
  final controllerCategoria = TextEditingController();
  final categoriasProvider = CategoriaProvider();
  bool firstLoad = true;
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  int _valueCat = 0;
  Categoria args = Categoria(id: 0, categoria: '', idColor: 1);

  _guardaCategoria() {
    if (controllerCategoria.text.isNotEmpty && _valueCat != 0) {
      setState(() {
        textLoading = (args.id == 0)
            ? 'Registrando nueva categoria'
            : 'Actualizando categoria';
        isLoading = true;
      });
      Categoria nvaCat = Categoria();
      nvaCat.categoria = controllerCategoria.text;
      nvaCat.idColor = _valueCat;
      if (args.id == 0) {
        categoriasProvider.nuevaCategoria(nvaCat).then((value) {
          setState(() {
            isLoading = false;
            textLoading = '';
          });
          if (value.status == 1) {
            Navigator.pushReplacementNamed(context, 'categorias');
            mostrarAlerta(context, '', value.mensaje!);
          } else {
            mostrarAlerta(context, '', value.mensaje!);
          }
        });
      } else {
        nvaCat.id = args.id;
        categoriasProvider.editaCategoria(nvaCat).then((value) {
          setState(() {
            isLoading = false;
            textLoading = '';
          });
          if (value.status == 1) {
            Navigator.pushReplacementNamed(context, 'categorias');
            mostrarAlerta(context, '', value.mensaje!);
          } else {
            mostrarAlerta(context, '', value.mensaje!);
          }
        });
      }
    } else {
      mostrarAlerta(context, 'ERROR',
          'El nombre de la categoría y color son obligatorios.');
    }
  }

  _alertaElimnar() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              'ATENCIÓN',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '¿Desea eliminar la categoría  ${args.categoria} ? Esta acción no podrá revertirse.',
                )
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _eliminarCategoria();
                  },
                  child: const Text('Eliminar')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'))
            ],
          );
        });
  }

  _eliminarCategoria() {
    setState(() {
      textLoading = 'Eliminando categoria';
      isLoading = true;
    });
    categoriasProvider.eliminaCategoria(args.id!).then((value) {
      setState(() {
        textLoading = '';
        isLoading = false;
      });
      if (value.status == 1) {
        Navigator.pushReplacementNamed(context, 'categorias');
        mostrarAlerta(context, '', value.mensaje!);
      } else {
        mostrarAlerta(context, '', value.mensaje!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)?.settings.arguments != null && firstLoad) {
      firstLoad = false;
      args = ModalRoute.of(context)?.settings.arguments as Categoria;
      for (var color in listaColores) {
        if (color.id == args.idColor) {
          _valueCat = color.id!;
        }
      }
      controllerCategoria.text = args.categoria!;
    }
    final title = (args.id == 0) ? 'Nueva categoría' : 'Editar categoría';
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(title),
        actions: [
          if (args.id != 0)
            IconButton(
                onPressed: () {
                  _alertaElimnar();
                },
                icon: const Icon(Icons.delete))
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
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              margin: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  InputField(
                      textCapitalization: TextCapitalization.words,
                      labelText: 'Ingrese categoría',
                      controller: controllerCategoria),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      const Text('Seleccione color:'),
                      const SizedBox(
                        width: 10,
                      ),
                      _colores(windowWidth * 0.3),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        _guardaCategoria();
                      },
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
                      )),
                ],
              ),
            ),
    );
  }

  _colores(double width) {
    var lista = [
      DropdownMenuItem(
          value: 0,
          child: SizedBox(
            width: width,
            child: const Text('Ninguno'),
          ))
    ];

    for (var color in listaColores) {
      lista.add(DropdownMenuItem(
          value: color.id,
          child: Container(
            width: width,
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(border: Border.all(), color: color.color),
          )));
    }

    return DropdownButton(
        items: lista,
        value: _valueCat,
        onChanged: (value) {
          setState(() {
            _valueCat = value ?? 0;
          });
        });
  }
}
