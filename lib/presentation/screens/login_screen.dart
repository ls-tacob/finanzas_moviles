import 'package:flutter/material.dart';
// 1. IMPORTA EL SERVICIO, NO EL REPOSITORIO DIRECTAMENTE
import '../../data/services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _passController = TextEditingController();

  // 2. INSTANCIA EL SERVICIO
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscureText = true;


  @override
  void dispose() {
    _correoController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 3. USA EL SERVICIO (que ya guarda el token internamente)
      final success = await _authService.login(
        _correoController.text.trim(),
        _passController.text.trim(),
      );

      if (success && mounted) {
        // 4. RECUPERA EL USUARIO DEL SERVICIO PARA EL SALUDO
        final user = _authService.currentUser;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bienvenido, ${user?.nombres ?? 'Usuario'}'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else if (mounted) {
        _showError('Credenciales incorrectas');
      }
    } catch (e) {
      if (mounted)
        _showError('Error: ${e.toString().replaceAll("Exception: ", "")}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... El resto de tu UI (Scaffold, Form, Column) se mantiene igual
    // Solo asegúrate de que el botón llame a _handleLogin como ya lo hace.
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Icon(
                      Icons.lock_person,
                      size: 80,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Ingreso al Sistema",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _correoController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (val) => (val == null || !val.contains('@'))
                          ? "Correo inválido"
                          : null,
                    ),
                    const SizedBox(height: 16),
                    // 1. Agrega esta variable al inicio de tu _LoginScreenState
// 2. Modifica el TextFormField de la contraseña:
TextFormField(
  controller: _passController,
  obscureText: _obscureText, // Usa la variable aquí
  decoration: InputDecoration(
    labelText: 'Contraseña',
    border: const OutlineInputBorder(),
    prefixIcon: const Icon(Icons.lock),
    // AGREGA ESTO:
    suffixIcon: IconButton(
      icon: Icon(
        _obscureText ? Icons.visibility_off : Icons.visibility,
      ),
      onPressed: () {
        setState(() {
          _obscureText = !_obscureText;
        });
      },
    ),
  ),
  validator: (val) => (val == null || val.length < 6)
      ? "Mínimo 6 caracteres"
      : null,
),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _handleLogin,
                              child: const Text("ENTRAR"),
                            ),
                          ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      ),
                      child: const Text("¿No tienes cuenta? Regístrate"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
