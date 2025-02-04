import 'dart:convert';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:http/http.dart' as http;

class CorteProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> solicitarCorte(String efectivo, String comentarios) async {
    var url = Uri.parse('$baseUrl/corte-nuevo');
    print('id_negocio: ${sesion.idNegocio}');
    print('id_usuario: ${sesion.idUsuario}');
    print('id_sucursal: ${sesion.idSucursal}');
    print('efectivo: $efectivo');
    print('observaciones: $comentarios');

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
      print(decodedData);
      if (decodedData['status'] == 1) {
        listaCortes.clear();
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
        corteActual.id = decodedData['corte']['id'];
        corteActual.idNegocio = decodedData['corte']['id_negocio'];
        corteActual.idUsuario = decodedData['corte']['id_usuario'];
        corteActual.idSucursal = decodedData['corte']['id_sucursal'];
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
}
