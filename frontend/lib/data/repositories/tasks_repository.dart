import 'package:dio/dio.dart';
import 'package:taskdo/data/models/task.dart';
import 'package:taskdo/data/providers/api_provider.dart';
import 'package:taskdo/data/providers/secure_storage.dart';
import 'package:taskdo/utils/exceptions.dart';

class TasksRepository {
  final ApiProvider _apiProvider;
  final SecureStorageProvider _secureStorageProvider;
  
  TasksRepository({
    required ApiProvider apiProvider,
    required SecureStorageProvider secureStorageProvider,
  })  : _apiProvider = apiProvider,
        _secureStorageProvider = secureStorageProvider;

  Future<List<Task>> getTasks({
    String? projectId,
    String? status,
    String? priority,
    String? tagId,
    bool includeDeleted = false,
  }) async {
    try {
      final token = await _secureStorageProvider.getAuthToken();
      
      if (token == null) {
        throw AuthenticationException('No authentication token found');
      }

      // Build query parameters
      final Map<String, dynamic> queryParams = {};
      if (projectId != null) queryParams['project_id'] = projectId;
      if (status != null) queryParams['status'] = status;
      if (priority != null) queryParams['priority'] = priority;
      if (tagId != null) queryParams['tag_id'] = tagId;
      if (includeDeleted) queryParams['is_deleted'] = 'true';

      // Construct URL with query parameters
      String url = '/tasks';
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${e.key}=${e.value}')
            .join('&');
        url = '$url?$queryString';
      }
      
      final response = await _apiProvider.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data is List) {
          final tasksList = data.map((task) => Task.fromJson(task)).toList();
          return tasksList;
        } else if (data is Map && data['tasks'] != null) {
          final tasksList = (data['tasks'] as List)
              .map((task) => Task.fromJson(task))
              .toList();
          return tasksList;
        } else {
          return [];
        }
      } else if (response.statusCode == 401) {
        throw AuthenticationException('Authentication failed');
      } else {
        throw ApiException('Failed to fetch tasks: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException in getTasks: $e');
      if (e.response?.statusCode == 401) {
        throw AuthenticationException('Authentication failed');
      }
      throw ApiException('Failed to fetch tasks: ${e.message}');
    } catch (e) {
      print('Error in getTasks: $e');
      if (e is AuthenticationException || e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to fetch tasks: $e');
    }
  }

  Future<Task> getTask(String id) async {
    try {
      final token = await _secureStorageProvider.getAuthToken();
      
      if (token == null) {
        throw AuthenticationException('No authentication token found');
      }
      
      final response = await _apiProvider.get('/tasks/$id');

      if (response.statusCode == 200) {
        return Task.fromJson(response.data);
      } else if (response.statusCode == 401) {
        throw AuthenticationException('Authentication failed');
      } else if (response.statusCode == 404) {
        throw ApiException('Task not found');
      } else {
        throw ApiException('Failed to fetch task: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException in getTask: $e');
      if (e.response?.statusCode == 401) {
        throw AuthenticationException('Authentication failed');
      } else if (e.response?.statusCode == 404) {
        throw ApiException('Task not found');
      }
      throw ApiException('Failed to fetch task: ${e.message}');
    } catch (e) {
      print('Error in getTask: $e');
      if (e is AuthenticationException || e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to fetch task: $e');
    }
  }

  Future<Task> createTask({
    required String projectId,
    required String name,
    required int estimatedPomodoros,
    required DateTime dueDate,
    required String priority,
    required String status,
    List<String>? tags,
    String? notes,
    List<Subtask>? subtasks,
  }) async {
    try {
      final token = await _secureStorageProvider.getAuthToken();
      
      if (token == null) {
        throw AuthenticationException('No authentication token found');
      }
      
      final data = {
        'project_id': projectId,
        'name': name,
        'estimated_pomodoros': estimatedPomodoros,
        'due_date': dueDate.toIso8601String(),
        'priority': priority,
        'status': status,
        if (tags != null) 'tags': tags,
        if (notes != null) 'notes': notes,
        if (subtasks != null) 'subtasks': subtasks.map((s) => s.toJson()).toList(),
      };
      
      final response = await _apiProvider.post('/tasks', data: data);

      if (response.statusCode == 201) {
        return Task.fromJson(response.data);
      } else if (response.statusCode == 401) {
        throw AuthenticationException('Authentication failed');
      } else {
        throw ApiException('Failed to create task: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException in createTask: $e');
      if (e.response?.statusCode == 401) {
        throw AuthenticationException('Authentication failed');
      }
      throw ApiException('Failed to create task: ${e.message}');
    } catch (e) {
      print('Error in createTask: $e');
      if (e is AuthenticationException || e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to create task: $e');
    }
  }

  Future<Task> updateTask({
    required String id,
    String? projectId,
    String? name,
    int? estimatedPomodoros,
    int? completedPomodoros,
    DateTime? dueDate,
    String? priority,
    String? status,
    List<String>? tags,
    String? notes,
    List<Subtask>? subtasks,
  }) async {
    try {
      final token = await _secureStorageProvider.getAuthToken();
      
      if (token == null) {
        throw AuthenticationException('No authentication token found');
      }
      
      final data = {
        if (projectId != null) 'project_id': projectId,
        if (name != null) 'name': name,
        if (estimatedPomodoros != null) 'estimated_pomodoros': estimatedPomodoros,
        if (completedPomodoros != null) 'completed_pomodoros': completedPomodoros,
        if (dueDate != null) 'due_date': dueDate.toIso8601String(),
        if (priority != null) 'priority': priority,
        if (status != null) 'status': status,
        if (tags != null) 'tags': tags,
        if (notes != null) 'notes': notes,
        if (subtasks != null) 'subtasks': subtasks.map((s) => s.toJson()).toList(),
      };
      
      final response = await _apiProvider.put('/tasks/$id', data: data);

      if (response.statusCode == 200) {
        return Task.fromJson(response.data);
      } else if (response.statusCode == 401) {
        throw AuthenticationException('Authentication failed');
      } else if (response.statusCode == 404) {
        throw ApiException('Task not found');
      } else {
        throw ApiException('Failed to update task: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException in updateTask: $e');
      if (e.response?.statusCode == 401) {
        throw AuthenticationException('Authentication failed');
      } else if (e.response?.statusCode == 404) {
        throw ApiException('Task not found');
      }
      throw ApiException('Failed to update task: ${e.message}');
    } catch (e) {
      print('Error in updateTask: $e');
      if (e is AuthenticationException || e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to update task: $e');
    }
  }

  Future<Task> updateTaskStatus({
    required String id,
    required String status,
  }) async {
    try {
      return await updateTask(id: id, status: status);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      final token = await _secureStorageProvider.getAuthToken();
      
      if (token == null) {
        throw AuthenticationException('No authentication token found');
      }
      
      final response = await _apiProvider.delete('/tasks/$id');

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw AuthenticationException('Authentication failed');
      } else if (response.statusCode == 404) {
        throw ApiException('Task not found');
      } else {
        throw ApiException('Failed to delete task: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException in deleteTask: $e');
      if (e.response?.statusCode == 401) {
        throw AuthenticationException('Authentication failed');
      } else if (e.response?.statusCode == 404) {
        throw ApiException('Task not found');
      }
      throw ApiException('Failed to delete task: ${e.message}');
    } catch (e) {
      print('Error in deleteTask: $e');
      if (e is AuthenticationException || e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to delete task: $e');
    }
  }
} 