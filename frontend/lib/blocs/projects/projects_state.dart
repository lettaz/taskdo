import 'package:equatable/equatable.dart';
import 'package:taskdo/data/models/project.dart';

abstract class ProjectsState extends Equatable {
  const ProjectsState();

  @override
  List<Object?> get props => [];
}

class ProjectsInitial extends ProjectsState {}

class ProjectsLoading extends ProjectsState {}

class ProjectsLoaded extends ProjectsState {
  final List<Project> projects;
  final bool includeArchived;

  const ProjectsLoaded({
    required this.projects,
    this.includeArchived = false,
  });

  @override
  List<Object?> get props => [projects, includeArchived];

  ProjectsLoaded copyWith({
    List<Project>? projects,
    bool? includeArchived,
  }) {
    return ProjectsLoaded(
      projects: projects ?? this.projects,
      includeArchived: includeArchived ?? this.includeArchived,
    );
  }
}

class ProjectsFailure extends ProjectsState {
  final String message;

  const ProjectsFailure(this.message);

  @override
  List<Object?> get props => [message];
} 