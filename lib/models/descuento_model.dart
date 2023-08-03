class Descuento {
  int? id;
  String? nombre;
  double? valor;
  int? tipoValor; //1-> %, 2->$
  int? valorPred; // 1 -> si, 0 -> no

  Descuento({this.id, this.nombre, this.valor, this.tipoValor, this.valorPred});
}

List<Descuento> listaDescuentos = [];
