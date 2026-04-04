// lib/data/services/gasto_service.dart
import 'dart:convert';
import 'package:finanzas_moviles/core/constants.dart';
import 'package:finanzas_moviles/domain/entities/gasto.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class GastoService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Crear gasto
  Future<Map<String, dynamic>> createGasto(Gasto gasto) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiEndpoints.expenses),
        headers: headers,
        body: jsonEncode(gasto.toJson()),
      );

      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'Error al registrar gasto'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Obtener gastos de un presupuesto
  Future<List<dynamic>> getGastosByBudget(int budgetId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(ApiEndpoints.expensesByBudget(budgetId)),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Obtener resumen
  Future<Map<String, dynamic>> getSummary(int budgetId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(ApiEndpoints.expensesSummary(budgetId)),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      return {};
    }
  }
}
