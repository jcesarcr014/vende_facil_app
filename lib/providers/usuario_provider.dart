import 'dart:convert';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UsuarioProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> nuevoUsuario(Usuario user, String pass) async {
    var url = Uri.parse('$baseUrl/usuario-registro');

    try {
      final resp = await http.post(url, body: {
        'name': user.nombre,
        'email': user.email,
        'phone': user.telefono,
        'password': pass,
      });
      final decodedData = jsonDecode(resp.body);

      if (decodedData['status'] == 1) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', decodedData['token']);
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
        sesion.token = decodedData['token'];
        sesion.idUsuario = decodedData['usuario']['id'];
        sesion.idNegocio = decodedData['empresa_id'];
        sesion.tipoUsuario = decodedData['tipo_usuario'];
      } else {
        respuesta.status = 0;
        respuesta.mensaje = '${decodedData['msg']}: ${decodedData['errors']}';
      }
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la petición, $e';
    }

    return respuesta;
  }

  Future<Resultado> userInfo() async {
    var url = Uri.parse('$baseUrl/usuario-info');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      respuesta.status = 0;
      respuesta.mensaje = 'No hay token';
      return respuesta;
    }

    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
        sesion.token = token;
        sesion.idUsuario = decodedData['usuario']['id'];
        sesion.idNegocio = decodedData['empresa_id'];
        sesion.tipoUsuario = decodedData['tipo_usuario'];
        sesion.nombreUsuario = decodedData['usuario']['name'];
        sesion.email = decodedData['usuario']['email'];
        sesion.telefono = decodedData['usuario']['phone'];
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

  Future<Resultado> login(String email, String pass) async {
    var url = Uri.parse('$baseUrl/usuario-login');
    try {
      final resp = await http.post(url, body: {
        'email': email,
        'password': pass,
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', decodedData['token']);
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
        sesion.token = decodedData['token'];
        sesion.idUsuario = decodedData['usuario']['id'];
        sesion.idNegocio = decodedData['empresa_id'];
        sesion.tipoUsuario = decodedData['tipo_usuario'];
        sesion.nombreUsuario = decodedData['usuario']['name'];
        sesion.email = decodedData['usuario']['email'];
        sesion.telefono = decodedData['usuario']['phone'];
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
    var url = Uri.parse('$baseUrl/usuario/${sesion.idUsuario}');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);

      if (decodedData['status'] == 1) {
        user.id = decodedData['usuario']['id'];
        user.nombre = decodedData['usuario']['name'];
        user.telefono = decodedData['usuario']['phone'];
        user.email = decodedData['usuario']['email'];
        user.tipoUsuario = decodedData['tipo_usuario'];
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

  Future<Resultado> editaUsuario(Usuario user, int idUser) async {
    var url = Uri.parse('$baseUrl/usuario-actualizar/$idUser');
    try {
      final resp = await http.put(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'name': user.nombre,
        'phone': user.telefono,
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

  Future<Resultado> editaPassword(
      String oldPass, String newPass, int idUser) async {
    var url = Uri.parse('$baseUrl/usuario-cambiar-contrasena/$idUser');
    try {
      final resp = await http.put(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'old_pass': oldPass,
        'new_pass': newPass,
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
    var url = Uri.parse('$baseUrl/usuario-eliminar/$id');
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
