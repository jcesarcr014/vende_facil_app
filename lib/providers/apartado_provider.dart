import 'dart:convert';
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;
import 'package:http/http.dart' as http;

class ApartadoProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();

  Future<Resultado> guardaApartado(ApartadoCabecera apartado) async {
    var url = Uri.parse('$baseUrl/apartado/${sesion.idNegocio}');
    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'usuario_id': sesion.idUsuario.toString(),
        'cliente_id': apartado.clienteId.toString(),
        'subtotal': apartado.subtotal!.toStringAsFixed(2),
        'descuento_id': apartado.descuentoId.toString(),
        'descuento': apartado.descuento!.toStringAsFixed(2),
        'total': apartado.total!.toStringAsFixed(2),
        'anticipo': apartado.anticipo!.toStringAsFixed(2),
        'pago_efectivo': apartado.pagoEfectivo!.toStringAsFixed(2),
        'pago_tarjeta': apartado.pagoTarjeta!.toStringAsFixed(2),
        'saldo_pendiente': apartado.saldoPendiente!.toStringAsFixed(2),
        'fecha_apartado': apartado.fechaApartado.toString(),
        'fecha_vencimiento': apartado.fechaVencimiento.toString(),
        'fecha_pago_total': apartado.fechaApartado.toString(),
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
        respuesta.id = decodedData['apartado_id'];
        print('id apartado ${respuesta.id}');
      } else {
        respuesta.status = 0;
        respuesta.mensaje = decodedData['msg'];
      }
    } catch (e) {
      respuesta.status = 0;
      respuesta.mensaje = 'Error en la peticion. $e';
      print('Error en la peticion. $e');
    }

    return respuesta;
  }

  Future<Resultado> guardaApartadoDetalle(
    ApartadoDetalle apartado,
  ) async {
    print(apartado.apartadoId);
    var url = Uri.parse('$baseUrl/apartado-detalle/${apartado.apartadoId}');
    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'producto_id': apartado.productoId.toString(),
        'cantidad': apartado.cantidad.toString(),
        'precio': apartado.precio.toString(),
        'subtotal': apartado.subtotal.toString(),
        'descuento': apartado.descuento.toString(),
        'total': apartado.total.toString(),
        'descuento_id': apartado.descuentoId.toString(),
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
      print('Error en la peticion. $e');
    }

    return respuesta;
  }

  Future<Resultado> guardaAbono(Abono abono, int idApartado) async {
    var url = Uri.parse('$baseUrl/apartado-abono/$idApartado');
    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'saldo_anterior': abono.saldoAnterior.toString(),
        'cantidad_efectivo': abono.cantidadEfectivo.toString(),
        'cantidad_tarjeta': abono.cantidadTarjeta.toString(),
        'saldo_actual': abono.saldoActual.toString(),
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

  Future<Resultado> listarApartados() async {
    var url = Uri.parse('$baseUrl/apartado/${sesion.idNegocio}');

    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
        listaApartados.clear();
        for (int x = 0; x < decodedData['apartados'].length; x++) {
          ApartadoCabecera apartado = ApartadoCabecera();
          apartado.id = decodedData['apartados'][x]['id'];
          apartado.usuarioId = decodedData['apartados'][x]['usuario_id'];
          apartado.clienteId = decodedData['apartados'][x]['cliente_id'];
          apartado.folio = decodedData['apartados'][x]['folio'];
          apartado.subtotal = decodedData['apartados'][x]['subtotal'];

          apartado.descuentoId = decodedData['apartados'][x]['descuento_id'];
          apartado.descuento = decodedData['apartados'][x]['descuento'];
          apartado.total = decodedData['apartados'][x]['total'];
          apartado.anticipo = decodedData['apartados'][x]['anticipo'];
          apartado.pagoEfectivo = decodedData['apartados'][x]['pago_efectivo'];
          apartado.pagoTarjeta = decodedData['apartados'][x]['pago_tarjeta'];
          apartado.saldoPendiente =
              decodedData['apartados'][x]['saldo_pendiente'];
          apartado.fechaApartado =
              decodedData['apartados'][x]['fecha_apartado'];
          apartado.fechaVencimiento =
              decodedData['apartados'][x]['fecha_vencimiento'];
          apartado.fechaPagoTotal =
              decodedData['apartados'][x]['fecha_pago_total'];
          apartado.fechaEntrega = decodedData['apartados'][x]['fecha_entrega'];
          apartado.cancelado = decodedData['apartados'][x]['cancelado'];
          apartado.pagado = decodedData['apartados'][x]['pagado'];
          apartado.entregado = decodedData['apartados'][x]['entregado'];
          apartado.fechaCancelacion =
              decodedData['apartados'][x]['fecha_cancelacion'];

          listaApartados.add(apartado);
        }
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

  Future<Resultado> detallesApartado(int idApartado) async {
    var url = Uri.parse('$baseUrl/apartado-detalle/${sesion.idNegocio}');
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
        apartadoSeleccionado.id = decodedData['apartado']['id'];
        apartadoSeleccionado.usuarioId = decodedData['apartado']['usuario_id'];
        apartadoSeleccionado.clienteId = decodedData['apartado']['cliente_id'];
        apartadoSeleccionado.folio = decodedData['apartado']['folio'];
        apartadoSeleccionado.subtotal = decodedData['apartado']['subtotal'];

        apartadoSeleccionado.descuentoId =
            decodedData['apartado']['descuento_id'];
        apartadoSeleccionado.descuento = decodedData['apartado']['descuento'];
        apartadoSeleccionado.total = decodedData['apartado']['total'];
        apartadoSeleccionado.anticipo = decodedData['apartado']['anticipo'];
        apartadoSeleccionado.pagoEfectivo =
            decodedData['apartado']['pago_efectivo'];
        apartadoSeleccionado.pagoTarjeta =
            decodedData['apartado']['pago_tarjeta'];
        apartadoSeleccionado.saldoPendiente =
            decodedData['apartado']['saldo_pendiente'];
        apartadoSeleccionado.fechaApartado =
            decodedData['apartado']['fecha_apartado'];
        apartadoSeleccionado.fechaVencimiento =
            decodedData['apartado']['fecha_vencimiento'];
        apartadoSeleccionado.fechaPagoTotal =
            decodedData['apartado']['fecha_pago_total'];
        apartadoSeleccionado.fechaEntrega =
            decodedData['apartado']['fecha_entrega'];
        apartadoSeleccionado.cancelado = decodedData['apartado']['cancelado'];
        apartadoSeleccionado.pagado = decodedData['apartado']['pagado'];
        apartadoSeleccionado.entregado = decodedData['apartado']['entregado'];
        apartadoSeleccionado.fechaCancelacion =
            decodedData['apartado']['fecha_cancelacion'];

        detalleApartado.clear();
        for (int x = 0; x < decodedData['detalle'].length; x++) {
          ApartadoDetalle detalleTemp = ApartadoDetalle();
          detalleTemp.id = decodedData['detalle'][x]['id'];
          detalleTemp.apartadoId = decodedData['detalle'][x]['apartado_id'];
          detalleTemp.productoId = decodedData['detalle'][x]['producto_id'];
          detalleTemp.cantidad = decodedData['detalle'][x]['cantidad'];
          detalleTemp.precio = decodedData['detalle'][x]['precio'];
          detalleTemp.subtotal = decodedData['detalle'][x]['subtotal'];
          detalleTemp.descuento = decodedData['detalle'][x]['descuento'];
          detalleTemp.total = decodedData['detalle'][x]['total'];
          detalleTemp.descuentoId = decodedData['detalle'][x]['descuento_id'];
          detalleApartado.add(detalleTemp);
        }

        listaAbonos.clear();
        for (int x = 0; x < decodedData['abonos'].length; x++) {
          Abono abonoTemp = Abono();
          abonoTemp.id = decodedData['abonos'][x]['id'];
          abonoTemp.apartadoId = decodedData['abonos'][x]['apartado_id'];
          abonoTemp.saldoAnterior = decodedData['abonos'][x]['saldo_anterior'];
          abonoTemp.cantidadEfectivo =
              decodedData['abonos'][x]['cantidad_efectivo'];
          abonoTemp.cantidadTarjeta =
              decodedData['abonos'][x]['cantidad_tarjeta'];
          abonoTemp.saldoActual = decodedData['abonos'][x]['saldo_actual'];
          abonoTemp.fechaAbono = decodedData['abonos'][x]['fecha_abono'];
          listaAbonos.add(abonoTemp);
        }
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

  Future<Resultado> entregarProducto(int idApartado) async {
    var url = Uri.parse('$baseUrl/apartado-entrega/$idApartado');
    try {
      final resp = await http.put(url, headers: {
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
      respuesta.mensaje = 'Error en la peticion. $e';
    }
    return respuesta;
  }

  Future<Resultado> cancelarApartado(int idApartado) async {
    var url = Uri.parse('$baseUrl/apartado-cancelar/$idApartado');
    try {
      final resp = await http.put(url, headers: {
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
      respuesta.mensaje = 'Error en la peticion. $e';
    }
    return respuesta;
  }
}
