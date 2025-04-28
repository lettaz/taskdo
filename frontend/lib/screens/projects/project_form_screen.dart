import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskdo/blocs/projects/projects.dart';
import 'package:taskdo/config/themes.dart';
import 'package:taskdo/data/models/project.dart';

class ProjectFormScreen extends StatefulWidget {
  final Project? project;

  const ProjectFormScreen({
    super.key,
    this.project,
  });

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _deadline;
  String _selectedColor = '#FF5A5A'; // Default color

  final List<String> _colorOptions = [
    '#FF5A5A', // Red
    '#FF9500', // Orange
    '#FFCC00', // Yellow
    '#34C759', // Green
    '#5AC8FA', // Light Blue
    '#007AFF', // Blue
    '#5856D6', // Purple
    '#AF52DE', // Pink
  ];

  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.project!.name;
      _descriptionController.text = widget.project!.description;
      _deadline = widget.project!.deadline;
      _selectedColor = widget.project!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Project' : 'Create Project'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.archive),
              onPressed: _confirmArchiveProject,
              tooltip: 'Archive Project',
            ),
        ],
      ),
      body: BlocListener<ProjectsBloc, ProjectsState>(
        listener: (context, state) {
          if (state is ProjectsLoaded) {
            context.pop();
          } else if (state is ProjectsFailure) {
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
                    labelText: 'Project Name',
                    hintText: 'Enter project name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a project name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter project description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                
                // Color selection
                const Text(
                  'Color',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildColorSelector(),
                const SizedBox(height: 16),
                
                // Deadline field
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Deadline: ${_deadline != null ? _formatDate(_deadline!) : 'None'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: _selectDeadline,
                      child: Text(_deadline != null ? 'Change' : 'Set Deadline'),
                    ),
                    if (_deadline != null)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _deadline = null;
                          });
                        },
                        child: const Text('Clear'),
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: AppTheme.secondaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(_isEditing ? 'Update Project' : 'Create Project'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    return Wrap(
      spacing: 8,
      children: _colorOptions.map((color) {
        final isSelected = color == _selectedColor;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _parseColor(color),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Future<void> _selectDeadline() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = _deadline ?? now;
    
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    
    if (picked != null) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_isEditing) {
        context.read<ProjectsBloc>().add(
          ProjectsUpdateRequested(
            id: widget.project!.id,
            name: _nameController.text,
            description: _descriptionController.text,
            color: _selectedColor,
            deadline: _deadline,
          ),
        );
      } else {
        context.read<ProjectsBloc>().add(
          ProjectsCreateRequested(
            name: _nameController.text,
            description: _descriptionController.text,
            color: _selectedColor,
            deadline: _deadline,
          ),
        );
      }
    }
  }

  void _confirmArchiveProject() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Archive Project'),
          content: const Text(
            'Are you sure you want to archive this project? '
            'Archived projects can be viewed by enabling "Show Archived Projects" in the filter options.',
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
                  ProjectsArchiveRequested(id: widget.project!.id),
                );
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: AppTheme.secondaryColor,
              ),
              child: const Text('Archive'),
            ),
          ],
        );
      },
    );
  }

  Color _parseColor(String colorCode) {
    if (colorCode.startsWith('#')) {
      return Color(int.parse('0xFF${colorCode.substring(1)}'));
    }
    return AppTheme.primaryColor;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 