import 'dart:convert';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:http/http.dart' as http;
import '../models/models.dart';


class ReportesProvider {
  final String baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> reporteGeneral(String startDate, String endDate) async {
    final url = Uri.parse('$baseUrl/reporte-general/$startDate/$endDate/${sesion.idNegocio}');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      
      final decodedData = jsonDecode(response.body);

      if(decodedData["status"] != 1) {
        respuesta.status = 0;
        respuesta.mensaje = decodedData["msg"];
        return respuesta;
      }

      List<dynamic> dataList = decodedData['data'];
      listaVentas.clear();

      for (dynamic venta in dataList) {
          VentaCabecera nuevaVenta = VentaCabecera(
            id: venta['id'],
            usuarioId: venta['usuario_id'],
            name: venta['name'],
            tipo_movimiento: venta['tipo_movimiento'],
            importeEfectivo: double.parse(venta['monto_efectivo']),
            importeTarjeta: double.parse(venta['monto_tarjeta']),
            total: double.parse(venta['total']),
            fecha_venta: venta['fecha'],
            id_sucursal: venta['sucursal_id'],
            nombreCliente: venta['nombre_sucursal'],
          );
          listaVentas.add(nuevaVenta);
      }

      respuesta.mensaje = decodedData["msg"];
      respuesta.status = 1;
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la peticion. $e';
    }
    return respuesta;
  }

  Future<Resultado> reporteSucursal(String startDate, String endDate) async {
    final url = Uri.parse('$baseUrl/reporte-sucursal/$startDate/$endDate/${sesion.idSucursal}');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      
      final decodedData = jsonDecode(response.body);

      if(decodedData["status"] != 1) {
        respuesta.status = 0;
        respuesta.mensaje = decodedData["msg"];
        return respuesta;
      }

      List<dynamic> dataList = decodedData['data'];
      listaVentas.clear();

      for (dynamic venta in dataList) {
          VentaCabecera nuevaVenta = VentaCabecera(
            id: venta['id'],
            usuarioId: venta['usuario_id'],
            name: venta['name'],
            tipo_movimiento: venta['tipo_movimiento'],
            importeEfectivo: double.parse(venta['monto_efectivo']),
            importeTarjeta: double.parse(venta['monto_tarjeta']),
            total: double.parse(venta['total']),
            fecha_venta: venta['fecha'],
            id_sucursal: venta['sucursal_id'],
            nombreCliente: venta['nombre_sucursal'],
          );
          listaVentas.add(nuevaVenta);
      }

      respuesta.mensaje = decodedData["msg"];
      respuesta.status = 1;
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la peticion. $e';
    }
    return respuesta;
  }

}