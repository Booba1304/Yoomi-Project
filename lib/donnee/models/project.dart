import 'package:hive/hive.dart';
part 'project.g.dart'; // fichier généré automatiquement

@HiveType(typeId: 0)
enum ProjectStatus {
  @HiveField(0)
  draft,

  @HiveField(1)
  published,

  @HiveField(2)
  archived,
}

@HiveType(typeId: 1)
class Project {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final ProjectStatus status;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final DateTime createdAt;

  Project({
    required this.id,
    required this.name,
    required this.status,
    required this.amount,
    required this.createdAt,
  });

  /// Convertir JSON → Project
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      status: ProjectStatus.values.firstWhere(
            (s) => s.name.toUpperCase() == json['status'],
      ),
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  /// Convertir Project → JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'status': status.name.toUpperCase(),
    'amount': amount,
    'createdAt': createdAt.toIso8601String(),
  };
}