// ignore_for_file: non_constant_identifier_names
class Cotizacion {
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
  String? name;
  String? tipo_movimiento;
  int? id_sucursal;
  int? dias_vigentes;
  Cotizacion({
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
    this.name,
    this.tipo_movimiento,
    this.id_sucursal,
    this.dias_vigentes,
  });
}

List<Cotizacion> listacotizacion = [];
