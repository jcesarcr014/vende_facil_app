import 'dart:convert';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime_type/mime_type.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class TicketProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> saveLogo(File imagen) async {
    final url = Uri.parse('$baseUrl/logo-ticket');
    final mimeType = mime(imagen.path)?.split('/');
    final imageUploadRequest = http.MultipartRequest('POST', url);
    bool result = await InternetConnectionChecker().hasConnection;

    if(!result) {
      respuesta.status = 0;
      respuesta.mensaje = 'Verifique su conexión a internter';
      return respuesta;
    }

    final file = await http.MultipartFile.fromPath('file', imagen.path, contentType: MediaType(mimeType![0], mimeType[1]));
    imageUploadRequest.files.add(file);
    imageUploadRequest.fields['negocio_id'] = sesion.idNegocio.toString();
    imageUploadRequest.headers['Authorization'] = 'Bearer ${sesion.token}';
    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);
    final json = jsonDecode(resp.body);

    if (json['status'] == 1) {
      respuesta.status = 1;
      respuesta.mensaje = json['msg'];
      respuesta.url = json['url'];
    } else {
      respuesta.status = 0;
      respuesta.mensaje = json['msg'];
    }
    
    return respuesta;
  }

  Future<Resultado> saveMessage(int negocioId, String mensaje) async {
    try {
      final url = Uri.parse('$baseUrl/mensaje-ticket');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${sesion.token}',
        },
        body: {
          'negocio_id': negocioId.toString(),
          'mensaje': mensaje,
        }
      );
      final responseJson = jsonDecode(response.body);

      if(responseJson["status"] != 1) {
        respuesta.status = 0;
        respuesta.mensaje = responseJson["msg"];
        return respuesta;
      }

      respuesta.status = 1;
      respuesta.mensaje = responseJson["msg"];
    } catch(e) {
      respuesta.status = 0;
      respuesta.mensaje = e.toString();
    }
    return respuesta;
  }

  Future<TicketModel?> getData(String negocioId, bool? aux) async {
    final url = Uri.parse('$baseUrl/datos-ticket/$negocioId');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });

      final responseJson = jsonDecode(response.body);
      final data = responseJson["datos"];

      if (responseJson["status"] != 1 && aux == null) {
        throw 'Verifica tus datos.';
      }
      return TicketModel(
        id: data["id"],
        negocioId: data["negocio_id"],
        message: data["mensaje"],
        logo: data["logo"],
      );
    } catch (e) {
      if(aux == null) {
        throw 'Inténtalo más tarde';
      }
    }
    return null;
  }

}