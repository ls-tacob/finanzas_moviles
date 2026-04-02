import 'package:finanzas_moviles/data/repositories/auth_repository_impl.dart';
import 'package:finanzas_moviles/domain/entities/user.dart';
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

  final _cedulaController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController(); // <-- NUEVO
  final _profesionController = TextEditingController(); // <-- NUEVO
  final _sueldoController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _cedulaController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _profesionController.dispose();
    _sueldoController.dispose();
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
              // --- CÉDULA ---
              TextFormField(
                controller: _cedulaController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: "Cédula",
                  icon: Icon(Icons.badge),
                ),
                validator: (val) => (val == null || val.length != 10)
                    ? "10 dígitos requeridos"
                    : null,
              ), // --- CAMPO NOMBRES ---
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

             
              // ...

              // --- CORREO ---
              TextFormField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Correo",
                  icon: Icon(Icons.email),
                ),
                validator: (val) => (val == null || !val.contains('@'))
                    ? "Correo inválido"
                    : null,
              ),

              // --- NUEVO: TELÉFONO (Obligatorio en tu Backend) ---
              TextFormField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Teléfono",
                  icon: Icon(Icons.phone),
                ),
                validator: (val) =>
                    (val == null || val.isEmpty) ? "Campo obligatorio" : null,
              ),

              // --- NUEVO: PROFESIÓN (Opcional) ---
              TextFormField(
                controller: _profesionController,
                decoration: const InputDecoration(
                  labelText: "Profesión",
                  icon: Icon(Icons.work),
                ),
              ),

              // --- SUELDO ---
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

              // --- BOTÓN REGISTRARSE ACTUALIZADO ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("REGISTRARSE"),
                )),

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
              // ... Resto de botones igual
            ],
          ),
        ),
      ),
    );
  }

  // Lógica de registro separada para mayor orden
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authRepo = AuthRepositoryImpl();

      // 1. CREAMOS EL MODELO CON LOS DATOS DE LA UI
      final newUser = UserModel(
        cedula: _cedulaController.text.trim(),
        nombres: _nombreController.text.trim(),
        apellidos: _apellidoController.text.trim(),
        correo: _correoController.text.trim(),
        telefono: _telefonoController.text.trim(),
        profesion: _profesionController.text.trim(),
        sueldo: double.tryParse(_sueldoController.text) ?? 0.0,
      );

      // 2. LLAMAMOS AL REPO PASANDO EL MODELO
      // El password y el idRol se pasan aparte para que no vivan en el modelo de persistencia
      final success = await authRepo.registrarUsuario(
        newUser,
        _passController.text.trim(),
        2,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Registro exitoso! Por favor inicia sesión."),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        // Aquí se mostrarán errores como "La cédula ya está registrada"
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
