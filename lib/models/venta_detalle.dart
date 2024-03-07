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
    this.idVenta,
    this.idProd,
    this.cantidad,
    this.precio,
    this.idDesc,
    this.cantidadDescuento,
    this.total,
    this.subtotal,
  });
}
List<VentaDetalle> listaVentadetalles = [];
