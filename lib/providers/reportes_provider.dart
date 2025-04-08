import 'dart:convert';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ReportesProvider {
  final String baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> reporteGeneral(String date) async {
    final url = Uri.parse(
        '$baseUrl/reporte-movimientos/${sesion.idNegocio.toString()}/$date');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });

      final decodedData = jsonDecode(response.body);

      if (decodedData["status"] != 1) {
        respuesta.status = 0;
        respuesta.mensaje = decodedData["msg"];
        return respuesta;
      }

      listaMovimientosReporte.clear();

      List<dynamic> dataList = decodedData['movimientos'];

      for (dynamic movimiento in dataList) {
        MovimientoCorte nuevoMovimiento = MovimientoCorte(
          id: movimiento['id'],
          idUsario: movimiento['usuario_id'],
          idSucursal: movimiento['sucursal_id'],
          folio: movimiento['folio'],
          idCorte: movimiento['id_corte'] ?? 0,
          idMovimiento: movimiento['id_movimiento'],
          tipoMovimiento: movimiento['tipo_movimiento'],
          montoEfectivo: movimiento['monto_efectivo'],
          montoTarjeta: movimiento['monto_tarjeta'],
          total: movimiento['total'],
          fecha: movimiento['fecha'],
          hora: movimiento['hora'],
          nombreUsuario: movimiento['vendedor'],
          nombreSucursal: movimiento['sucursal'],
        );

        listaMovimientosReporte.add(nuevoMovimiento);
      }

      respuesta.mensaje = decodedData["msg"];
      respuesta.status = 1;
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la petición: $e';
    }

    return respuesta;
  }

  Future<Resultado> reporteSucursal(
      String startDate, String endDate, String idSucursal) async {
    final url =
        Uri.parse('$baseUrl/reporte-sucursal/$startDate/$endDate/$idSucursal');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });

      final decodedData = jsonDecode(response.body);

      if (decodedData["status"] != 1) {
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
            idMovimiento: venta['id_movimiento']);
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

  Future<Resultado> reporteEmpleado(String startDate, String endDate,
      String idSucursal, String idEmpleado) async {
    final url = Uri.parse(
        '$baseUrl/reporte-empleado/$startDate/$endDate/$idSucursal/$idEmpleado');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });

      final decodedData = jsonDecode(response.body);

      if (decodedData["status"] != 1) {
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
            idMovimiento: venta['id_movimiento']);
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
