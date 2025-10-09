class Corte {
  int? id;
  int? idNegocio;
  int? idUsuario;
  int? idSucursal;
  String? empleado;
  String? fecha;
  String? efectivoCaja;
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
      this.empleado,
      this.fecha,
      this.efectivoCaja,
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
