import 'package:vende_facil/models/models.dart';

class SucursalMapper {
  static Sucursal dataToSucursalModel(Map<String, dynamic> json) => Sucursal(
      id: json["id"],
      negocioId: json["negocio_id"],
      nombreSucursal: json["nombre_sucursal"],
      direccion: json["direccion"],
      telefono: json["telefono"]);
}
