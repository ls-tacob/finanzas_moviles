// lib/data/models/category_model.dart
class Category {
  final int id;
  final String name;
  final String? description;
  final String? icon;
  final String? color;
  final int status;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.color,
    required this.status,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    icon: json['icon'],
    color: json['color'],
    status: json['status'],
  );
}
