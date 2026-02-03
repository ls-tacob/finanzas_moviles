import 'package:finanzas_moviles/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
// IMPORTANTE: Asegúrate de que esta ruta sea la correcta según tu carpeta
import '../../data/repositories/auth_repository_impl.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final List<String> _roles = ['Usuario Estándar', 'Administrador'];
  String _selectedRole = 'Usuario Estándar';

  // Controladores para capturar el texto
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _passController = TextEditingController();

  @override
  void dispose() {
    // Es buena práctica limpiar los controladores al cerrar la pantalla
    _nombreController.dispose();
    _correoController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro - Finanzas Móviles')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Añadido por si el teclado tapa los campos
          child: Column(
            children: [
              // Quitamos el 'const' y añadimos el 'controller'
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: _correoController,
                decoration: const InputDecoration(labelText: 'Correo'),
              ),
              TextField(
                controller: _passController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                items: _roles
                    .map(
                      (role) =>
                          DropdownMenuItem(value: role, child: Text(role)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedRole = val!),
                decoration: const InputDecoration(
                  labelText: 'Selecciona tu Rol',
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  final repo = AuthRepositoryImpl();

                  // 1. Guardamos en la base de datos
                  await repo.registrarUsuario(
                    _nombreController.text,
                    _correoController.text,
                    _passController.text,
                    _selectedRole,
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '¡Bienvenido ${_nombreController.text}! Sesión iniciada como $_selectedRole',
                        ),
                      ),
                    );

                    // 2. NAVEGACIÓN DIRECTA AL HOME
                    // Usamos pushAndRemoveUntil para que el usuario no pueda darle "atrás" y volver al registro
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                      (route) => false, // Esto borra el historial de pantallas
                    );
                  }
                },
                child: const Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
