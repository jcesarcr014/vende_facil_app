// ignore_for_file: unrelated_type_equality_checks, avoid_print, prefer_final_fields
import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/screens/productos/qr_scanner_screen.dart';
import 'package:vende_facil/widgets/widgets.dart';
import 'package:flutter/services.dart';

class AgregaProductoScreen extends StatefulWidget {
  const AgregaProductoScreen({super.key});

  @override
  State<AgregaProductoScreen> createState() => _AgregaProductoScreenState();
}

class _AgregaProductoScreenState extends State<AgregaProductoScreen> {
  final articulosProvider = ArticuloProvider();
  final categoriasProvider = CategoriaProvider();
  final controllerProducto = TextEditingController();
  final controllerDescripcion = TextEditingController();
  final controllerPrecio = TextEditingController();
  final controllercosto = TextEditingController();
  final controllerClave = TextEditingController();
  final controllerCodigoB = TextEditingController();
  final controllerCantidad = TextEditingController();
  final controllerprecioMayoreo = TextEditingController();
  final controllerPrecioDirecto = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String textLoading = '';
  String _valueIdCategoria = '0';
  bool firstLoad = true;
  bool _valuePieza = true;
  final bool _valueInventario = true;
  bool _valueApartado = false;
  bool _puedeGurdar = false;
  Producto producto = Producto();
  Producto args = Producto(id: 0);

  String _generaCodigo() {
    final numProductos = (listaProductos.length + 1).toString();
    final numEmpresa = sesion.idNegocio.toString();
    final numUsuario = sesion.idUsuario.toString();

    final codigo =
        '${numEmpresa.padRight(6, '0')}-${numUsuario.padRight(6, '0')}-${numProductos.padLeft(8, '0')}';

    return codigo;
  }

