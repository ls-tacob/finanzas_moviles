import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/entities/import_radar.dart';

class CurrencyService {
  // Asegúrate de que esto no tenga "/" al final
  final String _baseUrl = dotenv.get('API_URL');

  Future<ImportRadar?> getExchangeRates() async {
    try {
      final url = Uri.parse('$_baseUrl/finance-summary');
      print("Intentando conectar a: $url"); // ESTO SALDRÁ EN TU CONSOLA

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return ImportRadar.fromJson(json.decode(response.body));
      } else {
        print("Servidor respondió con error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print(
        "ERROR CRÍTICO DE RED: $e",
      ); // Aquí verás si es Timeout o Connection Refused
      return null;
    }
  }
}
