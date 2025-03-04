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
  int? venta_realizada;
  double? importeTarjeta;
  int? cancelado;
  DateTime? fecha_cotizacion;
  DateTime? fecha_vencimiento;
  String? fecha_cancelacion;
  String? nombreCliente;
  String? name;
  String? tipo_movimiento;
  int? id_sucursal;
  String? nombreSucursal;
  String? dirSucursal;
  String? telsucursal;
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
    this.venta_realizada,
    this.importeTarjeta,
    this.cancelado,
    this.fecha_cotizacion,
    this.fecha_vencimiento,
    this.fecha_cancelacion,
    this.nombreCliente,
    this.name,
    this.tipo_movimiento,
    this.id_sucursal,
    this.nombreSucursal,
    this.dirSucursal,
    this.telsucursal,
    this.dias_vigentes,
  });
}

List<Cotizacion> listacotizacion = [];
Cotizacion cotActual = Cotizacion();
