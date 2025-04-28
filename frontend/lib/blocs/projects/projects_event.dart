import 'package:equatable/equatable.dart';
import 'package:taskdo/data/models/project.dart';

abstract class ProjectsEvent extends Equatable {
  const ProjectsEvent();

  @override
  List<Object?> get props => [];
}

class ProjectsLoadRequested extends ProjectsEvent {}

class ProjectsCreateRequested extends ProjectsEvent {
  final String name;
  final String description;
  final String color;
  final DateTime? deadline;

  const ProjectsCreateRequested({
    required this.name,
    required this.description,
    required this.color,
    this.deadline,
  });

  @override
  List<Object?> get props => [name, description, color, deadline];
}

class ProjectsUpdateRequested extends ProjectsEvent {
  final String id;
  final String name;
  final String description;
  final String color;
  final DateTime? deadline;

  const ProjectsUpdateRequested({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    this.deadline,
  });

  @override
  List<Object?> get props => [id, name, description, color, deadline];
}

class ProjectsArchiveRequested extends ProjectsEvent {
  final String id;

  const ProjectsArchiveRequested({
    required this.id,
  });

  @override
  List<Object?> get props => [id];
}

class ProjectsFilterChanged extends ProjectsEvent {
  final bool includeArchived;

  const ProjectsFilterChanged({
    this.includeArchived = false,
  });

  @override
  List<Object?> get props => [includeArchived];
} 