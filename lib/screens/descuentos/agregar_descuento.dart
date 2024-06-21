import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

class AgregaDescuentoScreen extends StatefulWidget {
  const AgregaDescuentoScreen({super.key});

  @override
  State<AgregaDescuentoScreen> createState() => _AgregaDescuentoScreenState();
}

class _AgregaDescuentoScreenState extends State<AgregaDescuentoScreen> {
  final descuentosProvider = DescuentoProvider();
  final controllerNombre = TextEditingController();
  final controllerValor = TextEditingController();
  bool firstLoad = true;
  bool _tipoValor = true;
  bool _tipoValorS = true;
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  Descuento args = Descuento(id: 0);
  String title = 'Agregar descuento';

  _guardaDescuento() {
    if (controllerNombre.text.isNotEmpty) {
      setState(() {
        textLoading = (args.id == 0)
            ? 'Registrando nuevo descuento'
            : 'Actualizando descuento';
        isLoading = true;
      });
      Descuento descuento = Descuento();
      descuento.nombre = controllerNombre.text;
      descuento.tipoValor = (_tipoValor) ? 1 : 0;
      descuento.valor = (controllerValor.text.isNotEmpty)
          ? double.parse(controllerValor.text)
          : 0;
      descuento.valorPred = (_tipoValorS) ? 1 : 0;
      if (args.id == 0) {
        descuentosProvider.nuevoDescuento(descuento).then((value) {
          setState(() {
            isLoading = false;
            textLoading = '';
            globals.actualizaDescuentos = true;
          });
          if (value.status == 1) {
            Navigator.pushReplacementNamed(context, 'descuentos');
            mostrarAlerta(context, '', value.mensaje!);
          } else {
            mostrarAlerta(context, '', value.mensaje!);
          }
        });
      } else {
        descuento.id = args.id;
        descuentosProvider.editaDescuento(descuento).then((value) {
          setState(() {
            isLoading = false;
            textLoading = '';
            globals.actualizaDescuentos = true;
          });
          if (value.status == 1) {
            Navigator.pushReplacementNamed(context, 'descuentos');
            mostrarAlerta(context, '', value.mensaje!);
          } else {
            mostrarAlerta(context, '', value.mensaje!);
          }
        });
      }
    } else {
      mostrarAlerta(context, 'ERROR', 'El nombre del descuento es obligatorio');
    }
  }

  @override
  void dispose() {
    controllerNombre.dispose();
    controllerValor.dispose();
    super.dispose();
  }

  _alertaEliminar() {
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
                  '¿Desea eliminar el descuento  ${args.nombre} ? Esta acción no podrá revertirse.',
                )
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _eliminarDescuento();
                  },
                  child: const Text('Eliminar')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'))
            ],
          );
        });
  }

  _eliminarDescuento() {
    setState(() {
      textLoading = 'Eliminando descuento';
      isLoading = true;
    });

    descuentosProvider.eliminaDescuento(args.id!).then((value) {
      setState(() {
        textLoading = '';
        isLoading = false;
      });
      if (value.status == 1) {
        Navigator.pushReplacementNamed(context, 'descuentos');
        mostrarAlerta(context, '', value.mensaje!);
        globals.actualizaDescuentos = true;
      } else {
        mostrarAlerta(context, '', value.mensaje!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)?.settings.arguments != null && firstLoad) {
      firstLoad = false;
      args = ModalRoute.of(context)?.settings.arguments as Descuento;
      controllerNombre.text = args.nombre!;
      if (args.valorPred == 0) {
        controllerValor.text = args.valor!.toStringAsFixed(2);
      }
      _tipoValor = (args.tipoValor == 1) ? true : false;
      _tipoValorS = (args.valorPred == 1) ? true : false;
      title = 'Editar descuento';
    }
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      onPopInvoked: (didpop) {
        globals.actualizaDescuentos = true;
        if (!didpop) Navigator.pushReplacementNamed(context, 'descuentos');
      },
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: [
              if (args.id != 0)
                IconButton(
                    onPressed: () {
                      _alertaEliminar();
                    },
                    icon: const Icon(Icons.delete))
            ],
            title: Text(title),
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
                    children: [
                      SizedBox(
                        height: windowHeight * 0.05,
                      ),
                      InputField(
                          labelText: 'Nombre descuento:',
                          textCapitalization: TextCapitalization.words,
                          controller: controllerNombre),
                      SizedBox(
                        height: windowHeight * 0.03,
                      ),
                      SwitchListTile.adaptive(
                          title: Row(
                            children: [
                              const Text('Tipo descuento: '),
                              Text((_tipoValor) ? '%' : '\$')
                            ],
                          ),
                          value: _tipoValor,
                          onChanged: (value) {
                            _tipoValor = value;
                            setState(() {});
                          }),
                      SwitchListTile.adaptive(
                          title: Row(
                            children: [
                              const Text('Tipo de descuento: '),
                              Text((_tipoValorS) ? 'Variable' : 'Fijo')
                            ],
                          ),
                          value: _tipoValorS,
                          onChanged: (value) {
                            _tipoValorS = value;
                            setState(() {});
                          }),
                      if (!_tipoValorS)
                        InputField(
                            labelText: 'Descuento:',
                            keyboardType: TextInputType.number,
                            textCapitalization: TextCapitalization.none,
                            controller: controllerValor),
                      SizedBox(
                        height: windowHeight * 0.03,
                      ),
                      const Text(
                        'Si el valor queda en blanco, se considera descuento variable.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: windowHeight * 0.05,
                      ),
                      SizedBox(
                        height: windowHeight * 0.05,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                              onPressed: () => _guardaDescuento(),
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
                          SizedBox(
                            width: windowWidth * 0.05,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                globals.actualizaArticulos = true;
                                Navigator.pushReplacementNamed(
                                    context, 'descuentos');
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cancel_outlined),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Cancelar',
                                  ),
                                ],
                              )),
                        ],
                      )
                    ],
                  ))),
    );
  }
}
