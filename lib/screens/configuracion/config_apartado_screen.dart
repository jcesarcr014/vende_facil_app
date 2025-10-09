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
  final variablesprovider = VariablesProvider();
  final GlobalKey<FormState> _formApartadoConf = GlobalKey<FormState>();
  final controllerPorcentaje = TextEditingController();
  final controllerArticulos = TextEditingController();
  final controllerArticulosMayoreo = TextEditingController();
  String? _porcentajeError;
  String? _articulosError;
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;

  // Valores de las variables
  bool aplicaApartado = false;
  bool aplicaMayoreo = false;
  bool empleadoCantidades = false;
  bool empleadoCorte = false;
  bool aplicaInventario = false;

  // IDs de las variables
  Map<String, int> variableIds = {};

  @override
  void dispose() {
    controllerPorcentaje.dispose();
    controllerArticulos.dispose();
    controllerArticulosMayoreo.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _cargarVariables();
  }

  void _cargarVariables() {
    setState(() {
      textLoading = 'Cargando configuración...';
      isLoading = true;
    });

    variablesprovider.variablesConfiguracion().then((value) {
      if (value.status == 1) {
        _actualizarVariablesLocales();
        setState(() {
          isLoading = false;
          textLoading = '';
        });
      } else {
        setState(() {
          isLoading = false;
          textLoading = '';
        });
        Navigator.pop(context);
        mostrarAlerta(context, 'Error', 'Error: ${value.mensaje}');
      }
    });
  }

  void _actualizarVariablesLocales() {
    for (var variable in listaVariables) {
      variableIds[variable.nombre] = variable.id;
      switch (variable.nombre) {
        case 'aplica_apartado':
          aplicaApartado = variable.valor == '1';
          break;
        case 'porcentaje_anticipo':
          controllerPorcentaje.text = variable.valor;
          break;
        case 'productos_apartados':
          controllerArticulos.text = variable.valor;
          break;
        case 'aplica_mayoreo':
          aplicaMayoreo = variable.valor == '1';
          break;
        case 'productos_mayoreo':
          controllerArticulosMayoreo.text = variable.valor;
          break;
        case 'empleado_cantidades':
          empleadoCantidades = variable.valor == '1';
          break;
        case 'empleado_corte':
          empleadoCorte = variable.valor == '1';
          break;
        case 'aplica_inventario':
          aplicaInventario = variable.valor == '1';
          break;
      }
    }
  }

  Future<void> _guardarVariable(String nombre, String valor) async {
    setState(() {
      textLoading = 'Guardando configuración...';
      isLoading = true;
    });

    try {
      final resultado = await variablesprovider.modificarVariable(
          variableIds[nombre]!, valor);
      setState(() {
        isLoading = false;
        textLoading = '';
      });

      if (resultado.status == 1) {
        mostrarAlerta(
            context, 'Guardado', 'Configuración actualizada correctamente',
            tituloColor: Colors.green);
      } else {
        mostrarAlerta(
            context, 'Error', 'Error al guardar: ${resultado.mensaje}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        textLoading = '';
      });
      mostrarAlerta(context, 'Error', 'Error inesperado: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Negocio'),
        automaticallyImplyLeading: true,
      ),
      body: (isLoading)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(textLoading),
                  const SizedBox(height: 10),
                  const CircularProgressIndicator(),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.05),
              child: Form(
                key: _formApartadoConf,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: windowHeight * 0.02),

                    // SECCIÓN APARTADO
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          SwitchListTile.adaptive(
                            title: const Text(
                              'Activar sistema de apartado',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(aplicaApartado
                                ? 'El sistema de apartado está activado'
                                : 'El sistema de apartado está desactivado'),
                            value: aplicaApartado,
                            onChanged: (value) async {
                              await _guardarVariable(
                                  'aplica_apartado', value ? '1' : '0');
                              setState(() {
                                aplicaApartado = value;
                              });
                            },
                          ),
                          if (aplicaApartado)
                            Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  const Text(
                                    'Configuración de apartado',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: windowHeight * 0.02),

                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: const Text(
                                          'Porcentaje mínimo de anticipo:',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      SizedBox(width: windowWidth * 0.02),
                                      Expanded(
                                        flex: 2,
                                        child: InputField(
                                          controller: controllerPorcentaje,
                                          labelText: '%',
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Requerido';
                                            }
                                            try {
                                              final double parsedValue =
                                                  double.parse(value);
                                              if (parsedValue < 1 ||
                                                  parsedValue > 100) {
                                                return 'Entre 1-100';
                                              }
                                            } catch (e) {
                                              return 'Inválido';
                                            }
                                            return null;
                                          },
                                          errorText: _porcentajeError,
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: windowHeight * 0.02),

                                  // Artículos máximos por apartado
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: const Text(
                                          'Artículos máximos por apartado:',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      SizedBox(width: windowWidth * 0.02),
                                      Expanded(
                                        flex: 2,
                                        child: InputField(
                                          controller: controllerArticulos,
                                          labelText: 'Cantidad',
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Requerido';
                                            }
                                            try {
                                              final int parsedValue =
                                                  int.parse(value);
                                              if (parsedValue < 1) {
                                                return 'Mínimo 1';
                                              }
                                            } catch (e) {
                                              return 'Inválido';
                                            }
                                            return null;
                                          },
                                          errorText: _articulosError,
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: windowHeight * 0.02),

                                  // Botón guardar configuración de apartado
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (_formApartadoConf.currentState!
                                            .validate()) {
                                          _guardarConfiguracionApartado();
                                        }
                                      },
                                      child: const Text(
                                          'Guardar configuración de apartado'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // SECCIÓN MAYOREO
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          SwitchListTile.adaptive(
                            title: const Text(
                              'Activar precios de mayoreo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(aplicaMayoreo
                                ? 'Los precios de mayoreo están activados'
                                : 'Los precios de mayoreo están desactivados'),
                            value: aplicaMayoreo,
                            onChanged: (value) async {
                              await _guardarVariable(
                                  'aplica_mayoreo', value ? '1' : '0');
                              setState(() {
                                aplicaMayoreo = value;
                              });
                            },
                          ),

                          // Contenedor con configuraciones adicionales de mayoreo
                          if (aplicaMayoreo)
                            Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  const Text(
                                    'Configuración de mayoreo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: windowHeight * 0.02),

                                  // Cantidad de artículos para mayoreo
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: const Text(
                                          'Cantidad mínima para mayoreo:',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      SizedBox(width: windowWidth * 0.02),
                                      Expanded(
                                        flex: 2,
                                        child: InputField(
                                          controller:
                                              controllerArticulosMayoreo,
                                          labelText: 'Cantidad',
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Requerido';
                                            }
                                            try {
                                              final int parsedValue =
                                                  int.parse(value);
                                              if (parsedValue < 2) {
                                                return 'Mínimo 2';
                                              }
                                            } catch (e) {
                                              return 'Inválido';
                                            }
                                            return null;
                                          },
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: windowHeight * 0.02),

                                  // Botón guardar configuración de mayoreo
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (_formApartadoConf.currentState!
                                            .validate()) {
                                          _guardarVariable('productos_mayoreo',
                                              controllerArticulosMayoreo.text);
                                        }
                                      },
                                      child: const Text(
                                          'Guardar configuración de mayoreo'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // CONFIGURACIONES DE EMPLEADOS Y SISTEMA
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Otras configuraciones',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // Ver cantidades de inventario
                          SwitchListTile.adaptive(
                            title: const Text(
                              'Empleados pueden ver inventario',
                              style: TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(empleadoCantidades
                                ? 'Los empleados pueden ver cantidades en inventario'
                                : 'Los empleados no pueden ver cantidades en inventario'),
                            value: empleadoCantidades,
                            onChanged: (value) async {
                              await _guardarVariable(
                                  'empleado_cantidades', value ? '1' : '0');
                              setState(() {
                                empleadoCantidades = value;
                              });
                            },
                          ),

                          const Divider(height: 1),

                          // Ver totales en corte
                          SwitchListTile.adaptive(
                            title: const Text(
                              'Empleados pueden ver totales en corte',
                              style: TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(empleadoCorte
                                ? 'Los empleados pueden ver los totales en su corte'
                                : 'Los empleados no pueden ver los totales en su corte'),
                            value: empleadoCorte,
                            onChanged: (value) async {
                              await _guardarVariable(
                                  'empleado_corte', value ? '1' : '0');
                              setState(() {
                                empleadoCorte = value;
                              });
                            },
                          ),

                          const Divider(height: 1),

                          // Vender sin inventario
                          SwitchListTile.adaptive(
                            title: const Text(
                              'Vender sin inventario suficiente',
                              style: TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(aplicaInventario
                                ? 'Se permite la venta aunque no haya inventario suficiente'
                                : 'No se permite la venta si no hay inventario suficiente'),
                            value: aplicaInventario,
                            onChanged: (value) async {
                              await _guardarVariable(
                                  'aplica_inventario', value ? '1' : '0');
                              setState(() {
                                aplicaInventario = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: windowHeight * 0.05),
                  ],
                ),
              ),
            ),
    );
  }

  void _guardarConfiguracionApartado() async {
    setState(() {
      textLoading = 'Guardando configuración de apartado...';
      isLoading = true;
    });

    try {
      // Guardar porcentaje de anticipo
      final resultadoPorcentaje = await variablesprovider.modificarVariable(
          variableIds['porcentaje_anticipo']!, controllerPorcentaje.text);

      if (resultadoPorcentaje.status == 1) {
        // Guardar cantidad de artículos por apartado
        final resultadoArticulos = await variablesprovider.modificarVariable(
            variableIds['productos_apartados']!, controllerArticulos.text);

        setState(() {
          isLoading = false;
          textLoading = '';
        });

        if (resultadoArticulos.status == 1) {
          mostrarAlerta(context, 'Guardado',
              'Configuración de apartado actualizada correctamente',
              tituloColor: Colors.green);
        } else {
          mostrarAlerta(context, 'Error',
              'Error al guardar: ${resultadoArticulos.mensaje}');
        }
      } else {
        setState(() {
          isLoading = false;
          textLoading = '';
        });
        mostrarAlerta(context, 'Error',
            'Error al guardar: ${resultadoPorcentaje.mensaje}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        textLoading = '';
      });
      mostrarAlerta(context, 'Error', 'Error inesperado: $e');
    }
  }
}
