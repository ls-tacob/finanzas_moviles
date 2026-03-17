import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NewsService {
  final String _baseUrl = dotenv.get('API_URL');

  Future<List<dynamic>> getBusinessNews() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/finance-summary'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['noticias_emprendimiento']; // Solo devolvemos la lista de noticias
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
