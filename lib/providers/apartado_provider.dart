import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vende_facil/models/models.dart';
import 'package:vende_facil/providers/globals.dart' as globals;

class ApartadoProvider {
  final baseUrl = globals.baseUrl;
  Resultado respuesta = Resultado();
  Future<Resultado> guardaApartadoSucursal(ApartadoCabecera apartado) async {
    var url = Uri.parse('$baseUrl/apartado/${sesion.idSucursal}');
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
        'fecha_apartado': apartado.fechaApartado,
        'fecha_vencimiento': apartado.fechaVencimiento,
        'fecha_pago_total': apartado.fechaVencimiento,
        'sucursal_id': sesion.idSucursal!.toString(),
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
        respuesta.id = decodedData['apartado_id'];
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

  Future<Resultado> guardaApartadoDetalle(
    ApartadoDetalle apartado,
  ) async {
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
        'id_apartado': apartado.idsucursal.toString(),
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
          apartado.idnegocio = decodedData['apartados'][x]['negocio_id'];
          apartado.usuarioId = decodedData['apartados'][x]['usuario_id'];
          apartado.clienteId = decodedData['apartados'][x]['cliente_id'];
          apartado.folio = decodedData['apartados'][x]['folio'];
          apartado.subtotal =
              double.parse(decodedData['apartados'][x]['subtotal']);
          apartado.descuentoId = decodedData['apartados'][x]['descuento_id'];
          apartado.descuento =
              double.parse(decodedData['apartados'][x]['descuento']);
          apartado.total = double.parse(decodedData['apartados'][x]['total']);
          apartado.anticipo =
              double.parse(decodedData['apartados'][x]['anticipo']);
          apartado.pagoEfectivo =
              double.parse(decodedData['apartados'][x]['pago_efectivo']);
          apartado.pagoTarjeta =
              double.parse(decodedData['apartados'][x]['pago_tarjeta']);
          apartado.saldoPendiente =
              double.parse(decodedData['apartados'][x]['saldo_pendiente']);
          apartado.fechaApartado =
              decodedData['apartados'][x]['fecha_apartado'];
          apartado.fechaVencimiento =
              decodedData['apartados'][x]['fecha_vencimiento'];
          apartado.fechaPagoTotal =
              decodedData['apartados'][x]['fecha_pago_total'];
          apartado.fechaEntrega = decodedData['apartados'][x]['fecha_entrega'];
          apartado.cancelado =
              int.parse(decodedData['apartados'][x]['cancelado']);
          apartado.pagado = int.parse(decodedData['apartados'][x]['pagado']);
          apartado.entregado =
              int.parse(decodedData['apartados'][x]['entregado']);
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
    var url = Uri.parse('$baseUrl/apartado-detalle/$idApartado');
    listaApartados2.clear();
    try {
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      });
      final decodedData = jsonDecode(resp.body);
      if (decodedData['status'] == 1) {
        respuesta.status = 1;
        respuesta.mensaje = decodedData['msg'];
        apartadoSeleccionado.id = decodedData['apartado'][0]['id'];
        apartadoSeleccionado.usuarioId =
            decodedData['apartado'][0]['usuario_id'];
        apartadoSeleccionado.clienteId =
            decodedData['apartado'][0]['cliente_id'];
        apartadoSeleccionado.folio = decodedData['apartado'][0]['folio'];
        apartadoSeleccionado.subtotal =
            double.parse(decodedData['apartado'][0]['subtotal']);
        apartadoSeleccionado.descuentoId =
            decodedData['apartado'][0]['descuento_id'];
        apartadoSeleccionado.descuento =
            double.parse(decodedData['apartado'][0]['descuento']);
        apartadoSeleccionado.total =
            double.parse(decodedData['apartado'][0]['total']);
        apartadoSeleccionado.anticipo =
            double.parse(decodedData['apartado'][0]['anticipo']);
        apartadoSeleccionado.pagoEfectivo =
            double.parse(decodedData['apartado'][0]['pago_efectivo']);
        apartadoSeleccionado.pagoTarjeta =
            double.parse(decodedData['apartado'][0]['pago_tarjeta']);
        apartadoSeleccionado.saldoPendiente =
            double.parse(decodedData['apartado'][0]['saldo_pendiente']);
        apartadoSeleccionado.fechaApartado =
            decodedData['apartado'][0]['fecha_apartado'];
        apartadoSeleccionado.fechaVencimiento =
            decodedData['apartado'][0]['fecha_vencimiento'];
        apartadoSeleccionado.fechaPagoTotal =
            decodedData['apartado'][0]['fecha_pago_total'];
        apartadoSeleccionado.fechaEntrega =
            decodedData['apartado'][0]['fecha_entrega'];
        apartadoSeleccionado.cancelado =
            int.parse(decodedData['apartado'][0]['cancelado']);
        apartadoSeleccionado.pagado =
            int.parse(decodedData['apartado'][0]['pagado']);
        apartadoSeleccionado.entregado =
            int.parse(decodedData['apartado'][0]['entregado']);
        apartadoSeleccionado.fechaCancelacion =
            decodedData['apartado'][0]['fecha_cancelacion'];
        listaApartados2.add(apartadoSeleccionado);

        detalleApartado.clear();
        for (int x = 0; x < decodedData['detalle'].length; x++) {
          ApartadoDetalle detalleTemp = ApartadoDetalle();
          detalleTemp.id = decodedData['detalle'][x]['id'];
          detalleTemp.apartadoId = decodedData['detalle'][x]['apartado_id'];
          detalleTemp.productoId = decodedData['detalle'][x]['producto_id'];
          detalleTemp.cantidad =
              double.parse(decodedData['detalle'][x]['cantidad']);
          detalleTemp.precio =
              double.parse(decodedData['detalle'][x]['precio']);
          detalleTemp.subtotal =
              double.parse(decodedData['detalle'][x]['subtotal']);
          detalleTemp.descuento =
              double.parse(decodedData['detalle'][x]['descuento']);
          detalleTemp.total = double.parse(decodedData['detalle'][x]['total']);
          detalleTemp.descuentoId = decodedData['detalle'][x]['descuento_id'];
          detalleTemp.producto = decodedData['detalle'][x]['producto'];
          detalleApartado.add(detalleTemp);
        }

        listaAbonos.clear();
        for (int x = 0; x < decodedData['abonos'].length; x++) {
          Abono abonoTemp = Abono();
          abonoTemp.id = decodedData['abonos'][x]['id'];
          abonoTemp.apartadoId = decodedData['abonos'][x]['apartado_id'];
          abonoTemp.saldoAnterior =
              double.parse(decodedData['abonos'][x]['saldo_anterior']);
          abonoTemp.cantidadEfectivo =
              double.parse(decodedData['abonos'][x]['cantidad_efectivo']);
          abonoTemp.cantidadTarjeta =
              double.parse(decodedData['abonos'][x]['cantidad_tarjeta']);
          abonoTemp.saldoActual =
              double.parse(decodedData['abonos'][x]['saldo_actual']);
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

  Future<Resultado> abono(int idApartado, Abono abono) async {
    var url = Uri.parse('$baseUrl/apartado-abono/$idApartado');
    try {
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer ${sesion.token}',
      }, body: {
        'saldo_anterior': "100",
        'cantidad_efectivo': abono.cantidadEfectivo?.toStringAsFixed(2),
        'cantidad_tarjeta': abono.cantidadTarjeta?.toStringAsFixed(2),
        'saldo_actual': "0",
        'usuario_id': sesion.idUsuario.toString(),
        'negocio_id': sesion.idNegocio.toString(),
        'sucursal_id': sesion.idSucursal.toString(),
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
