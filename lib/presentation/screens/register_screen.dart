import 'package:finanzas_moviles/data/repositories/auth_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // CONTROLADORES ACTUALIZADOS PARA ORACLE
  final _cedulaController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _sueldoController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _cedulaController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    _sueldoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Usuario")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // --- CAMPO CÉDULA (PK EN ORACLE) ---
              TextFormField(
                controller: _cedulaController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: "Cédula",
                  icon: Icon(Icons.badge),
                  hintText: "10 dígitos",
                ),
                validator: (val) => (val == null || val.length != 10)
                    ? "La cédula debe tener 10 dígitos"
                    : null,
              ),
              const SizedBox(height: 15),

              // --- CAMPO NOMBRES ---
              TextFormField(
                controller: _nombreController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                ],
                decoration: const InputDecoration(
                  labelText: "Nombres",
                  icon: Icon(Icons.person),
                ),
                validator: (val) =>
                    (val == null || val.isEmpty) ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 15),

              // --- CAMPO APELLIDOS ---
              TextFormField(
                controller: _apellidoController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                ],
                decoration: const InputDecoration(
                  labelText: "Apellidos",
                  icon: Icon(Icons.person_outline),
                ),
                validator: (val) =>
                    (val == null || val.isEmpty) ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 15),

              // --- CAMPO CORREO ---
              TextFormField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Correo Electrónico",
                  icon: Icon(Icons.email),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Ingrese un correo";
                  if (!val.contains('@')) return "Formato de correo incorrecto";
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // --- CAMPO SUELDO (OPCIONAL PERO ÚTIL) ---
              TextFormField(
                controller: _sueldoController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: "Sueldo Mensual",
                  icon: Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 15),

              // --- CAMPO CONTRASEÑA ---
              TextFormField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Contraseña",
                  icon: Icon(Icons.lock),
                ),
                validator: (val) => (val == null || val.length < 8)
                    ? "Mínimo 8 caracteres"
                    : null,
              ),
              const SizedBox(height: 15),

              // --- CAMPO CONFIRMAR ---
              TextFormField(
                controller: _confirmPassController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Confirmar Contraseña",
                  icon: Icon(Icons.security),
                ),
                validator: (val) => (val != _passController.text)
                    ? "Las contraseñas no coinciden"
                    : null,
              ),

              const SizedBox(height: 30),

              // --- BOTÓN REGISTRARSE ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);
                            try {
                              final authRepo = AuthRepositoryImpl();

                              // MAPEADO 1:1 CON EL DTO DE NESTJS
                              final success = await authRepo.registrarUsuario({
                                "cedula": _cedulaController.text.trim(),
                                "nombres": _nombreController.text.trim(),
                                "apellidos": _apellidoController.text.trim(),
                                "idRol": 1, // ID que insertamos en ROL
                                "correo": _correoController.text.trim(),
                                "password": _passController.text.trim(),
                                "sueldoActual":
                                    double.tryParse(_sueldoController.text) ??
                                    0.0,
                              });

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "¡Usuario registrado en el sistema!",
                                    ),
                                  ),
                                );
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: $e")),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          }
                        },
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("REGISTRARSE"),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OnboardingScreen(),
                      ),
                    ),
                    child: const Text("← Volver"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: const Text("Ya tengo cuenta"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