  _validaciones() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_valueIdCategoria == '0') {
      mostrarAlerta(context, 'ERROR', 'Debe seleccionar una categoría');
      return;
    }

    _puedeGurdar = true;
  }

  _guardaProducto() async {
    _validaciones();
    if (_puedeGurdar) {
      setState(() {
        textLoading = (args.id == 0)
            ? 'Agregando nuevo artículo'
            : 'Actualizando artículo';
        isLoading = true;
      });

      producto.cantidad = double.parse(controllerCantidad.text);
      producto.precioDist = double.parse(controllerPrecioDirecto.text);
      producto.precioMayoreo = double.parse(controllerprecioMayoreo.text);

      producto.producto = controllerProducto.text;
      producto.descripcion = controllerDescripcion.text;
      producto.idCategoria = int.parse(_valueIdCategoria);
      producto.unidad = (_valuePieza) ? '1' : '0';
      producto.precioPublico =
          double.parse(controllerPrecio.text.replaceAll(',', ''));
      producto.precioMayoreo =
          double.parse(controllerprecioMayoreo.text.replaceAll(',', ''));
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
              Navigator.pop(context);
              Navigator.popAndPushNamed(context, 'productos');
              mostrarAlerta(context, 'Éxito', value.mensaje!);
            } else {
              mostrarAlerta(context, '', value.mensaje!);
            }
          });
        }
      }
    }
  }

  _alertaEliminar() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'ATENCIÓN',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '¿Desea eliminar el artículo ${args.producto}? Esta acción no podrá revertirse.',
                  textAlign: TextAlign.center,
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar',
                    style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _eliminarProducto();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Eliminar',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
  }

  _eliminarProducto() {
    setState(() {
      textLoading = 'Eliminando artículo';
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
    controllerDescripcion.dispose();
    controllerPrecio.dispose();
    controllercosto.dispose();
    controllerClave.dispose();
    controllerCodigoB.dispose();
    controllerCantidad.dispose();
    controllerprecioMayoreo.dispose();
    controllerPrecioDirecto.dispose();
    super.dispose();
  }

  @override
  void initState() {
    textLoading = 'Cargando categorías';
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

      controllerprecioMayoreo.text = args.precioMayoreo.toString() == "null"
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
            ? args.cantidad!.toStringAsFixed(3)
            : '0.00';
      }
    } else {
      setState(() {});
    }
    final title = (args.id == 0) ? 'Nuevo producto' : 'Editar producto';

    return PopScope(
      canPop: false,
      onPopInvoked: (didpop) {
        if (args.id != 0 && !didpop) {
          Navigator.pop(context);
          Navigator.popAndPushNamed(context, 'productos');
          return;
        }

        if (!didpop) Navigator.pushReplacementNamed(context, 'products-menu');
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          automaticallyImplyLeading: false,
          elevation: 2,
          actions: [
            if (args.id != 0)
              IconButton(
                onPressed: _alertaEliminar,
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Eliminar producto',
              ),
            IconButton(
              onPressed: () {
                if (args.id != 0) {
                  Navigator.pop(context);
                  Navigator.popAndPushNamed(context, 'productos');
                } else {
                  Navigator.pushReplacementNamed(context, 'products-menu');
                }
              },
              icon: const Icon(Icons.close),
              tooltip: 'Cancelar',
            ),
          ],
        ),
        body: isLoading ? _buildLoadingIndicator() : _buildForm(),
      ),
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

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInformacionBasicaCard(),
            const SizedBox(height: 20),
            _buildPreciosCard(),
            const SizedBox(height: 20),
            _buildCodigosCard(),
            const SizedBox(height: 20),
            _buildInventarioCard(),
            const SizedBox(height: 32),
            _buildActionButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInformacionBasicaCard() {
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
              'Información Básica',
              Icons.inventory_2_outlined,
              Colors.blue,
            ),
            const SizedBox(height: 24),
            _buildFormField(
              labelText: 'Nombre del producto:',
              textCapitalization: TextCapitalization.sentences,
              controller: controllerProducto,
              icon: Icons.shopping_bag_outlined,
              required: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre del producto es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildFormField(
              labelText: 'Descripción:',
              textCapitalization: TextCapitalization.sentences,
              controller: controllerDescripcion,
              icon: Icons.description_outlined,
              required: true,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La descripción es requerida';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildCategoriaSelector(),
            const SizedBox(height: 16),
            _buildUnidadSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreciosCard() {
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
              'Precios',
              Icons.attach_money_outlined,
              Colors.green,
            ),
            const SizedBox(height: 24),
            _buildFormField(
              labelText: 'Costo:',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              controller: controllercosto,
              icon: Icons.receipt_outlined,
              required: true,
              prefixText: '\$ ',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El costo es requerido';
                }
                if (double.tryParse(value.replaceAll(',', '')) == null) {
                  return 'Ingrese un valor numérico válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildFormField(
              labelText: 'Precio público:',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              controller: controllerPrecio,
              icon: Icons.point_of_sale_outlined,
              required: true,
              prefixText: '\$ ',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El precio público es requerido';
                }
                if (double.tryParse(value.replaceAll(',', '')) == null) {
                  return 'Ingrese un valor numérico válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildFormField(
              labelText: 'Precio mayoreo:',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              controller: controllerprecioMayoreo,
              icon: Icons.store_outlined,
              required: true,
              prefixText: '\$ ',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El precio mayoreo es requerido';
                }
                if (double.tryParse(value.replaceAll(',', '')) == null) {
                  return 'Ingrese un valor numérico válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildFormField(
              labelText: 'Precio distribuidor:',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              controller: controllerPrecioDirecto,
              icon: Icons.local_shipping_outlined,
              required: true,
              prefixText: '\$ ',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El precio distribuidor es requerido';
                }
                if (double.tryParse(value.replaceAll(',', '')) == null) {
                  return 'Ingrese un valor numérico válido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodigosCard() {
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
              'Códigos e Identificación',
              Icons.qr_code_outlined,
              Colors.purple,
            ),
            const SizedBox(height: 24),
            _buildFormField(
              labelText: 'Clave:',
              controller: controllerClave,
              icon: Icons.key_outlined,
              readOnly: true,
              filled: true,
            ),
            const SizedBox(height: 16),
            _buildFormField(
              labelText: 'Código de barras:',
              controller: controllerCodigoB,
              icon: Icons.qr_code_scanner_outlined,
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner_outlined),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QRScannerScreen(),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      controllerCodigoB.text = result;
                    });
                  }
                },
                tooltip: 'Escanear código',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventarioCard() {
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
              'Inventario y Opciones',
              Icons.inventory_outlined,
              Colors.orange,
            ),
            const SizedBox(height: 24),
            _buildFormField(
              labelText: 'Cantidad:',
              keyboardType:
                  TextInputType.numberWithOptions(decimal: !_valuePieza),
              controller: controllerCantidad,
              icon: Icons.production_quantity_limits_outlined,
              required: true,
              inputFormatters: [
                if (_valuePieza)
                  FilteringTextInputFormatter.digitsOnly
                else
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La cantidad es requerida';
                }
                if (double.tryParse(value) == null) {
                  return 'Ingrese un valor numérico válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile.adaptive(
                title: const Text(
                  'Se puede apartar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _valueApartado
                      ? 'Los clientes podrán apartar este producto'
                      : 'Los clientes no podrán apartar este producto',
                  style: TextStyle(
                    fontSize: 12,
                    color: _valueApartado ? Colors.blue : Colors.grey,
                  ),
                ),
                value: _valueApartado,
                onChanged: (value) {
                  setState(() {
                    _valueApartado = value;
                  });
                },
                activeColor: Colors.blue,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriaSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categoría: *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.category_outlined, size: 20, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: _categorias(),
              ),
            ],
          ),
        ),
        if (_valueIdCategoria == '0')
          const Padding(
            padding: EdgeInsets.only(left: 12, top: 8),
            child: Text(
              'Debe seleccionar una categoría',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUnidadSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile.adaptive(
        title: const Text(
          'Unidad de venta:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _valuePieza ? 'Por piezas' : 'Por kilogramo/metro',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
        value: _valuePieza,
        onChanged: (value) {
          setState(() {
            _valuePieza = value;
            // Limpiar el campo de cantidad para que coincida con el tipo
            controllerCantidad.text = '';
          });
        },
        activeColor: Colors.blue,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
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
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    bool required = false,
    bool filled = false,
    String? prefixText,
    int maxLines = 1,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      readOnly: readOnly,
      validator: validator,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: required ? '$labelText *' : labelText,
        prefixIcon: Icon(icon, size: 20),
        prefixText: prefixText,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        filled: readOnly || filled,
        fillColor: readOnly || filled ? Colors.grey[100] : null,
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _guardaProducto,
        icon: const Icon(Icons.save_outlined),
        label: Text(args.id == 0 ? 'Guardar Producto' : 'Actualizar Producto'),
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

  Widget _categorias() {
    var listaCat = [
      const DropdownMenuItem(
        value: '0',
        child: Text('Seleccione categoría'),
      )
    ];

    if (args.id == 0) {
      for (Categoria categoria in listaCategorias) {
        listaCat.add(DropdownMenuItem(
          value: categoria.id.toString(),
          child: Text(categoria.categoria!, overflow: TextOverflow.ellipsis),
        ));
      }
    } else {
      for (Categoria categoria in listaCategorias) {
        listaCat.add(DropdownMenuItem(
          value: categoria.id.toString(),
          child: Text(categoria.categoria!, overflow: TextOverflow.ellipsis),
        ));
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
      underline: Container(),
      onChanged: (value) {
        setState(() {
          _valueIdCategoria = value!;
        });
      },
    );
  }
}
