import 'dart:convert';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Add this line
import 'package:mime_type/mime_type.dart'; // Add this line
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ImagenProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();
  Future<Resultado> subirImagen(File imagen) async {
    final url = Uri.parse('$baseUrl/imagen-producto');
    final mimeType = mime(imagen.path)?.split('/');
    final imageUploadRequest = http.MultipartRequest('POST', url);
    bool result = await InternetConnectionChecker().hasConnection;
    if (result == true) {
      final file = await http.MultipartFile.fromPath('file', imagen.path,
          contentType: MediaType(mimeType![0], mimeType[1]));
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
    } else {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la peticion: ';
    
    }
        return respuesta;
  }
}
