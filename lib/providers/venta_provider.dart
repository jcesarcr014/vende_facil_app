import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:http/http.dart' as http;

class VentasProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> guardarVentaCompleta(
      VentaCabecera cabecera, List<VentaDetalle> detalles) async {
    var url = Uri.parse('$baseUrl/ventas-completa/${sesion.idNegocio}');

    Map<String, dynamic> ventaData = {
      'cabecera': {
        'usuario_id': sesion.idUsuario.toString(),
        'cliente_id': cabecera.idCliente.toString(),
        'subtotal': cabecera.subtotal!.toStringAsFixed(2),
        'descuento_id': cabecera.idDescuento.toString(),
        'descuento': cabecera.descuento!.toStringAsFixed(2),
        'total': cabecera.total!.toStringAsFixed(2),
        'pago_efectivo': cabecera.importeEfectivo!.toStringAsFixed(2),
        'pago_tarjeta': cabecera.importeTarjeta!.toStringAsFixed(2),
        'tipo_venta': cabecera.tipoVenta.toString(),
        'cambio': cabecera.cambio!.toStringAsFixed(2),
        'sucursal_id': sesion.idSucursal.toString(),
      },
      'detalles': detalles.map((detalle) {
        if (detalle.idDesc != 0) {
          var descue = listaDescuentos
              .firstWhere((descuento) => descuento.id == detalle.idDesc)
              .valor;
          detalle.cantidadDescuento = (detalle.total! * descue! / 100);
          detalle.total = detalle.total! - detalle.cantidadDescuento!;
        }

        return {
          'producto_id': detalle.idProd.toString(),
          'cantidad': detalle.cantidad.toString(),
          'precio': detalle.precio.toString(),
          'subtotal': detalle.subtotal.toString(),
          'descuento': detalle.cantidadDescuento.toString(),
          'total': detalle.total.toString(),
          'descuento_id': detalle.idDesc.toString(),
          'id_sucursal': detalle.id_sucursal.toString(),
        };
      }).toList(),
    };
    try {
      final resp = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${sesion.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(ventaData),
      );
      print(jsonEncode(ventaData));
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
      respuesta.mensaje = 'Error en la petición: $e';
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
        VentaCabecera ventaCabecera = VentaCabecera();
        ventaCabecera.id = decodedData['venta'][0]['id'];
        ventaCabecera.negocioId = decodedData['venta'][0]['negocio_id'];
        ventaCabecera.usuarioId = decodedData['venta'][0]['usuario_id'];
        ventaCabecera.idCliente = decodedData['venta'][0]['cliente_id'];
        ventaCabecera.folio = decodedData['venta'][0]['folio'];
        ventaCabecera.subtotal =
            double.parse(decodedData['venta'][0]['subtotal']);
        ventaCabecera.idDescuento = decodedData['venta'][0]['descuento_id'];
        ventaCabecera.descuento =
            double.parse(decodedData['venta'][0]['descuento']);
        ventaCabecera.total = double.parse(decodedData['venta'][0]['total']);
        ventaCabecera.importeEfectivo =
            double.parse(decodedData['venta'][0]['pago_efectivo']);
        ventaCabecera.importeTarjeta =
            double.parse(decodedData['venta'][0]['pago_tarjeta']);
        ventaCabecera.cambio = double.parse(decodedData['venta'][0]['cambio']);
        ventaCabecera.fecha_venta = decodedData['venta'][0]['fecha_venta'];
        ventaCabecera.fecha_cancelacion =
            decodedData['venta'][0]['fecha_cancelacion'];
        ventaCabecera.cancelado =
            int.parse(decodedData['venta'][0]['cancelado']);
        ventaCabecera.nombreCliente = decodedData['venta'][0]['cliente_nombre'];
        listaVentaCabecera2.add(ventaCabecera);
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
