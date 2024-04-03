import 'dart:convert';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:http/http.dart' as http;

class TarjetaProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> nuevaTarjeta(TarjetaOP tarjeta) async {
    var url = Uri.parse('$baseUrl/tarjeta/${sesion.idUsuario}');

    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'numero': tarjeta.numero,
        'fechaM': tarjeta.fechaM,
        'fechaA': tarjeta.fechaA,
        'ccv': tarjeta.ccv,
        'titular': tarjeta.titular,
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

  Future<Resultado> listarTarjetas() async {
    var url = Uri.parse('$baseUrl/tarjeta/${sesion.idUsuario}');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        listaTarjetas.clear();
        for (int x = 0; x < decodedData['data'].length; x++) {
          TarjetaOP tarjetaTemp = TarjetaOP();
          tarjetaTemp.id = decodedData['data'][x]['id'];
          tarjetaTemp.numero = decodedData['data'][x]['numero'];

          listaTarjetas.add(tarjetaTemp);
        }
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
      }
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la peticion: $e';
    }
    return respuesta;
  }

  Future<Resultado> eliminarTarjeta(int idTarjeta) async {
    var url = Uri.parse('$baseUrl/tarjeta/$idTarjeta');
    try {
      final resp = await http.delete(url, headers: {
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
      respuesta.mensaje = 'Error en la peticion: $e';
    }
    return respuesta;
  }
}
