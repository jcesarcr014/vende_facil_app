import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';

class AgregaProductoScreen extends StatefulWidget {
  const AgregaProductoScreen({super.key});

  @override
  State<AgregaProductoScreen> createState() => _AgregaProductoScreenState();
}

class _AgregaProductoScreenState extends State<AgregaProductoScreen> {
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
  String _valueIdCategoria = '0';
  bool firstLoad = true;
  bool _valuePieza = true;
  bool _valueInventario = true;
  bool _valueApartado = true;
  final picker = ImagePicker();
  late File imagenProducto;
  String _rutaProducto = '';

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

  _guardaProducto() {
    if (controllerProducto.text.isNotEmpty &&
        controllerPrecio.text.isNotEmpty) {
      var valor = double.tryParse(controllerCantidad.text);
      var dato = (_valueInventario) ? 1 : 0;
      if (valor != null && dato == 1 && valor > 0) {
        setState(() {
          textLoading = (args.id == 0)
              ? 'Agregando nuevo articulo'
              : 'Actualizando articulo';
          isLoading = true;
        });
        Producto producto = Producto();
        producto.producto = controllerProducto.text;
        producto.idCategoria = int.parse(_valueIdCategoria); // int
        producto.unidad = (_valuePieza) ? '1' : '0';
        producto.precio =
            double.parse(controllerPrecio.text.replaceAll(',', ''));
        producto.costo = double.parse(controllercosto.text.replaceAll(',', ''));
        producto.clave = controllerClave.text;
        producto.codigoBarras = controllerCodigoB.text;
        producto.inventario = (_valueInventario) ? 1 : 0;
        producto.imagen =
            'https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg?20200913095930';
        producto.apartado = (_valueApartado) ? 1 : 0;
        if (args.id == 0) {
          /*
              AQUI GUARDAR LA IMAGEN
        */
          articulosProvider.nuevoProducto(producto).then((value) {
            if (value.status == 1) {
              if (producto.inventario == 1) {
                Existencia Inventario = Existencia();
                Inventario.idArticulo = value.id;
                var valor = double.parse(controllerCantidad.text);
                Inventario.cantidad = valor;
                Inventario.apartado = valor;
                Inventario.disponible = valor;
                inventarioProvider.guardar(Inventario).then((value) {
                  if (value.status == 1) {
                    Navigator.pushReplacementNamed(context, 'productos');
                    mostrarAlerta(context, '', value.mensaje!);
                  } else {
                    setState(() {
                      isLoading = false;
                      textLoading = '';
                    });
                    mostrarAlerta(context, '', value.mensaje!);
                  }
                });
              } else {
                Navigator.pushReplacementNamed(context, 'productos');
                mostrarAlerta(context, '', value.mensaje!);
              }
            } else {
              setState(() {
                isLoading = false;
                textLoading = '';
              });
              mostrarAlerta(context, '', value.mensaje!);
            }
          });
        } else {
          /*
          VALIDAR IMAGEN  Y ACTUALIZAR
          
        */
          producto.id = args.id;
          articulosProvider.editaProducto(producto).then((value) {
            setState(() {
              _valueIdCategoria = '0';
              isLoading = false;
              textLoading = '';
            });
            if (value.status == 1) {
              Navigator.pushReplacementNamed(context, 'home');
              mostrarAlerta(context, '', value.mensaje!);
            } else {
              mostrarAlerta(context, '', value.mensaje!);
            }
          });
        }
      } else {
        mostrarAlerta(context, 'ERROR',
            'el valor del inventario  tiene que ser mayor a cero y no puede estar vacio ');
      }
    } else {
      mostrarAlerta(
          context, 'ERROR', 'Los campos Nombre y Precio son obligatorios');
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
      controllerProducto.text = args.producto!;
      controllerPrecio.text =
          (args.precio != null) ? args.precio!.toStringAsFixed(2) : '0.00';

      controllercosto.text =
          (args.costo != null) ? args.costo!.toStringAsFixed(2) : '0.00';

      controllerClave.text = args.clave!;

      controllerCodigoB.text =
          (args.codigoBarras != null) ? args.codigoBarras! : '';

      //REVISAR CANTIDAD EN INVENTARIO
      _valueInventario = (args.inventario == 0) ? false : true;
      _valueApartado = (args.apartado == 0) ? false : true;
      if (_valueInventario) {
        for (var existencia in inventario) {
          if (args.id == existencia.idArticulo) {
            controllerCantidad.text = existencia.disponible.toString();
          }
        }
      }
    }
    final title = (args.id == 0) ? 'Nuevo producto' : 'Editar producto';
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
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
                        controller: controllerPrecio, labelText: 'Precio'),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    InputFieldMoney(
                        controller: controllercosto, labelText: 'costo'),
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
                        sufixIcon: IconButton(
                          icon: const Icon(Icons.qr_code_scanner),
                          onPressed: () async {
                            var codigo =
                                await Navigator.pushNamed(context, 'bar-code');

                            controllerCodigoB.text = codigo.toString();
                          },
                        ),
                        controller: controllerCodigoB),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    SwitchListTile.adaptive(
                        title: const Text('Inventario'),
                        value: _valueInventario,
                        onChanged: (value) {
                          _valueInventario = value;
                          setState(() {});
                        }),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    if (_valueInventario)
                      InputField(
                        labelText: 'Cantidad:',
                        keyboardType: TextInputType.number,
                        controller: controllerCantidad,
                        readOnly: (args.id != 0),
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
                    Row(
                      children: [
                        (args.imagen == '' || args.imagen == null)
                            ? Container(
                                decoration: BoxDecoration(border: Border.all()),
                                width: windowWidth * 0.5,
                                height: windowHeight * 0.2,
                                child: (_rutaProducto.isNotEmpty)
                                    ? SizedBox(
                                        height: windowHeight * 0.15,
                                        child: Image.file(
                                          File(_rutaProducto),
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                    : SizedBox(
                                        height: windowHeight * 0.15,
                                      ),
                              )
                            : Container(
                                decoration: BoxDecoration(border: Border.all()),
                                width: windowWidth * 0.5,
                                height: windowHeight * 0.2,
                                child: FadeInImage(
                                  image: NetworkImage(args.imagen!),
                                  placeholder:
                                      const AssetImage('assets/loading.gif'),
                                ),
                              ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextButton.icon(
                              onPressed: (() {
                                fotoProducto(ImageSource.camera);
                              }),
                              icon: const Icon(Icons.camera_alt_outlined),
                              label: const Text('Tomar foto'),
                            ),
                            TextButton.icon(
                              onPressed: (() {
                                fotoProducto(ImageSource.gallery);
                              }),
                              icon: const Icon(Icons.photo),
                              label: const Text('Galería'),
                            )
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: windowHeight * 0.05,
                    ),
                    ElevatedButton(
                        onPressed: () => _guardaProducto(),
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

  _categorias() {
    var listaCat = [
      const DropdownMenuItem(
          value: '0', child: SizedBox(child: Text('Seleccione categoría')))
    ];

    for (Categoria categoria in listaCategorias) {
      listaCat.add(DropdownMenuItem(
          value: categoria.id.toString(), child: Text(categoria.categoria!)));
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

  fotoProducto(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      imagenProducto = File(pickedFile.path);
      _rutaProducto = pickedFile.path;
      setState(() {});
    }
  }
}
