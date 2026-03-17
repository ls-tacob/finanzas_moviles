import 'package:finanzas_moviles/presentation/screens/opportunities_screen.dart';
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
  // 1. Llave global para el formulario y controladores
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _correoController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // 2. Solo procede si el formulario es válido
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final repo = AuthRepositoryImpl();
    bool esValido = await repo.validarLogin(
      _correoController.text.trim(),
      _passController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (esValido) {
      if (mounted) {
       Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OpportunitiesScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Correo o contraseña incorrectos'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating, // Se ve más moderno
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
            // 3. Envolvemos todo en el Form
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FlutterLogo(size: 80),
                  const SizedBox(height: 40),

                  // --- CAMPO CORREO ---
                  TextFormField(
                    controller: _correoController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo Electrónico',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                      hintText: 'ejemplo@correo.com',
                    ),
                    // Validación de campo vacío y formato
                    validator: (val) {
                      if (val == null || val.isEmpty)
                        return "El correo es requerido";
                      if (!val.contains('@') || !val.contains('.')) {
                        return "Ingresa un correo válido";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- CAMPO CONTRASEÑA ---
                  TextFormField(
                    controller: _passController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    // Validación de campo vacío
                    validator: (val) {
                      if (val == null || val.isEmpty)
                        return "La contraseña es requerida";
                      if (val.length < 6) return "Mínimo 6 caracteres";
                      return null;
                    },
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                  const SizedBox(height: 15),

                  TextButton(
                    onPressed: () {
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
      ),
    );
  }
}
