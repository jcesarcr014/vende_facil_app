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
    this.idCliente,
    this.subtotal,
    this.idDescuento,
    this.descuento,
    this.total,
    this.importeEfectivo,
    this.importeTarjeta,
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
List<VentaCabecera> listaVentaCabecera = [];
