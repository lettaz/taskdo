class ApiConstants {
  // Base URL
  static const String baseUrl = 'http://localhost:8000/api';
  
  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String verify = '$baseUrl/auth/verify';
  static const String resetPassword = '$baseUrl/auth/reset-password';
  static const String logout = '$baseUrl/auth/logout';
  
  // Projects endpoints
  static const String projects = '$baseUrl/projects';
  static const String projectDetails = '$baseUrl/projects/'; // append project_id
  static const String archiveProject = '$baseUrl/projects/'; // append project_id/archive
  
  // Tasks endpoints
  static const String tasks = '$baseUrl/tasks';
  static const String taskDetails = '$baseUrl/tasks/'; // append task_id
  static const String completeTask = '$baseUrl/tasks/'; // append task_id/complete
  
  // Tags endpoints
  static const String tags = '$baseUrl/tags';
  static const String tagDetails = '$baseUrl/tags/'; // append tag_id
}

class StorageConstants {
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
} 