class Usuario {
  final String cedula; // Obligatorio en Oracle
  final String nombres; // En plural, como en tu Entidad
  final String apellidos; // Obligatorio en Oracle
  final String correo;
  final String password; // Necesario para el registro
  final int idRol; // Cambiamos String por int para que coincida con ID_ROL
  final double sueldoActual;

  Usuario({
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.password,
    this.idRol = 1, // Por defecto el rol que insertamos
    this.sueldoActual = 0.0,
  });

  // Este método es el que enviará el JSON correcto a NestJS
  Map<String, dynamic> toJson() {
    return {
      "cedula": cedula,
      "nombres": nombres,
      "apellidos": apellidos,
      "idRol": idRol,
      "correo": correo,
      "password": password,
      "sueldoActual": sueldoActual,
    };
  }
}
