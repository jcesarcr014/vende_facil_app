import 'package:flutter/material.dart';
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
  int idcliente = 0;
  int idDescuento = 0;
  final ventaCabecera = VentasProvider();

  final cantidadConttroller = TextEditingController();
  @override
  void initState() {
    _actualizaTotalTemporal();
    listaDescuentos;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de venta'),
        automaticallyImplyLeading: true,
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
                              _compra();
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
                            onPressed: () {},
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
      importeEfectivo: 0.00,
      importeTarjeta: 0.00,
    );
    ventaCabecera.guardarVenta(venta).then((value) {
      if (value.status == 1) {
//        ventaTemporal.clear();
//        _actualizaTotalTemporal();
//        _valueIdDescuento = '0';
//        _valueIdcliente = '0';
//        idcliente = 0;
//        idDescuento = 0;
//        descuento = 0.00;
//        totalVentaTemporal = 0.00;

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
}
