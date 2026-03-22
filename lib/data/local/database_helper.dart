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
      version: 2, // 1. CAMBIAMOS LA VERSIÓN A 2
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE gastos (
            id TEXT PRIMARY KEY,
            monto REAL,
            fecha TEXT,
            nota TEXT,
            categoriaId TEXT,
            foto_path TEXT -- 2. AGREGAMOS ESTA COLUMNA
          )
        ''');

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
      // 3. AGREGAMOS ESTE BLOQUE PARA ACTUALIZAR SI YA EXISTÍA LA TABLA
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE gastos ADD COLUMN foto_path TEXT');
        }
      },
    );
  }
  
}
