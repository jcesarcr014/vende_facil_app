import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

class SuscripcionProvider {
  final String baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  //======================================================================
  // GESTIÓN DE PLANES
  //======================================================================

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
    var url = Uri.parse('$baseUrl/suscripcion/cambiar');

    final Map<String, dynamic> body = {
      'stripe_price_id': stripePriceId,
    };

    if (paymentMethodId != null) {
      body['payment_method_id'] = paymentMethodId;
    }

    try {
      final resp = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${sesion.token}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      final decodedData = jsonDecode(resp.body);
      print(decodedData);
      respuesta.status = decodedData['status'] ?? 0;
      respuesta.mensaje = decodedData['msg'] ?? 'Error desconocido.';
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la petición (cambiarSuscripcion): $e';
    }
    return respuesta;
  }

  // --- NUEVA FUNCIÓN ---
  Future<Resultado> cancelarSuscripcion() async {
    var url = Uri.parse('$baseUrl/suscripcion/cancelar');
    try {
      final resp = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${sesion.token}',
          'Accept': 'application/json',
        },
      );
      final decodedData = jsonDecode(resp.body);
      respuesta.status = decodedData['status'] ?? 0;
      respuesta.mensaje =
          decodedData['msg'] ?? 'Error desconocido al cancelar.';
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la petición (cancelarSuscripcion): $e';
    }
    return respuesta;
  }

  //======================================================================
  // GESTIÓN DE MÉTODOS DE PAGO
  //======================================================================

  Future<String?> prepararSetupDePago() async {
    var url = Uri.parse('$baseUrl/pago/preparar-setup');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
        'Accept': 'application/json',
      });

      if (resp.statusCode == 200) {
        final decodedData = jsonDecode(resp.body);
        return decodedData['clientSecret'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // --- NUEVA FUNCIÓN ---
  Future<Resultado> obtenerMetodoPago() async {
    var url = Uri.parse('$baseUrl/usuario/metodo-pago');
    metodoPagoActual = null; // Limpiar antes de la consulta

    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
        'Accept': 'application/json',
      });
      final decodedData = jsonDecode(resp.body);

      if (decodedData['status'] == 1 && decodedData['data'] != null) {
        final pagoData = decodedData['data'];
        metodoPagoActual = MetodoPago(
          marca: pagoData['marca'] ?? 'Desconocida',
          ultimos4: pagoData['ultimos_4'] ?? 'XXXX',
          mesExp: pagoData['mes_exp'] ?? 0,
          anoExp: pagoData['ano_exp'] ?? 0,
        );
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
      } else {
        // status 0 es un resultado esperado (no hay método de pago), no un error de app.
        respuesta.status = 0;
        respuesta.mensaje =
            decodedData['msg'] ?? 'No se encontró método de pago.';
      }
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la petición (obtenerMetodoPago): $e';
    }
    return respuesta;
  }

  // --- NUEVA FUNCIÓN ---
  Future<Resultado> actualizarMetodoPago(String paymentMethodId) async {
    var url = Uri.parse('$baseUrl/usuario/metodo-pago');
    try {
      final resp = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${sesion.token}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'payment_method_id': paymentMethodId}),
      );
      final decodedData = jsonDecode(resp.body);
      respuesta.status = decodedData['status'] ?? 0;
      respuesta.mensaje =
          decodedData['msg'] ?? 'Error desconocido al actualizar.';
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la petición (actualizarMetodoPago): $e';
    }
    return respuesta;
  }
}
