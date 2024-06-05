class ItemVenta {
  int idArticulo;
  double cantidad;
  double precio;
  int idDescuento;
  double descuento;
  double subTotalItem;
  double totalItem;
  bool apartado;

  ItemVenta(
      {required this.idArticulo,
      required this.cantidad,
      required this.precio,
      required this.idDescuento,
      required this.descuento,
      required this.subTotalItem,
      required this.totalItem,
      required this.apartado});
}

List<ItemVenta> ventaTemporal = [];
double totalVentaTemporal = 0;
bool apartadoValido = true;
