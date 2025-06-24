import 'dart:convert';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:http/http.dart' as http;

class ArticuloProvider {
  final String baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  //======================================================================
  // FUNCIONES GENERALES DE PRODUCTOS (CRUD básico)
  //======================================================================

  Future<Resultado> nuevoProducto(Producto producto) async {
    // Endpoint sin cambios: La API /productos/{idNegocio} (POST) maneja la lógica mono/multi
    var url = Uri.parse('$baseUrl/productos/${sesion.idNegocio}');
    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
        // 'Content-Type': 'application/x-www-form-urlencoded', // Si antes no enviabas JSON
      }, body: {
        // Mantengo tu formato de body original
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
        producto.id = decodedData['data']['id'];
        // listaProductos.add(producto); // La lógica de manejo de listaProductos se mantiene como la tenías
      } else {
        respuesta.status = 0;
        respuesta.mensaje = decodedData['msg'];
      }
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la peticion (nuevoProducto): $e';
    }
    return respuesta;
  }

  Future<Resultado> editaProducto(Producto producto) async {
    // Endpoint sin cambios: La API /productos/{idProducto} (PUT) maneja la lógica mono/multi
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
      respuesta.mensaje = 'Error en la peticion (editaProducto): $e';
    }
    return respuesta;
  }

  Future<Producto> consultaProducto(int idProd) async {
    // Endpoint sin cambios: La API /producto/{idProducto} (GET) ahora puede devolver info adaptada
    Producto productoTemp = Producto(id: 0);
    var url = Uri.parse('$baseUrl/producto/$idProd');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1 &&
          decodedData['data'] != null &&
          decodedData['data']['producto'] != null) {
        final productoData = decodedData['data']['producto'];
        productoTemp.id = productoData['id'];
        productoTemp.producto = productoData['nombre'];
        productoTemp.descripcion = productoData['descripcion'];
        productoTemp.idCategoria = productoData['categoria_id'];
        productoTemp.unidad = productoData['unidad'].toString();
        productoTemp.precioPublico =
            double.tryParse(productoData['precio_publico'].toString());
        productoTemp.precioMayoreo =
            double.tryParse(productoData['precio_mayoreo'].toString());
        productoTemp.precioDist =
            double.tryParse(productoData['precio_dist'].toString());
        productoTemp.costo = double.tryParse(productoData['costo'].toString());
        productoTemp.clave = productoData['clave'];
        productoTemp.codigoBarras = productoData['codigo_barras'];
        productoTemp.apartado =
            int.tryParse(productoData['aplica_apartado'].toString());

        if (/*sesion.esMonoSucursal == true &&*/ decodedData['data']
                ['inventario_unica_sucursal'] !=
            null) {
          final inventarioData =
              decodedData['data']['inventario_unica_sucursal'];
          productoTemp.cantidad =
              double.tryParse(inventarioData['disponibles'].toString());
          productoTemp.idInv = inventarioData['id'];
          productoTemp.cantidadInv =
              double.tryParse(inventarioData['cantidad'].toString());
          productoTemp.apartadoInv =
              double.tryParse(inventarioData['apartado'].toString());
        } else {
          productoTemp.cantidad =
              double.tryParse(productoData['cantidad'].toString());
        }
      } else {
        productoTemp.producto = decodedData['msg'] ?? 'Producto no encontrado.';
      }
    } catch (e) {
      productoTemp.producto = 'Error en la peticion (consultaProducto): $e';
    }
    return productoTemp;
  }

  Future<Resultado> eliminaProducto(int idProd) async {
    // Esta función ahora DEBE decidir si llamar a la ruta unisucursal o multi-sucursal
    // Necesitas una forma de saber si 'sesion.esMonoSucursal' es true
    var url;
    Map<String, String>? body;

    url = Uri.parse('$baseUrl/productos/multi-sucursal/eliminar/$idProd');
    try {
      http.Response resp;
      if (body != null) {
        resp = await http.delete(url,
            headers: {
              'Authorization': 'Bearer ${sesion.token}',
              'Content-Type': 'application/json', // Si envías body como JSON
              'Accept': 'application/json',
            },
            body: jsonEncode(body));
      } else {
        resp = await http.delete(url, headers: {
          'Authorization': 'Bearer ${sesion.token}',
          'Accept': 'application/json',
        });
      }

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
      respuesta.mensaje = 'Error en la peticion (eliminaProducto): $e';
    }
    return respuesta;
  }

  //======================================================================
  // FUNCIONES LISTADO (PUEDEN NECESITAR DECISIÓN MONO/MULTI EN LA UI)
  //======================================================================

  Future<Resultado> listarProductos() async {
    // Esta función originalmente llamaba a 'productos/{idNegocio}'
    // que ahora es 'productos/almacen/{idNegocio}' para multi-sucursal.
    // La UI deberá decidir si llama a esta o a listarInventarioUnicaSucursal().
    listaProductos.clear();
    var url = Uri.parse(
        '$baseUrl/productos/almacen/${sesion.idNegocio}'); // Actualizado
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        for (int x = 0; x < decodedData['data'].length; x++) {
          Producto productoTemp = Producto();
          // ... (mapeo igual a tu original) ...
          productoTemp.id = decodedData['data'][x]['id'];
          productoTemp.producto = decodedData['data'][x]['nombre'];
          // ... todos los demás campos ...
          productoTemp.cantidad =
              double.tryParse(decodedData['data'][x]['cantidad'].toString());
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
      respuesta.mensaje = 'Error en la peticion (listarProductos): $e';
    }
    return respuesta;
  }

  Future<Resultado> listarProductosCotizaciones() async {
    listaProductosCotizaciones.clear();
    // Igual que listarProductos, ahora apunta a la vista de almacén.
    var url = Uri.parse(
        '$baseUrl/productos/almacen/${sesion.idNegocio}'); // Actualizado
    try {
      // ... (lógica de request y parseo igual a tu original) ...
      // (Solo he omitido el cuerpo del for para brevedad, debe ser igual a tu original)
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        for (int x = 0; x < decodedData['data'].length; x++) {
          Producto productoTemp = Producto();
          // Mapeo igual que tu original
          productoTemp.id = decodedData['data'][x]['id'];
          //...
          productoTemp.cantidad =
              double.parse(decodedData['data'][x]['cantidad']);
          //...
          listaProductosCotizaciones.add(productoTemp);
        }
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
      } else {
        respuesta.status = 0;
        respuesta.mensaje = decodedData['msg'];
      }
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje =
          'Error en la peticion (listarProductosCotizaciones): $e';
    }
    return respuesta;
  }

  //======================================================================
  // FUNCIONES ESPECÍFICAS PARA MONO-SUCURSAL (NUEVAS)
  //======================================================================

  Future<Resultado> listarInventarioUnicaSucursal() async {
    var url = Uri.parse(
        '$baseUrl/productos/unisucursal/inventario/${sesion.idNegocio}');
    listaProductos
        .clear(); // Decide si esta es la lista correcta a limpiar/llenar

    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
        'Accept': 'application/json',
      });
      final decodedData = jsonDecode(resp.body);
      respuesta.status = decodedData['status'] ?? 0;
      respuesta.mensaje = decodedData['msg'] ?? 'Error desconocido';

      if (respuesta.status == 1 && decodedData['data'] != null) {
        for (var itemData in decodedData['data']) {
          Producto productoTemp = Producto();
          productoTemp.id = itemData['producto_id'];
          productoTemp.producto = itemData['nombre_producto'];
          productoTemp.idCategoria = itemData['categoria_id'];
          productoTemp.descripcion = itemData['descripcion_producto'];
          productoTemp.unidad = itemData['unidad_producto'].toString();
          productoTemp.precioPublico =
              double.tryParse(itemData['precio_publico'].toString());
          productoTemp.costo = double.tryParse(itemData['costo'].toString());
          productoTemp.clave = itemData['clave_producto'];
          productoTemp.codigoBarras = itemData['codigo_barras_producto'];

          productoTemp.idInv = itemData['inventario_id'];
          productoTemp.cantidad = double.tryParse(
              itemData['cantidad_disponible_sucursal'].toString());
          productoTemp.cantidadInv =
              double.tryParse(itemData['cantidad_total_sucursal'].toString());
          productoTemp.apartadoInv = double.tryParse(
              itemData['cantidad_apartada_sucursal'].toString());

          listaProductos
              .add(productoTemp); // O una lista específica para esta vista
        }
      }
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje =
          'Error en la petición (listarInventarioUnicaSucursal): $e';
    }
    return respuesta;
  }

  Future<Resultado> editarInventarioUnicaSucursal(
      int productoId, double nuevaCantidadFisica) async {
    var url = Uri.parse(
        '$baseUrl/productos/unisucursal/inventario/cantidad/${sesion.idNegocio}');
    try {
      final resp = await http.put(url,
          headers: {
            'Authorization': 'Bearer ${sesion.token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'producto_id': productoId,
            'nueva_cantidad_fisica': nuevaCantidadFisica,
          }));
      final decodedData = jsonDecode(resp.body);
      respuesta.status = decodedData['status'] ?? 0;
      respuesta.mensaje = decodedData['msg'] ?? 'Error desconocido';
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje =
          'Error en la petición (editarInventarioUnicaSucursal): $e';
    }
    return respuesta;
  }

  Future<Resultado> eliminarProductoUnicaSucursal(int productoId) async {
    var url = Uri.parse(
        '$baseUrl/productos/unisucursal/eliminar/${sesion.idNegocio}');
    try {
      final resp = await http.delete(url,
          headers: {
            'Authorization': 'Bearer ${sesion.token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'producto_id': productoId,
          }));
      final decodedData = jsonDecode(resp.body);
      respuesta.status = decodedData['status'] ?? 0;
      respuesta.mensaje = decodedData['msg'] ?? 'Error desconocido';
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje =
          'Error en la petición (eliminarProductoUnicaSucursal): $e';
    }
    return respuesta;
  }

  //======================================================================
  // FUNCIONES PARA MULTI-SUCURSAL (ALMACÉN Y TRANSFERENCIAS)
  //======================================================================

  Future<Resultado> listarProductosAlmacen() async {
    // Endpoint actualizado: productos/almacen/lista-detallada/{idNegocio}
    var url = Uri.parse(
        '$baseUrl/productos/almacen/lista-detallada/${sesion.idNegocio}');
    List<Producto> listaProductosAlmacenTemporal =
        []; // Usar una lista temporal aquí

    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);

      if (decodedData['status'] == 1) {
        for (int x = 0; x < decodedData['data'].length; x++) {
          Producto productoTemp = Producto();
          // ... (mapeo igual a tu original) ...
          productoTemp.id = decodedData['data'][x]['id'];
          productoTemp.producto = decodedData['data'][x]['nombre'];
          // ...
          productoTemp.cantidad =
              double.tryParse(decodedData['data'][x]['cantidad'].toString());
          listaProductosAlmacenTemporal.add(productoTemp);
        }
        // Actualizar la lista global después de cargar todo
        listaProductos = listaProductosAlmacenTemporal;
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
      } else {
        respuesta.status = 0;
        respuesta.mensaje = decodedData['msg'];
      }
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la petición (listarProductosAlmacen): $e';
    }
    return respuesta;
  }

  Future<Resultado> actualizarCantidadProducto(
      int idProducto, double cantidad) async {
    // Endpoint actualizado: productos/almacen/cantidad/{idProducto}
    var url = Uri.parse('$baseUrl/productos/almacen/cantidad/$idProducto');
    try {
      final resp = await http.put(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
        // 'Content-Type': 'application/x-www-form-urlencoded', // O jsonEncode si la API lo espera
      }, body: {
        // Mantengo tu formato de body
        'cantidad': cantidad.toString(),
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        // ... (tu lógica de actualizar listaProductos) ...
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
      } else {
        respuesta.status = 0;
        respuesta.mensaje = decodedData['msg'];
      }
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje =
          'Error en la petición (actualizarCantidadProducto): $e';
    }
    return respuesta;
  }

  Future<Resultado> listarProductosSucursal(int idSucursal) async {
    var url = Uri.parse(
        '$baseUrl/productos/sucursal/$idSucursal'); // Ajustado para consistencia
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      print(decodedData);
      if (decodedData['status'] == 1) {
        listaProductosSucursal.clear();
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

          productoTemp.idInv = decodedData['data'][x]['id_inv'];

          productoTemp.cantidadInv =
              double.parse(decodedData['data'][x]['cantidad_inv']);
          productoTemp.apartadoInv =
              double.parse(decodedData['data'][x]['apartado_inv']);
          productoTemp.disponibleInv =
              double.parse(decodedData['data'][x]['disponibles_inv']);
          listaProductosSucursal.add(productoTemp);
        }
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
      } else {
        respuesta.status = 0;
        respuesta.mensaje = decodedData['msg'];
      }
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la peticion (listarProductosSucursal): $e';
    }
    return respuesta;
  }

  Future<Resultado> nvoInventarioSuc(Producto producto) async {
    // Endpoint actualizado: inventario/sucursal/nuevo (POST)
    // Ya no se envía idUser en la URL
    var url = Uri.parse('$baseUrl/inventario/sucursal/nuevo');
    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
        // 'Content-Type': 'application/x-www-form-urlencoded',
      }, body: {
        // Mantengo tu formato de body
        'sucursal_id': producto.idSucursal.toString(),
        'producto_id': producto.id.toString(),
        'cantidad': producto.cantidadInv.toString()
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
      respuesta.mensaje = 'Error en la peticion (nvoInventarioSuc): $e';
    }
    return respuesta;
  }

  Future<Resultado> inventarioSucAgregar(Producto producto) async {
    // Endpoint actualizado: inventario/sucursal/agregar (PUT)
    var url = Uri.parse('$baseUrl/inventario/sucursal/agregar');
    try {
      // ... (lógica igual a tu original, solo la URL cambia si es necesario) ...
      // Mantengo tu formato de body
      final resp = await http.put(url, headers: {
        'Authorization': 'Bearer ${sesion.token}'
      }, body: {
        'inventario_id': producto.idInv.toString(),
        'cantidad': producto.cantidadInv.toString()
      });
      // ...
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
      respuesta.mensaje = 'Error en la peticion (inventarioSucAgregar): $e';
    }
    return respuesta;
  }

  Future<Resultado> inventarioSucQuitar(
      String idInventario, String cantidad) async {
    // Endpoint actualizado: inventario/sucursal/quitar (PUT)
    var url = Uri.parse('$baseUrl/inventario/sucursal/quitar');
    try {
      // ... (lógica igual a tu original, solo la URL cambia si es necesario) ...
      // Mantengo tu formato de body
      final resp = await http.put(url,
          headers: {'Authorization': 'Bearer ${sesion.token}'},
          body: {'inventario_id': idInventario, 'cantidad': cantidad});
      // ...
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
      respuesta.mensaje = 'Error en la peticion (inventarioSucQuitar): $e';
    }
    return respuesta;
  }

  // Esta función parece ser un alias o un caso específico de nvoInventarioSuc.
  // La he dejado tal cual, pero considera si es necesaria o si se puede unificar.
  Future<Resultado> agregarProdSucursal(Producto producto) async {
    // Debería apuntar a la misma ruta que nvoInventarioSuc si la funcionalidad es la misma.
    var url =
        Uri.parse('$baseUrl/inventario/sucursal/nuevo'); // Asumiendo misma ruta
    try {
      // ... (lógica igual a tu original) ...
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}'
      }, body: {
        'sucursal_id': producto.idSucursal.toString(),
        'producto_id': producto.id.toString(),
        'cantidad': producto.cantidadInv.toString()
      });
      // ...
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
      respuesta.mensaje = 'Error en la peticion (agregarProdSucursal): $e';
    }
    return respuesta;
  }
}
