import 'package:vende_facil/models/models.dart';

class SucursalMapper {
  
  static Sucursale dataToSucursalModel(Map<String, dynamic> json) => Sucursale(id: json["id"], negocioId: json["negocio_id"], nombreSucursal: json["nombre_sucursal"], direccion: json["direccion"], telefono: json["telefono"]);

}