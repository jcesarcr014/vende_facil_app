import 'dart:convert';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:http/http.dart' as http;

class ArticuloProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> nuevoProducto(Producto producto) async {
    var url = Uri.parse('$baseUrl/productos/${sesion.idNegocio}');

    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'categoria_id': producto.idCategoria.toString(),
        'nombre': producto.producto,
        'descripcion': producto.descripcion,
        'imagen': producto.imagen,
        'unidad': producto.unidad.toString(),
        'precio': producto.precio!.toStringAsFixed(2),
        'costo': producto.costo!.toStringAsFixed(2),
        'clave': producto.clave,
        'codigo_barras': producto.codigoBarras!.padRight(13, '0'),
        'aplica_inventario': producto.inventario.toString(),
        'aplica_apartado': producto.apartado.toString(),
      });
      final decodedData = jsonDecode(resp.body);
<<<<<<< HEAD
      print(decodedData);
      if (decodedData['status'] == 1) {
        respuesta2.status = 1;
        respuesta2.mensaje = decodedData['msg'];
        respuesta2.id= decodedData['empresa_id'];
=======
>>>>>>> 19a980dbe31c4065349feb9e1a43bd41ef6772d7

      if (decodedData['status'] == 1) {
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
        respuesta.id = decodedData['data']['id'];
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
    var url = Uri.parse('$baseUrl/productos/${sesion.idNegocio}');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);

      if (decodedData['status'] == 1) {
        for (int x = 0; x < decodedData['data'].length; x++) {
          Producto productoTemp = Producto();
          productoTemp.id = decodedData['data'][x]['id'];
          productoTemp.producto = decodedData['data'][x]['nombre'];
          productoTemp.idCategoria = decodedData['data'][x]['categoria_id'];
          productoTemp.unidad = decodedData['data'][x]['unidad'];
          productoTemp.precio = double.parse(decodedData['data'][x]['precio']);
          productoTemp.costo = double.parse(decodedData['data'][x]['costo']);
          productoTemp.clave = decodedData['data'][x]['clave'];
          productoTemp.codigoBarras = decodedData['data'][x]['codigo_barras'];
<<<<<<< HEAD
          productoTemp.inventario =
              int.parse(decodedData['data'][x]['inventario']);
          productoTemp.imagen = decodedData['data'][x]['imagen'];
          productoTemp.apartado = int.parse(decodedData['data'][x]['apartado']);

=======
          productoTemp.inventario = decodedData['data'][x]['inventario'];
          productoTemp.imagen = decodedData['data'][x]['imagen'];
          productoTemp.apartado = decodedData['data'][x]['apartado'];
>>>>>>> 19a980dbe31c4065349feb9e1a43bd41ef6772d7
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
    var url = Uri.parse('$baseUrl/producto/$idProd');

    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);

      if (decodedData['status'] == 1) {
        productoTemp.id = decodedData['producto']['id'];
        productoTemp.producto = decodedData['producto']['nombre'];
        productoTemp.descripcion = decodedData['producto']['descripcion'];
        productoTemp.idCategoria = decodedData['producto']['categoria_id'];
        productoTemp.unidad = decodedData['producto']['unidad'];
        productoTemp.precio = double.parse(decodedData['producto']['precio']);
        productoTemp.costo = double.parse(decodedData['producto']['costo']);
        productoTemp.clave = decodedData['producto']['clave'];
        productoTemp.codigoBarras = decodedData['producto']['codigo_barras'];
        productoTemp.inventario = decodedData['producto']['inventario'];
        productoTemp.imagen = decodedData['producto']['imagen'];
        productoTemp.apartado = decodedData['producto']['apartado'];
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
    var url = Uri.parse('$baseUrl/productos/${producto.id}');
    try {
      final resp = await http.put(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'categoria_id': producto.idCategoria.toString(),
        'nombre': producto.producto,
        'descripcion': producto.descripcion,
        'imagen': producto.imagen,
        'unidad': producto.unidad.toString(),
        'precio': producto.precio.toString(),
        'costo': producto.costo.toString(),
        'clave': producto.clave,
        'codigo_barras': producto.codigoBarras,
        'aplica_inventario': producto.inventario.toString(),
        'aplica_apartado': producto.apartado.toString(),
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
    var url = Uri.parse('$baseUrl/productos/$idProd');
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
      respuesta.mensaje = 'Error en la peticion. $e';
    }

    return respuesta;
  }
}
