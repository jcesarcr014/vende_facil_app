import 'package:vende_facil/models/models.dart';

class ActualizaMontos {
  void actualizaTotalVenta() {
    subtotalVT = 0.0;
    descuentoVT = 0.0;
    totalVT = 0.0;
    ahorroVT = 0.0;
    if (ventaTemporal.isEmpty) return;
    final distribuidor = clienteVentaActual.distribuidor == 1;
    final descuentoActivo = descuentoVentaActual.id != 0;

    print(' ====== descuentoVentaActual.id ${descuentoVentaActual.id} ======');
    print(' ====== descuentoActivo ${descuentoActivo} ======');

    final mayoreoActivo =
        listaVariables.firstWhere((v) => v.nombre == "aplica_mayoreo").valor ==
            '1';
    final cantidadMayoreo = int.parse(listaVariables
        .firstWhere((v) => v.nombre == 'productos_mayoreo')
        .valor!);

    for (ItemVenta item in ventaTemporal) {
      double precio = _seleccionarPrecio(item,
          distribuidor: distribuidor,
          mayoreoActivo: mayoreoActivo,
          cantidadMayoreo: cantidadMayoreo);
      item.precioUtilizado = precio;

      double descuentoAplicado =
          _calcularDescuento(item, precio, descuentoActivo: descuentoActivo);

      item.subTotalItem = item.precioPublico * item.cantidad;
      item.descuento = descuentoAplicado;
      item.totalItem = item.subTotalItem - item.descuento;

      subtotalVT += item.subTotalItem;
      descuentoVT += item.descuento;
      totalVT += item.totalItem;
      ahorroVT += ahorroVT += (item.precioPublico - precio) * item.cantidad;
    }
  }

  double _seleccionarPrecio(ItemVenta item,
      {required bool distribuidor,
      required bool mayoreoActivo,
      required int cantidadMayoreo}) {
    if (ventaDomicilio) return item.precioPublico;
    if (distribuidor) {
      return item.precioDistribuidor != 0
          ? item.precioDistribuidor
          : item.precioPublico;
    }

    if (mayoreoActivo && item.cantidad >= cantidadMayoreo) {
      return item.precioMayoreo != 0 ? item.precioMayoreo : item.precioPublico;
    }

    return item.precioPublico;
  }

  double _calcularDescuento(ItemVenta item, double precio,
      {required bool descuentoActivo}) {
    double descuento = 0.0;

    if (descuentoActivo) {
      descuento = precio * (descuentoVentaActual.valor! / 100) * item.cantidad;
    }

    return descuento;
  }
}
