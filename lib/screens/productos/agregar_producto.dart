// ignore_for_file: unrelated_type_equality_checks, avoid_print, prefer_final_fields
import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/screens/productos/qr_scanner_screen.dart'; // Asumo que esta pantalla existe
import 'package:vende_facil/widgets/widgets.dart';
import 'package:flutter/services.dart';

class AgregaProductoScreen extends StatefulWidget {
  const AgregaProductoScreen({super.key});

  @override
  State<AgregaProductoScreen> createState() => _AgregaProductoScreenState();
}

class _AgregaProductoScreenState extends State<AgregaProductoScreen> {
  final _articulosProvider = ArticuloProvider();
  final _categoriasProvider = CategoriaProvider();
  final _controllerProducto = TextEditingController();
  final _controllerDescripcion = TextEditingController();
  final _controllerPrecio = TextEditingController();
  final _controllercosto = TextEditingController();
  final _controllerClave = TextEditingController();
  final _controllerCodigoB = TextEditingController();
  final _controllerCantidad = TextEditingController();
  final _controllerprecioMayoreo = TextEditingController();
  final _controllerPrecioDirecto = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String _textLoading = '';
  String _valueIdCategoria = '0';
  bool _valuePieza = true;
  // final bool _valueInventario = true; // No parece usarse para lógica condicional crítica
  bool _valueApartado = false;

  Producto _args = Producto(id: 0); // Producto que se está editando o creando
  String? _rutaOrigen; // Para saber de dónde se llamó esta pantalla

