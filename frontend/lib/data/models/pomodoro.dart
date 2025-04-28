import 'package:equatable/equatable.dart';

class PomodoroSession extends Equatable {
  final String id;
  final String taskId;
  final DateTime startTime;
  final DateTime? endTime;
  final int duration;
  final String type;
  final bool completed;
  final bool interrupted;
  final DateTime createdAt;

  const PomodoroSession({
    required this.id,
    required this.taskId,
    required this.startTime,
    this.endTime,
    required this.duration,
    required this.type,
    this.completed = false,
    this.interrupted = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    taskId,
    startTime,
    endTime,
    duration,
    type,
    completed,
    interrupted,
    createdAt,
  ];

  factory PomodoroSession.fromJson(Map<String, dynamic> json) {
    return PomodoroSession(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null 
          ? DateTime.parse(json['end_time'] as String)
          : null,
      duration: json['duration'] as int,
      type: json['type'] as String,
      completed: json['completed'] as bool? ?? false,
      interrupted: json['interrupted'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration': duration,
      'type': type,
      'completed': completed,
      'interrupted': interrupted,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  PomodoroSession copyWith({
    String? id,
    String? taskId,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    String? type,
    bool? completed,
    bool? interrupted,
    DateTime? createdAt,
  }) {
    return PomodoroSession(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      completed: completed ?? this.completed,
      interrupted: interrupted ?? this.interrupted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  // Session type constants
  static const String typeFocus = 'focus';
  static const String typeShortBreak = 'short_break';
  static const String typeLongBreak = 'long_break';
} 