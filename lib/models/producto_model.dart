class Producto {
  int? id;
  int? idCategoria;
  int? idNegocio;
  String? producto;
  String? descripcion;
  String? unidad;
  double? precioPublico;
  double? precioMayoreo;
  double? precioDist;
  double? costo;
  double? cantidad;
  String? clave;
  String? codigoBarras;
  int? apartado;
  int? idInv;
  int? idSucursal;
  double? cantidadInv;
  double? apartadoInv;
  double? disponibleInv;

  Producto({
    this.id,
    this.idCategoria,
    this.idNegocio,
    this.producto,
    this.descripcion,
    this.unidad,
    this.precioPublico,
    this.precioMayoreo,
    this.precioDist,
    this.costo,
    this.cantidad,
    this.clave,
    this.codigoBarras,
    this.apartado,
    this.idInv,
    this.idSucursal,
    this.cantidadInv,
    this.apartadoInv,
    this.disponibleInv,
  });
}

List<Producto> listaProductos = [];
List<Producto> listaProductosCotizaciones = [];
List<Producto> listaProductosSucursal = [];
