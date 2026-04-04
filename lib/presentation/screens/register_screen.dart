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
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10), // Bloqueo físico en 10
                ],
                decoration: const InputDecoration(
                  labelText: "Cédula",
                  hintText: "Ej: 1712345678",
                  icon: Icon(Icons.badge),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Campo obligatorio";
                  if (val.length != 10) return "Debe tener 10 dígitos";
                  if (!_isCedulaValida(val))
                    return "La cédula no es válida en Ecuador";
                  return null;
                },
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
                  labelText: "Correo Electrónico",
                  hintText: "ejemplo@dominio.com",
                  icon: Icon(Icons.email),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "El correo es obligatorio";
                  }

                  // RegEx estándar para validación de email
                  final emailRegExp = RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                  );

                  if (!emailRegExp.hasMatch(val)) {
                    return "Introduce un formato de correo válido";
                  }

                  return null;
                },
              ),

              // --- NUEVO: TELÉFONO (Obligatorio en tu Backend) ---
             TextFormField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: const InputDecoration(
                  // <--- Inicia decoration
                  labelText: "Teléfono",
                  icon: Icon(Icons.phone),
                ), // <--- AQUÍ debes cerrar el paréntesis de decoration
                validator: (val) {
                  // <--- Ahora validator está al mismo nivel que controller y decoration
                  if (val == null || val.isEmpty) {
                    return "Campo obligatorio";
                  }
                  if (val.length != 10) {
                    return "El teléfono debe tener exactamente 10 dígitos";
                  }
                  return null;
                },
              ),

              // --- NUEVO: PROFESIÓN (Opcional) ---
              TextFormField(
                controller: _profesionController,
                decoration: const InputDecoration(
                  labelText: "Profesión",
                  icon: Icon(Icons.work),
                ),
              ),

              TextFormField(
                controller: _sueldoController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                // Esto es lo que realmente bloquea la entrada de texto no deseado
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: "Sueldo Mensual",
                  prefixText: "\$ ", // Mejor que solo un icono
                  icon: Icon(Icons.money),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Ingresa un monto";
                  if (double.tryParse(val) == null) return "Monto inválido";
                  return null;
                },
              ),
              // --- CAMPO CONTRASEÑA ---
              TextFormField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Contraseña",
                  helperText: "Mayúsculas, minúsculas, números y símbolos.",
                  icon: Icon(Icons.lock),
                ),
                validator:
                    _validatePassword, // Referencia a la función de arriba
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
  String? _validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'La contraseña es obligatoria';
  }

  // 1. Longitud mínima (8-10 caracteres mínimo)
  if (value.length < 8) {
    return 'Debe tener al menos 8 caracteres';
  }

  // 2. Validar complejidad con RegEx
  // Contiene al menos una mayúscula
  if (!value.contains(RegExp(r'[A-Z]'))) {
    return 'Debe incluir al menos una mayúscula';
  }

  // Contiene al menos una minúscula
  if (!value.contains(RegExp(r'[a-z]'))) {
    return 'Debe incluir al menos una minúscula';
  }

  // Contiene al menos un número
  if (!value.contains(RegExp(r'[0-9]'))) {
    return 'Debe incluir al menos un número';
  }

  // Contiene al menos un carácter especial
  if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
    return 'Debe incluir un carácter especial (ej. @, #)';
  }

  return null; // Si pasa todo, es válida
}
bool _isCedulaValida(String cedula) {
    if (cedula.length != 10) return false;

    // Verificar provincia (primeros dos dígitos entre 01 y 24, o 30)
    int provincia = int.parse(cedula.substring(0, 2));
    if (!((provincia >= 1 && provincia <= 24) || provincia == 30)) return false;

    // Verificar el tercer dígito (debe ser menor a 6 para personas naturales)
    int tercerDigito = int.parse(cedula[2]);
    if (tercerDigito >= 6) return false;

    // Algoritmo de Luhn (Módulo 10) modificado para EC
    List<int> coeficientes = [2, 1, 2, 1, 2, 1, 2, 1, 2];
    int suma = 0;

    for (int i = 0; i < 9; i++) {
      int valor = int.parse(cedula[i]) * coeficientes[i];
      if (valor >= 10) valor -= 9;
      suma += valor;
    }

    int verificadorObtenido = (suma % 10 == 0) ? 0 : 10 - (suma % 10);
    int verificadorReal = int.parse(cedula[9]);

    return verificadorObtenido == verificadorReal;
  }
}
