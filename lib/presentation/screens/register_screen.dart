import 'package:finanzas_moviles/data/repositories/auth_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para el filtro de no números
import 'dart:async';
import 'home_screen.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // 1. TODOS LOS CONTROLADORES DEFINIDOS AQUÍ
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _isEmailChecking = false;

  @override
  void dispose() {
    // 2. LIMPIEZA DE MEMORIA
    _nombreController.dispose();
    _correoController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
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
              // --- CAMPO NOMBRE ---
              TextFormField(
                controller: _nombreController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                ],
                decoration: const InputDecoration(
                  labelText: "Nombres",
                  icon: Icon(Icons.person),
                  hintText: "Solo letras",
                ),
                validator: (val) {
                  if (val == null || val.isEmpty)
                    return "El nombre es obligatorio";
                  if (val.length < 3) return "Nombre demasiado corto";
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // --- CAMPO CORREO ---
              TextFormField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Correo Electrónico",
                  icon: const Icon(Icons.email),
                  suffixIcon: _isEmailChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Ingrese un correo";
                  if (!val.contains('@')) return "Formato de correo incorrecto";
                  return null;
                },
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
                validator: (val) {
                  if (val == null || val.length < 8)
                    return "Mínimo 8 caracteres";
                  return null;
                },
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
                validator: (val) {
                  if (val != _passController.text)
                    return "Las contraseñas no coinciden";
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // --- BOTÓN REGISTRARSE ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    // Asegúrate de que no haya nada entre 'onPressed:' y '() async {'
                    if (_formKey.currentState!.validate()) {
                      try {
                        // 1. Instanciamos tu repositorio
                        final authRepo = AuthRepositoryImpl();

                        // 2. Intentamos registrar al usuario
                        await authRepo.registrarUsuario(
                          _nombreController.text.trim(),
                          _correoController.text.trim(),
                          _passController.text.trim(),
                          'usuario',
                        );

                        // 3. Si todo sale bien, avisamos y navegamos
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("¡Usuario registrado localmente!"),
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
                        // Por si algo falla en la base de datos
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error al guardar: $e")),
                          );
                        }
                      }
                    }
                  },
                  child: const Text("REGISTRARSE"),
                ),
              ),

              const SizedBox(height: 20),

              // --- BOTONES DE NAVEGACIÓN INFERIOR ---
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
                    child: const Text("← Volver al inicio"),
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
