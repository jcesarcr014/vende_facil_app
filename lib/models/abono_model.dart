class Abono {
  int? id;
  int? apartadoId;
  double? saldoAnterior;
  double? cantidadEfectivo;
  double? cantidadTarjeta;
  double? saldoActual;
  String? fechaAbono;

  Abono({
    this.id,
    this.apartadoId,
    this.saldoAnterior,
    this.cantidadEfectivo,
    this.cantidadTarjeta,
    this.saldoActual,
    this.fechaAbono,
  });
}

List<Abono> listaAbonos = [];
