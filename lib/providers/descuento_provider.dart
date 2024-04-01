import 'dart:convert';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:http/http.dart' as http;

class DescuentoProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> nuevoDescuento(Descuento descuento) async {
    var url = Uri.parse('$baseUrl/descuentos/${sesion.idNegocio}');

    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'nombre': descuento.nombre,
        'tipo': descuento.tipoValor.toString(),
        'valor': descuento.valor?.toStringAsFixed(2),
        'valor_predeterminado': descuento.valorPred.toString(),
        'estatus': '1',
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

  Future<Resultado> listarDescuentos() async {
    listaDescuentos.clear();
    var url = Uri.parse('$baseUrl/descuentos/${sesion.idNegocio}');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        for (int x = 0; x < decodedData['data'].length; x++) {
          Descuento descTemporal = Descuento();
          descTemporal.id = decodedData['data'][x]['id'];
          descTemporal.nombre = decodedData['data'][x]['nombre'];
          descTemporal.valor =
              double.parse(decodedData['data'][x]['valor'].toString());
          descTemporal.tipoValor = int.parse(decodedData['data'][x]['tipo']);
          descTemporal.valorPred =
              int.parse(decodedData['data'][x]['valor_predeterminado']);
          listaDescuentos.add(descTemporal);
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

  Future<Descuento> consultaDescuento(int idDesc) async {
    Descuento descuento = Descuento();
    var url = Uri.parse('$baseUrl/descuento/$idDesc');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);

      if (decodedData['status'] == 1) {
        descuento.id = decodedData['data'][0]['id'];
        descuento.nombre = decodedData['data'][0]['nombre'];
        descuento.valor = decodedData['data'][0]['valor'];
        descuento.tipoValor = decodedData['data'][0]['tipo'];
        descuento.valorPred = decodedData['data'][0]['valor_predeterminado'];
      } else {
        descuento.id = 0;
        descuento.nombre = decodedData['msg'];
      }
    } catch (e) {
      descuento.id = 0;
      descuento.nombre = 'Error en la petición. $e';
    }

    return descuento;
  }

  Future<Resultado> editaDescuento(Descuento descuento) async {
    var url = Uri.parse('$baseUrl/descuentos/${descuento.id}');
    try {
      final resp = await http.put(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'nombre': descuento.nombre,
        'tipo': descuento.tipoValor.toString(),
        'valor': descuento.valor?.toStringAsFixed(2),
        'valor_predeterminado': descuento.valorPred.toString(),
        'estatus': '1',
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

  Future<Resultado> eliminaDescuento(int idDesc) async {
    var url = Uri.parse('$baseUrl/descuentos/$idDesc');
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
}
