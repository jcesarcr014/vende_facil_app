class CuentaSesion {
  int? idUsuario;
  String? tipoUsuario;
  int? idNegocio;
  int? idSucursal;
  String? token;
  String? nombreUsuario;
  String? email;
  String? telefono;
  bool? cotizar;
  String? sucursal;
  bool? caja;

  CuentaSesion(
      {this.idUsuario,
      this.tipoUsuario,
      this.idNegocio,
      this.idSucursal,
      this.token,
      this.nombreUsuario,
      this.email,
      this.telefono,
      this.cotizar,
      this.sucursal,
      this.caja});

  void limpiar() {
    idUsuario = null;
    tipoUsuario = null;
    idNegocio = null;
    idSucursal = null;
    token = null;
    nombreUsuario = null;
    email = null;
    telefono = null;
    cotizar = null;
    sucursal = null;
    caja = null;
  }
}

CuentaSesion sesion = CuentaSesion();
