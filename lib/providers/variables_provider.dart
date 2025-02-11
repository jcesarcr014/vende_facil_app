import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

class VariablesProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> variablesApartado() async {
    var url = Uri.parse('$baseUrl/variables-conf/${sesion.idNegocio}');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
        listaVariables.clear();

        for (int x = 0; x < decodedData['data'].length; x++) {
          VariableConf variable = VariableConf(
            id: decodedData['data'][x]['id'],
            nombre: decodedData['data'][x]['nombre'],
            valor: decodedData['data'][x]['valor'],
          );
          if (variable.nombre == 'empleado_cantidades') {
            globals.empleadoInvetario = variable.valor == '1' ? true : false;
          }
          listaVariables.add(variable);
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

  Future<Resultado> modificarVariables(int id, String valor) async {
    var url = Uri.parse('$baseUrl/variable/$id');
    try {
      final resp = await http.put(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'valor': valor.toString(),
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
        for (VariableConf variable in listaVariables) {
          if (variable.id == id) {
            variable.valor = valor;
          }
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
