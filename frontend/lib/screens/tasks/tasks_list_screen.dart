import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskdo/blocs/projects/projects.dart';
import 'package:taskdo/blocs/tasks/tasks.dart';
import 'package:taskdo/config/routes.dart';
import 'package:taskdo/config/themes.dart';
import 'package:taskdo/data/models/task.dart';

class TasksListScreen extends StatefulWidget {
  const TasksListScreen({Key? key}) : super(key: key);

  @override
  State<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<TasksListScreen> {
  String? _selectedProjectId;
  String? _selectedStatus;
  String? _selectedPriority;

  @override
  void initState() {
    super.initState();
    context.read<TasksBloc>().add(const TasksLoadRequested());
    context.read<ProjectsBloc>().add(ProjectsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
            tooltip: 'Filter tasks',
          ),
        ],
      ),
      body: BlocBuilder<TasksBloc, TasksState>(
        builder: (context, state) {
          if (state is TasksInitial || state is TasksLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TasksLoaded) {
            return _buildTasksList(state.tasks);
          } else if (state is TasksFailure) {
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
                      context.read<TasksBloc>().add(const TasksLoadRequested());
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
        onPressed: () => context.push(AppRouter.taskCreate),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTasksList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.task_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No tasks found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push(AppRouter.taskCreate),
              icon: const Icon(Icons.add),
              label: const Text('Create Task'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.secondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task);
      },
    );
  }

  Widget _buildTaskCard(Task task) {
    final Color priorityColor = _getPriorityColor(task.priority);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onTap: () => context.push('${AppRouter.tasks}/${task.id}'),
        leading: CircleAvatar(
          backgroundColor: priorityColor,
          radius: 24,
          child: Icon(
            _getStatusIcon(task.status),
            color: Colors.white,
          ),
        ),
        title: Text(
          task.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            
            // Project name from BLoC (if available)
            BlocBuilder<ProjectsBloc, ProjectsState>(
              builder: (context, state) {
                if (state is ProjectsLoaded) {
                  try {
                    final project = state.projects.firstWhere(
                      (p) => p.id == task.projectId,
                    );
                    
                    return Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _parseColor(project.color),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          project.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    );
                  } catch (e) {
                    // Project not found
                  }
                }
                return const SizedBox();
              },
            ),
            
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Due date
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: _isDatePassed(task.dueDate)
                          ? AppTheme.errorColor
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(task.dueDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: _isDatePassed(task.dueDate)
                            ? AppTheme.errorColor
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                
                // Pomodoros
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${task.completedPomodoros}/${task.estimatedPomodoros}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleAction(value, task),
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'edit',
              child: Text('Edit'),
            ),
            if (task.status != Task.statusCompleted)
              const PopupMenuItem<String>(
                value: 'complete',
                child: Text('Mark as complete'),
              ),
            if (task.status != Task.statusInProgress)
              const PopupMenuItem<String>(
                value: 'progress',
                child: Text('Mark as in progress'),
              ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAction(String action, Task task) {
    switch (action) {
      case 'edit':
        context.push('${AppRouter.taskEdit}/${task.id}', extra: task);
        break;
      case 'complete':
        context.read<TasksBloc>().add(
          TaskStatusUpdateRequested(
            id: task.id,
            status: Task.statusCompleted,
          ),
        );
        break;
      case 'progress':
        context.read<TasksBloc>().add(
          TaskStatusUpdateRequested(
            id: task.id,
            status: Task.statusInProgress,
          ),
        );
        break;
      case 'delete':
        _confirmDelete(task);
        break;
    }
  }

  void _confirmDelete(Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Text('Are you sure you want to delete "${task.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<TasksBloc>().add(TaskDeleteRequested(id: task.id));
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showFilterOptions() {
    final tasksState = context.read<TasksBloc>().state;
    final projectsState = context.read<ProjectsBloc>().state;
    
    String? projectId = _selectedProjectId;
    String? status = _selectedStatus;
    String? priority = _selectedPriority;
    
    if (tasksState is TasksLoaded) {
      projectId = tasksState.projectId;
      status = tasksState.status;
      priority = tasksState.priority;
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Tasks'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project filter
                    const Text('Project', style: TextStyle(fontWeight: FontWeight.bold)),
                    if (projectsState is ProjectsLoaded)
                      DropdownButton<String?>(
                        isExpanded: true,
                        value: projectId,
                        hint: const Text('All Projects'),
                        onChanged: (value) {
                          setState(() {
                            projectId = value;
                          });
                        },
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All Projects'),
                          ),
                          ...projectsState.projects.map((project) {
                            return DropdownMenuItem<String?>(
                              value: project.id,
                              child: Text(project.name),
                            );
                          }).toList(),
                        ],
                      ),
                    
                    const SizedBox(height: 16),
                    // Status filter
                    const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String?>(
                      isExpanded: true,
                      value: status,
                      hint: const Text('All Statuses'),
                      onChanged: (value) {
                        setState(() {
                          status = value;
                        });
                      },
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Statuses'),
                        ),
                        DropdownMenuItem<String?>(
                          value: Task.statusTodo,
                          child: const Text('To Do'),
                        ),
                        DropdownMenuItem<String?>(
                          value: Task.statusInProgress,
                          child: const Text('In Progress'),
                        ),
                        DropdownMenuItem<String?>(
                          value: Task.statusCompleted,
                          child: const Text('Completed'),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    // Priority filter
                    const Text('Priority', style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String?>(
                      isExpanded: true,
                      value: priority,
                      hint: const Text('All Priorities'),
                      onChanged: (value) {
                        setState(() {
                          priority = value;
                        });
                      },
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Priorities'),
                        ),
                        DropdownMenuItem<String?>(
                          value: Task.priorityLow,
                          child: const Text('Low'),
                        ),
                        DropdownMenuItem<String?>(
                          value: Task.priorityMedium,
                          child: const Text('Medium'),
                        ),
                        DropdownMenuItem<String?>(
                          value: Task.priorityHigh,
                          child: const Text('High'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _selectedProjectId = projectId;
                    _selectedStatus = status;
                    _selectedPriority = priority;
                    
                    context.read<TasksBloc>().add(
                      TasksFilterChanged(
                        projectId: projectId,
                        status: status,
                        priority: priority,
                      ),
                    );
                    
                    Navigator.pop(context);
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

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case Task.priorityLow:
        return Colors.green;
      case Task.priorityMedium:
        return Colors.orange;
      case Task.priorityHigh:
        return AppTheme.errorColor;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case Task.statusTodo:
        return Icons.circle_outlined;
      case Task.statusInProgress:
        return Icons.play_arrow;
      case Task.statusCompleted:
        return Icons.check;
      default:
        return Icons.circle_outlined;
    }
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

  bool _isDatePassed(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(now);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 