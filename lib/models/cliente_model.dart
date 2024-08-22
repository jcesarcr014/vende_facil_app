class Cliente {
  int? id;
  String? nombre;
  String? correo;
  String? telefono;
  String? direccion;
  String? ciudad;
  String? estado;
  String? cp;
  String? pais;
  String? codigoCliente;
  String? nota;
  int? distribuidor;
  Cliente({
    this.id,
    this.nombre,
    this.correo,
    this.telefono,
    this.direccion,
    this.ciudad,
    this.estado,
    this.cp,
    this.pais,
    this.codigoCliente,
    this.nota,
    this.distribuidor,
  });
}

List<Cliente> listaClientes = [];
