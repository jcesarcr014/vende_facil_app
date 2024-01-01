import 'dart:convert';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:http/http.dart' as http;

class ClienteProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> nuevoCliente(Cliente cliente) async {
    var url = Uri.parse('$baseUrl/customers');
    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'empresa_id': sesion.idNegocio.toString(),
        'nombre': cliente.nombre,
        'telefono': cliente.telefono,
        'direccion': cliente.direccion,
        'ciudad': cliente.ciudad,
        'estado': cliente.estado,
        'cp': cliente.cp,
        'pais': cliente.pais,
        'codigo_cliente': cliente.codigoCliente,
        'nota': cliente.nota,
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

  Future<Resultado> listarClientes() async {
    listaClientes.clear();
    var url = Uri.parse('$baseUrl/listarCust/${sesion.idNegocio}');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        for (int x = 0; x < decodedData['data'].length; x++) {
          Cliente clienteTemp = Cliente();
          clienteTemp.id = decodedData['data'][x]['id'];
          clienteTemp.nombre = decodedData['data'][x]['nombre'];
          clienteTemp.correo = decodedData['data'][x]['email'];
          clienteTemp.telefono = decodedData['data'][x]['telefono'];
          clienteTemp.direccion = decodedData['data'][x]['direccion'];
          clienteTemp.ciudad = decodedData['data'][x]['ciudad'];
          clienteTemp.estado = decodedData['data'][x]['estado'];
          clienteTemp.cp = decodedData['data'][x]['cp'];
          clienteTemp.pais = decodedData['data'][x]['pais'];
          clienteTemp.codigoCliente = decodedData['data'][x]['codigo_cliente'];
          clienteTemp.nota = decodedData['data'][x]['nota'];
          listaClientes.add(clienteTemp);
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

  Future<Cliente> consultaCliente(int idCliente) async {
    Cliente cliente = Cliente();
    var url = Uri.parse('$baseUrl/customers/$idCliente');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);

      if (decodedData['status'] == 1) {
        cliente.id = decodedData['data'][0]['id'];
        cliente.nombre = decodedData['data'][0]['nombre'];
        cliente.correo = decodedData['data'][0]['email'];
        cliente.telefono = decodedData['data'][0]['telefono'];
        cliente.direccion = decodedData['data'][0]['direccion'];
        cliente.ciudad = decodedData['data'][0]['ciudad'];
        cliente.estado = decodedData['data'][0]['estado'];
        cliente.cp = decodedData['data'][0]['cp'];
        cliente.pais = decodedData['data'][0]['pais'];
        cliente.codigoCliente = decodedData['data'][0]['codigo_cliente'];
        cliente.nota = decodedData['data'][0]['nota'];
      } else {
        cliente.id = 0;
        cliente.nombre = decodedData['msg'];
      }
    } catch (e) {
      cliente.id = 0;
      cliente.nombre = 'Error en la petición. $e';
    }

    return cliente;
  }

  Future<Resultado> editaCliente(Cliente cliente) async {
    var url = Uri.parse('$baseUrl/customers/${cliente.id}');
    try {
      final resp = await http.put(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'empresa_id': sesion.idNegocio.toString(),
        'nombre': cliente.nombre,
        'telefono': cliente.telefono,
        'direccion': cliente.direccion,
        'ciudad': cliente.ciudad,
        'estado': cliente.estado,
        'cp': cliente.cp,
        'pais': cliente.pais,
        'codigo_cliente': cliente.codigoCliente,
        'nota': cliente.nota,
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

  Future<Resultado> eliminaCliente(int idCliente) async {
    var url = Uri.parse('$baseUrl/customers/$idCliente');
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
