import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

class CategoriasScreens extends StatefulWidget {
  const CategoriasScreens({super.key});

  @override
  State<CategoriasScreens> createState() => _CategoriasScreensState();
}

class _CategoriasScreensState extends State<CategoriasScreens> {
  final categoriasProvider = CategoriaProvider();
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;

  @override
  void initState() {
    setState(() {
      textLoading = 'Leyendo categorias';
      isLoading = true;
    });
    categoriasProvider.listarCategorias().then((value) {
      setState(() {
        textLoading = '';
        isLoading = false;
      });
      if (value.status != 1) {
        Navigator.pop(context);
        mostrarAlerta(context, 'ERROR', value.mensaje!);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      onPopInvoked: (didpop) {
        if (!didpop) Navigator.pushReplacementNamed(context, 'menu');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categorias'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, 'menu');
                },
                icon: const Icon(Icons.menu)),
          ],
        ),
        body: (isLoading)
            ? Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Espere...$textLoading'),
                      SizedBox(
                        height: windowHeight * 0.01,
                      ),
                      const CircularProgressIndicator(),
                    ]),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.04),
                child: Column(
                  children: [
                    SizedBox(
                      height: windowHeight * 0.02,
                    ),
                    if (sesion.tipoUsuario == 'P')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, 'nva-categoria');
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add),
                              SizedBox(
                                width: 5,
                              ),
                              Text('Nueva categoria'),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(
                      height: windowHeight * 0.02,
                    ),
                    const Divider(),
                    SizedBox(
                      height: windowHeight * 0.01,
                    ),
                    Column(children: _categorias())
                  ],
                ),
              ),
      ),
    );
  }

  _categorias() {
    List<Widget> listaCat = [];
    if (listaCategorias.isNotEmpty) {
      for (Categoria cat in listaCategorias) {
        for (ColorCategoria color in listaColores) {
          if (color.id == cat.idColor) {
            listaCat.add(Column(
              children: [
                ListTile(
                  onTap: () {
                    if (sesion.tipoUsuario == 'P') {
                      Navigator.pushNamed(context, 'nva-categoria',
                          arguments: cat);
                    }
                  },
                  leading: Icon(
                    Icons.square,
                    color: color.color,
                    size: 36,
                  ),
                  title: Text(
                    cat.categoria!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
              ],
            ));
          }
        }
      }
    } else {
      final TextTheme textTheme = Theme.of(context).textTheme;

      listaCat.add(Column(
        children: [
          const Opacity(
            opacity: 0.2,
            child: Icon(
              Icons.filter_alt_off,
              size: 130,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            'No hay categorias guardadas.',
            style: textTheme.titleMedium,
          )
        ],
      ));
    }

    return listaCat;
  }
}
