import 'package:equatable/equatable.dart';

class Tag extends Equatable {
  final String id;
  final String name;
  final String color;
  final DateTime createdAt;

  const Tag({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
  });

  @override
  List<Object> get props => [id, name, color, createdAt];

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  Tag copyWith({
    String? id,
    String? name,
    String? color,
    DateTime? createdAt,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 