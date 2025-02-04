class Corte {
  int? id;
  int? idNegocio;
  int? idUsuario;
  int? idSucursal;
  String? fecha;
  String? efectivoInicial;
  String? ventasEfectivo;
  String? ventasTarjeta;
  String? totalIngresos;
  String? observaciones;
  int? numVentas;
  String? diferencia;
  String? tipoDiferencia;

  Corte(
      {this.id,
      this.idNegocio,
      this.idUsuario,
      this.idSucursal,
      this.fecha,
      this.efectivoInicial,
      this.ventasEfectivo,
      this.ventasTarjeta,
      this.totalIngresos,
      this.observaciones,
      this.numVentas,
      this.diferencia,
      this.tipoDiferencia});
}

Corte corteActual = Corte();

List<Corte> listaCortes = [];
