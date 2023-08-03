class Existencia {
  int? id;
  int? idArticulo;
  double? cantidad;
  double? apartado;
  double? disponible;

  Existencia(
      {this.id,
      this.idArticulo,
      this.cantidad,
      this.apartado,
      this.disponible});
}

List<Existencia> inventario = [
  Existencia(id: 1, idArticulo: 1, cantidad: 16, disponible: 12),
  Existencia(id: 2, idArticulo: 2, cantidad: 13, apartado: 2, disponible: 11),
  Existencia(id: 3, idArticulo: 3, cantidad: 5, apartado: 0, disponible: 5),
];
