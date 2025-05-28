import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

class VariablesProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> variablesConfiguracion() async {
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
          listaVariables.add(variable);
        }
        VariableConf.asignarVariablesGlobales(listaVariables);
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

  Future<Resultado> modificarVariable(int id, String valor) async {
    var url = Uri.parse('$baseUrl/variable');

    try {
      final resp = await http.put(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'id_variable': id.toString(),
        'valor': valor.toString(),
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
        listaVariables.clear();
        for (int x = 0; x < decodedData['variables'].length; x++) {
          VariableConf variable = VariableConf(
            id: decodedData['variables'][x]['id'],
            nombre: decodedData['variables'][x]['nombre'],
            valor: decodedData['variables'][x]['valor'],
          );
          listaVariables.add(variable);
        }
        VariableConf.asignarVariablesGlobales(listaVariables);
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
