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

List<TarjetaOP> listatarjetas = [
  TarjetaOP(id: 1, digitos: '1234', banco: 'HSBC'),
  TarjetaOP(id: 2, digitos: '2345', banco: 'BBVA'),
  TarjetaOP(id: 3, digitos: '3456', banco: 'HEY!'),
  TarjetaOP(id: 4, digitos: '4567', banco: 'STP'),
];
