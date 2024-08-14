import 'dart:convert';
import 'package:vende_facil/mappers/sucursal_mapper.dart';
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
        sesion.nombreUsuario = decodedData['usuario']['name'];
        sesion.email = decodedData['usuario']['email'];
        sesion.telefono = decodedData['usuario']['phone'];
        suscripcionActual.id = decodedData['suscripcion']['id'];
        suscripcionActual.idUsuario =
            decodedData['suscripcion']['id_usuario_app'];
        suscripcionActual.idPlan = decodedData['suscripcion']['id_plan'];
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
        sesion.nombreUsuario = decodedData['usuario']['name'];
        if (sesion.tipoUsuario == 'P') {
          suscripcionActual.id = decodedData['suscripcion']['id'];
          suscripcionActual.idPlan = decodedData['suscripcion']['id_plan'];
          listaSucursales.clear();
          List<dynamic> sucursalesJson = decodedData['sucursales'];
          List<Sucursal> sucursales = sucursalesJson
              .map((json) => SucursalMapper.dataToSucursalModel(json))
              .toList();
          listaSucursales.addAll(sucursales);
          globals.actualizaSucursales = false;
        } else {
          globals.actualizaSucursales = false;
          sesion.idSucursal = decodedData["sucursales"];
        }
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
        if (sesion.tipoUsuario == 'P') {
          suscripcionActual.id = decodedData['suscripcion']['id'];
          suscripcionActual.idPlan = decodedData['suscripcion']['id_plan'];
          listaSucursales.clear();
          List<dynamic> sucursalesJson = decodedData['sucursales'];
          List<Sucursal> sucursales = sucursalesJson
              .map((json) => SucursalMapper.dataToSucursalModel(json))
              .toList();
          listaSucursales.addAll(sucursales);
        } else {
          sesion.idSucursal = decodedData["sucursales"];
        }
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

  Future<Resultado> editaPassword(String oldPass, String newPass) async {
    var url =
        Uri.parse('$baseUrl/usuario-cambiar-contrasena/${sesion.idUsuario}');
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

  //Empleados
  Future<Resultado> nuevoEmpleado(Usuario user, String pass) async {
    var url =
        Uri.parse('$baseUrl/empleado-registro/${sesion.idUsuario.toString()}');
    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
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
    }

    return respuesta;
  }

  Future<Resultado> obtenerUsuarios() async {
    var url = Uri.parse('$baseUrl/usuarios/${sesion.idNegocio}');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        listaUsuarios.clear();
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
        for (int x = 0; x < decodedData['data'].length; x++) {
          Usuario usuarioTemp = Usuario();
          usuarioTemp.id = decodedData['data'][x]['id'];
          usuarioTemp.nombre = decodedData['data'][x]['name'];
          usuarioTemp.email = decodedData['data'][x]['email'];
          usuarioTemp.telefono = decodedData['data'][x]['phone'];
          usuarioTemp.tipoUsuario = decodedData['data'][x]['tipo'];
          usuarioTemp.estatus = decodedData['data'][x]['estatus'];
          listaUsuarios.add(usuarioTemp);
        }
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

  Future<Resultado> obtenerEmpleados() async {
    var url = Uri.parse('$baseUrl/empleados/${sesion.idUsuario}');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        listaEmpleados.clear();
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
        for (int x = 0; x < decodedData['data'].length; x++) {
          Usuario empleadoTemp = Usuario();
          empleadoTemp.id = decodedData['data'][x]['id'];
          empleadoTemp.nombre = decodedData['data'][x]['name'];
          empleadoTemp.email = decodedData['data'][x]['email'];
          empleadoTemp.telefono = decodedData['data'][x]['phone'];
          empleadoTemp.tipoUsuario = decodedData['data'][x]['tipo'];
          empleadoTemp.estatus = decodedData['data'][x]['estatus'];
          listaEmpleados.add(empleadoTemp);
        }
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

  Future<Resultado> estatusEmpleado(int id, String estatus) async {
    var url = Uri.parse('$baseUrl/empleado-estatus/${sesion.idUsuario}');
    try {
      final resp = await http.put(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'id_usuario_empleado': id.toString(),
        'estatus': estatus,
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

  Future<Resultado> cambiaPasswordEmpleado(int idEmpleado, String pass) async {
    var url = Uri.parse('$baseUrl/empleado-contrasena/${sesion.idUsuario}');
    try {
      final resp = await http.put(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'id_usuario_empleado': idEmpleado.toString(),
        'new_pass': pass,
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

  Future<Resultado> eliminaEmpleado(int id) async {
    var url = Uri.parse('$baseUrl/empleado-eliminar/$id');
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
      respuesta.mensaje = 'Error en la peticion, $e';
    }
    return respuesta;
  }
}
