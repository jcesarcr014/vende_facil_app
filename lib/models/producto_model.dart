class Producto {
  int? id;
  String? producto;
  String? descripcion;
  int? idCategoria;
  String? unidad;
  double? precio;
  double? costo;
  String? clave;
  String? codigoBarras;
  int? inventario;
  String? imagen;
  int? apartado;

  Producto({
    this.id,
    this.producto,
    this.descripcion,
    this.idCategoria,
    this.unidad,
    this.precio,
    this.costo,
    this.clave,
    this.codigoBarras,
    this.inventario,
    this.imagen,
    this.apartado,
  });
}

List<Producto> listaProductos = [];
