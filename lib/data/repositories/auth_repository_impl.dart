import 'dart:convert';
import 'package:finanzas_moviles/core/constants.dart';
import 'package:http/http.dart' as http;


class AuthRepositoryImpl {
  // LOGIN
  Future<Map<String, dynamic>?> validarLogin(
    String correo,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.login), // <--- USA LA CONSTANTE
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"correo": correo, "password": password}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      throw Exception("Error de conexión: $e");
    }
  }

  // REGISTRO
  Future<bool> registrarUsuario(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse(
          ApiEndpoints.register,
        ), // <--- AQUÍ ESTABA TU ERROR (Cannot POST /)
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        // Manejo de errores de NestJS (puede ser String o List)
        String message = errorData['message'] is List
            ? errorData['message'][0]
            : errorData['message'];

        throw Exception(message ?? "Error en el servidor");
      }
    } catch (e) {
      throw Exception("Fallo en el registro: $e");
    }
  }
}
