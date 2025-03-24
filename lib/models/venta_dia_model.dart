class VentaDia {
  int idVenta;
  String folio;
  String empleado;
  String sucursal;
  String producto;
  String cantidad;
  String precio;
  String subtotal;
  String total;
  String fechaVenta;

  VentaDia({
    required this.idVenta,
    required this.folio,
    required this.empleado,
    required this.sucursal,
    required this.producto,
    required this.cantidad,
    required this.precio,
    required this.subtotal,
    required this.total,
    required this.fechaVenta,
  });
}

List<VentaDia> listaVentasDia = [];
