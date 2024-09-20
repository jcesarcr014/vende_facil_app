class ApartadoPagadoModel {
  final int? id;
  final int? negocioId;
  final int? sucursalId;
  final int? usuarioId;
  final int? clienteId;
  final String? folio;
  final double? subtotal;
  final int? descuentoId;
  final double? descuento;
  final double? total;
  final double? anticipo;
  final double? pagoEfectivo;
  final double? pagoTarjeta;
  final double? saldoPendiente;
  final DateTime? fechaApartado;
  final DateTime? fechaVencimiento;
  final DateTime? fechaPagoTotal;
  final DateTime? fechaEntrega;
  final String? cancelado;
  final String? pagado;
  final String? entregado;
  final DateTime? fechaCancelacion;

  ApartadoPagadoModel({
    this.id,
    this.negocioId,
    this.sucursalId,
    this.usuarioId,
    this.clienteId,
    this.folio,
    this.subtotal,
    this.descuentoId,
    this.descuento,
    this.total,
    this.anticipo,
    this.pagoEfectivo,
    this.pagoTarjeta,
    this.saldoPendiente,
    this.fechaApartado,
    this.fechaVencimiento,
    this.fechaPagoTotal,
    this.fechaEntrega,
    this.cancelado,
    this.pagado,
    this.entregado,
    this.fechaCancelacion,
  });
}

final List<ApartadoPagadoModel> apartadosPagados = [];