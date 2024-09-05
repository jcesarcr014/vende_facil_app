import 'dart:convert';

import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:http/http.dart' as http;

class CotizarProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> guardarCotizacion(Cotizacion cotiza) async {
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
    print(respuesta.mensaje);
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
    print(respuesta.mensaje);
    return respuesta;
  }
}
