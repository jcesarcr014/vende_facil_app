import 'dart:convert';

import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:http/http.dart' as http;

class CotizarProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> guardarCotizacion(Cotizacion cotiza) async {
    sesion.idSucursal = 0;
    var url = Uri.parse('$baseUrl/cotizacion-cabecera/${sesion.idNegocio}');
    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'negocio_id': sesion.idNegocio.toString(),
        'sucursal_id': sesion.idSucursal.toString(),
        'usuario_id': sesion.idUsuario.toString(),
        'cliente_id': cotiza.idCliente.toString(),
        'subtotal': cotiza.subtotal!.toStringAsFixed(2),
        'descuento_id': "0",
        'descuento': "0",
        'total': cotiza.total!.toStringAsFixed(2),
        'dias_vigencia': cotiza.dias_vigentes.toString(),
      });

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
      respuesta.mensaje = 'Error en la peticion. $e';
    }
    return respuesta;
  }

  Future<Resultado> guardarCotizacionDetalle(CotizacionDetalle cotiz) async {
    var url = Uri.parse('$baseUrl/cotizacion-detalle/${cotiz.idcotizacion}');
    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'cotizacion_id': cotiz.idcotizacion.toString(),
        'producto_id': cotiz.idProd.toString(),
        'cantidad': cotiz.cantidad.toString(),
        'precio': cotiz.precio.toString(),
        'subtotal': cotiz.subtotal.toString(),
        'descuento': '0',
        'total': cotiz.total.toString(),
        'descuento_id': '0',
        'id_sucursal': cotiz.id_sucursal.toString(),
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

  Future<Resultado> listarCotizaciones(int idSucursal) async {
    listacotizacion.clear();
    var url = Uri.parse('$baseUrl/cotizacion-cabeceras/$idSucursal');
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

Future<Resultado> consultarcotizacion(int idCotizar) async {
  listacotizacionCabecera.clear();
  listacotizaciondetalles2.clear();
  var url = Uri.parse('$baseUrl/cotizacion-detalle/$idCotizar');
  try {
    final resp = await http.get(url, headers: {
      'Authorization': 'Bearer ${sesion.token}',
    });

    final decodedData = jsonDecode(resp.body);
    
    if (decodedData['status'] == 1) {
      // Accede a cotizacion como un mapa, sin índice
      Cotizacion cotizar = Cotizacion();
      cotizar.id = decodedData['cotizacion']['id'];
      cotizar.negocioId = decodedData['cotizacion']['negocio_id'];
      cotizar.id_sucursal = decodedData['cotizacion']['sucursal_id'];
      cotizar.usuarioId = decodedData['cotizacion']['usuario_id'];
      cotizar.idCliente = decodedData['cotizacion']['cliente_id'];
      cotizar.folio = decodedData['cotizacion']['folio'];
      cotizar.subtotal = double.parse(decodedData['cotizacion']['subtotal']);
      cotizar.idDescuento = decodedData['cotizacion']['descuento_id'];
      cotizar.descuento = double.parse(decodedData['cotizacion']['descuento']);
      cotizar.total = double.parse(decodedData['cotizacion']['total']);
      cotizar.venta_realizada = int.parse(decodedData['cotizacion']['venta_realizada']);
      cotizar.fecha_cotizacion = DateTime.parse(decodedData['cotizacion']['fecha_cotizacion']);
      cotizar.dias_vigentes = decodedData['cotizacion']['dias_vigencia'];
      listacotizacionCabecera.add(cotizar);

      // Procesa los detalles
      for (int x = 0; x < decodedData['detalles'].length; x++) {
        CotizacionDetalle detalleCotizar = CotizacionDetalle();
        detalleCotizar.id = decodedData['detalles'][x]['id'];
        detalleCotizar.idcotizacion = decodedData['detalles'][x]['cotizacion_id'];
        detalleCotizar.idProd = decodedData['detalles'][x]['producto_id'];
        detalleCotizar.cantidad = double.parse(decodedData['detalles'][x]['cantidad']);
        detalleCotizar.precio = double.parse(decodedData['detalles'][x]['precio']);
        detalleCotizar.subtotal = double.parse(decodedData['detalles'][x]['subtotal']);
        detalleCotizar.cantidadDescuento = double.parse(decodedData['detalles'][x]['descuento']);
        detalleCotizar.total = double.parse(decodedData['detalles'][x]['total']);
        detalleCotizar.nombreProducto = decodedData['detalles'][x]['nombre'];
        detalleCotizar.idDesc = decodedData['detalles'][x]['descuento_id'];
        listacotizaciondetalles2.add(detalleCotizar);
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

}
