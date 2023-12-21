import 'dart:convert';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:http/http.dart' as http;

class UsuarioProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> nuevoUsuario(Usuario user, String pass) async {
    var url = Uri.parse('$baseUrl/register');

      try {
        final resp = await http.post(url, body: {
          'name': user.nombre,
          'email': user.email,
          'phone': user.telefono,
          'password': pass,
        });
        final decodedData = jsonDecode(resp.body);
        if (decodedData['status'] == 1) {
          respuesta.status = 1;
          respuesta.mensaje = decodedData['msg'];
        } else {
          respuesta.status = 0;
          respuesta.mensaje = '${decodedData['msg']}: ${decodedData['errors']}';
        }
      } catch (e) {
        respuesta.status = 0;
        respuesta.mensaje = 'Error en la petición, $e';
      };

    return respuesta;
  }

  Future<Resultado> login(String email, String pass) async {
    var url = Uri.parse('$baseUrl/login');
    try {
      final resp = await http.post(url, body: {
        'email': email,
        'password': pass,
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
        sesion.token = decodedData['Token'];
        sesion.idUsuario = decodedData['usuario'];
        sesion.idNegocio = decodedData['empresa_id'];
      } else {
        respuesta.status = 0;
        respuesta.mensaje = decodedData['msg'];
      }
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la peticion, $e';
    }
    return respuesta;
  }

  Future<Usuario> consultaUsuario() async {
    Usuario user = Usuario();
    var url = Uri.parse('$baseUrl/showU/${sesion.idUsuario}');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);

      if (decodedData['status'] == 1) {
        user.id = decodedData['data'][0]['id'];
        user.nombre = decodedData['data'][0]['name'];
        user.telefono = decodedData['data'][0]['phone'];
        user.email = decodedData['data'][0]['email'];
        user.tipoUsuario = decodedData['data'][0]['tipo_usuario'];
      } else {
        user.id = 0;
        user.nombre = decodedData['msg'];
      }
    } catch (e) {
      user.id = 0;
      user.nombre = 'Error en la consulta. $e';
    }

    return user;
  }

  Future<Resultado> editaUsuario(Usuario user, String pass, int idUser) async {
    var url = Uri.parse('$baseUrl/update/$idUser');
    try {
      final resp = await http.put(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'name': user.nombre,
        'email': user.email,
        'phone': user.telefono,
        'tipo_usuario': user.tipoUsuario,
        'password': pass,
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
      respuesta.mensaje = 'Error en la peticion, $e';
    }
    return respuesta;
  }

  Future<Resultado> eliminaUsuario(int id) async {
    var url = Uri.parse('$baseUrl/deleteU/$id');
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
      respuesta.mensaje = 'Error en la peticion, $e';
    }
    return respuesta;
  }
}
