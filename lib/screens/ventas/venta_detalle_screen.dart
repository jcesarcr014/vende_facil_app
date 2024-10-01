// ignore_for_file: dead_code, prefer_final_fields, depend_on_referenced_packages, null_check_always_fails

import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/providers.dart';
import 'package:vende_facil/providers/ticket_provider.dart';
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
  String _valueIdcliente = listaClientes
      .firstWhere((cliente) => cliente.nombre == 'Público en general')
      .id
      .toString();
  double descuento = 0.0;
  double restate = 0.0;
  int idcliente = 0;
  int idDescuento = 0;
  bool _valuePieza = false;
  final cantidadControllers = TextEditingController();
  Descuento descuentoSeleccionado =
      Descuento(id: -1, valor: 0.00, nombre: '', tipoValor: 0, valorPred: 0);

  final TicketProvider ticketProvider = TicketProvider();
  final NegocioProvider negocioProvider = NegocioProvider();
  List<Producto> listaProductosCotizaciones = [];

  final cantidadConttroller = TextEditingController();

  @override
  void initState() {
    _actualizaTotalTemporal();
    listaDescuentos;
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
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'home');
              },
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 8),
            const Text('Detalle de venta'),
          ],
        ),
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
                  SizedBox(
                    height: windowHeight * 0.03,
                  ),
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
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SwitchListTile.adaptive(
                      title: const Text('Tipo de venta:'),
                      subtitle: Text(_valuePieza ? 'Domicilio' : 'Tienda'),
                      value: _valuePieza,
                      onChanged: (value) {
                        _valuePieza = value;
                        setState(() {
                          _actualizaTotalTemporal();
                        });
                      },
                    ),
                  ),
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
                              VentaCabecera venta = VentaCabecera(
                                idCliente: int.parse(_valueIdcliente),
                                subtotal: subTotalItem,
                                idDescuento: idDescuento,
                                descuento: descuento,
                                total: totalVentaTemporal,
                              );
                              Navigator.pushNamed(context, 'venta',
                                  arguments: venta);
                              setState(() {});
                            },
                            child: SizedBox(
                              height: windowHeight * 0.1,
                              width: windowWidth * 0.6,
                              child: Center(
                                child: Text(
                                  'Cobrar   \$${totalVentaTemporal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )),
                        const SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              _validaApartado();
                            },
                            child: SizedBox(
                              height: windowHeight * 0.07,
                              width: windowWidth * 0.6,
                              child: const Center(
                                child: Text(
                                  'Apartar',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
      for (Producto prod in listaProductosSucursal) {
        if (prod.id == item.idArticulo) {
          prod.costo = item.totalItem;
          prod.cantidad = item.cantidad;
          if (!listaProductosCotizaciones.any((p) => p.id == prod.id)) {
            listaProductosCotizaciones.add(prod);
          }
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
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: Tooltip(
                              message: 'Editar Cantidad',
                              child: IconButton(
                                key: ValueKey<double>(item.cantidad),
                                onPressed: item.totalItem > 0.00
                                    ? () {
                                        setState(() {
                                          cantidadControllers.text =
                                              '${item.cantidad}';
                                        });
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              content: Row(
                                                children: [
                                                  const Flexible(
                                                    child: Text(
                                                      'Cantidad :',
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: windowWidth * 0.05,
                                                  ),
                                                  Flexible(
                                                    child: InputField(
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .words,
                                                      controller:
                                                          cantidadControllers,
                                                      keyboardType: TextInputType
                                                          .number, // This will show the numeric keyboard
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    if (cantidadControllers
                                                            .text.isEmpty ||
                                                        double.parse(
                                                                cantidadControllers
                                                                    .text) <=
                                                            0) {
                                                      mostrarAlerta(
                                                          context,
                                                          "AVISO",
                                                          "valor invalido");
                                                    } else {
                                                      if (double.parse(
                                                              cantidadControllers
                                                                  .text) >
                                                          prod.disponibleInv!) {
                                                        cantidadControllers
                                                                .text =
                                                            '${item.cantidad}';
                                                        mostrarAlerta(
                                                            context,
                                                            "AVISO",
                                                            "Nose puede agregar mas articulos de este producto :${prod.producto}, Productos Disponibles: ${prod.disponibleInv} ");
                                                      } else {
                                                        item.cantidad =
                                                            double.parse(
                                                                cantidadControllers
                                                                    .text);
                                                        _actualizaTotalTemporal();
                                                        cantidadControllers
                                                                .text =
                                                            '${item.cantidad}';
                                                      }
                                                    }
                                                  },
                                                  child: const Text('Aceptar '),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('Cancelar'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    : null,
                                icon: const Icon(Icons.edit),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                            width: windowWidth * 0.15,
                            child: Text(
                              '  ${item.cantidad} ',
                              textAlign: TextAlign.center,
                            )),
                        // SizedBox(
                        //     width: windowWidth * 0.1,
                        //     child: IconButton(
                        //         onPressed: () {
                        //             var catidad = item.cantidad + 1;

                        //             if (catidad > prod.disponibleInv!) {
                        //               mostrarAlerta(context, "AVISO",
                        //                   "Nose puede agregar mas articulos de este producto ");
                        //             } else {
                        //               item.cantidad++;
                        //               // item.subTotalItem =
                        //               //     item.precioPublico * item.cantidad;
                        //               // item.totalItem =
                        //               //     item.subTotalItem - item.descuento;
                        //               _actualizaTotalTemporal();
                        //             }
                        //         },
                        //         icon: const Icon(Icons.add_circle_outline))),
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
    setState(() {});
    return productos;
  }

  _validaApartado() {
    apartadoValido = true;
    double numArticulos = 0;
    for (ItemVenta articuloTemporal in ventaTemporal) {
      if (articuloTemporal.apartado == false) {
        apartadoValido = false;
        mostrarAlerta(context, 'ERROR',
            'El articulo nose puede apartar. Para modificar este valor, ve a Productos -> Editar producto.');

        return;
      } else {
        numArticulos = numArticulos + articuloTemporal.cantidad;
      }
    }
    if (double.parse(listaVariables[1].valor!) < numArticulos) {
      apartadoValido = false;
      mostrarAlerta(context, 'ERROR',
          'Superas la cantidad de artículos que se pueden apartar. Para modificar este valor, ve a Configuración -> Ajustes apartado.');
      return;
    }
    if (apartadoValido) {
      ApartadoCabecera apartado = ApartadoCabecera(
        clienteId: int.parse(_valueIdcliente),
        subtotal: subTotalItem,
        descuentoId: idDescuento,
        descuento: descuento,
        total: totalVentaTemporal,
      );
      Navigator.pushNamed(context, 'apartado', arguments: apartado);
    } else {
      mostrarAlerta(
          context, 'ERROR', 'Todos los articulos deben ser apartables.');
    }
  }

  _removerItemTemporal(ItemVenta item) {
    setState(() {
      ventaTemporal.remove(item);
      _actualizaTotalTemporal();
    });
  }

  _actualizaTotalTemporal() {
    var aplica = listaVariables
        .firstWhere((variables) => variables.nombre == "aplica_mayoreo");
    totalVentaTemporal = 0;
    subTotalItem = 0;
    descuento = 0;
    if (_valuePieza == true) {
      for (ItemVenta item in ventaTemporal) {
        totalVentaTemporal += item.cantidad * item.precioPublico;
        subTotalItem += item.cantidad * item.precioPublico;
        item.totalItem = item.cantidad * item.precioPublico;
      }
    } else {
      for (ItemVenta item in ventaTemporal) {
        if (aplica.valor == "0") {
          totalVentaTemporal += item.cantidad * item.precioPublico;
          subTotalItem += item.cantidad * item.precioPublico;
          item.totalItem = item.cantidad * item.precioPublico;
          descuento += item.descuento;
        } else {
          if (item.cantidad >= double.parse(listaVariables[3].valor!)) {
            totalVentaTemporal += item.cantidad * item.preciomayoreo;
            subTotalItem += item.cantidad * item.preciomayoreo;
            item.totalItem = item.cantidad * item.preciomayoreo;
            descuento += item.descuento;
          } else {
            totalVentaTemporal += item.cantidad * item.precioPublico;
            subTotalItem += item.cantidad * item.precioPublico;
            item.totalItem = item.cantidad * item.precioPublico;
            descuento += item.descuento;
          }
        }
      }
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
          descuentoSeleccionado = Descuento(
              id: -1, valor: 0.00, nombre: '', tipoValor: 0, valorPred: 0);
        } else {
          descuentoSeleccionado = listaDescuentos
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
                _valuePieza = false;
              });
            } else {
              setState(() {
                idDescuento = descuentoSeleccionado.id!;
                descuento = 0.00;
                descuento = descuentoSeleccionado.valor!;
                totalVentaTemporal = subTotalItem;
                totalVentaTemporal =
                    totalVentaTemporal - descuentoSeleccionado.valor!;
                _valuePieza = false;
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
    List<DropdownMenuItem> listaClien = [];
    for (Cliente cliente in listaClientes) {
      if (cliente.nombre == 'Público en general') {
        listaClien.add(DropdownMenuItem(
            value: cliente.id.toString(),
            child: const Text('Público en general')));
      }
    }

    for (Cliente cliente in listaClientes) {
      if (cliente.nombre != 'Público en general') {
        listaClien.add(DropdownMenuItem(
            value: cliente.id.toString(), child: Text(cliente.nombre!)));
      }
    }
    if (_valueIdcliente.isEmpty) {
      _valueIdcliente = listaClientes
          .firstWhere((cliente) => cliente.nombre == 'Público en general')
          .id
          .toString();
    }
    return DropdownButton(
      items: listaClien,
      isExpanded: true,
      value: _valueIdcliente,
      onChanged: (value) {
        _valueIdcliente = value!;
        setState(() {
          var clienteseleccionado = listaClientes.firstWhere(
              (cliente) => cliente.id == int.parse(_valueIdcliente));
          if (clienteseleccionado.distribuidor == 1) {
            setState(() {
              totalVentaTemporal = 0.00;
              for (ItemVenta item in ventaTemporal) {
                totalVentaTemporal = item.cantidad * item.preciodistribuidor;
                subTotalItem = totalVentaTemporal;
              }
              _valuePieza = false;
              if (descuentoSeleccionado.valorPred == 0) {
                if (descuentoSeleccionado.tipoValor == 1) {
                  setState(() {
                    idDescuento = descuentoSeleccionado.id!;
                    descuento = 0.00;
                    descuento = descuentoSeleccionado.valor!;
                    totalVentaTemporal = subTotalItem;
                    descuento = (totalVentaTemporal * descuento) / 100;
                    totalVentaTemporal = totalVentaTemporal - descuento;
                    _valuePieza = false;
                  });
                } else {
                  setState(() {
                    idDescuento = descuentoSeleccionado.id!;
                    descuento = 0.00;
                    descuento = descuentoSeleccionado.valor!;
                    totalVentaTemporal = subTotalItem;
                    totalVentaTemporal =
                        totalVentaTemporal - descuentoSeleccionado.valor!;
                    _valuePieza = false;
                  });
                }
              } else {
                _alertadescuento(descuentoSeleccionado);
              }
            });
          } else {
            setState(() {
              totalVentaTemporal = 0.00;
              for (ItemVenta item in ventaTemporal) {
                totalVentaTemporal = item.cantidad * item.precioPublico;
                subTotalItem = totalVentaTemporal;
              }
              _valuePieza = false;
              if (descuentoSeleccionado.valorPred == 0) {
                if (descuentoSeleccionado.tipoValor == 1) {
                  setState(() {
                    idDescuento = descuentoSeleccionado.id!;
                    descuento = 0.00;
                    descuento = descuentoSeleccionado.valor!;
                    totalVentaTemporal = subTotalItem;
                    descuento = (totalVentaTemporal * descuento) / 100;
                    totalVentaTemporal = totalVentaTemporal - descuento;
                    _valuePieza = false;
                  });
                } else {
                  setState(() {
                    idDescuento = descuentoSeleccionado.id!;
                    descuento = 0.00;
                    descuento = descuentoSeleccionado.valor!;
                    totalVentaTemporal = subTotalItem;
                    totalVentaTemporal =
                        totalVentaTemporal - descuentoSeleccionado.valor!;
                    _valuePieza = false;
                  });
                }
              } else {
                _alertadescuento(descuentoSeleccionado);
              }
            });
          }
        });
      },
    );
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
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: cantidadConttroller,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                double cantidad =
                    double.tryParse(cantidadConttroller.text) ?? -1;

                // Validar que la cantidad no sea menor que cero ni mayor que totalVentaTemporal
                if (cantidad < 0) {
                  mostrarAlerta(
                      context, "error", 'La cantidad no puede ser menor a 0');
                } else if (cantidad > totalVentaTemporal) {
                  mostrarAlerta(
                      context,"error",'La cantidad no puede ser mayor al total de la venta');
                } else {
                  Navigator.pop(context);

                  // Aplicar descuento
                  if (descuentos.tipoValor == 1) {
                    setState(() {
                      idDescuento = descuentos.id!;
                      descuento = (totalVentaTemporal * cantidad) / 100;
                      totalVentaTemporal = totalVentaTemporal - descuento;
                      _valuePieza = false;
                    });
                  } else {
                    setState(() {
                      idDescuento = descuentos.id!;
                      descuento = cantidad;
                      totalVentaTemporal = totalVentaTemporal - descuento;
                      _valuePieza = false;
                    });
                  }
                }
              },
              child: const Text('Aceptar'),
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
}
