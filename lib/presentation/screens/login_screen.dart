import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import '../../data/repositories/auth_repository_impl.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para capturar el texto ingresado
  final _correoController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false; // Para mostrar un indicador de carga si deseas

  @override
  void dispose() {
    // Es vital liberar la memoria de los controladores al cerrar la pantalla
    _correoController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // Función para manejar la lógica de entrada
  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    final repo = AuthRepositoryImpl();
    // Buscamos en la base de datos local SQLite
    bool esValido = await repo.validarLogin(
      _correoController.text.trim(),
      _passController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (esValido) {
      if (mounted) {
        // Navegamos al Home y eliminamos el Login del historial
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Correo o contraseña incorrectos'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingreso - Finanzas Móviles'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FlutterLogo(size: 80), // Un toque visual simple
                const SizedBox(height: 40),

                TextField(
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _passController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          child: const Text(
                            'INGRESAR',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: () {
                    // Navegamos a la pantalla de Registro que ya creaste
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text('¿No tienes cuenta? Regístrate aquí'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
