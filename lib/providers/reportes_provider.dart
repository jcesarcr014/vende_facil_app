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

  Future<Resultado> reporteDetalle(String date) async {
    final url = Uri.parse(
        '$baseUrl/reporte-detalle/${sesion.idNegocio.toString()}/$date');

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

      ReporteDetalleDia.limpiarListas();

      if (decodedData.containsKey('ventasDias') &&
          decodedData['ventasDias'] is List) {
        List<dynamic> ventasList = decodedData['ventasDias'];
        for (var venta in ventasList) {
          ReporteDetalleDia.listaVentasDia
              .add(ReporteVentaDetalle.fromJson(venta));
        }
      }

      if (decodedData.containsKey('apartadosDia') &&
          decodedData['apartadosDia'] is List) {
        List<dynamic> apartadosList = decodedData['apartadosDia'];
        for (var apartado in apartadosList) {
          ReporteDetalleDia.listaApartadosDia
              .add(ReporteApartadoDetalle.fromJson(apartado));
        }
      }

      if (decodedData.containsKey('abonosDia') &&
          decodedData['abonosDia'] is List) {
        List<dynamic> abonosList = decodedData['abonosDia'];
        for (var abono in abonosList) {
          ReporteDetalleDia.listaAbonosDia
              .add(ReporteAbonoDetalle.fromJson(abono));
        }
      }

      respuesta.mensaje = decodedData["msg"];
      respuesta.status = 1;
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la petición: $e';
    }

    return respuesta;
  }
}
