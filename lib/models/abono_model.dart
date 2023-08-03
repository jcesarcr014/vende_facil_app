class AbonoDetalle {
  int? id;
  int idMov;
  double cantidad;
  String fecha;

  AbonoDetalle({
    this.id,
    required this.idMov,
    required this.cantidad,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'idMov': idMov, 'cantidad': cantidad, 'fecha': fecha};
  }
}
