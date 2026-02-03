import 'package:finanzas_moviles/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Dentro del AppBar de tu HomeScreen
        title: Text(dotenv.get('APP_NAME', fallback: 'Finanzas Móviles')),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            // En el IconButton de logout en home_screen.dart
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }, // Simula cierre de sesión
          ),
        ],
      ),
      body: const Center(
        child: Text(
          '¡Bienvenido! Esta es tu vista protegida.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
