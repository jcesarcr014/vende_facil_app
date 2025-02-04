class MovimientoCorte {
  int? id;
  int? idNegocio;
  int? idSucursal;
  int? idUsario;
  int? idMovimiento;
  String? tipoMovimiento; // V = Venta, P = Apartado, A = Abono
  String? montoEfectivo;
  String? montoTarjeta;
  String? total;
  int? idCorte;

  MovimientoCorte(
      {this.id,
      this.idNegocio,
      this.idSucursal,
      this.idUsario,
      this.idMovimiento,
      this.tipoMovimiento,
      this.montoEfectivo,
      this.montoTarjeta,
      this.total,
      this.idCorte});
}

List<MovimientoCorte> listaMovimientosCorte = [];
