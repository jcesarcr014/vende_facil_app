import 'package:sqflite/sqflite.dart';

class DB {
  static Future<Database> _openDB() async {
    return openDatabase(
      'vende_facil.db',version: 1,
      onCreate: (db, version) async {
         await db.execute('''CREATE TABLE categorias(id INTEGER PRIMARY KEY AUTOINCREMENT,categoria TEXT,idColor INTEGER)''');
         await db.execute('''CREATE TABLE clientes(id INTEGER PRIMARY KEY AUTOINCREMENT,nombre TEXT,correo TEXT,telefono TEXT,direccion TEXT,ciudad TEXT,estado TEXT,cp TEXT,pais TEXT,codigoCliente TEXT,nota TEXT)''');
         await db.execute('''CREATE TABLE productos(id INTEGER PRIMARY KEY AUTOINCREMENT,producto TEXT,descripcion TEXT,idCategoria INTEGER,unidad TEXT,precio REAL,costo REAL,clave TEXT,codigoBarras TEXT,inventario INTEGER,imagen TEXT,apartado INTEGER,idInventario INTEGER,idNegocio INTEGER,idproducto INTEGER,cantidad REAL,catidadApartado REAL,disponible REAL)''');
      },
    );
  }
  static Future<void> deleteDatabase() async {
    databaseFactory.deleteDatabase(await getDatabasesPath());
  }

  static Future<int> limpiaTablaproductos() async {
    Database database = await _openDB();
    int resultado = await database.rawDelete('DELETE FROM productos');
    return resultado;
  }
  static Future<int> limpiaTablacategorias() async {
    Database database = await _openDB();
    int resultado = await database.rawDelete('DELETE FROM categorias');
    return resultado;
  }
  static Future<int> limpiaTablaclientes() async {
    Database database = await _openDB();
    int resultado = await database.rawDelete('DELETE FROM clientes');
    return resultado;
  }
  
}
