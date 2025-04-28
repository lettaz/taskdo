import 'package:equatable/equatable.dart';
import 'package:taskdo/data/models/task.dart';

abstract class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

class TasksLoadRequested extends TasksEvent {
  final String? projectId;
  final String? status;
  final String? priority;
  final String? tagId;
  final bool includeDeleted;

  const TasksLoadRequested({
    this.projectId,
    this.status,
    this.priority,
    this.tagId,
    this.includeDeleted = false,
  });

  @override
  List<Object?> get props => [projectId, status, priority, tagId, includeDeleted];
}

class TaskCreateRequested extends TasksEvent {
  final String projectId;
  final String name;
  final int estimatedPomodoros;
  final DateTime dueDate;
  final String priority;
  final String status;
  final List<String>? tags;
  final String? notes;
  final List<Subtask>? subtasks;

  const TaskCreateRequested({
    required this.projectId,
    required this.name,
    required this.estimatedPomodoros,
    required this.dueDate,
    required this.priority,
    required this.status,
    this.tags,
    this.notes,
    this.subtasks,
  });

  @override
  List<Object?> get props => [
    projectId,
    name,
    estimatedPomodoros,
    dueDate,
    priority,
    status,
    tags,
    notes,
    subtasks,
  ];
}

class TaskUpdateRequested extends TasksEvent {
  final String id;
  final String? projectId;
  final String? name;
  final int? estimatedPomodoros;
  final int? completedPomodoros;
  final DateTime? dueDate;
  final String? priority;
  final String? status;
  final List<String>? tags;
  final String? notes;
  final List<Subtask>? subtasks;

  const TaskUpdateRequested({
    required this.id,
    this.projectId,
    this.name,
    this.estimatedPomodoros,
    this.completedPomodoros,
    this.dueDate,
    this.priority,
    this.status,
    this.tags,
    this.notes,
    this.subtasks,
  });

  @override
  List<Object?> get props => [
    id,
    projectId,
    name,
    estimatedPomodoros,
    completedPomodoros,
    dueDate,
    priority,
    status,
    tags,
    notes,
    subtasks,
  ];
}

class TaskStatusUpdateRequested extends TasksEvent {
  final String id;
  final String status;

  const TaskStatusUpdateRequested({
    required this.id,
    required this.status,
  });

  @override
  List<Object?> get props => [id, status];
}

class TaskDeleteRequested extends TasksEvent {
  final String id;

  const TaskDeleteRequested({
    required this.id,
  });

  @override
  List<Object?> get props => [id];
}

class TasksFilterChanged extends TasksEvent {
  final String? projectId;
  final String? status;
  final String? priority;
  final String? tagId;
  final bool includeDeleted;

  const TasksFilterChanged({
    this.projectId,
    this.status,
    this.priority,
    this.tagId,
    this.includeDeleted = false,
  });

  @override
  List<Object?> get props => [projectId, status, priority, tagId, includeDeleted];
} 