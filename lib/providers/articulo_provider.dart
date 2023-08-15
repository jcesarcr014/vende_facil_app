import 'dart:convert';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:http/http.dart' as http;

class ArticuloProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> nuevoProducto(Producto producto) async {
    var url = Uri.parse('$baseUrl/articles');
    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'empresa_id': sesion.idNegocio.toString(),
        'articulo': producto.producto,
        'categoria_id': producto.idCategoria.toString(),
        'imagen': producto.imagen,
        'unidad': producto.unidad,
        'precio': producto.precio!.toStringAsFixed(2),
        'costo': producto.costo!.toStringAsFixed(2),
        'clave': producto.clave,
        'codigo_barras': producto.codigoBarras!.padRight(13, '0'),
        'inventario': producto.inventario.toString(),
        'apartado': producto.apartado.toString(),
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

  Future<Resultado> listarProductos() async {
    listaProductos.clear();
    var url = Uri.parse('$baseUrl/listarArt/${sesion.idNegocio}');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        for (int x = 0; x < decodedData['data'].length; x++) {
          Producto productoTemp = Producto();
          productoTemp.id = decodedData['data'][x]['id'];
          productoTemp.producto = decodedData['data'][x]['articulo'];
          productoTemp.idCategoria = decodedData['data'][x]['categoria_id'];
          // productoTemp.unidad = decodedData['data'][x]['unidad'];
          // productoTemp.precio = double.parse(decodedData['data'][x]['precio']);
          // productoTemp.costo = double.parse(decodedData['data'][x]['costo']);
          // productoTemp.clave = decodedData['data'][x]['clave'];
          // productoTemp.codigoBarras = decodedData['data'][x]['codigo_barras'];
          // productoTemp.inventario =
          //     int.parse(decodedData['data'][x]['inventario']);
          // productoTemp.imagen = decodedData['data'][x]['imagen'];
          // productoTemp.apartado = int.parse(decodedData['data'][x]['apartado']);

          listaProductos.add(productoTemp);
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

  Future<Producto> consultaProducto(int idProd) async {
    Producto productoTemp = Producto();
    var url = Uri.parse('$baseUrl/articles/$idProd');

    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);

      if (decodedData['status'] == 1) {
        productoTemp.id = decodedData['data']['id'];
        productoTemp.producto = decodedData['data']['articulo'];
        productoTemp.idCategoria = decodedData['data']['categoria_id'];
        productoTemp.unidad = decodedData['data']['unidad'];
        productoTemp.precio = double.parse(decodedData['data']['precio']);
        productoTemp.costo = double.parse(decodedData['data']['costo']);
        productoTemp.clave = decodedData['data']['clave'];
        productoTemp.codigoBarras = decodedData['data']['codigo_barras'];
        productoTemp.inventario = decodedData['data']['inventario'];
        productoTemp.imagen = decodedData['data']['imagen'];
        productoTemp.apartado = decodedData['data']['apartado'];
        listaProductos.add(productoTemp);
      } else {
        productoTemp.id = 0;
        productoTemp.producto = decodedData['msg'];
      }
    } catch (e) {
      productoTemp.id = 0;
      productoTemp.producto = 'Error en la peticion. $e';
    }
    return productoTemp;
  }

  Future<Resultado> editaProducto(Producto producto) async {
    var url = Uri.parse('$baseUrl/articles/${producto.id}');
    try {
      final resp = await http.put(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'empresa_id': sesion.idNegocio,
        'articulo': producto.producto,
        'categoria_id': producto.idCategoria,
        'imagen': producto.imagen,
        'unidad': producto.unidad,
        'precio': producto.precio,
        'costo': producto.costo,
        'clave': producto.clave,
        'codigo_barras': producto.codigoBarras,
        'inventario': producto.inventario,
        'apartado': producto.apartado,
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

  Future<Resultado> eliminaProducto(int idProd) async {
    var url = Uri.parse('$baseUrl/destoyA/$idProd');
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
      respuesta.mensaje = 'Error en la peticion. $e';
    }

    return respuesta;
  }
}
