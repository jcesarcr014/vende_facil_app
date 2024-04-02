// ignore_for_file: non_constant_identifier_names
class VentaCabecera {
  int? id;
  int? negocioId;
  int? usuarioId;
  int? idCliente;
  String? folio;
  double? subtotal;
  int? idDescuento;
  double? descuento;
  double? total;
  double? importeEfectivo;
  double? importeTarjeta;
  int? cancelado;
  String? fecha_venta;
  String? fecha_cancelacion;
  String? nombreCliente;
  VentaCabecera({
    this.id,
    this.negocioId,
    this.usuarioId,
    this.idCliente,
    this.folio,
    this.subtotal,
    this.idDescuento,
    this.descuento,
    this.total,
    this.importeEfectivo,
    this.importeTarjeta,
    this.cancelado,
    this.fecha_venta,
    this.fecha_cancelacion,
    this.nombreCliente,
  });
}

List<VentaCabecera> listaVentaCabecera = [];
List<VentaCabecera> listaVentaCabecera2 = [];
