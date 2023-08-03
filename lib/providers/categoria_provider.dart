import 'dart:convert';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:http/http.dart' as http;

class CategoriaProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> nuevaCategoria(Categoria categoria) async {
    var url = Uri.parse('$baseUrl/categories');
    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'categoria': categoria.categoria,
        'color': categoria.idColor.toString(),
        'empresa_id': sesion.idNegocio.toString(),
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
      } else {
        respuesta.status = 0;
        respuesta.mensaje = decodedData['msg'];
      }
    } catch (_) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la peticion, verifique su conexión';
    }

    return respuesta;
  }

  Future<Resultado> listarCategorias() async {
    listaCategorias.clear();
    var url = Uri.parse('$baseUrl/listarC/${sesion.idNegocio}');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      Map decodedData = jsonDecode(resp.body);

      if (decodedData['status'] == 1) {
        for (int x = 0; x < decodedData['data'].length; x++) {
          Categoria catTemporal = Categoria();

          catTemporal.id = decodedData["data"][x]["id"];
          catTemporal.categoria = decodedData["data"][x]["categoria"];
          catTemporal.idColor = decodedData["data"][x]["color"];
          listaCategorias.add(catTemporal);
        }
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

  Future<Categoria> consultaGategoria(int idCat) async {
    Categoria categoria = Categoria();
    var url = Uri.parse('$baseUrl/categories/$idCat');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);

      if (decodedData['status'] == 1) {
        categoria.id = decodedData['data'][0]['id'];
        categoria.categoria = decodedData['data'][0]['categoria'];
        categoria.idColor = decodedData['data'][0]['color'];
      } else {
        categoria.id = 0;
        categoria.categoria = decodedData['msg'];
      }
    } catch (e) {
      categoria.id = 0;
      categoria.categoria = 'Error en la petición. $e';
    }

    return categoria;
  }

  Future<Resultado> editaCategoria(Categoria categoria) async {
    var url = Uri.parse('$baseUrl/categories/${categoria.id}');
    try {
      final resp = await http.put(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'categoria': categoria.categoria,
        'color': categoria.idColor.toString(),
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

  Future<Resultado> eliminaCategoria(int idCat) async {
    var url = Uri.parse('$baseUrl/destoyC/$idCat');
    try {
      final resp = await http.put(url, headers: {
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
