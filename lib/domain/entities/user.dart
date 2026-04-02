class UserModel {
  final int? id; // <--- Aumento mínimo
  final int? idRol; // <--- Aumento mínimo
  final String cedula;
  final String nombres;
  final String apellidos;
  final String? correo;
  final String? telefono;
  final String? profesion;
  final String? estado;
  final double sueldo;

  UserModel({
    this.id, // <--- Opcional
    this.idRol, // <--- Opcional
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    this.correo,
    this.telefono,
    this.profesion,
    this.estado,
    required this.sueldo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['idUsuario'],
      idRol: json['idRol'], // <--- Captura el nuevo Rol
      cedula: json['cedula'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      correo:
          json['correo'] ??
          (json['info'] != null ? json['info']['correo'] : null),
      telefono: json['telefono'],
      profesion: json['profesion'],
      sueldo: (json['sueldo'] as num?)?.toDouble() ?? 0.0,
      estado: json['estado'] ?? '',
    );
  }

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
      "estado": estado
    };
  }
}
