import 'package:finanzas_moviles/domain/entities/user.dart';

import '../repositories/auth_repository_impl.dart';
import '../../core/session_manager.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  
  final AuthRepositoryImpl _repository = AuthRepositoryImpl();
  final SessionManager _sessionManager = SessionManager();

  // 1. Variable privada para guardar el usuario en memoria
  UserModel? _currentUser;

  // 2. Getter público para que la UI pueda leerlo
  UserModel? get currentUser => _currentUser;

Future<bool> login(String correo, String password) async {
    try {
      final result = await _repository.validarLogin(correo, password);

      if (result != null) {
        // Si el repositorio ya devuelve el objeto UserModel, solo asígnalo.
        // Si el repositorio devuelve un MAP, entonces usa UserModel.fromJson(result['user']).

        final dynamic userData = result['user'];

        if (userData is UserModel) {
          _currentUser = userData;
        } else {
          _currentUser = UserModel.fromJson(userData as Map<String, dynamic>);
        }

        final String token = result['token'] as String;
        await _sessionManager.saveSession(token, _currentUser!);
        return true;
      }
      return false;
    } catch (e) {
      print("Error en AuthService Login: $e");
      rethrow;
    }
  }

  // Este método es vital para que al abrir la app,
  // el 'currentUser' no sea null si ya había una sesión.
  Future<bool> checkExistingSession() async {
    final user = await _sessionManager.getUser();
    if (user != null) {
      _currentUser = user;
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _currentUser = null;
    await _sessionManager.clearSession();
  }
}
