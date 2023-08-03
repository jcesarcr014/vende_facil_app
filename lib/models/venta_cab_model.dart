class VentaCabecera {
  int? id;
  int idCliente;
  double subtotal;
  double descuento;
  double total;
  String fecha;
  int idCajero;
  String tipo;
  double importeEfectivo;
  double importeTarjeta;
  double? saldo;
  String? fechaUltimaMod;

  VentaCabecera({
    this.id,
    required this.idCliente,
    required this.subtotal,
    required this.descuento,
    required this.total,
    required this.fecha,
    required this.idCajero,
    required this.tipo,
    required this.importeEfectivo,
    required this.importeTarjeta,
    this.saldo,
    this.fechaUltimaMod,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idCliente': idCliente,
      'subtotal': subtotal,
      'descuento': descuento,
      'total': total,
      'fecha': fecha,
      'idCajero': idCajero,
      'tipo': tipo,
      'importeEfectivo': importeEfectivo,
      'importeTarjeta': importeTarjeta,
      'saldo': saldo,
      'fechaUltimaMod': fechaUltimaMod,
    };
  }
}
