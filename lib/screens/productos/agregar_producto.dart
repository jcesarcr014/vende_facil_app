// ignore_for_file: unrelated_type_equality_checks, avoid_print, prefer_final_fields
import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:vende_facil/providers/globals.dart' as globals;


class AgregaProductoScreen extends StatefulWidget {
  const AgregaProductoScreen({super.key});

  @override
  State<AgregaProductoScreen> createState() => _AgregaProductoScreenState();
}

class _AgregaProductoScreenState extends State<AgregaProductoScreen> {
  final articulosProvider = ArticuloProvider();
  final imagenProvider = ImagenProvider();
  final categoriasProvider = CategoriaProvider();
  final controllerProducto = TextEditingController();
  final controllerDescripcion = TextEditingController();
  final controllerPrecio = TextEditingController();
  final controllercosto = TextEditingController();
  final controllerClave = TextEditingController();
  final controllerCodigoB = TextEditingController();
  final controllerCantidad = TextEditingController();

  final controllerPrecioMayoreo = TextEditingController();
  final controllerPrecioDirecto = TextEditingController();

  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  String _valueIdCategoria = '0';
  bool firstLoad = true;
  bool _valuePieza = false;
  final bool _valueInventario = true;
  bool _valueApartado = false;
  bool _puedeGurdar = false;
  Producto producto = Producto();
  Producto args = Producto(
    id: 0,
  );

  String _generaCodigo() {
    final numProductos = (listaProductos.length + 1).toString();
    final numEmpresa = sesion.idNegocio.toString();
    final numUsuario = sesion.idUsuario.toString();

    final codigo =
        '${numEmpresa.padRight(6, '0')}-${numUsuario.padRight(6, '0')}-${numProductos.padLeft(8, '0')}';

    return codigo;
  }

  _validaciones() {
    int errores = 0;
    String mensaje = 'Faltan los siguientes datos: ';
    if (controllerProducto.text.isEmpty) {
      mensaje += 'Nombre del producto, ';
      errores++;
    }
    if (controllerDescripcion.text.isEmpty) {
      mensaje += 'Descripcion, ';
      errores++;
    }
    if (_valueIdCategoria == '0') {
      mensaje += 'Categoria, ';
      errores++;
    }
    if (controllerPrecio.text.isEmpty) {
      mensaje += 'Precio Público, ';
      errores++;
    }

    if (controllerPrecioMayoreo.text.isEmpty) {
      mensaje += 'Precio Mayoreo, ';
      errores++;
    }

    if (controllerPrecioDirecto.text.isEmpty) {
      mensaje += 'Precio Directo, ';
      errores++;
    }

    if (controllercosto.text.isEmpty) {
      mensaje += 'Costo, ';
      errores++;
    }
    if (_valueInventario && controllerCantidad.text.isEmpty) {
      mensaje += 'Cantidad, ';
      errores++;
    }
    if (errores > 0) {
      mensaje = mensaje.substring(0, mensaje.length - 2);
      mostrarAlerta(context, 'ERROR', mensaje);
    } else {
      _puedeGurdar = true;
    }
  }

