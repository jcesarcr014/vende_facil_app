// En models/models.dart o un archivo similar

class MetodoPago {
  String marca;
  String ultimos4;
  int mesExp;
  int anoExp;

  MetodoPago({
    required this.marca,
    required this.ultimos4,
    required this.mesExp,
    required this.anoExp,
  });
}

MetodoPago? metodoPagoActual;