// lib/domain/entities/gasto_model.dart
class Gasto {
  final int? id;
  final int budgetId;
  final int categoryId;
  final double amount;
  final String? description;
  final String expenseDate;
  final String? photoPath;
  final double? latitude;
  final double? longitude;

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
}
