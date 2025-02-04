import 'dart:convert';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:http/http.dart' as http;

class CorteProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> solicitarCorte(String efectivo, String comentarios) async {
    var url = Uri.parse('$baseUrl/corte-nuevo');

    try {
      final response = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'id_negocio': sesion.idNegocio.toString(),
        'id_usuario': sesion.idUsuario.toString(),
        'id_sucursal': sesion.idSucursal.toString(),
        'efectivo': efectivo,
        'observaciones': comentarios,
      });
      final decodedData = json.decode(response.body);
      if (decodedData['status'] == 1) {
        listaMovimientosCorte.clear();
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
        corteActual.id = decodedData['corte']['id'];
        corteActual.idNegocio = int.parse(decodedData['corte']['id_negocio']);
        corteActual.idUsuario = int.parse(decodedData['corte']['id_usuario']);
        corteActual.idSucursal = int.parse(decodedData['corte']['id_sucursal']);
        corteActual.fecha = decodedData['corte']['fecha'];
        corteActual.efectivoInicial =
            decodedData['corte']['efectivo_inicial'].toString();
        corteActual.ventasEfectivo =
            decodedData['corte']['ventas_efectivo'].toString();
        corteActual.ventasTarjeta =
            decodedData['corte']['ventas_tarjeta'].toString();
        corteActual.totalIngresos =
            decodedData['corte']['total_ingresos'].toString();
        corteActual.observaciones = decodedData['corte']['observaciones'];
        corteActual.numVentas = decodedData['corte']['numero_ventas'];
        corteActual.diferencia = decodedData['corte']['diferencia'].toString();
        corteActual.tipoDiferencia = decodedData['corte']['tipo_diferencia'];
        for (int x = 0; x < decodedData['movimientos'].length; x++) {
          MovimientoCorte mov = MovimientoCorte();
          mov.id = decodedData['movimientos'][x]['id'];
          mov.idNegocio = decodedData['movimientos'][x]['negocio_id'];
          mov.idSucursal = decodedData['movimientos'][x]['sucursal_id'];
          mov.idUsario = decodedData['movimientos'][x]['usuario_id'];
          mov.idMovimiento = decodedData['movimientos'][x]['id_movimiento'];
          mov.tipoMovimiento = decodedData['movimientos'][x]['tipo_movimiento'];
          mov.montoEfectivo = decodedData['movimientos'][x]['monto_efectivo'];
          mov.montoTarjeta = decodedData['movimientos'][x]['monto_tarjeta'];
          mov.total = decodedData['movimientos'][x]['total'];
          mov.idCorte = decodedData['movimientos'][x]['corte_id'];
          mov.folio = decodedData['movimientos'][x]['folio'] ?? 'N/A';
          listaMovimientosCorte.add(mov);
        }
      } else {
        respuesta.status = 0;
        respuesta.mensaje = decodedData['msg'];
      }
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error al solicitar corte $e';
    }
    return respuesta;
  }

  Future<Resultado> cortesFecha(String fecha) async {
    var url = Uri.parse('$baseUrl/cortes-fecha/$fecha');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = json.decode(response.body);
      if (decodedData['status'] == 1) {
        listaCortes.clear();
        for (int x = 0; x < decodedData['cortes'].length; x++) {
          Corte corte = Corte();
          corte.id = decodedData['cortes'][x]['id'];
          corte.idNegocio = decodedData['cortes'][x]['negocio_id'];
          corte.idUsuario = decodedData['cortes'][x]['usuario_id'];
          corte.idSucursal = decodedData['cortes'][x]['sucursal_id'];
          corte.fecha = decodedData['cortes'][x]['fecha'];
          corte.efectivoInicial =
              decodedData['cortes'][x]['efectivo_inicial'].toString();
          corte.ventasEfectivo =
              decodedData['cortes'][x]['ventas_efectivo'].toString();
          corte.ventasTarjeta =
              decodedData['cortes'][x]['ventas_tarjeta'].toString();
          corte.totalIngresos =
              decodedData['cortes'][x]['total_ingresos'].toString();
          corte.observaciones = decodedData['cortes'][x]['observaciones'];
          corte.numVentas = decodedData['cortes'][x]['numero_ventas'];
          corte.diferencia = decodedData['cortes'][x]['diferencia'].toString();
          corte.tipoDiferencia = decodedData['cortes'][x]['tipo_diferencia'];
          listaCortes.add(corte);
        }
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
      } else {
        respuesta.status = 0;
        respuesta.mensaje = decodedData['msg'];
      }
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error al solicitar corte $e';
    }
    return respuesta;
  }
}
