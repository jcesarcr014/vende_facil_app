import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/widgets/widgets.dart';

class VentaDetalleScreen extends StatefulWidget {
  const VentaDetalleScreen({super.key});
  @override
  State<VentaDetalleScreen> createState() => _VentaDetalleScreenState();
}

class _VentaDetalleScreenState extends State<VentaDetalleScreen> {
  bool isLoading = false;
  String textLoading = '';
  double windowWidth = 0.0;
  double windowHeight = 0.0;
  double subTotalItem = 0.0;
  String _valueIdDescuento = '0';
  String _valueIdcliente = '0';
  double descuento = 0.0;
  double restate = 0.0;
  int idcliente = 0;
  int idDescuento = 0;
  String formattedEndDate = "";
  String formattedStartDate = "";
  DateTime now = DateTime.now();
  late DateTime _startDate;
  late DateTime _endDate;
  late DateFormat dateFormatter;
  final ventaCabecera = VentasProvider();
  final apartadosCabecera = ApartadoProvider();

  final cantidadConttroller = TextEditingController();
  final totalConttroller = TextEditingController();
  final efectivoConttroller = TextEditingController();
  final tarjetaConttroller = TextEditingController();
  final cambioConttroller = TextEditingController();

  @override
  void initState() {
    _actualizaTotalTemporal();
    listaDescuentos;
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = _startDate.add(const Duration(days: 30));
    dateFormatter = DateFormat('yyyy-MM-dd');
    formattedStartDate = dateFormatter.format(_startDate);
    formattedEndDate = dateFormatter.format(_endDate);
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de venta'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () {
                initState() {
                  _actualizaTotalTemporal();
                }

                Navigator.pushReplacementNamed(context, 'home');
              },
              icon: const Icon(Icons.arrow_back)),
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
              padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.0),
              child: Column(
                children: [
                  SizedBox(
                    height: windowHeight * 0.02,
                  ),
                  Column(children: _listaTemporal()),
                  const SizedBox(height: 0.5),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    SizedBox(width: windowWidth * 0.1),
                    SizedBox(
                      width: windowWidth * 0.2,
                      child: const Text(
                        'Subtotal ',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: windowWidth * 0.5),
                    SizedBox(
                      width: windowWidth * 0.2,
                      child: Text(
                        '\$${subTotalItem.toStringAsFixed(2)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 0.5),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    SizedBox(width: windowWidth * 0.1),
                    SizedBox(
                      width: windowWidth * 0.2,
                      child: const Text(
                        'Descuento ',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: windowWidth * 0.1),
                    Expanded(
                      child: _descuentos(),
                    ),
                    SizedBox(width: windowWidth * 0.1),
                    SizedBox(
                        width: windowWidth * 0.2,
                        child: Text(
                          '\$${descuento.toStringAsFixed(2)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )),
                  ]),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    SizedBox(width: windowWidth * 0.1),
                    SizedBox(
                      width: windowWidth * 0.2,
                      child: const Text(
                        'Total ',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: windowWidth * 0.5),
                    SizedBox(
                        width: windowWidth * 0.2,
                        child: Text(
                          '\$${totalVentaTemporal.toStringAsFixed(2)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )),
                  ]),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    SizedBox(width: windowWidth * 0.1),
                    SizedBox(
                      width: windowWidth * 0.2,
                      child: const Text(
                        'Selecione el  cliente',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: windowWidth * 0.1),
                    Expanded(
                      child: _clientes(),
                    ),
                    SizedBox(width: windowWidth * 0.1),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    SizedBox(width: windowWidth * 0.1),
                    SizedBox(
                      width: windowWidth * 0.2,
                      height: windowHeight * 0.1,
                    ),
                  ]),
                  Center(
                    child: Column(
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              totalConttroller.text =
                                  totalVentaTemporal.toStringAsFixed(2);
                              _alertaVenta();
                            },
                            child: SizedBox(
                              height: windowHeight * 0.1,
                              width: windowWidth * 0.6,
                              child: Center(
                                child: Text(
                                    'Cobrar \$${totalVentaTemporal.toStringAsFixed(2)}'),
                              ),
                            )),
                        const SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              totalConttroller.text =
                                  totalVentaTemporal.toStringAsFixed(2);
                              _alertaApartados();
                            },
                            child: SizedBox(
                              height: windowHeight * 0.07,
                              width: windowWidth * 0.6,
                              child: const Center(
                                child: Text('Apartar'),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              )),
    );
  }

  _listaTemporal() {
    List<Widget> productos = [];
    for (ItemVenta item in ventaTemporal) {
      for (Producto prod in listaProductos) {
        if (prod.id == item.idArticulo) {
          productos.add(Dismissible(
              key: Key(item.idArticulo.toString()),
              onDismissed: (direction) {
                _removerItemTemporal(item);
              },
              background: Container(
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: windowWidth * 0.3,
                      child: Text(
                        '${prod.producto} ',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: windowWidth * 0.1,
                          child: IconButton(
                            onPressed: item.totalItem > 0.00
                                ? () {
                                    item.cantidad--;
                                    item.subTotalItem =
                                        item.precio * item.cantidad;
                                    item.totalItem =
                                        item.subTotalItem - item.descuento;
                                    _actualizaTotalTemporal();
                                  }
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                        ),
                        SizedBox(
                            width: windowWidth * 0.15,
                            child: Text(
                              '  ${item.cantidad} ',
                              textAlign: TextAlign.center,
                            )),
                        SizedBox(
                            width: windowWidth * 0.1,
                            child: IconButton(
                                onPressed: () {
                                  item.cantidad++;
                                  item.subTotalItem =
                                      item.precio * item.cantidad;
                                  item.totalItem =
                                      item.subTotalItem - item.descuento;
                                  _actualizaTotalTemporal();
                                },
                                icon: const Icon(Icons.add_circle_outline))),
                      ],
                    ),
                    Text('\$${item.totalItem.toStringAsFixed(2)}')
                  ],
                ),
                subtitle: const Divider(),
              )));
        }
      }
    }
    return productos;
  }

  _removerItemTemporal(ItemVenta item) {
    setState(() {
      ventaTemporal.remove(item);
      _actualizaTotalTemporal();
    });
  }

  _actualizaTotalTemporal() {
    totalVentaTemporal = 0;
    subTotalItem = 0;
    descuento = 0;
    for (ItemVenta item in ventaTemporal) {
      totalVentaTemporal += item.totalItem;
      subTotalItem += item.subTotalItem;
      descuento += item.descuento;
    }
    setState(() {});
  }

  _descuentos() {
    var listades = [
      const DropdownMenuItem(
        value: '0',
        child: SizedBox(child: Text('Ninguno')),
      )
    ];
    for (Descuento descuentos in listaDescuentos) {
      listades.add(DropdownMenuItem(
          value: descuentos.id.toString(), child: Text(descuentos.nombre!)));
    }
    if (_valueIdDescuento.isEmpty) {
      _valueIdDescuento = '0';
    }
    return DropdownButton(
      items: listades,
      isExpanded: true,
      value: _valueIdDescuento,
      onChanged: (value) {
        _valueIdDescuento = value!;
        if (value == "0") {
          setState(() {});
          descuento = 0.00;
          totalVentaTemporal = subTotalItem;
        } else {
          Descuento descuentoSeleccionado = listaDescuentos
              .firstWhere((descuento) => descuento.id.toString() == value);
          if (descuentoSeleccionado.valorPred == 0) {
            if (descuentoSeleccionado.tipoValor == 1) {
              setState(() {
                idDescuento = descuentoSeleccionado.id!;
                descuento = 0.00;
                descuento = descuentoSeleccionado.valor!;
                totalVentaTemporal = subTotalItem;
                descuento = (totalVentaTemporal * descuento) / 100;
                totalVentaTemporal = totalVentaTemporal - descuento;
              });
            } else {
              setState(() {
                idDescuento = descuentoSeleccionado.id!;
                descuento = 0.00;
                descuento = descuentoSeleccionado.valor!;
                totalVentaTemporal = subTotalItem;
                totalVentaTemporal =
                    totalVentaTemporal - descuentoSeleccionado.valor!;
              });
            }
          } else {
            _alertadescuento(descuentoSeleccionado);
          }
        }
      },
    );
  }

  _clientes() {
    var listaClien = [
      const DropdownMenuItem(
        value: '0',
        child: SizedBox(child: Text('Ninguno')),
      )
    ];
    for (Cliente cliente in listaClientes) {
      listaClien.add(DropdownMenuItem(
          value: cliente.id.toString(), child: Text(cliente.nombre!)));
    }
    if (_valueIdcliente.isEmpty) {
      _valueIdcliente = '0';
    }
    return DropdownButton(
      items: listaClien,
      isExpanded: true,
      value: _valueIdcliente,
      onChanged: (value) {
        _valueIdcliente = value!;
        if (value == "0") {
          setState(() {});
        } else {
          idcliente = listaClientes
              .firstWhere((cliente) => cliente.id.toString() == value)
              .id!;
        }
        setState(() {});
      },
    );
  }

  _compra() {
    VentaCabecera venta = VentaCabecera(
      idCliente: idcliente,
      subtotal: subTotalItem,
      idDescuento: idDescuento,
      descuento: descuento,
      total: totalVentaTemporal,
      importeEfectivo: efectivoConttroller.text.isNotEmpty
          ? double.parse(efectivoConttroller.text)
          : 0.00,
      importeTarjeta: tarjetaConttroller.text.isNotEmpty
          ? double.parse(tarjetaConttroller.text)
          : 0.00,
    );
    ventaCabecera.guardarVenta(venta).then((value) {
      if (value.status == 1) {
        for (ItemVenta item in ventaTemporal) {
          VentaDetalle ventaDetalle = VentaDetalle(
            idVenta: value.id,
            idProd: item.idArticulo,
            cantidad: item.cantidad,
            precio: item.precio,
            idDesc: idDescuento,
            cantidadDescuento: descuento,
            total: item.totalItem,
            subtotal: item.subTotalItem,
          );
          ventaCabecera.guardarVentaDetalle(ventaDetalle).then((value) {
            if (value.status == 1) {
            } else {}
          });
        }
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              content: const Text('Venta realizada con exito'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    totalConttroller.clear();
                    efectivoConttroller.clear();
                    tarjetaConttroller.clear();
                    cambioConttroller.clear();
                    ventaTemporal.clear();
                    _actualizaTotalTemporal();
                    _valueIdDescuento = '0';
                    _valueIdcliente = '0';
                    idcliente = 0;
                    idDescuento = 0;
                    descuento = 0.00;
                    totalVentaTemporal = 0.00;
                    Navigator.pop(context);
                  },
                  child: const Text('Aceptar '),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              content: Text('${value.mensaje}'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Aceptar '),
                ),
              ],
            );
          },
        );
      }
    });
  }

  _apartadoCabecera() {
    ApartadoCabecera apartado = ApartadoCabecera(
      clienteId: idcliente,
      subtotal: subTotalItem,
      descuentoId: idDescuento,
      descuento: descuento,
      total: totalVentaTemporal,
      pagoEfectivo: efectivoConttroller.text.isNotEmpty
          ? double.parse(efectivoConttroller.text)
          : 0.00,
      pagoTarjeta: tarjetaConttroller.text.isNotEmpty
          ? double.parse(tarjetaConttroller.text)
          : 0.00,
      fechaApartado: formattedStartDate.toString(),
      fechaVencimiento: formattedEndDate.toString(),
      saldoPendiente: restate,
      anticipo: efectivoConttroller.text.isNotEmpty
          ? double.parse(efectivoConttroller.text)
          : 0.00,
    );
    apartadosCabecera.guardaApartado(apartado).then((value) {
      if (value.status == 1) {
        for (ItemVenta item in ventaTemporal) {
          ApartadoDetalle ventaDetalle = ApartadoDetalle(
            apartadoId: value.id,
            productoId: item.idArticulo,
            cantidad: item.cantidad,
            precio: item.precio,
            descuentoId: idDescuento,
            descuento: descuento,
            total: item.totalItem,
            subtotal: item.subTotalItem,
          );
          apartadosCabecera.guardaApartadoDetalle(ventaDetalle).then((value) {
            if (value.status == 1) {
            } else {}
          });
        }
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              content: const Text('Venta realizada con exito'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    totalConttroller.clear();
                    efectivoConttroller.clear();
                    tarjetaConttroller.clear();
                    cambioConttroller.clear();
                    ventaTemporal.clear();
                    _actualizaTotalTemporal();
                    _valueIdDescuento = '0';
                    _valueIdcliente = '0';
                    idcliente = 0;
                    idDescuento = 0;
                    descuento = 0.00;
                    totalVentaTemporal = 0.00;
                    Navigator.pop(context);
                  },
                  child: const Text('Aceptar '),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              content: Text('${value.mensaje}'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Aceptar '),
                ),
              ],
            );
          },
        );
      }
    });
  }

  _alertadescuento(Descuento descuentos) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Row(
            children: [
              const Flexible(
                child: Text(
                  'Cantidad :',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              SizedBox(
                width: windowWidth * 0.05,
              ),
              Flexible(
                child: InputField(
                  textCapitalization: TextCapitalization.words,
                  controller: cantidadConttroller,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (descuentos.tipoValor == 1) {
                  double.parse(cantidadConttroller.text);
                  setState(() {
                    idDescuento = descuentos.id!;
                    descuento = 0.00;
                    descuento = double.parse(cantidadConttroller.text);
                    totalVentaTemporal = subTotalItem;
                    descuento = (totalVentaTemporal * descuento) / 100;
                    totalVentaTemporal = totalVentaTemporal - descuento;
                  });
                } else {
                  setState(() {
                    idDescuento = descuentos.id!;
                    descuento = 0.00;
                    descuento = double.parse(cantidadConttroller.text);
                    totalVentaTemporal = subTotalItem;
                    totalVentaTemporal = totalVentaTemporal - descuento;
                  });
                }
              },
              child: const Text('Aceptar '),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  _alertaVenta() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: windowHeight * 0.05),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      const Flexible(
                        child: Text(
                          'Total :',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      SizedBox(width: windowWidth * 0.05),
                      Flexible(
                        fit: FlexFit.loose,
                        child: TextFormField(
                          textCapitalization: TextCapitalization.words,
                          controller: totalConttroller,
                          enabled: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 1.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: windowHeight * 0.05),
                Container(
                  width: windowWidth * 0.9,
                  child: Row(
                    children: [
                      const Flexible(
                        child: Text(
                          'Efectivo :',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      SizedBox(width: windowWidth * 0.05),
                      Flexible(
                        fit: FlexFit.loose,
                        child: TextFormField(
                          textCapitalization: TextCapitalization.words,
                          controller: efectivoConttroller,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 1.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onChanged: (value) {
                            // Llama a la función que deseas ejecutar cuando cambie el valor del campo de entrada de efectivo
                            tuFuncion();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: windowHeight * 0.05),
                Container(
                  width: windowWidth * 0.9,
                  child: Row(
                    children: [
                      const Flexible(
                        child: Text(
                          'Tarjeta :',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      SizedBox(width: windowWidth * 0.05),
                      Flexible(
                        child: InputField(
                          textCapitalization: TextCapitalization.words,
                          controller: tarjetaConttroller,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: windowHeight * 0.05),
                SizedBox(
                  width: windowWidth * 0.9,
                  child: Row(
                    children: [
                      const Flexible(
                        child: Text(
                          'Cambio :',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      SizedBox(width: windowWidth * 0.05),
                      Flexible(
                        fit: FlexFit.loose,
                        child: TextFormField(
                          textCapitalization: TextCapitalization.words,
                          controller: cambioConttroller,
                          enabled: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 1.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (ventaTemporal.isEmpty) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        content: const Text('No hay productos en la venta'),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Aceptar '),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  double efectivo = double.parse(efectivoConttroller.text);
                  double total = double.parse(totalConttroller.text);
                  double tarjeta = double.parse(tarjetaConttroller.text);

                  double resultado = efectivo + tarjeta;
                  // ignore: avoid_print
                  print(" el dato de la suma es $resultado");
                  if (resultado >= total) {
                    _compra();
                    Navigator.pop(context);
                  } else {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          content: const Text('El efectivo es menor al total'),
                          actions: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Aceptar '),
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              },
              child: const Text('Aceptar '),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  _alertaApartados() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.all(5.0),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2015),
                            lastDate: DateTime(2100),
                            initialDateRange: DateTimeRange(
                              start: formattedStartDate.isEmpty
                                  ? DateTime.now()
                                  : _startDate,
                              end: formattedEndDate.isEmpty
                                  ? _startDate.add(const Duration(days: 30))
                                  : _endDate,
                            ),
                          );
                          if (picked != null &&
                              picked !=
                                  DateTimeRange(
                                      start: _startDate,
                                      end: formattedEndDate.isEmpty
                                          ? _startDate
                                              .add(const Duration(days: 30))
                                          : _endDate)) {
                            setState(() {
                              _startDate = picked.start;
                              _endDate = picked.end;
                              dateFormatter = DateFormat('yyyy-MM-dd');
                              formattedStartDate =
                                  dateFormatter.format(_startDate);
                              formattedEndDate = dateFormatter.format(_endDate);
                            });
                          }
                        },
                        child: Text(
                          '$formattedStartDate - $formattedEndDate',
                          style: const TextStyle(fontSize: 15.0),
                        ),
                      ),
                      const Icon(Icons.calendar_today, size: 15.0),
                    ],
                  ),
                ),
                SizedBox(height: windowHeight * 0.05),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      const Flexible(
                        child: Text(
                          'Apartado :',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      SizedBox(width: windowWidth * 0.05),
                      Flexible(
                        fit: FlexFit.loose,
                        child: TextFormField(
                          textCapitalization: TextCapitalization.words,
                          controller: totalConttroller,
                          enabled: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 1.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: windowHeight * 0.05),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      const Flexible(
                        child: Text(
                          'Total :',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      SizedBox(width: windowWidth * 0.05),
                      Flexible(
                        fit: FlexFit.loose,
                        child: TextFormField(
                          textCapitalization: TextCapitalization.words,
                          controller: totalConttroller,
                          enabled: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 1.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: windowHeight * 0.05),
                SizedBox(
                  width: windowWidth * 0.9,
                  child: Row(
                    children: [
                      const Flexible(
                        child: Text(
                          'Efectivo :',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      SizedBox(width: windowWidth * 0.05),
                      Flexible(
                        fit: FlexFit.loose,
                        child: TextFormField(
                          textCapitalization: TextCapitalization.words,
                          controller: efectivoConttroller,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 1.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onChanged: (value) {
                            tuFuncion();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: windowHeight * 0.05),
                SizedBox(
                  width: windowWidth * 0.9,
                  child: Row(
                    children: [
                      const Flexible(
                        child: Text(
                          'Tarjeta :',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      SizedBox(width: windowWidth * 0.05),
                      Flexible(
                        fit: FlexFit.loose,
                        child: TextFormField(
                          textCapitalization: TextCapitalization.words,
                          controller: tarjetaConttroller,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 1.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onChanged: (value) {
                            tuFuncion();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: windowHeight * 0.05),
                SizedBox(
                  width: windowWidth * 0.9,
                  child: Row(
                    children: [
                      const Flexible(
                        child: Text(
                          'Cambio :',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      SizedBox(width: windowWidth * 0.05),
                      Flexible(
                        fit: FlexFit.loose,
                        child: TextFormField(
                          textCapitalization: TextCapitalization.words,
                          controller: cambioConttroller,
                          enabled: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 1.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                try {
                  double efectivo = double.parse(efectivoConttroller.text);
                  double total = double.parse(totalConttroller.text);
                  double tarjeta = double.parse(tarjetaConttroller.text);

                  restate = efectivo + tarjeta;
                  restate = total - restate;
                  _apartadoCabecera();
                  Navigator.pop(context);
                } catch (e) {
                  print("Error: $e");
                }
              },
              child: const Text('Aceptar '),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  tuFuncion() {
    try {
      double total = double.parse(totalConttroller.text);
      double efectivo = double.parse(efectivoConttroller.text);
      var cambio = efectivo - total;
      if (cambio < 0) {
        cambioConttroller.text = "0.00";
      } else {
        cambioConttroller.text = cambio.toStringAsFixed(2);
      }

      setState(() {
        // Actualiza el estado
      });
    } catch (e) {}
  }

  apartadosomprobacion() {
    try {
      double total = double.parse(totalConttroller.text);
      double efectivo = double.parse(efectivoConttroller.text);
      var cambio = efectivo - total;
      if (cambio < 0) {
        cambioConttroller.text = "0.00";
      } else {
        cambioConttroller.text = cambio.toStringAsFixed(2);
      }

      setState(() {
        // Actualiza el estado
      });
    } catch (e) {
      print("Error: $e");
    }
  }
}
