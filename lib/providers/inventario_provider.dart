import 'dart:convert';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:http/http.dart' as http;

class InventarioProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> guardar(Existencia inventario) async {
    var url = Uri.parse('$baseUrl/inventories');
    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'empresa_id': sesion.idNegocio.toString(),
        'articulo_id': inventario.idArticulo.toString,
        'cantidad': inventario.cantidad.toString,
        'apartado': inventario.apartado.toString,
        'disponibles': inventario.disponible.toString,
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

  Future<Resultado> listar() async {
    inventario.clear();
    var url = Uri.parse('$baseUrl/listarI/${sesion.idNegocio}');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        for (int x = 0; x < decodedData['data'].length; x++) {
          Existencia productoTemp = Existencia();
          productoTemp.id = decodedData['data'][x]['id'];
          productoTemp.idArticulo = decodedData['data'][x]['articulo_id'];
          productoTemp.cantidad = decodedData['data'][x]['cantidad'];
          productoTemp.apartado = decodedData['data'][x]['apartado'];
          productoTemp.disponible = decodedData['data'][x]['disponibles'];
          inventario.add(productoTemp);
        }
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

  Future<Resultado> mostrar(int idInventario) async {
    inventario.clear();
    var url = Uri.parse('$baseUrl/inventories/$idInventario');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        for (int x = 0; x < decodedData['data'].length; x++) {
          Existencia productoTemp = Existencia();
          productoTemp.id = decodedData['data'][x]['id'];
          productoTemp.idArticulo = decodedData['data'][x]['articulo_id'];
          productoTemp.cantidad = decodedData['data'][x]['cantidad'];
          productoTemp.apartado = decodedData['data'][x]['apartado'];
          productoTemp.disponible = decodedData['data'][x]['disponibles'];
          inventario.add(productoTemp);
        }
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

  Future<Resultado> editar(Existencia existencia) async {
    var url = Uri.parse('$baseUrl/inventories/${existencia.id}');
    try {
      final resp = await http.put(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'empresa_id': sesion.idNegocio,
        'articulo_id': existencia.idArticulo,
        'cantidad': existencia.cantidad,
        'apartado': existencia.apartado,
        'disponibles': existencia.disponible,
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
}
