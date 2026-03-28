import 'package:finanzas_moviles/domain/entities/user.dart';

import '../repositories/auth_repository_impl.dart';
import '../../core/session_manager.dart';

class AuthService {
  final AuthRepositoryImpl _repository = AuthRepositoryImpl();
  final SessionManager _sessionManager = SessionManager();

  // 1. Variable privada para guardar el usuario en memoria
  UserModel? _currentUser;

  // 2. Getter público para que la UI pueda leerlo
  UserModel? get currentUser => _currentUser;

 // lib/data/services/auth_service.dart

  Future<bool> login(String correo, String password) async {
    try {
      // Aquí recibes el MAP: { 'user': UserModel, 'token': String }
      final result = await _repository.validarLogin(correo, password);

      if (result != null) {
        // CORRECCIÓN: Extraer explícitamente el objeto que ya es un UserModel
        _currentUser = result['user'] as UserModel; // El cast asegura el tipo
        final String token = result['token'] as String;

        await _sessionManager.saveSession(token, _currentUser!);
        return true;
      }
      return false;
    } catch (e) {
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
