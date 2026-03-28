class UserModel {
  final String cedula;
  final String nombres;
  final String apellidos;
  final String? correo;
  final String? telefono;
  final String? profesion;
  final double sueldo;

  UserModel({
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    this.correo,
    this.telefono,
    this.profesion,
    required this.sueldo,
  });

  // Este método sirve para mapear la respuesta del Login
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      cedula: json['cedula'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      correo: json['correo'],
      telefono: json['telefono'],
      profesion: json['profesion'],
      sueldo: (json['sueldo'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Nuevo: Este método convierte el objeto a un Map para enviarlo al Registro (POST)
  Map<String, dynamic> toJson(String password, int idRol) {
    return {
      "cedula": cedula,
      "nombres": nombres,
      "apellidos": apellidos,
      "correo": correo,
      "password": password,
      "idRol": idRol,
      "telefono": telefono,
      "profesion": profesion,
      "sueldoActual": sueldo,
    };
  }
}
