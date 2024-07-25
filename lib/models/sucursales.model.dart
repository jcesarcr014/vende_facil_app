class Sucursale{
  int? id;
  int? negocioId;
  String? nombreSucursal;
  String? direccion;
  String? telefono;
  Sucursale({
    this.id,
    this.negocioId,
    this.nombreSucursal,
    this.direccion,
    this.telefono,
  });
  void limpiar() {
    id = null;
    negocioId = null;
    nombreSucursal = null;
    direccion = null;
    telefono = null;
  }
  void asignarValores({
    int? id,
    int? negocioId,
    String? nombreSucursal,
    String? direccion,
    String? telefono,
  }) {
    this.id = id;
    this.negocioId = negocioId;
    this.nombreSucursal = nombreSucursal;
    this.direccion = direccion;
    this.telefono = telefono;
  }



}
List<Sucursale> listaSucursales = [];
Sucursale sucursalSeleccionado = Sucursale();