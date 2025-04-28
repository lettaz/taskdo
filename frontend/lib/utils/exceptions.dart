class AppException implements Exception {
  final String message;
  
  AppException(this.message);
  
  @override
  String toString() => message;
}

class AuthenticationException extends AppException {
  AuthenticationException(String message) : super(message);
}

class ApiException extends AppException {
  ApiException(String message) : super(message);
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message);
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message);
} 