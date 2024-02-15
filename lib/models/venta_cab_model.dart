class VentaCabecera {
  int? id;
  int? idCliente;
  double? subtotal;
  int? idDescuento;
  double? descuento;
  double? total;
  double? importeEfectivo;
  double? importeTarjeta;
  VentaCabecera({
    this.id,
    required this.idCliente,
    required this.subtotal,
    required this.idDescuento,
    required this.descuento,
    required this.total,
    required this.importeEfectivo,
    required this.importeTarjeta,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idCliente': idCliente,
      'subtotal': subtotal,
      'descuento': descuento,
      'total': total,
      'importeEfectivo': importeEfectivo,
      'importeTarjeta': importeTarjeta,
    };
  }
}
