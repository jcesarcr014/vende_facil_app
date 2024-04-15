class Usuario {
  int? id;
  String? nombre;
  String? email;
  String? telefono;
  String? tipoUsuario;
  String? token;

  Usuario(
      {this.id,
      this.nombre,
      this.email,
      this.telefono,
      this.tipoUsuario,
      this.token});
}

List<Usuario> listaEmpleados = [];
