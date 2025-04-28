import 'package:equatable/equatable.dart';

class Project extends Equatable {
  final String id;
  final String name;
  final String description;
  final String color;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    this.deadline,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    color,
    deadline,
    createdAt,
    updatedAt,
    isArchived,
  ];

  factory Project.fromJson(Map<String, dynamic> json) {
    // Handle different ID field names
    String id = '';
    if (json['id'] != null) {
      id = json['id'].toString();
    } else if (json['_id'] != null) {
      id = json['_id'].toString();
    } else {
      id = DateTime.now().millisecondsSinceEpoch.toString();
    }

    // Parse the deadline if it exists
    DateTime? deadline;
    if (json['deadline'] != null) {
      try {
        deadline = DateTime.parse(json['deadline'].toString());
      } catch (e) {
        print('Error parsing deadline: $e');
      }
    }

    return Project(
      id: id,
      name: json['name'].toString(),
      description: json['description']?.toString() ?? '',
      color: json['color']?.toString() ?? '#FF5A5A',
      deadline: deadline,
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at'].toString())
        : DateTime.now(),
      updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at'].toString())
        : DateTime.now(),
      isArchived: json['is_archived'] as bool? ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'deadline': deadline?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_archived': isArchived,
    };
  }
  
  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    DateTime? deadline,
    bool? clearDeadline,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      deadline: clearDeadline == true ? null : (deadline ?? this.deadline),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }
} 