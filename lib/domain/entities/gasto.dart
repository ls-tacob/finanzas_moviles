// lib/domain/entities/gasto_model.dart
class Gasto {
  final int? id; // ✅ Cambiado a int? (viene de la BD)
  final int budgetId; // ✅ Nuevo: ID del presupuesto
  final int categoryId; // ✅ Cambiado de String a int
  final double amount; // ✅ Cambiado de monto a amount
  final String? description; // ✅ Cambiado de nota a description
  final String
  expenseDate; // ✅ Cambiado de DateTime a String (formato YYYY-MM-DD)
  final String? photoPath;
  final double? latitude; // ✅ Nuevo: ubicación
  final double? longitude; // ✅ Nuevo: ubicación

  Gasto({
    this.id,
    required this.budgetId,
    required this.categoryId,
    required this.amount,
    this.description,
    required this.expenseDate,
    this.photoPath,
    this.latitude,
    this.longitude,
  });

  // Para convertir a JSON (enviar al backend)
  Map<String, dynamic> toJson() => {
    'budgetId': budgetId,
    'categoryId': categoryId,
    'amount': amount,
    'description': description,
    'expenseDate': expenseDate,
    'photoPath': photoPath,
    'latitude': latitude,
    'longitude': longitude,
  };

  // Para convertir desde JSON (recibir del backend)
  factory Gasto.fromJson(Map<String, dynamic> json) => Gasto(
    id: json['id'],
    budgetId: json['budgetId'],
    categoryId: json['categoryId'],
    amount: (json['amount'] as num).toDouble(),
    description: json['description'],
    expenseDate: json['expenseDate'],
    photoPath: json['photoPath'],
    latitude: json['latitude'] != null
        ? (json['latitude'] as num).toDouble()
        : null,
    longitude: json['longitude'] != null
        ? (json['longitude'] as num).toDouble()
        : null,
  );
}
