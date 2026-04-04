import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/import_radar.dart';
import '../../core/constants.dart';

class CurrencyService {
  Future<ImportRadar?> getExchangeRates() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/currency/exchange-rates'),
        headers: {'Content-Type': 'application/json'},
      );

      print("📊 Respuesta de exchange-rates: ${response.statusCode}");
      print("📊 Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ImportRadar.fromJson(data);
      } else {
        print("Error en getExchangeRates: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Excepción en getExchangeRates: $e");
      return null;
    }
  }
}
