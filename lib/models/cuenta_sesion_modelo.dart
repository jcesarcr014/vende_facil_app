class CuentaSesion {
  int? idUsuario;
  String? tipoUsuario;
  int? idNegocio;
  int? idSucursal;
  String? token;
  String? nombreUsuario;
  String? email;
  String? telefono;

  CuentaSesion(
      {this.idUsuario,
      this.tipoUsuario,
      this.idNegocio,
      this.idSucursal,
      this.token,
      this.nombreUsuario,
      this.email,
      this.telefono});
}

CuentaSesion sesion = CuentaSesion();
