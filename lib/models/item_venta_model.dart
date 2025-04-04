class ItemVenta {
  int idArticulo;
  String articulo;
  double cantidad;
  double precioPublico;
  double precioMayoreo;
  double precioDistribuidor;
  double precioUtilizado;
  int idDescuento;
  double descuento;
  double subTotalItem;
  double totalItem;
  bool apartado;

  ItemVenta({
    required this.idArticulo,
    required this.articulo,
    required this.cantidad,
    required this.precioPublico,
    required this.precioMayoreo,
    required this.precioDistribuidor,
    required this.precioUtilizado,
    required this.idDescuento,
    required this.descuento,
    required this.subTotalItem,
    required this.totalItem,
    required this.apartado,
  });
}

List<ItemVenta> ventaTemporal = [];
double subtotalVT = 0.0;
double descuentoVT = 0.0;
double totalVT = 0.0;
double ahorroVT = 0.0;
bool ventaDomicilio = false;
List<ItemVenta> cotizarTemporal = [];
double totalCotizacionTemporal = 0;
bool apartadoValido = true;
