class Usuario {
  int? id;
  String? nombre;
  String? email;
  String? telefono;
  String? tipoUsuario;
  String? token;
  String? estatus;

  Usuario(
      {this.id,
      this.nombre,
      this.email,
      this.telefono,
      this.tipoUsuario,
      this.token,
      this.estatus});
}

List<Usuario> listaEmpleados = [];
List<Usuario> listaUsuarios = [];
Usuario empleadoSeleccionado = Usuario();
