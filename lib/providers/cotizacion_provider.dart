import 'dart:convert';

import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:http/http.dart' as http;

class CotizarProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> guardarCotizacionCompleta(
      Cotizacion cotiza, List<CotizacionDetalle> detalles) async {
    var url = Uri.parse('$baseUrl/cotizacion-completa');

    try {
      List<Map<String, dynamic>> detallesJson = detalles
          .map((detalle) => {
                'producto_id': detalle.idProd.toString(),
                'cantidad': detalle.cantidad.toString(),
                'precio': detalle.precio.toString(),
                'subtotal': detalle.subtotal.toString(),
                'descuento': '0',
                'total': detalle.total.toString(),
                'descuento_id': '0',
              })
          .toList();
      final data = jsonEncode({
        'negocio_id': sesion.idNegocio.toString(),
        'sucursal_id': sesion.idSucursal.toString(),
        'usuario_id': sesion.idUsuario.toString(),
        'cliente_id': cotiza.idCliente.toString(),
        'subtotal': cotiza.subtotal!.toStringAsFixed(2),
        'descuento_id': "0",
        'descuento': "0",
        'total': cotiza.total!.toStringAsFixed(2),
        'dias_vigencia': cotiza.dias_vigentes.toString(),
        'detalles': detallesJson,
      });

      final resp = await http.post(url,
          headers: {
            'Authorization': 'Bearer ${sesion.token}',
            'Content-Type': 'application/json',
          },
          body: data);

      final decodedData = jsonDecode(resp.body);

      if (decodedData['status'] == 1) {
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
        respuesta.id = decodedData['cotizacion'];
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

  Future<Resultado> cotizacionesSucursal(int idSucursal) async {
    listacotizacion.clear();
    var url = Uri.parse('$baseUrl/cotizacion-sucursal/$idSucursal');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        for (int x = 0; x < decodedData['cotizaciones'].length; x++) {
          Cotizacion cotizar = Cotizacion();
          cotizar.id = decodedData['cotizaciones'][x]['id'];
          cotizar.negocioId = decodedData['cotizaciones'][x]['negocio_id'];
          cotizar.id_sucursal = decodedData['cotizaciones'][x]['sucursal_id'];
          cotizar.usuarioId = decodedData['cotizaciones'][x]['usuario_id'];
          cotizar.idCliente = decodedData['cotizaciones'][x]['cliente_id'];
          cotizar.nombreCliente = decodedData['cotizaciones'][x]['cliente'];
          cotizar.folio = decodedData['cotizaciones'][x]['folio'];
          cotizar.subtotal =
              double.parse(decodedData['cotizaciones'][x]['subtotal']);
          cotizar.idDescuento = decodedData['cotizaciones'][x]['descuento_id'];
          cotizar.descuento =
              double.parse(decodedData['cotizaciones'][x]['descuento']);
          cotizar.total = double.parse(decodedData['cotizaciones'][x]['total']);
          cotizar.venta_realizada =
              int.parse(decodedData['cotizaciones'][x]['venta_realizada']);
          cotizar.fecha_cotizacion = DateTime.parse(
              decodedData['cotizaciones'][x]['fecha_cotizacion']);
          cotizar.fecha_vencimiento = DateTime.parse(
              decodedData['cotizaciones'][x]['fecha_vencimiento']);
          cotizar.dias_vigentes =
              decodedData['cotizaciones'][x]['dias_vigencia'];
          listacotizacion.add(cotizar);
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

  Future<Resultado> cotizacionesNegocio(int idNegocio) async {
    listacotizacion.clear();
    var url = Uri.parse('$baseUrl/cotizacion-negocio/$idNegocio');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        for (int x = 0; x < decodedData['cotizaciones'].length; x++) {
          Cotizacion cotizar = Cotizacion();
          cotizar.id = decodedData['cotizaciones'][x]['id'];
          cotizar.negocioId = decodedData['cotizaciones'][x]['negocio_id'];
          cotizar.id_sucursal = decodedData['cotizaciones'][x]['sucursal_id'];
          cotizar.usuarioId = decodedData['cotizaciones'][x]['usuario_id'];
          cotizar.idCliente = decodedData['cotizaciones'][x]['cliente_id'];
          cotizar.nombreCliente = decodedData['cotizaciones'][x]['cliente'];
          cotizar.folio = decodedData['cotizaciones'][x]['folio'];
          cotizar.subtotal =
              double.parse(decodedData['cotizaciones'][x]['subtotal']);
          cotizar.idDescuento = decodedData['cotizaciones'][x]['descuento_id'];
          cotizar.descuento =
              double.parse(decodedData['cotizaciones'][x]['descuento']);
          cotizar.total = double.parse(decodedData['cotizaciones'][x]['total']);
          cotizar.venta_realizada =
              int.parse(decodedData['cotizaciones'][x]['venta_realizada']);
          cotizar.fecha_cotizacion = DateTime.parse(
              decodedData['cotizaciones'][x]['fecha_cotizacion']);
          cotizar.fecha_vencimiento = DateTime.parse(
              decodedData['cotizaciones'][x]['fecha_vencimiento']);
          cotizar.dias_vigentes =
              decodedData['cotizaciones'][x]['dias_vigencia'];
          listacotizacion.add(cotizar);
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

  Future<Resultado> cotizacionDetalle(int idCotizar) async {
    detalleCotActual.clear();
    cotActual = Cotizacion();
    var url = Uri.parse('$baseUrl/cotizacion-detalle/$idCotizar');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });

      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        cotActual.id = decodedData['cotizacion']['id'];
        cotActual.negocioId = decodedData['cotizacion']['negocio_id'];
        cotActual.id_sucursal = decodedData['cotizacion']['sucursal_id'];
        cotActual.usuarioId = decodedData['cotizacion']['usuario_id'];
        cotActual.nombreSucursal = decodedData['cotizacion']['nombre_sucursal'];
        cotActual.dirSucursal = decodedData['cotizacion']['direccion_sucursal'];
        cotActual.telsucursal = decodedData['cotizacion']['tel_sucursal'];
        cotActual.idCliente = decodedData['cotizacion']['cliente_id'];
        cotActual.nombreCliente = decodedData['cotizacion']['cliente'];
        cotActual.folio = decodedData['cotizacion']['folio'];
        cotActual.subtotal =
            double.parse(decodedData['cotizacion']['subtotal']);
        cotActual.idDescuento = decodedData['cotizacion']['descuento_id'];
        cotActual.descuento =
            double.parse(decodedData['cotizacion']['descuento']);
        cotActual.total = double.parse(decodedData['cotizacion']['total']);
        cotActual.venta_realizada =
            int.parse(decodedData['cotizacion']['venta_realizada']);
        cotActual.fecha_cotizacion =
            DateTime.parse(decodedData['cotizacion']['fecha_cotizacion']);
        cotActual.fecha_vencimiento =
            DateTime.parse(decodedData['cotizacion']['fecha_vencimiento']);
        cotActual.dias_vigentes = decodedData['cotizacion']['dias_vigencia'];

        for (int x = 0; x < decodedData['detalles'].length; x++) {
          CotizacionDetalle detalleCotizar = CotizacionDetalle();
          detalleCotizar.id = decodedData['detalles'][x]['id'];
          detalleCotizar.idcotizacion =
              decodedData['detalles'][x]['cotizacion_id'];
          detalleCotizar.idProd = decodedData['detalles'][x]['producto_id'];
          detalleCotizar.cantidad =
              double.parse(decodedData['detalles'][x]['cantidad']);
          detalleCotizar.precio =
              double.parse(decodedData['detalles'][x]['precio']);
          detalleCotizar.subtotal =
              double.parse(decodedData['detalles'][x]['subtotal']);
          detalleCotizar.cantidadDescuento =
              double.parse(decodedData['detalles'][x]['descuento']);
          detalleCotizar.total =
              double.parse(decodedData['detalles'][x]['total']);
          detalleCotizar.nombreProducto = decodedData['detalles'][x]['nombre'];
          detalleCotizar.idDesc = decodedData['detalles'][x]['descuento_id'];
          detalleCotActual.add(detalleCotizar);
        }

        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
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

  Future<Resultado> ventaCotizacion(
      int idCotizacion, String efectivo, String tarjeta, String tipo) async {
    var url = Uri.parse('$baseUrl/cotizacion-venta');

    try {
      final resp = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${sesion.token}',
        },
        body: {
          'cotizacion_id': idCotizacion.toString(),
          'usuario_id': sesion.idUsuario,
          'pago_efectivo': efectivo,
          'pago_tarjeta': tarjeta,
          'tipo_venta': tipo
        },
      );

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
}
