import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:finanzas_moviles/core/constants.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/user.dart';
import '../../core/session_manager.dart';

class AdminService {
  final Dio _dio = Dio();
  final SessionManager _sessionManager = SessionManager();

  Future<List<UserModel>> getAllUsers() async {
    try {
      final String? token = await _sessionManager.getToken();
      if (token == null) throw Exception("Token no encontrado");

      final response = await _dio.get(
        ApiEndpoints.users,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((userJson) => UserModel.fromJson(userJson)).toList();
      } else {
        throw Exception("Error del servidor: ${response.statusCode}");
      }
    } catch (e) {
      print("Error en AdminService: $e");
      rethrow;
    }
  }

Future<bool> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final token = await _sessionManager.getToken();
      final response = await _dio.patch(
        ApiEndpoints.userById(id),
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      // 🔍 Manejar ConflictException (409)
      if (e.response?.statusCode == 409) {
        final errorMessage =
            e.response?.data['message'] ?? 'Conflicto de datos';
        throw Exception('CONFLICT:$errorMessage');
      }
      print("Error en PATCH: $e");
      return false;
    } catch (e) {
      print("Error en PATCH: $e");
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      final token = await _sessionManager.getToken();
      final response = await _dio.delete(
        ApiEndpoints.userById(id),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error en DELETE: $e");
      return false;
    }
  }
  // Obtener un usuario por ID (con toda la estructura info)
  Future<Map<String, dynamic>> getUserById(int id) async {
    try {
      final String? token = await _sessionManager.getToken();
      if (token == null) throw Exception("Token no encontrado");

      final response = await _dio.get(
        ApiEndpoints.userById(id),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        print("========== USER BY ID RESPONSE ==========");
        print(response.data);
        print("=========================================");
        return response.data;
      } else {
        throw Exception("Error del servidor: ${response.statusCode}");
      }
    } catch (e) {
      print("Error en getUserById: $e");
      rethrow;
    }
  }
}
