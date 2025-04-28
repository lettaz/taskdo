import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskdo/blocs/tasks/tasks_event.dart';
import 'package:taskdo/blocs/tasks/tasks_state.dart';
import 'package:taskdo/data/models/task.dart';
import 'package:taskdo/data/repositories/tasks_repository.dart';
import 'package:taskdo/utils/exceptions.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TasksRepository _tasksRepository;
  
  TasksBloc({required TasksRepository tasksRepository})
      : _tasksRepository = tasksRepository,
        super(TasksInitial()) {
    on<TasksLoadRequested>(_onTasksLoadRequested);
    on<TaskCreateRequested>(_onTaskCreateRequested);
    on<TaskUpdateRequested>(_onTaskUpdateRequested);
    on<TaskStatusUpdateRequested>(_onTaskStatusUpdateRequested);
    on<TaskDeleteRequested>(_onTaskDeleteRequested);
    on<TasksFilterChanged>(_onTasksFilterChanged);
  }
  
  Future<void> _onTasksLoadRequested(
    TasksLoadRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(TasksLoading());
    
    try {
      final tasks = await _tasksRepository.getTasks(
        projectId: event.projectId,
        status: event.status,
        priority: event.priority,
        tagId: event.tagId,
        includeDeleted: event.includeDeleted,
      );
      
      emit(TasksLoaded(
        tasks: tasks,
        projectId: event.projectId,
        status: event.status,
        priority: event.priority,
        tagId: event.tagId,
        includeDeleted: event.includeDeleted,
      ));
    } on AuthenticationException catch (e) {
      emit(TasksFailure(e.toString()));
    } on ApiException catch (e) {
      emit(TasksFailure(e.toString()));
    } catch (e) {
      emit(TasksFailure('Failed to load tasks: $e'));
    }
  }
  
  Future<void> _onTaskCreateRequested(
    TaskCreateRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(TasksLoading());
    
    try {
      final task = await _tasksRepository.createTask(
        projectId: event.projectId,
        name: event.name,
        estimatedPomodoros: event.estimatedPomodoros,
        dueDate: event.dueDate,
        priority: event.priority,
        status: event.status,
        tags: event.tags,
        notes: event.notes,
        subtasks: event.subtasks,
      );
      
      if (state is TasksLoaded) {
        final currentState = state as TasksLoaded;
        
        // Check if the new task should be included in the current filter
        bool shouldInclude = true;
        
        if (currentState.projectId != null && currentState.projectId != task.projectId) {
          shouldInclude = false;
        }
        
        if (currentState.status != null && currentState.status != task.status) {
          shouldInclude = false;
        }
        
        if (currentState.priority != null && currentState.priority != task.priority) {
          shouldInclude = false;
        }
        
        // For tag filtering, we need to check if any of the task's tags match
        if (currentState.tagId != null && !task.tags.contains(currentState.tagId)) {
          shouldInclude = false;
        }
        
        if (shouldInclude) {
          final updatedTasks = List<Task>.from(currentState.tasks)..add(task);
          emit(currentState.copyWith(tasks: updatedTasks));
        } else {
          // If the task doesn't match the current filter, just re-emit the current state
          emit(currentState);
        }
      } else {
        // If we don't have tasks loaded, load them again with default filters
        add(const TasksLoadRequested());
      }
    } on AuthenticationException catch (e) {
      emit(TasksFailure(e.toString()));
    } on ApiException catch (e) {
      emit(TasksFailure(e.toString()));
    } catch (e) {
      emit(TasksFailure('Failed to create task: $e'));
    }
  }
  
  Future<void> _onTaskUpdateRequested(
    TaskUpdateRequested event,
    Emitter<TasksState> emit,
  ) async {
    if (state is! TasksLoaded) return;
    
    final currentState = state as TasksLoaded;
    final updatingTask = currentState.tasks.firstWhere(
      (t) => t.id == event.id,
      orElse: () => throw Exception('Task not found'),
    );
    
    try {
      final updatedTask = await _tasksRepository.updateTask(
        id: event.id,
        projectId: event.projectId,
        name: event.name,
        estimatedPomodoros: event.estimatedPomodoros,
        completedPomodoros: event.completedPomodoros,
        dueDate: event.dueDate,
        priority: event.priority,
        status: event.status,
        tags: event.tags,
        notes: event.notes,
        subtasks: event.subtasks,
      );
      
      // Check if the updated task should be included in the current filter
      bool shouldInclude = true;
      
      if (currentState.projectId != null && currentState.projectId != updatedTask.projectId) {
        shouldInclude = false;
      }
      
      if (currentState.status != null && currentState.status != updatedTask.status) {
        shouldInclude = false;
      }
      
      if (currentState.priority != null && currentState.priority != updatedTask.priority) {
        shouldInclude = false;
      }
      
      // For tag filtering, we need to check if any of the task's tags match
      if (currentState.tagId != null && !updatedTask.tags.contains(currentState.tagId)) {
        shouldInclude = false;
      }
      
      final updatedTasks = currentState.tasks.map((task) {
        return task.id == updatedTask.id ? updatedTask : task;
      }).toList();
      
      if (!shouldInclude) {
        // If the task no longer matches the filter, remove it
        updatedTasks.removeWhere((task) => task.id == updatedTask.id);
      }
      
      emit(currentState.copyWith(tasks: updatedTasks));
    } catch (e) {
      emit(TasksFailure('Failed to update task: $e'));
      // Revert to the previous state
      emit(currentState);
    }
  }
  
  Future<void> _onTaskStatusUpdateRequested(
    TaskStatusUpdateRequested event,
    Emitter<TasksState> emit,
  ) async {
    if (state is! TasksLoaded) return;
    
    final currentState = state as TasksLoaded;
    final updatingTask = currentState.tasks.firstWhere(
      (t) => t.id == event.id,
      orElse: () => throw Exception('Task not found'),
    );
    
    // Create a temporary version with the new status for optimistic UI update
    final tempUpdatedTask = updatingTask.copyWith(status: event.status);
    
    // Update tasks list optimistically
    final optimisticTasks = currentState.tasks.map((task) {
      return task.id == event.id ? tempUpdatedTask : task;
    }).toList();
    
    // Check if the task status filter would exclude the task now
    if (currentState.status != null && currentState.status != event.status) {
      optimisticTasks.removeWhere((task) => task.id == event.id);
    }
    
    emit(currentState.copyWith(tasks: optimisticTasks));
    
    try {
      await _tasksRepository.updateTaskStatus(
        id: event.id,
        status: event.status,
      );
      // We already updated the UI optimistically, so no need to emit again
    } catch (e) {
      // If there's an error, revert to the previous state
      emit(TasksFailure('Failed to update task status: $e'));
      emit(currentState);
    }
  }
  
  Future<void> _onTaskDeleteRequested(
    TaskDeleteRequested event,
    Emitter<TasksState> emit,
  ) async {
    if (state is! TasksLoaded) return;
    
    final currentState = state as TasksLoaded;
    final tasksWithoutDeleted = currentState.tasks
        .where((task) => task.id != event.id)
        .toList();
    
    // Update UI optimistically
    emit(currentState.copyWith(tasks: tasksWithoutDeleted));
    
    try {
      await _tasksRepository.deleteTask(event.id);
      // We already updated the UI optimistically, so no need to emit again
    } catch (e) {
      // If there's an error, revert to the previous state
      emit(TasksFailure('Failed to delete task: $e'));
      emit(currentState);
    }
  }
  
  Future<void> _onTasksFilterChanged(
    TasksFilterChanged event,
    Emitter<TasksState> emit,
  ) async {
    emit(TasksLoading());
    
    try {
      final tasks = await _tasksRepository.getTasks(
        projectId: event.projectId,
        status: event.status,
        priority: event.priority,
        tagId: event.tagId,
        includeDeleted: event.includeDeleted,
      );
      
      emit(TasksLoaded(
        tasks: tasks,
        projectId: event.projectId,
        status: event.status,
        priority: event.priority,
        tagId: event.tagId,
        includeDeleted: event.includeDeleted,
      ));
    } on AuthenticationException catch (e) {
      emit(TasksFailure(e.toString()));
    } on ApiException catch (e) {
      emit(TasksFailure(e.toString()));
    } catch (e) {
      emit(TasksFailure('Failed to load tasks: $e'));
    }
  }
} 