  _guardaProducto() async {
    _validaciones();
    if (_puedeGurdar) {
      setState(() {
        textLoading = (args.id == 0)
            ? 'Agregando nuevo articulo'
            : 'Actualizando articulo';
        isLoading = true;
      });

      producto.cantidad = double.parse(controllerCantidad.text);
      producto.precioDist = double.parse(controllerPrecioDirecto.text);
      producto.precioMayoreo = double.parse(controllerPrecioMayoreo.text);

      producto.producto = controllerProducto.text;
      producto.descripcion = controllerDescripcion.text;
      producto.idCategoria = int.parse(_valueIdCategoria);
      producto.unidad = (_valuePieza) ? '1' : '0';
      producto.precioPublico =
          double.parse(controllerPrecio.text.replaceAll(',', ''));
      producto.precioMayoreo =
          double.parse(controllerPrecioMayoreo.text.replaceAll(',', ''));
      producto.precioDist =
          double.parse(controllerPrecioDirecto.text.replaceAll(',', ''));

      producto.costo = double.parse(controllercosto.text.replaceAll(',', ''));
      producto.clave = controllerClave.text;
      producto.codigoBarras = (controllerCodigoB.text.isEmpty)
          ? controllerClave.text
          : controllerCodigoB.text;

      producto.apartado = (_valueApartado) ? 1 : 0;
      if (args.id == 0) {
        articulosProvider.nuevoProducto(producto).then((value) {
          if (value.status != 1) {
            setState(() {
              isLoading = false;
              textLoading = '';
            });
            mostrarAlerta(context, '', value.mensaje!);
            return;
          }

          Navigator.pushReplacementNamed(context, 'products-menu');
          globals.actualizaArticulos = true;
          mostrarAlerta(context, '', 'Producto Guardado Correctamente');
        });
      } else {
        var apartado = (_valueApartado) ? 1 : 0;
        if (producto.producto == controllerProducto &&
            producto.descripcion == controllerDescripcion &&
            producto.precioPublico == controllerPrecio &&
            producto.codigoBarras == controllerCodigoB &&
            producto.clave == controllerClave &&
            producto.apartado == apartado) {
          mostrarAlerta(context, 'Error', 'Actualiza por lo menos un campo');
        } else {
          producto.id = args.id;
          articulosProvider.editaProducto(producto).then((value) {
            setState(() {
              _valueIdCategoria = '0';
              isLoading = false;
              textLoading = '';
            });
            if (value.status == 1) {
              globals.actualizaArticulos = true;
              Navigator.pop(context);
              Navigator.popAndPushNamed(context, 'productos');
              mostrarAlerta(context, 'Exito', value.mensaje!);
            } else {
              mostrarAlerta(context, '', value.mensaje!);
            }
          });
        }
      }
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
                  '¿Desea eliminar el articulo ${args.producto} ? Esta acción no podrá revertirse.',
                )
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _eliminarProducto();
                  },
                  child: const Text('Eliminar')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'))
            ],
          );
        });
  }

  _eliminarProducto() {
    setState(() {
      textLoading = 'Eliminando articulo';
      isLoading = true;
    });
    articulosProvider.eliminaProducto(args.id!).then((value) {
      setState(() {
        textLoading = '';
        isLoading = false;
      });
      if (value.status == 1) {
        globals.actualizaArticulos = true;
        Navigator.pushReplacementNamed(context, 'productos');
        mostrarAlerta(context, '', value.mensaje!);
      } else {
        mostrarAlerta(context, '', value.mensaje!);
      }
    });
  }

  @override
  void dispose() {
    controllerProducto.dispose();
    //controllerPrecio.dispose();
    //controllercosto.dispose();
    controllerClave.dispose();
    controllerCodigoB.dispose();
    controllerCantidad.dispose();
    super.dispose();
  }

  @override
  void initState() {
    textLoading = 'Leyendo categorias';
    isLoading = true;
    setState(() {});
    categoriasProvider.listarCategorias().then((value) {
      textLoading = '';
      isLoading = false;
      setState(() {});
    });
    if (args.id == 0) {
      controllerClave.text = _generaCodigo();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)?.settings.arguments != null && firstLoad) {
      firstLoad = false;
      args = ModalRoute.of(context)?.settings.arguments as Producto;
      _valuePieza = args.unidad == "1" ? true : false;
      controllerProducto.text = args.producto!;
      controllerDescripcion.text = args.descripcion!;
      controllerPrecio.text = (args.precioPublico != null)
          ? args.precioPublico!.toStringAsFixed(2)
          : '0.00';

      controllercosto.text =
          (args.costo != null) ? args.costo!.toStringAsFixed(2) : '0.00';

      controllerPrecioMayoreo.text = args.precioMayoreo.toString() == "null"
          ? '0.00'
          : args.precioMayoreo.toString();
      controllerPrecioDirecto.text = args.precioDist.toString() == "null"
          ? '0.00'
          : args.precioDist.toString();

      controllerClave.text = args.clave!;

      controllerCodigoB.text =
          (args.codigoBarras != null) ? args.codigoBarras! : '';

      _valueApartado = (args.apartado == 0) ? false : true;
      if (_valueInventario) {
        controllerCantidad.text = (args.cantidad != null)
            ? args.cantidad!.toStringAsFixed(2)
            : '0.00';
      }
    } else {
      setState(() {});
    }
    final title = (args.id == 0) ? 'Nuevo producto' : 'Editar producto';
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      onPopInvoked: (didpop) {
        if(args.id != 0 && !didpop) {
          Navigator.pop(context);
          Navigator.popAndPushNamed(context, 'productos');
          return;
        }
        globals.actualizaArticulos = true;
        if (!didpop) Navigator.pushReplacementNamed(context, 'products-menu');
      },
      child: Scaffold(
          appBar: AppBar(
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
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.03),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: windowHeight * 0.05,
                      ),
                      InputField(
                          labelText: 'Producto:',
                          textCapitalization: TextCapitalization.sentences,
                          controller: controllerProducto),
                      SizedBox(
                        height: windowHeight * 0.03,
                      ),
                      InputField(
                          labelText: 'Descripción:',
                          textCapitalization: TextCapitalization.sentences,
                          controller: controllerDescripcion),
                      SizedBox(
                        height: windowHeight * 0.03,
                      ),
                      _categorias(),
                      SizedBox(
                        height: windowHeight * 0.03,
                      ),
                      SwitchListTile.adaptive(
                          title: const Text('Vendido por: '),
                          subtitle: Text((_valuePieza) ? 'Piezas' : 'kg/m'),
                          value: _valuePieza,
                          onChanged: (value) {
                            _valuePieza = value;
                            setState(() {});
                          }),
                      SizedBox(
                        height: windowHeight * 0.03,
                      ),
                      InputFieldMoney(
                          controller: controllercosto, labelText: 'Costo'),
                      SizedBox(
                        height: windowHeight * 0.03,
                      ),
                      InputFieldMoney(
                          controller: controllerPrecio,
                          labelText: 'Precio Público'),
                      SizedBox(
                        height: windowHeight * 0.03,
                      ),
                      InputFieldMoney(
                          controller: controllerPrecioMayoreo,
                          labelText: 'Precio Mayoreo'),
                      SizedBox(
                        height: windowHeight * 0.03,
                      ),
                      InputFieldMoney(
                          controller: controllerPrecioDirecto,
                          labelText: 'Precio Distribuidor'),
                      SizedBox(
                        height: windowHeight * 0.03,
                      ),
                      InputField(
                          readOnly: true,
                          labelText: 'Clave:',
                          textCapitalization: TextCapitalization.none,
                          controller: controllerClave),
                      SizedBox(
                        height: windowHeight * 0.03,
                      ),
                      InputField(
                          labelText: 'Código de barras:',
                          textCapitalization: TextCapitalization.none,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.qr_code_scanner),
                            onPressed: () async {
                              var res = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SimpleBarcodeScannerPage(),
                                  ));
                              setState(() {
                                if (res is String) {
                                  controllerCodigoB.text = res;
                                }
                              });
                            },
                          ),
                          controller: controllerCodigoB),
                      SizedBox(
                        height: windowHeight * 0.03,
                      ),
                      InputField(
                        labelText: 'Cantidad:',
                        keyboardType: TextInputType.number,
                        controller: controllerCantidad,
                        readOnly: (args.id == 0) ? false : true,
                      ),
                      SizedBox(
                        height: windowHeight * 0.03,
                      ),
                      SwitchListTile.adaptive(
                          title: const Text('Se puede apartar'),
                          value: _valueApartado,
                          onChanged: (value) {
                            _valueApartado = value;
                            setState(() {});
                          }),
                      SizedBox(
                        height: windowHeight * 0.03,
                      ),
                      SizedBox(
                        height: windowHeight * 0.05,
                      ),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () => _guardaProducto(),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save),
                                SizedBox(
                                  width: 5,
                                ),
                                Text('Guardar'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: windowHeight * 0.08,
                      ),
                    ],
                  ),
                )),
    );
  }

  Widget _categorias() {
    var listaCat = [
      const DropdownMenuItem(
          value: '0', child: SizedBox(child: Text('Seleccione categoría')))
    ];

    if (args.id == 0) {
      for (Categoria categoria in listaCategorias) {
        listaCat.add(DropdownMenuItem(
            value: categoria.id.toString(), child: Text(categoria.categoria!)));
      }
    } else {
      for (Categoria categoria in listaCategorias) {
        listaCat.add(DropdownMenuItem(
            value: categoria.id.toString(), child: Text(categoria.categoria!)));
        if (categoria.id == args.idCategoria) {
          _valueIdCategoria = categoria.id.toString();
        }
      }
    }
    if (_valueIdCategoria.isEmpty) {
      _valueIdCategoria = '0';
    }

    return DropdownButton(
        items: listaCat,
        isExpanded: true,
        value: _valueIdCategoria,
        onChanged: (value) {
          _valueIdCategoria = value!;
          setState(() {});
        });
  }
}
