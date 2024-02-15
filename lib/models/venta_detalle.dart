class VentaDetalle {
  int? id;
  int? idProd;
  double? cantidad;
  double? precio;
  int? idDesc;
  double? cantidadDescuento;
  double? total;
  double?subtotal;
  VentaDetalle({
    this.id,
    required this.idProd,
    required this.cantidad,
    required this.precio,
    required this.idDesc,
    required this.cantidadDescuento,
    required this.total,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idProd': idProd,
      'cantidad': cantidad,
      'precio': precio,
      'idDesc': idDesc,
      'cantidadDescuento': cantidadDescuento,
      'total': total,
      'subtotal':subtotal,
    };
  }
}