  bool _camposHanCambiado =
      false; // Para detectar si hubo cambios en modo edición

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _procesarArgumentosYCargarDatos();
    });
  }

  Future<void> _procesarArgumentosYCargarDatos() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _textLoading = 'Cargando datos...';
    });

    await _categoriasProvider.listarCategorias();

    if (!mounted) return;

    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs != null) {
      if (routeArgs is Map<String, dynamic>) {
        if (routeArgs.containsKey('producto') &&
            routeArgs['producto'] is Producto) {
          _args = routeArgs['producto'] as Producto;
        }
        // _rutaOrigen ya no es tan crucial para la lógica de pop si siempre hacemos pop con resultado
        // pero puede ser útil para debug o lógica muy específica si se necesita.
        // _rutaOrigen = routeArgs['origen_pantalla'] as String?;
      } else if (routeArgs is Producto) {
        _args = routeArgs;
      }
    }

    _poblarCamposConArgs(); // Esta función llena los controllers
    _registrarListenersDeCambios();

    if (mounted) {
      setState(() {
        _isLoading = false;
        _textLoading = '';
      });
    }
  }

  void _poblarCamposConArgs() {
    if (_args.id != 0) {
      // Estamos editando
      _controllerProducto.text = _args.producto ?? '';
      _controllerDescripcion.text = _args.descripcion ?? '';
      _controllerPrecio.text = (_args.precioPublico ?? 0.0).toStringAsFixed(2);
      _controllercosto.text = (_args.costo ?? 0.0).toStringAsFixed(2);
      _controllerprecioMayoreo.text =
          (_args.precioMayoreo ?? 0.0).toStringAsFixed(2);
      _controllerPrecioDirecto.text =
          (_args.precioDist ?? 0.0).toStringAsFixed(2);
      _controllerClave.text = _args.clave ?? '';
      _controllerCodigoB.text = _args.codigoBarras ?? '';
      _controllerCantidad.text =
          (_args.cantidad ?? 0).toStringAsFixed(_args.unidad == "1" ? 0 : 3);
      _valueIdCategoria = _args.idCategoria?.toString() ?? '0';
      _valuePieza = _args.unidad == "1";
      _valueApartado = _args.apartado == 1;
    } else {
      // Nuevo producto
      _controllerClave.text = _generaCodigo();
      // Valores por defecto para nuevo producto (opcional)
      _controllerPrecio.text = '0.00';
      _controllercosto.text = '0.00';
      _controllerprecioMayoreo.text = '0.00';
      _controllerPrecioDirecto.text = '0.00';
      _controllerCantidad.text = '0';
    }
  }

  void _registrarListenersDeCambios() {
    final controllers = [
      _controllerProducto,
      _controllerDescripcion,
      _controllerPrecio,
      _controllercosto,
      _controllerprecioMayoreo,
      _controllerPrecioDirecto,
      _controllerClave,
      _controllerCodigoB,
      _controllerCantidad
    ];
    for (var controller in controllers) {
      controller.addListener(_marcarCambio);
    }
    // Para los switches y dropdown, el cambio se detecta en sus onChanged
  }

  void _marcarCambio() {
    if (!_camposHanCambiado) {
      if (mounted) setState(() => _camposHanCambiado = true);
    }
  }

  String _generaCodigo() {
    final numProductos =
        (listaProductos.length + 1).toString(); // Asume listaProductos global
    final numEmpresa = sesion.idNegocio.toString();
    final numUsuario = sesion.idUsuario.toString();
    return '${numEmpresa.padRight(6, '0')}-${numUsuario.padRight(6, '0')}-${numProductos.padLeft(8, '0')}';
  }

  bool _validarFormulario() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }
    if (_valueIdCategoria == '0') {
      if (mounted)
        mostrarAlerta(context, 'Validación', 'Debe seleccionar una categoría.');
      return false;
    }
    return true;
  }

  Future<void> _guardarProducto() async {
    if (!_validarFormulario()) return;

    if (_args.id != 0 && !_camposHanCambiado) {
      if (mounted)
        mostrarAlerta(context, 'Información', 'No se han realizado cambios.');
      // Si no hay cambios, podríamos hacer pop con false para no recargar innecesariamente.
      // Navigator.pop(context, false);
      return;
    }

    if (!mounted) return;
    setState(() {
      _textLoading = (_args.id == 0)
          ? 'Guardando producto...'
          : 'Actualizando producto...';
      _isLoading = true;
    });

    Producto productoAGuardar = Producto(
      /* ... (llenar como lo tienes) ... */
      id: _args.id,
      producto: _controllerProducto.text,
      descripcion: _controllerDescripcion.text,
      idCategoria: int.tryParse(_valueIdCategoria),
      unidad: _valuePieza ? "1" : "0",
      precioPublico:
          double.tryParse(_controllerPrecio.text.replaceAll(',', '')),
      precioMayoreo:
          double.tryParse(_controllerprecioMayoreo.text.replaceAll(',', '')),
      precioDist:
          double.tryParse(_controllerPrecioDirecto.text.replaceAll(',', '')),
      costo: double.tryParse(_controllercosto.text.replaceAll(',', '')),
      clave: _controllerClave.text,
      codigoBarras: _controllerCodigoB.text.isEmpty
          ? _controllerClave.text
          : _controllerCodigoB.text,
      cantidad: double.tryParse(_controllerCantidad.text),
      apartado: _valueApartado ? 1 : 0,
      idNegocio: _args.idNegocio ?? sesion.idNegocio,
    );

    Resultado resultadoApi;
    if (_args.id == 0) {
      // Nuevo producto
      resultadoApi = await _articulosProvider.nuevoProducto(productoAGuardar);
    } else {
      // Editar producto
      resultadoApi = await _articulosProvider.editaProducto(productoAGuardar);
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _textLoading = '';
    });

    if (resultadoApi.status == 1) {
      Navigator.pop(context, true);
      mostrarAlerta(
          context, 'Éxito', resultadoApi.mensaje ?? 'Operación exitosa');
      // Siempre hacer pop con true si la operación fue exitosa (nuevo o edición)
    } else {
      mostrarAlerta(context, 'Error',
          resultadoApi.mensaje ?? 'No se pudo completar la operación.');
      // No hacer pop si hubo un error al guardar, para que el usuario pueda intentarlo de nuevo.
    }
  }

  void _mostrarAlertaEliminar() {
    if (_args.id == 0) return; // No se puede eliminar un producto no guardado
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ATENCIÓN',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text(
            '¿Desea eliminar el producto "${_args.producto ?? "este producto"}"? Esta acción no podrá revertirse.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _eliminarProducto();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarProducto() async {
    if (_args.id == 0 || !mounted) return;
    setState(() {
      _textLoading = 'Eliminando producto...';
      _isLoading = true;
    });

    Resultado resultadoApi;
    // Asumiendo que tienes sesion.esMonoSucursal para decidir el endpoint
    // if (sesion.esMonoSucursal) {
    //   resultadoApi = await _articulosProvider.eliminarProductoUnicaSucursal(_args.id!);
    // } else {
    resultadoApi = await _articulosProvider
        .eliminaProducto(_args.id!); // O el que corresponda
    // }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _textLoading = '';
    });

    if (resultadoApi.status == 1) {
      mostrarAlerta(context, 'Éxito', resultadoApi.mensaje!);
      Navigator.pop(context,
          true); // Indicar que se eliminó y la pantalla anterior debe recargar
    } else {
      mostrarAlerta(context, 'Error', resultadoApi.mensaje!);
    }
  }

  void _onUnidadChanged(bool esPieza) {
    if (mounted) {
      setState(() {
        _valuePieza = esPieza;
        _camposHanCambiado = true;
        // Opcional: Limpiar o re-formatear controllerCantidad
        final currentQty = double.tryParse(_controllerCantidad.text);
        if (currentQty != null) {
          _controllerCantidad.text =
              currentQty.toStringAsFixed(esPieza ? 0 : 3);
        } else {
          _controllerCantidad.text = esPieza ? '0' : '0.000';
        }
      });
    }
  }

  void _onApartadoChanged(bool puedeApartar) {
    if (mounted)
      setState(() {
        _valueApartado = puedeApartar;
        _camposHanCambiado = true;
      });
  }

  void _onCategoriaChanged(String? nuevaCategoriaId) {
    if (nuevaCategoriaId != null && mounted) {
      setState(() {
        _valueIdCategoria = nuevaCategoriaId;
        _camposHanCambiado = true;
      });
    }
  }

  @override
  void dispose() {
    _controllerProducto.removeListener(_marcarCambio);
    _controllerProducto.dispose();
    _controllerDescripcion.removeListener(_marcarCambio);
    _controllerDescripcion.dispose();
    // ... dispose para todos los controllers y remover listeners ...
    _controllerPrecio.dispose();
    _controllercosto.dispose();
    _controllerClave.dispose();
    _controllerCodigoB.dispose();
    _controllerCantidad.dispose();
    _controllerprecioMayoreo.dispose();
    _controllerPrecioDirecto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String title = (_args.id == 0)
        ? 'Nuevo Producto'
        : 'Editar: ${_args.producto ?? "Producto"}';

    return PopScope(
      canPop: !_camposHanCambiado
          ? false
          : true, // Prevenir pop si hay cambios sin guardar
      onPopInvoked: (bool didPop) async {
        // Hacerla async
        if (didPop)
          return; // Si se permitió el pop (ej. canPop = true), no hacer nada más

        if (_camposHanCambiado) {
          final debeSalir = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Cambios sin guardar'),
              content: const Text('¿Desea salir sin guardar los cambios?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar')),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Salir')),
              ],
            ),
          );
          if (debeSalir == true && mounted) {
            Navigator.pop(context,
                false); // Salir e indicar que no hubo cambios guardados
          }
        } else {
          Navigator.pop(context, false); // No hubo cambios, simplemente pop
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          // Quitar el leading automático para controlar la navegación con PopScope y actions
          automaticallyImplyLeading: false,
          elevation: 2,
          actions: [
            if (_args.id != 0)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _mostrarAlertaEliminar,
                tooltip: 'Eliminar producto',
              ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Cerrar',
              onPressed: () {
                // Simular un intento de pop para activar onPopInvoked si hay cambios
                Navigator.maybePop(context);
              },
            ),
          ],
        ),
        body: _isLoading ? _buildLoadingIndicator() : _buildForm(),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    /* ... (igual que antes) ... */
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _textLoading.isNotEmpty ? _textLoading : 'Cargando...',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    /* ... (igual que antes, usando los controllers y _value... del state) ... */
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        onChanged:
            _marcarCambio, // Detectar cambios en cualquier campo del form
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

  // Los _build...Card y _buildFormField se mantienen iguales,
  // pero el _buildUnidadSelector y _buildCategoriaSelector deben llamar a _onUnidadChanged y _onCategoriaChanged
  // y el SwitchListTile para Apartado a _onApartadoChanged.

  Widget _buildUnidadSelector() {
    return Container(
      /* ... (estilo como antes) ... */
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile.adaptive(
        title: const Text('Unidad de venta:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(_valuePieza ? 'Por piezas' : 'Por kilogramo/metro/litro',
            style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        value: _valuePieza,
        onChanged: _onUnidadChanged, // LLAMAR A LA FUNCIÓN
        activeColor: Colors.blue,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildInventarioCard() {
    // ... (otros campos)
    //   _buildFormField(
    //     labelText: 'Cantidad:',
    //     // ...
    //   ),
    // const SizedBox(height: 16),
    // Container( // Para el Switch de Apartado
    //   child: SwitchListTile.adaptive(
    //     title: const Text('Se puede apartar'),
    //     value: _valueApartado,
    //     onChanged: _onApartadoChanged, // LLAMAR A LA FUNCIÓN
    //      // ...
    //   ),
    // ),
    // ]
    // }
    // Asegúrate de pegar el widget _buildInventarioCard completo como lo tenías,
    // solo modificando el onChanged del SwitchListTile de apartado.
    // Yo solo mostré la parte relevante.
    // EL RESTO DE LOS WIDGETS _build...Card, _buildSectionTitle, _buildFormField, _buildActionButton
    // SE MANTIENEN IGUAL A COMO LOS TENÍAS EN TU CÓDIGO ORIGINAL.
    // La función _categorias() también debe modificarse para usar _onCategoriaChanged.
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
              // Este es el campo Cantidad
              labelText: 'Cantidad:',
              keyboardType:
                  TextInputType.numberWithOptions(decimal: !_valuePieza),
              controller: _controllerCantidad,
              icon: Icons.production_quantity_limits_outlined,
              required: true,
              inputFormatters: [
                if (_valuePieza)
                  FilteringTextInputFormatter.digitsOnly
                else
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'La cantidad es requerida';
                if (double.tryParse(value) == null)
                  return 'Ingrese un valor numérico válido';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Container(
              // Para el Switch de Apartado
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile.adaptive(
                title: const Text('Se puede apartar',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  _valueApartado
                      ? 'Los clientes podrán apartar este producto'
                      : 'Los clientes no podrán apartar este producto',
                  style: TextStyle(
                      fontSize: 12,
                      color: _valueApartado ? Colors.blue : Colors.grey),
                ),
                value: _valueApartado,
                onChanged: _onApartadoChanged, // LLAMAR A LA FUNCIÓN
                activeColor: Colors.blue,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categorias() {
    List<DropdownMenuItem<String>> listaCat = [
      const DropdownMenuItem(value: '0', child: Text('Seleccione categoría'))
    ];
    if (listaCategorias.isNotEmpty) {
      for (Categoria categoria in listaCategorias) {
        listaCat.add(DropdownMenuItem(
          value: categoria.id.toString(),
          child: Text(categoria.categoria ?? 'Categoría s/n',
              overflow: TextOverflow.ellipsis),
        ));
      }
    }
    bool valorValido = listaCat.any((item) => item.value == _valueIdCategoria);
    if (!valorValido) _valueIdCategoria = '0';

    return DropdownButton<String>(
      items: listaCat,
      isExpanded: true,
      value: _valueIdCategoria,
      underline: Container(),
      onChanged: _onCategoriaChanged, // LLAMAR A LA FUNCIÓN
    );
  }

  // Debes pegar aquí tus implementaciones de _buildInformacionBasicaCard, _buildPreciosCard,
  // _buildCodigosCard, _buildCategoriaSelector, _buildSectionTitle, _buildFormField, _buildActionButton
  // tal como las tenías, solo asegurándote que los onChanged de los switches y dropdowns
  // llamen a las nuevas funciones _onUnidadChanged, _onApartadoChanged, _onCategoriaChanged.
  // Ya modifiqué _buildUnidadSelector, _buildInventarioCard (para el switch de apartado), y _categorias.
  // El resto de _buildFormField y _buildActionButton no necesitan cambios en su estructura interna.
  // Lo importante es la lógica en initState, _guardarProducto, _eliminarProducto, y el PopScope.
  Widget _buildInformacionBasicaCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
                'Información Básica', Icons.inventory_2_outlined, Colors.blue),
            const SizedBox(height: 24),
            _buildFormField(
              labelText: 'Nombre del producto:',
              textCapitalization: TextCapitalization.sentences,
              controller: _controllerProducto,
              icon: Icons.shopping_bag_outlined,
              required: true,
              validator: (value) => value == null || value.isEmpty
                  ? 'El nombre es requerido'
                  : null,
            ),
            const SizedBox(height: 16),
            _buildFormField(
              labelText: 'Descripción:',
              textCapitalization: TextCapitalization.sentences,
              controller: _controllerDescripcion,
              icon: Icons.description_outlined,
              required: true,
              maxLines: 3,
              validator: (value) => value == null || value.isEmpty
                  ? 'La descripción es requerida'
                  : null,
            ),
            const SizedBox(height: 16),
            _buildCategoriaSelector(),
            const SizedBox(height: 16),
            _buildUnidadSelector(), // Ya modificado para usar _onUnidadChanged
          ],
        ),
      ),
    );
  }

  Widget _buildPreciosCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
                'Precios', Icons.attach_money_outlined, Colors.green),
            const SizedBox(height: 24),
            _buildFormField(
                labelText: 'Costo:',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                controller: _controllercosto,
                icon: Icons.receipt_outlined,
                required: true,
                prefixText: '\$ ',
                validator: (v) =>
                    (double.tryParse(v?.replaceAll(',', '') ?? "") == null)
                        ? "Inválido"
                        : null),
            const SizedBox(height: 16),
            _buildFormField(
                labelText: 'Precio público:',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                controller: _controllerPrecio,
                icon: Icons.point_of_sale_outlined,
                required: true,
                prefixText: '\$ ',
                validator: (v) =>
                    (double.tryParse(v?.replaceAll(',', '') ?? "") == null)
                        ? "Inválido"
                        : null),
            const SizedBox(height: 16),
            _buildFormField(
                labelText: 'Precio mayoreo:',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                controller: _controllerprecioMayoreo,
                icon: Icons.store_outlined,
                required: true,
                prefixText: '\$ ',
                validator: (v) =>
                    (double.tryParse(v?.replaceAll(',', '') ?? "") == null)
                        ? "Inválido"
                        : null),
            const SizedBox(height: 16),
            _buildFormField(
                labelText: 'Precio distribuidor:',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                controller: _controllerPrecioDirecto,
                icon: Icons.local_shipping_outlined,
                required: true,
                prefixText: '\$ ',
                validator: (v) =>
                    (double.tryParse(v?.replaceAll(',', '') ?? "") == null)
                        ? "Inválido"
                        : null),
          ],
        ),
      ),
    );
  }

  Widget _buildCodigosCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Códigos e Identificación',
                Icons.qr_code_outlined, Colors.purple),
            const SizedBox(height: 24),
            _buildFormField(
                labelText: 'Clave:',
                controller: _controllerClave,
                icon: Icons.key_outlined,
                readOnly: true,
                filled: true),
            const SizedBox(height: 16),
            _buildFormField(
              labelText: 'Código de barras:',
              controller: _controllerCodigoB,
              icon: Icons.qr_code_scanner_outlined,
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner_outlined),
                onPressed: () async {
                  final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => QRScannerScreen()));
                  if (result != null && mounted)
                    setState(() => _controllerCodigoB.text = result);
                },
                tooltip: 'Escanear código',
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
        const Text('Categoría: *',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.category_outlined, size: 20, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                  child:
                      _categorias()), // Ya modificado para usar _onCategoriaChanged
            ],
          ),
        ),
        // La validación del dropdown se hace en _validarFormulario o con el validator del DropdownButtonFormField
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 24)),
        const SizedBox(width: 12),
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            borderSide: const BorderSide(width: 1)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        filled: readOnly || filled,
        fillColor: readOnly || filled ? Colors.grey[100] : null,
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading
            ? null
            : _guardarProducto, // Deshabilitar si está cargando
        icon: const Icon(Icons.save_outlined),
        label: Text(_args.id == 0 ? 'Guardar Producto' : 'Actualizar Producto'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
} // Fin de _AgregaProductoScreenState
