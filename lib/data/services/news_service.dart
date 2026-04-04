import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  // API de noticias que NO requiere API key
  Future<List<dynamic>> getFinancialNews() async {
    try {
      final response = await http.get(
        Uri.parse('https://saurav.tech/NewsAPI/top-headlines/category/business/us.json'),
        headers: {
          'User-Agent': 'Mozilla/5.0',
          'Content-Type': 'application/json',
        },
      );

      print("📰 Respuesta noticias: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final articles = data['articles'] ?? [];
        print("📰 Noticias cargadas: ${articles.length}");
        return articles;
      } else {
        print("Error en noticias: ${response.statusCode}");
        print("Body: ${response.body}");
        // Si falla la API, usar datos locales
        return _getLocalNews();
      }
    } catch (e) {
      print("Excepción en noticias: $e");
      // Si hay excepción, usar datos locales
      return _getLocalNews();
    }
  }

  // Datos de respaldo locales (por si la API falla)
  List<dynamic> _getLocalNews() {
    return [
      {
        'title': 'Colombia mantiene tasa de interés estable',
        'description': 'El Banco de la República decide mantener las tasas ante la inflación controlada.',
        'url': '',
        'image': '',
        'source': {'name': 'Finanzas Móviles'},
      },
      {
        'title': 'Dólar hoy en Colombia se mantiene estable',
        'description': 'La moneda estadounidense se cotiza en 3666 COP.',
        'url': '',
        'image': '',
        'source': {'name': 'Finanzas Móviles'},
      },
      {
        'title': 'Oportunidades de inversión en el sector tecnológico',
        'description': 'Las startups colombianas atraen inversión extranjera.',
        'url': '',
        'image': '',
        'source': {'name': 'Finanzas Móviles'},
      },
      {
        'title': 'Exportaciones colombianas crecen un 15%',
        'description': 'Buen momento para los exportadores nacionales.',
        'url': '',
        'image': '',
        'source': {'name': 'Finanzas Móviles'},
      },
      {
        'title': 'Ahorro e inversión: consejos para principiantes',
        'description': 'Cómo empezar a invertir tu dinero de manera segura.',
        'url': '',
        'image': '',
        'source': {'name': 'Finanzas Móviles'},
      },
    ];
  }
}