class ItemVenta {
  int idArticulo;
  double cantidad;
  double precio;
  int idDescuento;
  double descuento;
  double subTotalItem;
  double totalItem;

  ItemVenta({
    required this.idArticulo,
    required this.cantidad,
    required this.precio,
    required this.idDescuento,
    required this.descuento,
    required this.subTotalItem,
    required this.totalItem,
  });
}

List<ItemVenta> ventaTemporal = [];
double totalVentaTemporal = 0;
