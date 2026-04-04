// lib/data/models/budget_model.dart
class BudgetDetail {
  final int? id;
  final int categoryId;
  final double estimatedAmount;

  BudgetDetail({
    this.id,
    required this.categoryId,
    required this.estimatedAmount,
  });

  Map<String, dynamic> toJson() => {
    'categoryId': categoryId,
    'estimatedAmount': estimatedAmount,
  };

  factory BudgetDetail.fromJson(Map<String, dynamic> json) => BudgetDetail(
    id: json['id'],
    categoryId: json['categoryId'],
    estimatedAmount: (json['estimatedAmount'] as num).toDouble(),
  );
}

class Budget {
  final int id;
  final String name;
  final String startDate;
  final String endDate;
  final double totalAmount;
  final int creatorId;
  final String? ip;
  final DateTime createdAt;
  final List<BudgetDetail>? details;

  Budget({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    required this.creatorId,
    this.ip,
    required this.createdAt,
    this.details,
  });

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
    id: json['id'],
    name: json['name'],
    startDate: json['startDate'],
    endDate: json['endDate'],
    totalAmount: (json['totalAmount'] as num).toDouble(),
    creatorId: json['creatorId'],
    ip: json['ip'],
    createdAt: DateTime.parse(json['createdAt']),
    details: json['details'] != null
        ? (json['details'] as List)
              .map((d) => BudgetDetail.fromJson(d))
              .toList()
        : null,
  );
}
