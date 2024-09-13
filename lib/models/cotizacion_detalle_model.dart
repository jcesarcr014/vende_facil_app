// ignore_for_file: non_constant_identifier_names

class CotizacionDetalle {
  int? id;
  int? idcotizacion;
  int? idProd;
  double? cantidad;
  double? precio;
  int? idDesc;
  double? cantidadDescuento;
  double? total;
  double? subtotal;
  String? nombreProducto;
  int? id_sucursal;
  String? folio;
  CotizacionDetalle({
    this.folio,
    this.id,
    this.idcotizacion,
    this.idProd,
    this.cantidad,
    this.precio,
    this.idDesc,
    this.cantidadDescuento,
    this.total,
    this.subtotal,
    this.nombreProducto,
    this.id_sucursal,
  });
}

List<CotizacionDetalle> listacotizaciondetalles = [];
List<CotizacionDetalle> listacotizaciondetalles2 = [];