import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:taskdo/data/models/project.dart';
import 'package:taskdo/data/providers/api_provider.dart';
import 'package:taskdo/data/providers/secure_storage.dart';
import 'package:taskdo/utils/exceptions.dart';

class ProjectsRepository {
  final ApiProvider _apiProvider;
  final SecureStorageProvider _secureStorageProvider;
  
  ProjectsRepository({
    required ApiProvider apiProvider,
    required SecureStorageProvider secureStorageProvider,
  })  : _apiProvider = apiProvider,
        _secureStorageProvider = secureStorageProvider;

  Future<List<Project>> getProjects({bool includeArchived = false}) async {
    try {
      final token = await _secureStorageProvider.getAuthToken();
      
      if (token == null) {
        throw AuthenticationException('No authentication token found');
      }

      String url = '/projects';
      if (includeArchived) {
        url += '?include_archived=true';
      }
      
      final response = await _apiProvider.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        print('Projects response: $data');
        
        if (data is List) {
          final projectsList = data
              .map((project) => Project.fromJson(project))
              .toList();
          return projectsList;
        } else if (data is Map && data['projects'] != null) {
          final projectsList = (data['projects'] as List)
              .map((project) => Project.fromJson(project))
              .toList();
          return projectsList;
        } else {
          return [];
        }
      } else if (response.statusCode == 401) {
        throw AuthenticationException('Authentication failed');
      } else {
        throw ApiException('Failed to fetch projects: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException in getProjects: $e');
      if (e.response?.statusCode == 401) {
        throw AuthenticationException('Authentication failed');
      }
      throw ApiException('Failed to fetch projects: ${e.message}');
    } catch (e) {
      print('Error in getProjects: $e');
      if (e is AuthenticationException || e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to fetch projects: $e');
    }
  }

  Future<Project> createProject({
    required String name,
    required String description,
    required String color,
    DateTime? deadline,
  }) async {
    try {
      final token = await _secureStorageProvider.getAuthToken();
      
      if (token == null) {
        throw AuthenticationException('No authentication token found');
      }
      
      final response = await _apiProvider.post('/projects', data: {
        'name': name,
        'description': description,
        'color': color,
        'deadline': deadline?.toIso8601String(),
      });

      if (response.statusCode == 201) {
        final data = response.data;
        return Project.fromJson(data);
      } else if (response.statusCode == 401) {
        throw AuthenticationException('Authentication failed');
      } else {
        throw ApiException('Failed to create project: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException in createProject: $e');
      if (e.response?.statusCode == 401) {
        throw AuthenticationException('Authentication failed');
      }
      throw ApiException('Failed to create project: ${e.message}');
    } catch (e) {
      print('Error in createProject: $e');
      if (e is AuthenticationException || e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to create project: $e');
    }
  }

  Future<Project> updateProject({
    required String id,
    required String name,
    required String description,
    required String color,
    DateTime? deadline,
  }) async {
    try {
      final token = await _secureStorageProvider.getAuthToken();
      
      if (token == null) {
        throw AuthenticationException('No authentication token found');
      }
      
      final response = await _apiProvider.put('/projects/$id', data: {
        'name': name,
        'description': description,
        'color': color,
        'deadline': deadline?.toIso8601String(),
      });

      if (response.statusCode == 200) {
        final data = response.data;
        return Project.fromJson(data);
      } else if (response.statusCode == 401) {
        throw AuthenticationException('Authentication failed');
      } else {
        throw ApiException('Failed to update project: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException in updateProject: $e');
      if (e.response?.statusCode == 401) {
        throw AuthenticationException('Authentication failed');
      }
      throw ApiException('Failed to update project: ${e.message}');
    } catch (e) {
      print('Error in updateProject: $e');
      if (e is AuthenticationException || e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to update project: $e');
    }
  }

  Future<void> archiveProject(String id) async {
    try {
      final token = await _secureStorageProvider.getAuthToken();
      
      if (token == null) {
        throw AuthenticationException('No authentication token found');
      }
      
      final response = await _apiProvider.delete('/projects/$id');

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw AuthenticationException('Authentication failed');
      } else {
        throw ApiException('Failed to archive project: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException in archiveProject: $e');
      if (e.response?.statusCode == 401) {
        throw AuthenticationException('Authentication failed');
      }
      throw ApiException('Failed to archive project: ${e.message}');
    } catch (e) {
      print('Error in archiveProject: $e');
      if (e is AuthenticationException || e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to archive project: $e');
    }
  }
} 