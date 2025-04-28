import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskdo/blocs/projects/projects.dart';
import 'package:taskdo/blocs/tasks/tasks.dart';
import 'package:taskdo/config/themes.dart';
import 'package:taskdo/data/models/task.dart';
import 'package:taskdo/data/models/project.dart';
import 'package:uuid/uuid.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({
    Key? key,
    this.task,
  }) : super(key: key);

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _selectedProjectId;
  int _estimatedPomodoros = 1;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  String _selectedPriority = Task.priorityMedium;
  String _selectedStatus = Task.statusTodo;
  
  List<Subtask> _subtasks = [];
  final _subtaskController = TextEditingController();
  
  bool get _isEditing => widget.task != null;
  
  @override
  void initState() {
    super.initState();
    
    // Load projects if not already loaded
    final projectsState = context.read<ProjectsBloc>().state;
    if (projectsState is! ProjectsLoaded) {
      context.read<ProjectsBloc>().add(ProjectsLoadRequested());
    }
    
    // Initialize form with existing task data if editing
    if (_isEditing) {
      _nameController.text = widget.task!.name;
      _notesController.text = widget.task!.notes;
      _selectedProjectId = widget.task!.projectId;
      _estimatedPomodoros = widget.task!.estimatedPomodoros;
      _dueDate = widget.task!.dueDate;
      _selectedPriority = widget.task!.priority;
      _selectedStatus = widget.task!.status;
      _subtasks = List.from(widget.task!.subtasks);
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Create Task'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: BlocListener<TasksBloc, TasksState>(
        listener: (context, state) {
          if (state is TasksLoaded) {
            context.pop();
          } else if (state is TasksFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Task Name',
                    hintText: 'Enter task name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a task name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Project selection
                BlocBuilder<ProjectsBloc, ProjectsState>(
                  builder: (context, state) {
                    if (state is ProjectsLoaded) {
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Project',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedProjectId != null && state.projects.any((p) => p.id == _selectedProjectId)
                            ? _selectedProjectId
                            : (state.projects.isNotEmpty ? state.projects.first.id : null),
                        items: state.projects.map((project) {
                          return DropdownMenuItem<String>(
                            value: project.id,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: _parseColor(project.color),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(project.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedProjectId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a project';
                          }
                          return null;
                        },
                      );
                    } else if (state is ProjectsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      return TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Project',
                          hintText: 'Loading projects...',
                          border: OutlineInputBorder(),
                        ),
                        enabled: false,
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Priority selection
                Row(
                  children: [
                    const Text('Priority:', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 16),
                    _buildPriorityChip(Task.priorityLow, 'Low'),
                    const SizedBox(width: 8),
                    _buildPriorityChip(Task.priorityMedium, 'Medium'),
                    const SizedBox(width: 8),
                    _buildPriorityChip(Task.priorityHigh, 'High'),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Status selection
                Row(
                  children: [
                    const Text('Status:', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 16),
                    _buildStatusChip(Task.statusTodo, 'To Do'),
                    const SizedBox(width: 8),
                    _buildStatusChip(Task.statusInProgress, 'In Progress'),
                    const SizedBox(width: 8),
                    _buildStatusChip(Task.statusCompleted, 'Completed'),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Pomodoro estimation
                Row(
                  children: [
                    const Text('Estimated Pomodoros:', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _estimatedPomodoros > 1
                          ? () => setState(() => _estimatedPomodoros--)
                          : null,
                    ),
                    Text(
                      '$_estimatedPomodoros',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(() => _estimatedPomodoros++),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Due date selection
                Row(
                  children: [
                    const Text('Due Date:', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 16),
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(_formatDate(_dueDate)),
                      onPressed: _selectDueDate,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Enter any additional notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                
                // Subtasks
                const Text('Subtasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                
                // Add subtask form
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _subtaskController,
                        decoration: const InputDecoration(
                          hintText: 'Add a subtask',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addSubtask,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Subtasks list
                ..._subtasks.map(_buildSubtaskItem).toList(),
                
                const SizedBox(height: 24),
                
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(_isEditing ? 'Update Task' : 'Create Task'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _dueDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _dueDate.hour,
          _dueDate.minute,
        );
      });
      
      // Show time picker
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate),
      );
      
      if (pickedTime != null) {
        setState(() {
          _dueDate = DateTime(
            _dueDate.year,
            _dueDate.month,
            _dueDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }
  
  void _addSubtask() {
    if (_subtaskController.text.isNotEmpty) {
      setState(() {
        _subtasks.add(
          Subtask(
            id: const Uuid().v4(), // Generate a unique ID
            description: _subtaskController.text,
            completed: false,
          ),
        );
        _subtaskController.clear();
      });
    }
  }
  
  Widget _buildSubtaskItem(Subtask subtask) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Checkbox(
            value: subtask.completed,
            onChanged: (value) {
              setState(() {
                final index = _subtasks.indexOf(subtask);
                _subtasks[index] = subtask.copyWith(completed: value ?? false);
              });
            },
          ),
          Expanded(
            child: Text(subtask.description),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                _subtasks.remove(subtask);
              });
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildPriorityChip(String priority, String label) {
    final bool isSelected = _selectedPriority == priority;
    
    Color chipColor;
    switch (priority) {
      case Task.priorityLow:
        chipColor = Colors.green;
        break;
      case Task.priorityMedium:
        chipColor = Colors.orange;
        break;
      case Task.priorityHigh:
        chipColor = AppTheme.errorColor;
        break;
      default:
        chipColor = Colors.blue;
    }
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: chipColor.withOpacity(0.7),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedPriority = priority;
          });
        }
      },
    );
  }
  
  Widget _buildStatusChip(String status, String label) {
    final bool isSelected = _selectedStatus == status;
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.blue.withOpacity(0.7),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedStatus = status;
          });
        }
      },
    );
  }
  
  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedProjectId != null) {
      if (_isEditing) {
        context.read<TasksBloc>().add(
          TaskUpdateRequested(
            id: widget.task!.id,
            name: _nameController.text,
            projectId: _selectedProjectId,
            estimatedPomodoros: _estimatedPomodoros,
            dueDate: _dueDate,
            priority: _selectedPriority,
            status: _selectedStatus,
            notes: _notesController.text,
            subtasks: _subtasks,
          ),
        );
      } else {
        context.read<TasksBloc>().add(
          TaskCreateRequested(
            name: _nameController.text,
            projectId: _selectedProjectId!,
            estimatedPomodoros: _estimatedPomodoros,
            dueDate: _dueDate,
            priority: _selectedPriority,
            status: _selectedStatus,
            notes: _notesController.text,
            subtasks: _subtasks,
          ),
        );
      }
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
} 