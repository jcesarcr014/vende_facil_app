import 'package:sqflite/sqflite.dart';

class DB {
  static Future<Database> _openDB() async {
    return openDatabase(
      'vende_facil.db',
      version: 1,
      onCreate: (db, version) {
        db.execute('''CREATE TABLE categorias(id INTEGER PRIMARY KEY AUTOINCREMENT,categoria TEXT,idColor INTEGER)''');
        db.execute('''CREATE TABLE clientes(id INTEGER PRIMARY KEY AUTOINCREMENT,nombre TEXT,correo TEXT,telefono TEXT,direccion TEXT,ciudad TEXT,estado TEXT,cp TEXT,pais TEXT,codigoCliente TEXT,nota TEXT)''');
        db.execute('''CREATE TABLE productos(id INTEGER PRIMARY KEY AUTOINCREMENT,producto TEXT,descripcion TEXT,idCategoria INTEGER,unidad TEXT,precio REAL,costo REAL,clave TEXT,codigoBarras TEXT,inventario INTEGER,imagen TEXT,apartado INTEGER,idInventario INTEGER,idNegocio INTEGER,idproducto INTEGER,cantidad REAL,catidadApartado REAL,disponible REAL)''');
      },
    );
  }
}
