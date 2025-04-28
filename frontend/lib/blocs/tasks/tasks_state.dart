import 'package:equatable/equatable.dart';
import 'package:taskdo/data/models/task.dart';

abstract class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object?> get props => [];
}

class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {
  final List<Task> tasks;
  final String? projectId;
  final String? status;
  final String? priority;
  final String? tagId;
  final bool includeDeleted;

  const TasksLoaded({
    required this.tasks,
    this.projectId,
    this.status,
    this.priority,
    this.tagId,
    this.includeDeleted = false,
  });

  @override
  List<Object?> get props => [tasks, projectId, status, priority, tagId, includeDeleted];

  TasksLoaded copyWith({
    List<Task>? tasks,
    String? projectId,
    String? status,
    String? priority,
    String? tagId,
    bool? includeDeleted,
  }) {
    return TasksLoaded(
      tasks: tasks ?? this.tasks,
      projectId: projectId ?? this.projectId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      tagId: tagId ?? this.tagId,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }
}

class TasksFailure extends TasksState {
  final String message;

  const TasksFailure(this.message);

  @override
  List<Object> get props => [message];
} 