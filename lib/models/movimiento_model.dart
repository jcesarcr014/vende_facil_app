class MovimientoCorte {
  int? id;
  int? idNegocio;
  int? idSucursal;
  int? idUsario;
  int? idCliente;
  int? idMovimiento;
  int? idCorte;
  String? tipoMovimiento;
  String?
      folio; // VT = Venta tienda,  VD = Venta domicilio, P = Apartado, A = Abono, E = Entrega
  String? montoEfectivo;
  String? montoTarjeta;
  String? total;
  String? fecha;
  String? hora;
  String? nombreSucursal;
  String? nombreUsuario;
  String? nombreCliente;

  MovimientoCorte({
    this.id,
    this.idNegocio,
    this.idSucursal,
    this.idUsario,
    this.idCliente,
    this.idMovimiento,
    this.idCorte,
    this.tipoMovimiento,
    this.folio,
    this.montoEfectivo,
    this.montoTarjeta,
    this.total,
    this.fecha,
    this.hora,
    this.nombreSucursal,
    this.nombreUsuario,
    this.nombreCliente,
  });
}

List<MovimientoCorte> listaMovimientosCorte = [];
List<MovimientoCorte> listaMovimientosReporte = [];
