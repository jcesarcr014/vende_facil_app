import 'dart:convert';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:openpay_bbva/openpay_bbva.dart';

class SuscripcionProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> nvaTarjetaOP(TarjetaOP tarjeta) async {
    var url = Uri.parse('$baseUrl/tarjeta/${sesion.idUsuario}');
    final openpay = OpenpayBBVA(
        merchantId: globals.opMerchantId,
        publicApiKey: globals.opPublicKey,
        productionMode: false);
    String? deviceID = '';
    String token = '';
    try {
      deviceID = await openpay.getDeviceID();
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error al obtener el token de la tarjeta. $e';
    }

    try {
      token = await openpay.getCardToken(
        CardInformation(
          holderName: tarjeta.titular!,
          cardNumber: tarjeta.numero!,
          expirationYear: tarjeta.fechaA!,
          expirationMonth: tarjeta.fechaM!,
          cvv2: tarjeta.ccv!,
        ),
      );
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error al obtener el token de la tarjeta. $e';
    }

    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'numero': tarjeta.numero,
        'device_id': deviceID,
        'token': token,
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

  Future<Resultado> listarTarjetas() async {
    var url = Uri.parse('$baseUrl/tarjetas/${sesion.idUsuario}');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);

      if (decodedData['status'] == 1) {
        listaTarjetas.clear();
        for (int x = 0; x < decodedData['data'].length; x++) {
          TarjetaOP tarjetaTemp = TarjetaOP();
          tarjetaTemp.id = decodedData['data'][x]['id'];
          tarjetaTemp.numero = decodedData['data'][x]['num_tarjeta'];

          listaTarjetas.add(tarjetaTemp);
        }
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
      }
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la peticion: $e';
    }
    return respuesta;
  }

  Future<Resultado> eliminarTarjeta(int idTarjeta) async {
    var url = Uri.parse('$baseUrl/tarjeta/$idTarjeta');
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
      respuesta.mensaje = 'Error en la peticion: $e';
    }
    return respuesta;
  }

  Future<Resultado> obtienePlanes() async {
    var url = Uri.parse('$baseUrl/planes');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);

      if (decodedData['status'] == 1) {
        listaPlanes.clear();
        listaDetalles.clear();
        for (int x = 0; x < decodedData['planes'].length; x++) {
          PlanSuscripcion planTemp = PlanSuscripcion();
          planTemp.id = decodedData['planes'][x]['id'];
          planTemp.monto = decodedData['planes'][x]['monto'];
          planTemp.idPlanOp = decodedData['planes'][x]['id_plan_op'];
          planTemp.nombrePlan = decodedData['planes'][x]['nombre_plan'];
          planTemp.periodicidad = decodedData['planes'][x]['periodicidad'];
          planTemp.divisa = decodedData['planes'][x]['divisa'];
          if (suscripcionActual.idPlan == planTemp.id) {
            planTemp.activo = true;
          } else {
            planTemp.activo = false;
          }

          listaPlanes.add(planTemp);
        }

        for (int x = 0; x < decodedData['detalles'].length; x++) {
          DetallePlan detalleTemp = DetallePlan();
          detalleTemp.id = decodedData['detalles'][x]['id'];
          detalleTemp.idPlan = decodedData['detalles'][x]['plan_id'];
          detalleTemp.descripcion = decodedData['detalles'][x]['descripcion'];
          listaDetalles.add(detalleTemp);
        }
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
      } else {
        respuesta.status = 0;
        respuesta.mensaje = decodedData['msg'];
      }
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la peticion: $e';
    }
    return respuesta;
  }

  Future<Resultado> leeSuscripcion() async {
    var url = Uri.parse('$baseUrl/suscripcion/${sesion.idUsuario}');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        detallesSuscripcion.clear();
        suscripcionActual.id = decodedData['suscripcion']['id'];
        suscripcionActual.idUsuario =
            decodedData['suscripcion']['id_usuario_app'];
        suscripcionActual.idTarjeta ?? decodedData['suscripcion']['id_tarjeta'];
        suscripcionActual.idPlan = decodedData['suscripcion']['id_plan'];
        suscripcionActual.idSuscripcionOP ??
            decodedData['suscripcion']['id_suscripcion_op'];
        for (int x = 0; x < decodedData['detalles'].length; x++) {
          DetallePlan detalleTemp = DetallePlan();
          detalleTemp.id = decodedData['detalles'][x]['id'];
          detalleTemp.idPlan = decodedData['detalles'][x]['id_plan'];
          detalleTemp.descripcion = decodedData['detalles'][x]['descripcion'];
          detallesSuscripcion.add(detalleTemp);
        }
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
      } else {
        respuesta.status = 0;
        respuesta.mensaje = decodedData['msg'];
      }
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la peticion: $e';
    }
    return respuesta;
  }
}
