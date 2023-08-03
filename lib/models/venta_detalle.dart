class VentaDetalle {
  int? id;
  int idMov;
  int idProd;
  double cantidad;
  double precio;
  int aplicoDesc;
  int? idDesc;
  double cantidadDescuento;
  double? total;
  int apartado;
  VentaDetalle({
    this.id,
    required this.idMov,
    required this.idProd,
    required this.cantidad,
    required this.precio,
    required this.aplicoDesc,
    this.idDesc,
    required this.cantidadDescuento,
    required this.total,
    required this.apartado,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idMov': idMov,
      'idProd': idProd,
      'cantidad': cantidad,
      'precio': precio,
      'aplicoDesc': aplicoDesc,
      'idDesc': idDesc,
      'cantidadDescuento': cantidadDescuento,
      'total': total,
      'apartado': apartado,
    };
  }
}
