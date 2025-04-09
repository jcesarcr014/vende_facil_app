class ReporteDetalleDia {
  // Listas para almacenar los diferentes tipos de movimientos
  static List<ReporteVentaDetalle> listaVentasDia = [];
  static List<ReporteApartadoDetalle> listaApartadosDia = [];
  static List<ReporteAbonoDetalle> listaAbonosDia = [];

  // Método para limpiar las listas
  static void limpiarListas() {
    listaVentasDia.clear();
    listaApartadosDia.clear();
    listaAbonosDia.clear();
  }
}

// Modelo para detalles de ventas
class ReporteVentaDetalle {
  int? id;
  String? folio;
  String? vendedor;
  String? cliente;
  String? nombreSucursal;
  String? producto;
  String? cantidad;
  String? precio;
  String? subtotal;
  String? total;
  String? createdAt;

  ReporteVentaDetalle({
    this.id,
    this.folio,
    this.vendedor,
    this.cliente,
    this.nombreSucursal,
    this.producto,
    this.cantidad,
    this.precio,
    this.subtotal,
    this.total,
    this.createdAt,
  });

  // Método para crear un objeto a partir de un mapa (JSON)
  factory ReporteVentaDetalle.fromJson(Map<String, dynamic> json) {
    return ReporteVentaDetalle(
      id: json['id'],
      folio: json['folio'],
      vendedor: json['vendedor'],
      cliente: json['cliente'],
      nombreSucursal: json['nombre_sucursal'],
      producto: json['producto'],
      cantidad: json['cantidad'],
      precio: json['precio'],
      subtotal: json['subtotal'],
      total: json['total'],
      createdAt: json['created_at'],
    );
  }
}

// Modelo para detalles de apartados
class ReporteApartadoDetalle {
  int? id;
  String? folio;
  String? usuario;
  String? cliente;
  String? nombreSucursal;
  String? producto;
  String? cantidad;
  String? precio;
  String? total; // Total del producto
  String? anticipo; // Lo importante es el anticipo
  String? saldoPendiente;

  ReporteApartadoDetalle({
    this.id,
    this.folio,
    this.usuario,
    this.cliente,
    this.nombreSucursal,
    this.producto,
    this.cantidad,
    this.precio,
    this.total,
    this.anticipo,
    this.saldoPendiente,
  });

  // Método para crear un objeto a partir de un mapa (JSON)
  factory ReporteApartadoDetalle.fromJson(Map<String, dynamic> json) {
    return ReporteApartadoDetalle(
      id: json['id'],
      folio: json['folio'],
      usuario: json['usuario'],
      cliente: json['cliente'],
      nombreSucursal: json['nombre_sucursal'],
      producto: json['producto'],
      cantidad: json['cantidad'],
      precio: json['precio'],
      total: json['total'],
      anticipo: json['anticipo'],
      saldoPendiente: json['saldo_pendiente'],
    );
  }
}

// Modelo para abonos (sin detalle, solo la información del abono)
class ReporteAbonoDetalle {
  int? id;
  String? folioApartado; // Referencia al apartado original
  int? apartadoId;
  String? usuario;
  String? nombreSucursal;
  String? cliente;
  String? saldoAnterior;
  String? cantidadEfectivo;
  String? cantidadTarjeta;
  String? saldoActual;
  String? createdAt;

  ReporteAbonoDetalle({
    this.id,
    this.folioApartado,
    this.apartadoId,
    this.usuario,
    this.nombreSucursal,
    this.cliente,
    this.saldoAnterior,
    this.cantidadEfectivo,
    this.cantidadTarjeta,
    this.saldoActual,
    this.createdAt,
  });

  // Método para crear un objeto a partir de un mapa (JSON)
  factory ReporteAbonoDetalle.fromJson(Map<String, dynamic> json) {
    return ReporteAbonoDetalle(
      id: json['id'],
      folioApartado: json['folio_apartado'],
      apartadoId: json['apartado_id'],
      usuario: json['usuario'],
      nombreSucursal: json['nombre_sucursal'],
      cliente: json['cliente'],
      saldoAnterior: json['saldo_anterior'],
      cantidadEfectivo: json['cantidad_efectivo'],
      cantidadTarjeta: json['cantidad_tarjeta'],
      saldoActual: json['saldo_actual'],
      createdAt: json['created_at'],
    );
  }
}
