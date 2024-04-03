class TarjetaOP {
  int? id;
  String? numero;
  String? fechaM;
  String? fechaA;
  String? ccv;

  String? titular;

  TarjetaOP(
      {this.id, this.numero, this.fechaM, this.fechaA, this.ccv, this.titular});
}

List<TarjetaOP> listaTarjetas = [];
