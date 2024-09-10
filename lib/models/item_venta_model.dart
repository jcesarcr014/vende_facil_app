class ItemVenta {
  int idArticulo;
  double cantidad;
  double precioPublico;
  int idDescuento;
  double descuento;
  double subTotalItem;
  double totalItem;
  bool apartado;
  double preciomayoreo;
  double preciodistribuidor;


  ItemVenta(
      {required this.idArticulo,
      required this.cantidad,
      required this.precioPublico,
      required this.idDescuento,
      required this.descuento,
      required this.subTotalItem,
      required this.totalItem,
      required this.apartado,
      required this.preciomayoreo,
      required this.preciodistribuidor
      
      });
}

List<ItemVenta> ventaTemporal = [];
double totalVentaTemporal = 0;
List<ItemVenta> cotizarTemporal = [];
double totalCotizacionTemporal = 0;
bool apartadoValido = true;
