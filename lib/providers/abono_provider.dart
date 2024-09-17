import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;


class AbonoProvider {
  final baseUrl = globals.baseUrl;
  final respuesta = Resultado();

  Future<Resultado> obtenerAbono(String abonoID) async {
    final url = Uri.parse('$baseUrl/apartado-abono/$abonoID');
    try {
      final response = await http.get(url, headers: {
          'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(response.body);

      respuesta.mensaje = decodedData['msg'];

      if(decodedData['status'] == 1) {
        respuesta.status = 1;
        abonoSeleccionado.saldoActual = double.parse(decodedData['abono']['saldo_actual']);
        abonoSeleccionado.saldoAnterior = double.parse(decodedData['abono']['saldo_anterior']);
        abonoSeleccionado.fechaAbono = decodedData['abono']['fecha_abono'];
        abonoSeleccionado.cantidadEfectivo = double.parse(decodedData['abono']['cantidad_efectivo']);
        abonoSeleccionado.cantidadTarjeta = double.parse(decodedData['abono']['cantidad_tarjeta']);
      } else {
        respuesta.status = 0;
      }
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la peticion. $e';
    }

    return respuesta;

  }
}