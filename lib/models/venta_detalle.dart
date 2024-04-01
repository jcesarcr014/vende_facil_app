class VentaDetalle {
  int? id;
  int? idVenta;
  int? idProd;
  double? cantidad;
  double? precio;
  int? idDesc;
  double? cantidadDescuento;
  double? total;
  double? subtotal;
  VentaDetalle({
    this.id,
    required this.idVenta,
    required this.idProd,
    required this.cantidad,
    required this.precio,
    required this.idDesc,
    required this.cantidadDescuento,
    required this.total,
    required this.subtotal,
  });
}
