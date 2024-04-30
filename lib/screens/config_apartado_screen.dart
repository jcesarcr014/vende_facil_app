import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/providers/providers.dart';

class AjustesApartadoScreen extends StatefulWidget {
  const AjustesApartadoScreen({super.key});

  @override
  State<AjustesApartadoScreen> createState() => _AjustesApartadoScreenState();
}

class _AjustesApartadoScreenState extends State<AjustesApartadoScreen> {
  final apartadoProvider = ApartadoProvider();
  final GlobalKey<FormState> _formApartadoConf = GlobalKey<FormState>();
  final controllerPorcentaje = TextEditingController();
  final controllerArticulos = TextEditingController();
  String? _porcentajeError;
  String? _articulosError;
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;

  @override
  void dispose() {
    controllerPorcentaje.dispose();
    controllerArticulos.dispose();
    super.dispose();
  }

  @override
  void initState() {
    setState(() {
      textLoading = 'Leyendo valores.';
      isLoading = true;
    });
    apartadoProvider.variablesApartado().then((value) {
      setState(() {
        isLoading = false;
        textLoading = '';
      });
      if (value.status == 1) {
        for (VariableConf varTemp in listaVariables) {
          if (varTemp.nombre == 'porcentaje_anticipo') {
            controllerPorcentaje.text = varTemp.valor;
          } else if (varTemp.nombre == 'productos_apartados') {
            controllerArticulos.text = varTemp.valor;
          }
        }
      } else {
        Navigator.pop(context);
        mostrarAlerta(context, 'Error', 'Error: ${value.mensaje}');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Configuración de apartado'),
          automaticallyImplyLeading: true,
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
                child: Form(
                  key: _formApartadoConf,
                  child: Column(
                    children: [
                      SizedBox(
                        height: windowHeight * 0.08,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: windowWidth * 0.6,
                            child: const Text(
                              'Porcentaje minimo de anticipo: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              maxLines: 2,
                            ),
                          ),
                          SizedBox(
                            width: windowWidth * 0.02,
                          ),
                          Expanded(
                            child: InputField(
                              controller: controllerPorcentaje,
                              labelText: 'Procentaje',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese un porcentaje';
                                }
                                final numericValue =
                                    value.replaceAll(RegExp(r'[^\d.]'), '');
                                try {
                                  final double parsedValue =
                                      double.parse(numericValue);
                                  if (parsedValue < 0 || parsedValue > 100) {
                                    return 'El porcentaje debe estar entre 0 y 100';
                                  }
                                } catch (e) {
                                  return 'Valor no válido';
                                }
                                return null;
                              },
                              errorText: _porcentajeError,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: windowHeight * 0.02,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: windowWidth * 0.6,
                            child: const Text(
                              'Artículos máximos permitidos apartar por compra: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              maxLines: 2,
                            ),
                          ),
                          SizedBox(
                            width: windowWidth * 0.02,
                          ),
                          Expanded(
                              child: InputField(
                            controller: controllerArticulos,
                            labelText: 'Artículos',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese un número de artículos';
                              }
                              final numericValue =
                                  value.replaceAll(RegExp(r'[^\d.]'), '');
                              try {
                                final int parsedValue = int.parse(numericValue);
                                if (parsedValue < 0) {
                                  return 'No se permiten valores negativos';
                                }
                              } catch (e) {
                                return 'Valor no válido';
                              }
                              return null;
                            },
                            errorText: _articulosError,
                            keyboardType: TextInputType.number,
                          )),
                        ],
                      ),
                      SizedBox(
                        height: windowHeight * 0.08,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formApartadoConf.currentState!.validate()) {
                            setState(() {
                              textLoading = 'Guardando valores.';
                              isLoading = true;
                            });
                            apartadoProvider
                                .modificarVariables(
                                    int.parse(controllerPorcentaje.text))
                                .then((value) {
                              setState(() {
                                isLoading = false;
                                textLoading = '';
                              });
                              if (value.status == 1) {
                                Navigator.pop(context);
                                mostrarAlerta(context, 'Guardado',
                                    'Valores guardados correctamente');
                              } else {
                                mostrarAlerta(context, 'Error',
                                    'Error: ${value.mensaje}');
                              }
                            });
                          }
                        },
                        child: const Text('Guardar'),
                      ),
                    ],
                  ),
                )));
  }
}
