class ApartadoDetalle {
  int? id;
  int? apartadoId;
  int? productoId;
  double? cantidad;
  double? precio;
  double? subtotal;
  double? descuento;
  double? total;
  int? descuentoId;
  String? producto;
  int? idsucursal;

  ApartadoDetalle(
      {this.id,
      this.apartadoId,
      this.productoId,
      this.cantidad,
      this.precio,
      this.subtotal,
      this.descuento,
      this.total,
      this.descuentoId,
      this.producto,
      this.idsucursal,
      });
}

List<ApartadoDetalle> detalleApartado = [];
