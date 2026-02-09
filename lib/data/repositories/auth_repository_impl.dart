import '../local/database_helper.dart';

class AuthRepositoryImpl {
  final _dbHelper = DatabaseHelper();

  // Esta es la función que te marcaba error
  Future<int> registrarUsuario(
    String nombre,
    String correo,
    String password,
    String rol,
  ) async {
    final db = await _dbHelper.database;

    // Insertamos en la tabla 'usuarios'
    return await db.insert('usuarios', {
      'nombre': nombre,
      'correo': correo,
      'password': password,
      'rol': rol,
    });
  }

  // Esta sirve para el Login
  Future<bool> validarLogin(String correo, String password) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'correo = ? AND password = ?',
      whereArgs: [correo, password],
    );

    return maps.isNotEmpty;
  }
}
