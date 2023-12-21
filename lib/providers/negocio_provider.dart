import 'dart:convert';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:http/http.dart' as http;

class NegocioProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> nuevoNegocio(Negocio negocio) async {
    var url = Uri.parse('$baseUrl/companies');
    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'user_id': negocio.idUsuario.toString(),
        'nombre_negocio': negocio.nombreNegocio,
        'direccion': negocio.direccion,
        'rfc': negocio.rfc,
        'telefono': negocio.telefono,
        'razon_social': negocio.razonSocial,
      });
      final decodedData = jsonDecode(resp.body);

      if (decodedData['status'] == 1) {
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
        sesion.idNegocio = decodedData['empresa_id'];
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

  Future<Negocio> consultaNegocio() async {
    Negocio negocio = Negocio();
    var url = Uri.parse('$baseUrl/companies/${sesion.idNegocio}');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);

      if (decodedData['status'] == 1) {
        negocio.id = sesion.idNegocio;
        negocio.nombreNegocio = decodedData['data']['nombre_negocio'];
        negocio.razonSocial = decodedData['data']['razon_social'];
        negocio.rfc = decodedData['data']['rfc'];
        negocio.direccion = decodedData['data']['direccion'];
        negocio.telefono = decodedData['data']['telefono'];
      } else {
        negocio.id = 0;
        negocio.nombreNegocio = decodedData['msg'];
      }
    } catch (e) {
      negocio.id = 0;
      negocio.nombreNegocio = 'Error en la petición. $e';
    }

    return negocio;
  }

  Future<Resultado> editaNegocio(Negocio negocio) async {
    var url = Uri.parse('$baseUrl/companies/${sesion.idNegocio}');
    try {
      final resp = await http.put(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'user_id': negocio.idUsuario.toString(),
        'nombre_negocio': negocio.nombreNegocio,
        'direccion': negocio.direccion,
        'rfc': negocio.rfc,
        'telefono': negocio.telefono,
        'razon_social': negocio.razonSocial,
      });

      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
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

  Future<Resultado> eliminaNegocio() async {
    var url = Uri.parse('$baseUrl/destoyCo/${sesion.idNegocio}');
    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });

      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
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
}
