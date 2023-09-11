class TarjetaOP {
  int? id;
  String? digitos;
  String? fechaM;
  String? fechaA;
  String? ccv;
  String? banco;
  String? titular;

  TarjetaOP(
      {this.id,
      this.digitos,
      this.fechaM,
      this.fechaA,
      this.ccv,
      this.banco,
      this.titular});
}

List<TarjetaOP> listatarjetas = [];
