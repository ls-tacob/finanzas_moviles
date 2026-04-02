import 'package:finanzas_moviles/data/services/auth_service.dart';
import 'package:finanzas_moviles/presentation/screens/admin/admin_main_screen.dart';
import 'package:flutter/material.dart';
import 'register_gasto_screen.dart';
import 'opportunities_screen.dart'; // Importa la de oportunidades
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    print("Rol del usuario logueado: ${authService.currentUser?.idRol}"); 
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finanzas Móviles - Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Panel de Control',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            if (authService.currentUser?.idRol == 1)
              _menuButton(
                context,
                icon: Icons.verified_user_sharp,
                label: "Administración",
                screen:
                    const AdminMainScreen(), // Esta es la que crearemos ahora
              ),
            const SizedBox(height: 15),
            _menuButton(
              context,
              icon: Icons.camera_alt,
              label: "Nuevo Gasto",
              screen: const RegisterGastoScreen(),
            ),

            const SizedBox(height: 15),

            // BOTÓN 2: OPORTUNIDADES (Donde te mandaba antes el login)
            _menuButton(
              context,
              icon: Icons.lightbulb,
              label: "Ver Oportunidades",
              screen: OpportunitiesScreen(), // Asegúrate que esta clase exista
            ),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para no repetir código de botones
  Widget _menuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Widget screen,
  }) {
    return SizedBox(
      width: 280,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        ),
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey[50],
          foregroundColor: Colors.blue[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
