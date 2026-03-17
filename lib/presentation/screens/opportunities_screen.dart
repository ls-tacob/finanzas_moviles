import 'package:flutter/material.dart';
import '../../data/services/currency_service.dart';
import '../../domain/entities/import_radar.dart';
import 'news_screen.dart'; // Importante para el salto

class OpportunitiesScreen extends StatelessWidget {
  final CurrencyService _service = CurrencyService();
  OpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inversiones y Radar")),
      body: FutureBuilder<ImportRadar?>(
        future: _service.getExchangeRates(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData)
            return const Center(child: Text("Error de conexión"));

          final radar = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Oportunidad en Colombia",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 4,
                  child: ListTile(
                    title: Text(radar.mensajeEstrategico),
                    subtitle: Text("Cambio: ${radar.usdToCop} COP"),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewsScreen()),
                  ),
                  icon: const Icon(Icons.newspaper),
                  label: const Text("Ver Noticias de Importación"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
