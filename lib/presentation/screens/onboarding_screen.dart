import 'package:finanzas_moviles/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _data = [
    {
      "title": "Bienvenido a Finanzas Pro",
      "desc": "La mejor forma de controlar tus gastos diarios.",
      "icon": "💰",
    },
    {
      "title": "Analiza tus Ahorros",
      "desc": "Gráficas detalladas para entender a dónde va tu dinero.",
      "icon": "📊",
    },
    {
      "title": "Seguridad Total",
      "desc": "Tus datos están protegidos localmente en tu dispositivo.",
      "icon": "🔒",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) => setState(() => _currentPage = value),
                itemCount: _data.length,
                itemBuilder: (context, i) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _data[i]['icon']!,
                      style: const TextStyle(fontSize: 100),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _data[i]['title']!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        _data[i]['desc']!,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: const Text("SALTAR"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _data.length - 1) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                    child: Text(
                      _currentPage == _data.length - 1
                          ? "EMPEZAR"
                          : "SIGUIENTE",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
