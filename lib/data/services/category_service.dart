// lib/data/services/category_service.dart
import 'dart:convert';
import 'package:finanzas_moviles/core/constants.dart';
import 'package:finanzas_moviles/domain/entities/category_model.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class CategoryService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Obtener todas las categorías activas
  Future<List<Category>> getCategories() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(ApiEndpoints.categories),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error al obtener categorías: $e');
      return [];
    }
  }

  // Crear nueva categoría
  Future<Map<String, dynamic>> createCategory(
    String name, {
    String? description,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = {'name': name, 'description': description, 'status': 1};

      final response = await http.post(
        Uri.parse(ApiEndpoints.categories),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': Category.fromJson(data)};
      }
      return {'success': false, 'message': 'Error al crear categoría'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }
}
