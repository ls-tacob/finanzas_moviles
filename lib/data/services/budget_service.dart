// lib/data/services/budget_service.dart
import 'dart:convert';// ✅ Cambiar import
import 'package:finanzas_moviles/core/constants.dart';
import 'package:finanzas_moviles/domain/entities/budget.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class BudgetService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Crear presupuesto
  Future<Map<String, dynamic>> createBudget({
    required String name,
    required String startDate,
    required String endDate,
    required double totalAmount,
    List<BudgetDetail>? details,
  }) async {
    try {
      final headers = await _getHeaders();

      // Verificar que hay token
      if (headers['Authorization'] == 'Bearer null') {
        return {
          'success': false,
          'message': 'No hay sesión activa. Inicia sesión nuevamente.',
        };
      }

      final body = {
        'name': name,
        'startDate': startDate,
        'endDate': endDate,
        'totalAmount': totalAmount,
        if (details != null && details.isNotEmpty)
          'details': details.map((d) => d.toJson()).toList(),
      };

      print('📤 Enviando presupuesto: ${jsonEncode(body)}');
      print('🔑 Token: ${headers['Authorization']}');

      final response = await http.post(
        Uri.parse(ApiEndpoints.budgets), // ✅ Cambiado
        headers: headers,
        body: jsonEncode(body),
      );

      print('📥 Respuesta: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Presupuesto creado con éxito',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al crear presupuesto',
        };
      }
    } catch (e) {
      print('❌ Error en createBudget: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Obtener todos los presupuestos del usuario
  Future<Map<String, dynamic>> getMyBudgets() async {
    try {
      final headers = await _getHeaders();

      if (headers['Authorization'] == 'Bearer null') {
        return {'success': false, 'message': 'No hay sesión activa'};
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.budgets), // ✅ Cambiado
        headers: headers,
      );

      print('📥 GET budgets: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data'] ?? data};
      } else {
        return {'success': false, 'message': 'Error al obtener presupuestos'};
      }
    } catch (e) {
      print('❌ Error en getMyBudgets: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Obtener un presupuesto específico
  Future<Map<String, dynamic>> getBudgetById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(ApiEndpoints.budgetById(id)), // ✅ Cambiado
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Presupuesto no encontrado'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Actualizar presupuesto
  Future<Map<String, dynamic>> updateBudget(
    int id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse(ApiEndpoints.budgetById(id)), // ✅ Cambiado
        headers: headers,
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al actualizar',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Eliminar presupuesto
  Future<Map<String, dynamic>> deleteBudget(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse(ApiEndpoints.budgetById(id)), // ✅ Cambiado
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Presupuesto eliminado con éxito'};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al eliminar presupuesto',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}
