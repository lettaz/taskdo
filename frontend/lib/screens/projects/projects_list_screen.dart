import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskdo/blocs/projects/projects.dart';
import 'package:taskdo/config/routes.dart';
import 'package:taskdo/config/themes.dart';
import 'package:taskdo/data/models/project.dart';

class ProjectsListScreen extends StatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  State<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends State<ProjectsListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProjectsBloc>().add(ProjectsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
            tooltip: 'Filter projects',
          ),
        ],
      ),
      body: BlocBuilder<ProjectsBloc, ProjectsState>(
        builder: (context, state) {
          if (state is ProjectsInitial || state is ProjectsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProjectsLoaded) {
            return _buildProjectsList(state.projects);
          } else if (state is ProjectsFailure) {
            return Center(
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
                    onPressed: () {
                      context.read<ProjectsBloc>().add(ProjectsLoadRequested());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: AppTheme.secondaryColor,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRouter.projectCreate),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProjectsList(List<Project> projects) {
    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.folder_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No projects found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push(AppRouter.projectCreate),
              icon: const Icon(Icons.add),
              label: const Text('Create Project'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.secondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return _buildProjectCard(project);
      },
    );
  }

  Widget _buildProjectCard(Project project) {
    final Color projectColor = _parseColor(project.color);
    final bool isLargeScreen = MediaQuery.of(context).size.width > 600;
    
    return InkWell(
      onTap: () => context.push('${AppRouter.projects}/${project.id}'),
      borderRadius: BorderRadius.circular(8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: projectColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border(
              top: BorderSide(
                color: projectColor,
                width: 4,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (project.isArchived)
                    const Icon(
                      Icons.archive,
                      size: 16,
                      color: Colors.grey,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                project.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              if (project.deadline != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isDeadlinePassed(project.deadline!) 
                        ? AppTheme.errorColor.withOpacity(0.1) 
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: _isDeadlinePassed(project.deadline!)
                            ? AppTheme.errorColor
                            : Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(project.deadline!),
                        style: TextStyle(
                          fontSize: 12,
                          color: _isDeadlinePassed(project.deadline!)
                              ? AppTheme.errorColor
                              : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              // Task completion status (only visible on larger screens)
              if (isLargeScreen) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 14,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '0/0 tasks', // Placeholder - to be replaced with actual task count
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: 0, // Placeholder - to be replaced with actual progress
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(projectColor),
                    minHeight: 5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterOptions() {
    final state = context.read<ProjectsBloc>().state;
    bool includeArchived = state is ProjectsLoaded ? state.includeArchived : false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Projects'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: const Text('Show Archived Projects'),
                    value: includeArchived,
                    onChanged: (value) {
                      setState(() {
                        includeArchived = value ?? false;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<ProjectsBloc>().add(
                      ProjectsFilterChanged(includeArchived: includeArchived),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.secondaryColor,
                  ),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
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
} 