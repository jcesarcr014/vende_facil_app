class ApartadoCabecera {
  int? id;
  int? usuarioId;
  int? clienteId;
  String? folio;
  double? subtotal;
  int? descuentoId;
  double? descuento;
  double? total;
  double? anticipo;
  double? pagoEfectivo;
  double? pagoTarjeta;
  double? saldoPendiente;
  String? fechaApartado;
  String? fechaVencimiento;
  String? fechaPagoTotal;
  String? fechaEntrega;
  int? cancelado;
  int? pagado;
  int? entregado;
  String? fechaCancelacion;
  int? idnegocio;

  ApartadoCabecera({
    this.id,
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
    this.idnegocio,
  });
}

ApartadoCabecera apartadoSeleccionado = ApartadoCabecera();
List<ApartadoCabecera> listaApartados = [];
List<ApartadoCabecera> listaApartados2 = [];
