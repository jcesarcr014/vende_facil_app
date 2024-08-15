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
        'unidad': producto.unidad.toString(),
        'precio_publico': producto.precioPublico!.toStringAsFixed(2),
        'precio_mayoreo': producto.precioMayoreo!.toStringAsFixed(2),
        'precio_dist': producto.precioDist!.toStringAsFixed(2),
        'costo': producto.costo!.toStringAsFixed(2),
        'clave': producto.clave,
        'cantidad': producto.cantidad!.toStringAsFixed(2),
        'codigo_barras': producto.codigoBarras!.padRight(13, '0'),
        'aplica_apartado': producto.apartado.toString(),
      });
      final decodedData = jsonDecode(resp.body);

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
          productoTemp.idNegocio = decodedData['data'][x]['negocio_id'];
          productoTemp.idCategoria = decodedData['data'][x]['categoria_id'];
          productoTemp.unidad = decodedData['data'][x]['unidad'];
          productoTemp.precioPublico =
              double.parse(decodedData['data'][x]['precio_publico']);
          productoTemp.precioMayoreo =
              double.parse(decodedData['data'][x]['precio_mayoreo']);

          productoTemp.precioDist =
              double.parse(decodedData['data'][x]['precio_dist']);
          productoTemp.costo = double.parse(decodedData['data'][x]['costo']);
          productoTemp.clave = decodedData['data'][x]['clave'];
          productoTemp.codigoBarras = decodedData['data'][x]['codigo_barras'];
          productoTemp.cantidad =
              double.parse(decodedData['data'][x]['cantidad']);
          productoTemp.apartado =
              int.parse(decodedData['data'][x]['aplica_apartado']);
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
        productoTemp.precioPublico =
            double.parse(decodedData['producto']['precio_publico']);
        productoTemp.precioMayoreo =
            double.parse(decodedData['producto']['precio_mayoreo']);
        productoTemp.precioDist =
            double.parse(decodedData['producto']['precio_dist']);
        productoTemp.costo = double.parse(decodedData['producto']['costo']);
        productoTemp.clave = decodedData['producto']['clave'];
        productoTemp.codigoBarras = decodedData['producto']['codigo_barras'];
        productoTemp.cantidad =
            double.parse(decodedData['producto']['cantidad']);
        productoTemp.apartado =
            int.parse(decodedData['producto']['aplica_apartado']);
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
        'unidad': producto.unidad.toString(),
        'precio_publico': producto.precioPublico.toString(),
        'precio_mayoreo': producto.precioMayoreo.toString(),
        'precio_dist': producto.precioDist.toString(),
        'costo': producto.costo.toString(),
        'clave': producto.clave,
        'codigo_barras': producto.codigoBarras,
        'cantidad': producto.cantidad.toString(),
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
