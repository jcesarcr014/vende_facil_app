import 'dart:convert';

import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:http/http.dart' as http;

class VentasProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> guardarVenta(VentaCabecera venta) async {
    var url = Uri.parse('$baseUrl/ventas/${sesion.idNegocio}');
    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'usuario_id': sesion.idUsuario.toString(),
        'cliente_id': venta.idCliente.toString(),
        'subtotal': venta.subtotal!.toStringAsFixed(2),
        'descuento_id': venta.idDescuento.toString(),
        'descuento': venta.descuento!.toStringAsFixed(2),
        'total': venta.total!.toStringAsFixed(2),
        'pago_efectivo': venta.importeEfectivo!.toStringAsFixed(2),
        'pago_tarjeta': venta.importeTarjeta!.toStringAsFixed(2),
        'sucursal_id': sesion.idSucursal.toString(),
      });

      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
        respuesta.id = decodedData['venta_id'];
        respuesta.folio = decodedData['folio'];
      } else {
        respuesta.status = 0;
        respuesta.mensaje = decodedData['msg'];
      }
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la peticion. $e';
    }
    return respuesta;
  }

  Future<Resultado> guardarVentaDetalle(VentaDetalle venta) async {
    if (venta.idDesc != 0) {
      var descue = listaDescuentos
          .firstWhere((descuento) => descuento.id == venta.idDesc)
          .valor;
      venta.cantidadDescuento = (venta.total! * descue! / 100);
      venta.total = venta.total! - venta.cantidadDescuento!;
    }
    var url = Uri.parse('$baseUrl/ventas-detalle/${venta.idVenta}');
    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'producto_id': venta.idProd.toString(),
        'cantidad': venta.cantidad.toString(),
        'precio': venta.precio.toString(),
        'subtotal': venta.subtotal.toString(),
        'descuento': venta.cantidadDescuento.toString(),
        'total': venta.total.toString(),
        'descuento_id': venta.idDesc.toString(),
        'id_sucursal': venta.id_sucursal.toString(),
      });

      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
        respuesta.id = decodedData['venta_id'];
      } else {
        respuesta.status = 0;
        respuesta.mensaje = decodedData['msg'];
      }
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la peticion. $e';
    }

    return respuesta;
  }

  Future<Resultado> listarventas() async {
    listaVentaCabecera.clear();
    var url = Uri.parse('$baseUrl/ventas/${sesion.idNegocio}');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        for (int x = 0; x < decodedData['data'].length; x++) {
          VentaCabecera ventasCabezera = VentaCabecera();
          ventasCabezera.id = decodedData['data'][x]['id'];
          ventasCabezera.negocioId = decodedData['data'][x]['negocio_id'];
          ventasCabezera.usuarioId = decodedData['data'][x]['usuario_id'];
          ventasCabezera.idCliente = decodedData['data'][x]['cliente_id'];
          ventasCabezera.folio = decodedData['data'][x]['folio'];
          ventasCabezera.subtotal =
              double.parse(decodedData['data'][x]['subtotal']);
          ventasCabezera.idDescuento = decodedData['data'][x]['descuento_id'];
          ventasCabezera.descuento =
              double.parse(decodedData['data'][x]['descuento']);
          ventasCabezera.total = double.parse(decodedData['data'][x]['total']);
          ventasCabezera.importeEfectivo =
              double.parse(decodedData['data'][x]['pago_efectivo']);
          ventasCabezera.importeTarjeta =
              double.parse(decodedData['data'][x]['pago_tarjeta']);
          ventasCabezera.cancelado =
              int.parse(decodedData['data'][x]['cancelado']);
          ventasCabezera.fecha_venta = decodedData['data'][x]['fecha_venta'];
          ventasCabezera.fecha_cancelacion =
              decodedData['data'][x]['fecha_cancelacion'];
          listaVentaCabecera.add(ventasCabezera);
        }
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
      } else {
        respuesta.status = 0;
        respuesta.mensaje = decodedData['msg'];
      }
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la peticion: $e';
    }
    return respuesta;
  }

  Future<Resultado> consultarventa(int idVenta) async {
    listaVentaCabecera2.clear();
    listaVentadetalles.clear();
    var url = Uri.parse('$baseUrl/venta/$idVenta');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        VentaCabecera ventasCabezera = VentaCabecera();
        ventasCabezera.id = decodedData['venta'][0]['id'];
        ventasCabezera.negocioId = decodedData['venta'][0]['negocio_id'];
        ventasCabezera.usuarioId = decodedData['venta'][0]['usuario_id'];
        ventasCabezera.idCliente = decodedData['venta'][0]['cliente_id'];
        ventasCabezera.folio = decodedData['venta'][0]['folio'];
        ventasCabezera.subtotal =
            double.parse(decodedData['venta'][0]['subtotal']);
        ventasCabezera.idDescuento = decodedData['venta'][0]['descuento_id'];
        ventasCabezera.descuento =
            double.parse(decodedData['venta'][0]['descuento']);
        ventasCabezera.total = double.parse(decodedData['venta'][0]['total']);
        ventasCabezera.importeEfectivo =
            double.parse(decodedData['venta'][0]['pago_efectivo']);
        ventasCabezera.importeTarjeta =
            double.parse(decodedData['venta'][0]['pago_tarjeta']);
        ventasCabezera.fecha_venta = decodedData['venta'][0]['fecha_venta'];
        ventasCabezera.fecha_cancelacion =
            decodedData['venta'][0]['fecha_cancelacion'];
        ventasCabezera.cancelado =
            int.parse(decodedData['venta'][0]['cancelado']);
        ventasCabezera.nombreCliente =
            decodedData['venta'][0]['cliente_nombre'];
        listaVentaCabecera2.add(ventasCabezera);
        for (int x = 0; x < decodedData['detalles'].length; x++) {
          VentaDetalle ventasDetalle = VentaDetalle();
          ventasDetalle.id = decodedData['detalles'][x]['id'];
          ventasDetalle.idVenta = decodedData['detalles'][x]['venta_id'];
          ventasDetalle.idProd = decodedData['detalles'][x]['producto_id'];
          ventasDetalle.cantidad =
              double.parse(decodedData['detalles'][x]['cantidad']);
          ventasDetalle.precio =
              double.parse(decodedData['detalles'][x]['precio']);
          ventasDetalle.cantidadDescuento =
              double.parse(decodedData['detalles'][x]['descuento']);
          ventasDetalle.total =
              double.parse(decodedData['detalles'][x]['total']);
          ventasDetalle.subtotal =
              double.parse(decodedData['detalles'][x]['subtotal']);
          ventasDetalle.nombreProducto = decodedData['detalles'][x]['producto'];
          listaVentadetalles.add(ventasDetalle);
        }
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
      } else {
        respuesta.status = 0;
        respuesta.mensaje = decodedData['msg'];
      }
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la peticion: $e';
    }
    return respuesta;
  }

  Future<Resultado> consultarVentasFecha(String inicio, String finalF) async {
    listaVentaCabecera.clear();
    var url = Uri.parse(
        '$baseUrl/reporte-fecha-general/$inicio/$finalF/${sesion.idNegocio}');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        for (int x = 0; x < decodedData['data'].length; x++) {
          VentaCabecera ventasCabezera = VentaCabecera();
          ventasCabezera.id = decodedData['data'][x]['id'];
          ventasCabezera.usuarioId = decodedData['data'][x]['usuario_id'];
          ventasCabezera.name = decodedData['data'][x]['name'];
          ventasCabezera.tipo_movimiento =
              decodedData['data'][x]['tipo_movimiento'];
          ventasCabezera.importeEfectivo =
              double.parse(decodedData['data'][x]['monto_efectivo']);
          ventasCabezera.importeTarjeta =
              double.parse(decodedData['data'][x]['monto_tarjeta']);
          ventasCabezera.total = double.parse(decodedData['data'][x]['total']);
          ventasCabezera.fecha_venta = decodedData['data'][x]['fecha'];
          listaVentaCabecera.add(ventasCabezera);
        }
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
      } else {
        respuesta.status = 0;
        respuesta.mensaje = decodedData['msg'];
      }
    } catch (e) {
      respuesta.status = 0;

      respuesta.mensaje = 'Error en la peticion: $e';
    }
    return respuesta;
  }

  Future<Resultado> consultarVentasFechaUsuario(
      String inicio, String finalF, String usuario) async {
    listaVentaCabecera.clear();
    var url = Uri.parse(
        '$baseUrl/reporte-fecha-usuario/$inicio/$finalF/${sesion.idNegocio}/$usuario');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        for (int x = 0; x < decodedData['data'].length; x++) {
          VentaCabecera ventasCabezera = VentaCabecera();
          ventasCabezera.id = decodedData['data'][x]['id'];
          ventasCabezera.usuarioId = decodedData['data'][x]['usuario_id'];
          ventasCabezera.name = decodedData['data'][x]['name'];
          ventasCabezera.tipo_movimiento =
              decodedData['data'][x]['tipo_movimiento'];
          ventasCabezera.importeEfectivo =
              double.parse(decodedData['data'][x]['monto_efectivo']);
          ventasCabezera.importeTarjeta =
              double.parse(decodedData['data'][x]['monto_tarjeta']);
          ventasCabezera.total = double.parse(decodedData['data'][x]['total']);
          ventasCabezera.fecha_venta = decodedData['data'][x]['fecha'];
          listaVentaCabecera.add(ventasCabezera);
        }
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
      } else {
        respuesta.status = 0;
        respuesta.mensaje = decodedData['msg'];
      }
    } catch (e) {
      respuesta.status = 0;

      respuesta.mensaje = 'Error en la peticion: $e';
    }
    return respuesta;
  }
}
