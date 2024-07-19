// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps

import 'dart:convert';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:http/http.dart' as http;

class NegocioProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> nuevoNegocio(Negocio negocio) async {
    var url = Uri.parse('$baseUrl/negocio/${sesion.idUsuario}');
    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
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
    var url = Uri.parse('$baseUrl/negocio/${sesion.idUsuario}');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);

      if (decodedData['status'] == 1) {
        negocio.id = sesion.idNegocio;
        negocio.nombreNegocio = decodedData['data'][0]['nombre_negocio'];
        negocio.razonSocial = decodedData['data'][0]['razon_social'];
        negocio.rfc = decodedData['data'][0]['rfc'];
        negocio.direccion = decodedData['data'][0]['direccion'];
        negocio.telefono = decodedData['data'][0]['telefono'];
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
    var url = Uri.parse('$baseUrl/negocio/${sesion.idNegocio}');
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

  Future<Resultado> deleteSUcursal(Sucursale sucur) async {
    var url = Uri.parse('$baseUrl/sucursal/${sucur.id}');
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

  Future<Resultado> deleteEmpleadoSUcursal(idE, idS) async {
    var url = Uri.parse('$baseUrl/sucursales-empleados/${idS}/${idE}');
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

  Future<Resultado> editarSUcursal(Sucursale sucur) async {
    var url = Uri.parse('$baseUrl/sucursal/${sucur.id}');
    try {
      final resp = await http.put(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'negocio_id': sucur.negocioId!.toString(),
        'nombre_sucursal': sucur.nombreSucursal,
        'direccion': sucur.direccion,
        'telefono': sucur.telefono,
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

  Future<Resultado> addSucursalEmpleado(SucursalEmpleado sucur) async {
    var url = Uri.parse('$baseUrl/sucursales-empleados');
    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'id_negocio': sesion.idNegocio.toString(),
        'id_propietario': sesion.idUsuario.toString(),
        'id_empleado': sucur.empleadoId.toString(),
        'id_sucursal': sucur.sucursalId.toString(),
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

  Future<Resultado> addSucursal(Sucursale sucur) async {
    var url = Uri.parse('$baseUrl/sucursal/${sesion.idUsuario}');
    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'negocio_id': sesion.idNegocio!.toString(),
        'nombre_sucursal': sucur.nombreSucursal,
        'direccion': sucur.direccion,
        'telefono': sucur.telefono,
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

  Future<Resultado> getlistaSucursales() async {
    listaSucursales.clear();
    var url = Uri.parse('$baseUrl/sucursal/${sesion.idNegocio}');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
        for (int i = 0; i < decodedData['data'].length; i++) {
          Sucursale Surcusal = Sucursale();
          Surcusal.id = decodedData['data'][i]['id'];
          Surcusal.negocioId = decodedData['data'][i]['negocio_id'];
          Surcusal.nombreSucursal = decodedData['data'][i]['nombre_sucursal'];
          Surcusal.direccion = decodedData['data'][i]['direccion'];
          Surcusal.telefono = decodedData['data'][i]['telefono'];
          listaSucursales.add(Surcusal);
        }
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

  Future<Resultado> getlistaempleadosEnsucursales() async {
    listasucursalEmpleado.clear();
    var url = Uri.parse('$baseUrl/sucursales-empleados/${sesion.idNegocio}');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
        for (int i = 0; i < decodedData['data'].length; i++) {
          SucursalEmpleado Surcusalempleado = SucursalEmpleado();
          Surcusalempleado.id = decodedData['data'][i]['id'];
          Surcusalempleado.negocioId = decodedData['data'][i]['negocio_id'];
          Surcusalempleado.sucursalId = decodedData['data'][i]['usuario_id'];
          Surcusalempleado.usuarioId = decodedData['data'][i]['sucursal_id'];
          Surcusalempleado.name = decodedData['data'][i]['name'];
          listasucursalEmpleado.add(Surcusalempleado);
        }
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
