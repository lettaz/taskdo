import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskdo/blocs/projects/projects.dart';
import 'package:taskdo/config/routes.dart';
import 'package:taskdo/config/themes.dart';
import 'package:taskdo/data/models/project.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({
    Key? key,
    required this.projectId,
  }) : super(key: key);

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadProject();
  }

  void _loadProject() {
    final state = context.read<ProjectsBloc>().state;
    if (state is! ProjectsLoaded) {
      context.read<ProjectsBloc>().add(ProjectsLoadRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectsBloc, ProjectsState>(
      builder: (context, state) {
        if (state is ProjectsLoaded) {
          final project = state.projects.firstWhere(
            (p) => p.id == widget.projectId,
            orElse: () => throw Exception('Project not found'),
          );

          return _buildContent(project);
        } else if (state is ProjectsLoading) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Project Details'),
              backgroundColor: AppTheme.primaryColor,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (state is ProjectsFailure) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Project Details'),
              backgroundColor: AppTheme.primaryColor,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: AppTheme.errorColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: AppTheme.secondaryColor,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Initial or unknown state
        return Scaffold(
          appBar: AppBar(
            title: const Text('Project Details'),
            backgroundColor: AppTheme.primaryColor,
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildContent(Project project) {
    final Color projectColor = _parseColor(project.color);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        backgroundColor: projectColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(project),
            tooltip: 'Edit Project',
          ),
          IconButton(
            icon: const Icon(Icons.archive),
            onPressed: () => _confirmArchive(project),
            tooltip: 'Archive Project',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project header section
            Container(
              padding: const EdgeInsets.all(16),
              color: projectColor.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: projectColor,
                        radius: 20,
                        child: Text(
                          project.name.isNotEmpty 
                              ? project.name.substring(0, 1).toUpperCase() 
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (project.isArchived)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.archive,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Archived',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (project.description.isNotEmpty)
                    Text(
                      project.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (project.deadline != null) ...[
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: _isDeadlinePassed(project.deadline!)
                              ? AppTheme.errorColor
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Deadline: ${_formatDate(project.deadline!)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: _isDeadlinePassed(project.deadline!)
                                ? AppTheme.errorColor
                                : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Created: ${_formatDate(project.createdAt)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Tasks section (to be implemented with tasks)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tasks',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // This will be implemented when we add task creation
                          // For now it just shows a coming soon message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Task creation coming soon!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Task'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: projectColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Placeholder for task list
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tasks will appear here once you create them',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEdit(Project project) {
    final path = AppRouter.projectEdit.replaceFirst(':id', project.id);
    context.push(path, extra: project);
  }

  Color _parseColor(String colorCode) {
    try {
      if (colorCode.startsWith('#')) {
        return Color(int.parse('0xFF${colorCode.substring(1)}'));
      }
      return AppTheme.primaryColor;
    } catch (e) {
      return AppTheme.primaryColor;
    }
  }

  bool _isDeadlinePassed(DateTime deadline) {
    final now = DateTime.now();
    return deadline.isBefore(now);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _confirmArchive(Project project) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Archive Project'),
          content: Text(
            'Are you sure you want to archive "${project.name}"? '
            'Archived projects will no longer appear in the active projects list.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _archiveProject(project.id);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
              ),
              child: const Text('Archive'),
            ),
          ],
        );
      },
    );
  }

  void _archiveProject(String projectId) {
    context.read<ProjectsBloc>().add(ProjectsArchiveRequested(id: projectId));
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Project archived successfully'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Navigate back to projects list
    context.pop();
  }
} 