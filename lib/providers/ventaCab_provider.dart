import 'dart:convert';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:http/http.dart' as http;

class VentaCabProvider {
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
        'subtotal': venta.subtotal.toStringAsFixed(2),
        'id_descuento': venta.idDescuento.toString(),
        'descuento': venta.descuento.toStringAsFixed(2),
        'total': venta.total.toStringAsFixed(2),
        'pago_efectivo': venta.importeEfectivo.toStringAsFixed(2),
        'pago_tarjeta': venta.importeTarjeta.toStringAsFixed(2),
      });
      print(resp.statusCode);
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
      print('Error en la peticion. $e');
    }

    return respuesta;
  }
  Future<Resultado> guardarVentaDetalle(VentaDetalle venta) async {
    var url = Uri.parse('$baseUrl/ventas-detalle/${sesion.idNegocio}');
    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'producto_id': sesion.idUsuario.toString(),
        'cantidad': venta.cantidad.toString(),
        'precio': venta.precio,
        'subtotal': venta.subtotal,
        'descuento': venta.cantidadDescuento,
        'total': venta.total,
        'descuento_id': venta.idDesc.toString(),
      });
      print(resp.statusCode);
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
      print('Error en la peticion. $e');
    }

    return respuesta;
  }
  Future<Resultado> listarventas() async {
    listaClientes.clear();
    var url = Uri.parse('$baseUrl/ventas/${sesion.idNegocio}');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        for (int x = 0; x < decodedData['data'].length; x++) {
          VentaCabecera clienteTemp = VentaCabecera();
          clienteTemp.id = decodedData['data'][x]['id'];
          clienteTemp.nombre = decodedData['data'][x]['nombre'];
          clienteTemp.correo = decodedData['data'][x]['email'];
          clienteTemp.telefono = decodedData['data'][x]['telefono'];
          clienteTemp.direccion = decodedData['data'][x]['direccion'];
          clienteTemp.ciudad = decodedData['data'][x]['ciudad'];
          clienteTemp.estado = decodedData['data'][x]['estado'];
          clienteTemp.cp = decodedData['data'][x]['cp'];
          clienteTemp.pais = decodedData['data'][x]['pais'];
          clienteTemp.codigoCliente = decodedData['data'][x]['codigo_cliente'];
          clienteTemp.nota = decodedData['data'][x]['nota'];
          listaClientes.add(clienteTemp);
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
