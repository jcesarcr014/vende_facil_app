import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

class TicketProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> saveLogo() async {
    final url = Uri.parse('$baseUrl/logo-ticket');

    try {
      final resp = await http.post(
        url, 
        headers: {
          'Authorization': 'Bearer ${sesion.token}',
        },
      );
      final decodedData = jsonDecode(resp.body);

    } catch(e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la peticion, $e';
    }

    return respuesta;

  }
}