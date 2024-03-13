import 'dart:convert';
import 'package:vende_facil/app_theme.dart';
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
      });

      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
        respuesta.id = decodedData['venta_id'];
        print(respuesta.id);
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
    listaVentaCabecera.clear();
    listaVentadetalles.clear();
    var url = Uri.parse('$baseUrl/venta/$idVenta');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        VentaCabecera ventasCabezera = VentaCabecera();
        ventasCabezera.id = decodedData['venta']['id'];
        ventasCabezera.negocioId = decodedData['venta']['negocio_id'];
        ventasCabezera.usuarioId = decodedData['venta']['usuario_id'];
        ventasCabezera.idCliente = decodedData['venta']['cliente_id'];
        ventasCabezera.folio = decodedData['venta']['folio'];
        ventasCabezera.subtotal =
            double.parse(decodedData['venta']['subtotal']);
        ventasCabezera.idDescuento = decodedData['venta']['descuento_id'];
        ventasCabezera.descuento =
            double.parse(decodedData['venta']['descuento']);
        ventasCabezera.total = double.parse(decodedData['venta']['total']);
        ventasCabezera.importeEfectivo =
            double.parse(decodedData['venta']['pago_efectivo']);
        ventasCabezera.importeTarjeta =
            double.parse(decodedData['venta']['pago_tarjeta']);
        ventasCabezera.cancelado = int.parse(decodedData['venta']['cancelado']);
        ventasCabezera.fecha_venta = decodedData['venta']['fecha_venta'];
        ventasCabezera.fecha_cancelacion =
            decodedData['venta']['fecha_cancelacion'];
        listaVentaCabecera.add(ventasCabezera);
        for (int x = 0; x < decodedData['detalles'].length; x++) {
          VentaDetalle ventasDetalle = VentaDetalle();
          ventasDetalle.id = decodedData['detalles'][x]['id'];
          ventasDetalle.idVenta = decodedData['detalles'][x]['venta_id'];
          ventasDetalle.idProd = decodedData['detalles'][x]['producto_id'];
          ventasDetalle.cantidad =
              double.parse(decodedData['detalles'][x]['cantidad']);
          ventasDetalle.precio =
              double.parse(decodedData['detalles'][x]['precio']);
          ventasDetalle.idDesc = decodedData['detalles'][x]['descuento_id'];
          ventasDetalle.cantidadDescuento =
              double.parse(decodedData['detalles'][x]['descuento']);
          ventasDetalle.total =
              double.parse(decodedData['detalles'][x]['total']);
          ventasDetalle.subtotal =
              double.parse(decodedData['detalles'][x]['subtotal']);
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

  Future<Resultado> consultarVentasFecha(
      String inicio, String finalF) async {
    listaVentaCabecera.clear();
    var url =
        Uri.parse('$baseUrl/ventas-fecha/${sesion.idNegocio}/$inicio/$finalF');
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
}
