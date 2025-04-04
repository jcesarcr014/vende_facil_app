class Descuento {
  int? id;
  String? nombre;
  double? valor;

  Descuento({this.id, this.nombre, this.valor});
}

List<Descuento> listaDescuentos = [];
Descuento descuentoVentaActual = Descuento();
