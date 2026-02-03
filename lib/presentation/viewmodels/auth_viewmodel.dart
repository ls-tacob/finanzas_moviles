import 'package:flutter/material.dart';

// El ViewModel es el "Cerebro" de la pantalla (State Holder en tu diseño)
class AuthViewModel extends ChangeNotifier {
  bool _isLoggedIn = false; // Estado privado
  String? _userRole;

  // Getters para que la UI pueda leer los datos pero no modificarlos directamente
  bool get isLoggedIn => _isLoggedIn;
  String? get userRole => _userRole;

  // "Intent": La intención del usuario de iniciar sesión
  void login(String email, String password) {
    // Aquí iría la validación con el backend en el futuro
    if (email.isNotEmpty && password.length > 4) {
      _isLoggedIn = true;
      _userRole = 'Usuario Estándar'; // Rol por defecto
      notifyListeners(); // Esto le avisa a la UI que debe redibujarse
    }
  }

  // "Intent": Cerrar sesión
  void logout() {
    _isLoggedIn = false;
    _userRole = null;
    notifyListeners();
  }
}
