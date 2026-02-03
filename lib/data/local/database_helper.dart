import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'finanzas.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Creamos la tabla de gastos según tu diseño
        await db.execute('''
          CREATE TABLE gastos (
            id TEXT PRIMARY KEY,
            monto REAL,
            fecha TEXT,
            nota TEXT,
            categoriaId TEXT
          )
        ''');
        // Tabla de roles/usuarios para el registro
        await db.execute('''
          CREATE TABLE usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT,
            correo TEXT,
            password TEXT,
            rol TEXT
          )
        ''');
      },
    );
  }
}
