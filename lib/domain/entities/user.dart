class UserModel {
  final int? id;
  final int? idRol;
  final String cedula;
  final String nombres;
  final String apellidos;
  final String? correo;
  final String? telefono;
  final String? profesion;
  final String? estado;
  final String? dellog;
  final String? foto; // ✅ NUEVO
  final double sueldo;

  UserModel({
    this.id,
    this.idRol,
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    this.correo,
    this.telefono,
    this.profesion,
    this.estado,
    this.dellog,
    this.foto, // ✅ NUEVO
    required this.sueldo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final info = json['info'] ?? {};

    return UserModel(
      id: json['id'] ?? json['idUsuario'],
      idRol: json['idRol'],
      cedula: json['cedula'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      correo: info['correo'] ?? json['correo'],
      telefono: info['telefono'] ?? json['telefono'],
      profesion: info['profesion'] ?? json['profesion'],
      sueldo: (info['sueldoActual'] ?? json['sueldo'] ?? 0).toDouble(),
      estado: json['estado'] ?? '',
      dellog: json['dellog'] ?? 'N',
      foto: json['foto'], // ✅ NUEVO
    );
  }

  // Tu toJson original (NO MODIFICAR - para registro/login)
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
      "estado": estado,
      "foto": foto, // ✅ NUEVO
    };
  }

  // Método para admin (sin password)
  Map<String, dynamic> toAdminJson() {
    return {
      "cedula": cedula,
      "nombres": nombres,
      "apellidos": apellidos,
      "correo": correo,
      "idRol": idRol,
      "telefono": telefono,
      "profesion": profesion,
      "sueldoActual": sueldo,
      "estado": estado,
      "dellog": dellog,
      "foto": foto, // ✅ NUEVO
    };
  }
}
