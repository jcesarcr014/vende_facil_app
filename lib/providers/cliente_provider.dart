import 'dart:convert';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:http/http.dart' as http;

class ClienteProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> nuevoCliente(Cliente cliente) async {
    var url = Uri.parse('$baseUrl/clientes/${sesion.idNegocio}');
    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'nombre': cliente.nombre,
        'telefono': cliente.telefono,
        'correo': cliente.correo,
        'direccion': cliente.direccion,
        'ciudad': cliente.ciudad,
        'estado': cliente.estado,
        'cp': cliente.cp,
        'pais': cliente.pais,
        'codigo_cliente': cliente.codigoCliente,
        'nota': cliente.nota,
        'distribuidor': cliente.distribuidor.toString(),
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
    var url = Uri.parse('$baseUrl/clientes/${sesion.idNegocio}');
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
          clienteTemp.correo = decodedData['data'][x]['correoñ'];
          clienteTemp.telefono = decodedData['data'][x]['telefono'];
          clienteTemp.direccion = decodedData['data'][x]['direccion'];
          clienteTemp.ciudad = decodedData['data'][x]['ciudad'];
          clienteTemp.estado = decodedData['data'][x]['estado'];
          clienteTemp.cp = decodedData['data'][x]['cp'];
          clienteTemp.pais = decodedData['data'][x]['pais'];
          clienteTemp.codigoCliente = decodedData['data'][x]['codigo_cliente'];
          clienteTemp.nota = decodedData['data'][x]['nota'];
          clienteTemp.distribuidor =
              int.parse(decodedData['data'][x]['distribuidor']);
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
    print(listaClientes.length);
    return respuesta;
  }

  Future<Cliente> consultaCliente(int idCliente) async {
    Cliente cliente = Cliente();
    var url = Uri.parse('$baseUrl/cliente/$idCliente');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        cliente.id = decodedData['data']['id'];
        cliente.nombre = decodedData['data']['nombre'];
        cliente.correo = decodedData['data']['correo'];
        cliente.telefono = decodedData['data']['telefono'];
        cliente.direccion = decodedData['data']['direccion'];
        cliente.ciudad = decodedData['data']['ciudad'];
        cliente.estado = decodedData['data']['estado'];
        cliente.cp = decodedData['data']['cp'];
        cliente.pais = decodedData['data']['pais'];
        cliente.codigoCliente = decodedData['data']['codigo_cliente'];
        cliente.nota = decodedData['data']['nota'];
        cliente.distribuidor = int.parse(decodedData['data']['distribuidor']);
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
    var url = Uri.parse('$baseUrl/clientes/${cliente.id}');
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
        'distribuidor': cliente.distribuidor.toString(),
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
    var url = Uri.parse('$baseUrl/clientes/$idCliente');
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
