import 'package:equatable/equatable.dart';

class Subtask extends Equatable {
  final String id;
  final String description;
  final bool completed;

  const Subtask({
    required this.id,
    required this.description,
    this.completed = false,
  });

  @override
  List<Object> get props => [id, description, completed];

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      description: json['description'] as String,
      completed: json['completed'] as bool? ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'completed': completed,
    };
  }
  
  Subtask copyWith({
    String? id,
    String? description,
    bool? completed,
  }) {
    return Subtask(
      id: id ?? this.id,
      description: description ?? this.description,
      completed: completed ?? this.completed,
    );
  }
}

class Task extends Equatable {
  final String id;
  final String projectId;
  final String name;
  final int estimatedPomodoros;
  final int completedPomodoros;
  final DateTime dueDate;
  final String priority;
  final List<String> tags;
  final String status;
  final String notes;
  final List<Subtask> subtasks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final bool isDeleted;

  const Task({
    required this.id,
    required this.projectId,
    required this.name,
    required this.estimatedPomodoros,
    this.completedPomodoros = 0,
    required this.dueDate,
    required this.priority,
    this.tags = const [],
    required this.status,
    this.notes = '',
    this.subtasks = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
    this.isDeleted = false,
  });

  @override
  List<Object> get props => [
    id,
    projectId,
    name,
    estimatedPomodoros,
    completedPomodoros,
    dueDate,
    priority,
    tags,
    status,
    notes,
    subtasks,
    createdAt,
    updatedAt,
    isArchived,
    isDeleted,
  ];

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'] as String? ?? json['id'] as String,
      projectId: json['project_id'] as String,
      name: json['name'] as String,
      estimatedPomodoros: json['estimated_pomodoros'] as int,
      completedPomodoros: json['completed_pomodoros'] as int? ?? 0,
      dueDate: DateTime.parse(json['due_date'] as String),
      priority: json['priority'] as String,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      status: json['status'] as String,
      notes: json['notes'] as String? ?? '',
      subtasks: (json['subtasks'] as List<dynamic>?)
          ?.map((e) => Subtask.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isArchived: json['is_archived'] as bool? ?? false,
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'name': name,
      'estimated_pomodoros': estimatedPomodoros,
      'completed_pomodoros': completedPomodoros,
      'due_date': dueDate.toIso8601String(),
      'priority': priority,
      'tags': tags,
      'status': status,
      'notes': notes,
      'subtasks': subtasks.map((s) => s.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_archived': isArchived,
      'is_deleted': isDeleted,
    };
  }
  
  Task copyWith({
    String? id,
    String? projectId,
    String? name,
    int? estimatedPomodoros,
    int? completedPomodoros,
    DateTime? dueDate,
    String? priority,
    List<String>? tags,
    String? status,
    String? notes,
    List<Subtask>? subtasks,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
    bool? isDeleted,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      estimatedPomodoros: estimatedPomodoros ?? this.estimatedPomodoros,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      subtasks: subtasks ?? this.subtasks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
  
  // Task status constants
  static const String statusTodo = 'todo';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  
  // Task priority constants
  static const String priorityLow = 'low';
  static const String priorityMedium = 'medium';
  static const String priorityHigh = 'high';
} 