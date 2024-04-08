import 'package:flutter/material.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/models/models.dart';

class AgregaTarjetaScreen extends StatefulWidget {
  const AgregaTarjetaScreen({super.key});

  @override
  _AgregaTarjetaScreenState createState() => _AgregaTarjetaScreenState();
}

class _AgregaTarjetaScreenState extends State<AgregaTarjetaScreen> {
  final tarjetaProvider = TarjetaProvider();
  final controllerTitular = TextEditingController();
  final controllerNumTarjeta = TextEditingController();
  final controllerVencM = TextEditingController();
  final controllerVencA = TextEditingController();
  final controllerCCV = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  String? _titularError;
  String? _numTarjetaError;
  String? _vencMError;
  String? _vencAError;
  String? _ccvError;

  _guardarTarjeta() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        textLoading = 'Guardando tarjeta...';
      });
      TarjetaOP tarjeta = TarjetaOP(
        titular: controllerTitular.text,
        numero: controllerNumTarjeta.text,
        fechaM: controllerVencM.text,
        fechaA: controllerVencA.text,
        ccv: controllerCCV.text,
      );
      tarjetaProvider.nuevaTarjeta(tarjeta).then((value) {
        setState(() {
          textLoading = '';
          isLoading = false;
        });
        if (value.status == 1) {
          Navigator.pop(context);
          mostrarAlerta(context, 'OK', value.mensaje!);
        } else {
          mostrarAlerta(context, 'Error', 'Error: ${value.mensaje}');
        }
      });
    }
  }

  @override
  void dispose() {
    controllerTitular.dispose();
    controllerNumTarjeta.dispose();
    controllerVencM.dispose();
    controllerVencA.dispose();
    controllerCCV.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Nueva tarjeta'),
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
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: windowHeight * 0.05,
                      ),
                      InputField(
                        labelText: 'Titular',
                        icon: Icons.person,
                        textCapitalization: TextCapitalization.words,
                        controller: controllerTitular,
                        validator: (nombre) {
                          if (nombre == null || nombre.isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          return null;
                        },
                        errorText: _titularError,
                      ),
                      SizedBox(
                        height: windowHeight * 0.03,
                      ),
                      InputField(
                        icon: Icons.credit_card,
                        labelText: 'Numero de tarjeta',
                        controller: controllerNumTarjeta,
                        keyboardType: TextInputType.number,
                        validator: (numTarjeta) {
                          if (numTarjeta == null || numTarjeta.isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          final RegExp numeric = RegExp(r'^[0-9]+$');
                          if (!numeric.hasMatch(numTarjeta) ||
                              numTarjeta.length < 16) {
                            return 'Numero de tarjeta invalido';
                          }

                          return null;
                        },
                        errorText: _numTarjetaError,
                      ),
                      SizedBox(
                        height: windowHeight * 0.03,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: InputField(
                              icon: Icons.calendar_today,
                              labelText: 'Mes',
                              keyboardType: TextInputType.number,
                              controller: controllerVencM,
                              validator: (vencM) {
                                if (vencM == null || vencM.isEmpty) {
                                  return 'Este campo es obligatorio';
                                }
                                final RegExp numeric = RegExp(r'^[0-9]+$');
                                if (!numeric.hasMatch(vencM) ||
                                    vencM.length < 2) {
                                  return 'Mes invalido';
                                }
                                return null;
                              },
                              errorText: _vencMError,
                            ),
                          ),
                          SizedBox(
                            width: windowWidth * 0.03,
                          ),
                          Expanded(
                            child: InputField(
                              icon: Icons.calendar_today,
                              labelText: 'Año',
                              controller: controllerVencA,
                              keyboardType: TextInputType.number,
                              validator: (vencA) {
                                if (vencA == null || vencA.isEmpty) {
                                  return 'Este campo es obligatorio';
                                }
                                final RegExp numeric = RegExp(r'^[0-9]+$');
                                if (!numeric.hasMatch(vencA) ||
                                    vencA.length < 2) {
                                  return 'Año invalido';
                                }
                                return null;
                              },
                              errorText: _vencAError,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: windowHeight * 0.03,
                      ),
                      InputField(
                        icon: Icons.lock,
                        labelText: 'CCV:',
                        keyboardType: TextInputType.number,
                        controller: controllerCCV,
                        validator: (ccv) {
                          if (ccv == null || ccv.isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          final RegExp numeric = RegExp(r'^[0-9]+$');
                          if (!numeric.hasMatch(ccv) || ccv.length < 3) {
                            return 'CCV invalido';
                          }
                          return null;
                        },
                        errorText: _ccvError,
                      ),
                      SizedBox(
                        height: windowHeight * 0.03,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            _guardarTarjeta();
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
                          ))
                    ],
                  ),
                ),
              ));
  }
}
