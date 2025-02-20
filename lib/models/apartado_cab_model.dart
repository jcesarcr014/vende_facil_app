class ApartadoCabecera {
  int? id;
  int? usuarioId;
  int? clienteId;
  int? idnegocio;
  int? idsucursal;
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
  String? nombreCliente;

  ApartadoCabecera(
      {this.id,
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
      this.idsucursal,
      this.nombreCliente});
}

ApartadoCabecera apartadoSeleccionado = ApartadoCabecera();
List<ApartadoCabecera> listaApartadosPendientes = [];
List<ApartadoCabecera> listaApartadosPagados = [];
List<ApartadoCabecera> listaApartadosEntregados = [];
List<ApartadoCabecera> listaApartadosCancelados = [];
