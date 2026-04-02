import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:finanzas_moviles/core/constants.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/user.dart';
import '../../core/session_manager.dart';

// Archivo: lib/data/services/admin_service.dart

class AdminService {
  // Dejamos Dio limpio, sin baseUrl fija para usar las constantes completas
  final Dio _dio = Dio();
  final SessionManager _sessionManager = SessionManager();

  Future<List<UserModel>> getAllUsers() async {
    try {
      final String? token = await _sessionManager.getToken();
      if (token == null) throw Exception("Token no encontrado");

      // USAMOS LA CONSTANTE DIRECTA: ApiEndpoints.users (ajusta el nombre según tu clase)
      // Supongamos que en ApiEndpoints tienes: static const String users = "$baseUrl/user";

      final response = await _dio.get(
        ApiEndpoints.users, // <--- Aquí usas tu constante centralizada
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
  // EDITAR (PATCH)
  Future<bool> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final token = await _sessionManager.getToken();
      final response = await _dio.patch(
        ApiEndpoints.userById(id),
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error en PATCH: $e");
      return false;
    }
  }

  // ELIMINAR (DELETE)
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

  Future<bool> patchUser(int id, Map<String, dynamic> data, String token) async {
    try {
      final response = await http.patch(
        Uri.parse(
          ApiEndpoints.userById(id),
        ), // Usa tu clase ApiEndpoints si la tienes
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Aquí usamos el token que recibimos
        },
        body: jsonEncode(data),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error en el servicio: $e");
      return false;
    }
  }

}
