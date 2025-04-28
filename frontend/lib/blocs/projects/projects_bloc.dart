import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskdo/blocs/projects/projects_event.dart';
import 'package:taskdo/blocs/projects/projects_state.dart';
import 'package:taskdo/data/models/project.dart';
import 'package:taskdo/data/repositories/projects_repository.dart';
import 'package:taskdo/utils/exceptions.dart';

class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  final ProjectsRepository _projectsRepository;
  
  ProjectsBloc({required ProjectsRepository projectsRepository})
      : _projectsRepository = projectsRepository,
        super(ProjectsInitial()) {
    on<ProjectsLoadRequested>(_onProjectsLoadRequested);
    on<ProjectsCreateRequested>(_onProjectsCreateRequested);
    on<ProjectsUpdateRequested>(_onProjectsUpdateRequested);
    on<ProjectsArchiveRequested>(_onProjectsArchiveRequested);
    on<ProjectsFilterChanged>(_onProjectsFilterChanged);
  }
  
  Future<void> _onProjectsLoadRequested(
    ProjectsLoadRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectsLoading());
    
    try {
      final bool includeArchived = state is ProjectsLoaded 
          ? (state as ProjectsLoaded).includeArchived 
          : false;
      
      final projects = await _projectsRepository.getProjects(
        includeArchived: includeArchived,
      );
      
      emit(ProjectsLoaded(
        projects: projects,
        includeArchived: includeArchived,
      ));
    } on AuthenticationException catch (e) {
      emit(ProjectsFailure(e.toString()));
    } on ApiException catch (e) {
      emit(ProjectsFailure(e.toString()));
    } catch (e) {
      emit(ProjectsFailure('Failed to load projects: $e'));
    }
  }
  
  Future<void> _onProjectsCreateRequested(
    ProjectsCreateRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectsLoading());
    
    try {
      final project = await _projectsRepository.createProject(
        name: event.name,
        description: event.description,
        color: event.color,
        deadline: event.deadline,
      );
      
      if (state is ProjectsLoaded) {
        final currentState = state as ProjectsLoaded;
        final updatedProjects = List<Project>.from(currentState.projects)
          ..add(project);
        
        emit(currentState.copyWith(projects: updatedProjects));
      } else {
        // If we don't have projects loaded, load them again
        add(ProjectsLoadRequested());
      }
    } on AuthenticationException catch (e) {
      emit(ProjectsFailure(e.toString()));
    } on ApiException catch (e) {
      emit(ProjectsFailure(e.toString()));
    } catch (e) {
      emit(ProjectsFailure('Failed to create project: $e'));
    }
  }
  
  Future<void> _onProjectsUpdateRequested(
    ProjectsUpdateRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectsLoading());
    
    try {
      final project = await _projectsRepository.updateProject(
        id: event.id,
        name: event.name,
        description: event.description,
        color: event.color,
        deadline: event.deadline,
      );
      
      if (state is ProjectsLoaded) {
        final currentState = state as ProjectsLoaded;
        final updatedProjects = currentState.projects.map((p) {
          return p.id == project.id ? project : p;
        }).toList();
        
        emit(currentState.copyWith(projects: updatedProjects));
      } else {
        // If we don't have projects loaded, load them again
        add(ProjectsLoadRequested());
      }
    } on AuthenticationException catch (e) {
      emit(ProjectsFailure(e.toString()));
    } on ApiException catch (e) {
      emit(ProjectsFailure(e.toString()));
    } catch (e) {
      emit(ProjectsFailure('Failed to update project: $e'));
    }
  }
  
  Future<void> _onProjectsArchiveRequested(
    ProjectsArchiveRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state is! ProjectsLoaded) return;
    
    final currentState = state as ProjectsLoaded;
    final projectToArchive = currentState.projects.firstWhere(
      (p) => p.id == event.id,
      orElse: () => throw Exception('Project not found'),
    );
    
    // Create a temporary version with isArchived=true for optimistic UI update
    final archivedProject = projectToArchive.copyWith(isArchived: true);
    
    // Update projects list optimistically
    final optimisticProjects = currentState.projects.map((p) {
      return p.id == event.id ? archivedProject : p;
    }).toList();
    
    // Filter out archived project if we're not including archived
    final updatedProjects = currentState.includeArchived
        ? optimisticProjects
        : optimisticProjects.where((p) => !p.isArchived).toList();
    
    emit(currentState.copyWith(projects: updatedProjects));
    
    try {
      await _projectsRepository.archiveProject(event.id);
      // We already updated the UI optimistically, so no need to emit again
    } catch (e) {
      // If there's an error, revert to the previous state
      emit(currentState);
      emit(ProjectsFailure('Failed to archive project: $e'));
    }
  }
  
  Future<void> _onProjectsFilterChanged(
    ProjectsFilterChanged event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectsLoading());
    
    try {
      final projects = await _projectsRepository.getProjects(
        includeArchived: event.includeArchived,
      );
      
      emit(ProjectsLoaded(
        projects: projects,
        includeArchived: event.includeArchived,
      ));
    } on AuthenticationException catch (e) {
      emit(ProjectsFailure(e.toString()));
    } on ApiException catch (e) {
      emit(ProjectsFailure(e.toString()));
    } catch (e) {
      emit(ProjectsFailure('Failed to load projects: $e'));
    }
  }
} 