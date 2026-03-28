import 'dart:convert';

import 'package:finanzas_moviles/core/constants.dart';
import 'package:finanzas_moviles/data/services/auth_service.dart';
import 'package:finanzas_moviles/domain/entities/user.dart';
import 'package:http/http.dart' as http;

class AuthRepositoryImpl {
  Future<Map<String, dynamic>?> validarLogin(
    String correo,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"correo": correo, "password": password}),
      );

// lib/data/repositories/auth_repository_impl.dart

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Convertimos el JSON interno a objeto UserModel
        final user = UserModel.fromJson(data['user']);
        final token = data['access_token'];

        // Devolvemos el mapa con el objeto YA convertido
        return {
          'user': user, // Esto ya no es un Map, es un UserModel
          'token': token,
        };
      }
    } catch (e) {
      throw Exception("Error de conexión: $e");
    }
  }

Future<bool> registrarUsuario(
    UserModel user,
    String password,
    int idRol,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.register),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
          user.toJson(password, idRol),
        ), // Convertimos el modelo a JSON
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        // Capturamos el ConflictException del backend (Cédula/Correo ya registrados)
        String message = errorData['message'] is List
            ? errorData['message'][0]
            : errorData['message'];
        throw Exception(message ?? "Error en el servidor");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
