import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

class SuscripcionProvider {
  final String baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> obtienePlanes() async {
    var url = Uri.parse('$baseUrl/planes');

    listaPlanes.clear();

    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
        'Accept': 'application/json',
      });

      if (resp.statusCode != 200) {
        respuesta.status = 0;
        respuesta.mensaje = 'Error del servidor: ${resp.statusCode}';
        return respuesta;
      }

      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1 && decodedData['data'] is List) {
        for (final planData in decodedData['data']) {
          PlanSuscripcion planTemp = PlanSuscripcion(
            id: planData['id'],
            nombrePlan: planData['nombre_plan'],
            monto: planData['monto'],
            periodicidad: planData['periodicidad'],
            divisa: planData['divisa'],
            sucursales: planData['sucursales'],
            empleados: planData['empleados'],
            productos: planData['productos'],
            ventas: planData['ventas'],
            idStripe: planData['stripe_price_id'],
          );
          listaPlanes.add(planTemp);
        }
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
      } else {
        respuesta.status = 0;
        respuesta.mensaje = decodedData['msg'] ??
            'La respuesta de la API no tiene el formato esperado.';
      }
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la petición (obtienePlanes): $e';
    }
    return respuesta;
  }

  //======================================================================
  // GESTIÓN DE SUSCRIPCIONES
  //======================================================================

  Future<Resultado> cambiarSuscripcion(String stripePriceId,
      {String? paymentMethodId}) async {
    respuesta.status = 0;
    respuesta.mensaje = 'Función no implementada.';
    return respuesta;
  }

  // --- NUEVA FUNCIÓN ---
  Future<Resultado> cancelarSuscripcion() async {
    respuesta.status = 0;
    respuesta.mensaje = 'Función no implementada.';
    return respuesta;
  }

  //======================================================================
  // GESTIÓN DE MÉTODOS DE PAGO
  //======================================================================
}
