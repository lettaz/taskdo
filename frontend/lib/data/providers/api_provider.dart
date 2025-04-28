import 'package:dio/dio.dart';
import 'package:taskdo/config/constants.dart';
import 'package:taskdo/data/providers/secure_storage.dart';

class ApiProvider {
  final Dio _dio = Dio();
  final SecureStorageProvider _secureStorage;
  
  ApiProvider({required SecureStorageProvider secureStorage}) : _secureStorage = secureStorage {
    _dio.options.baseUrl = AppConstants.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    
    // For debugging
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
    
    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }
  
  Future<void> _onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Add authorization token if available
    final token = await _secureStorage.getAuthToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    // Add API key to all requests
    options.headers['X-API-Key'] = AppConstants.apiKey;
    
    // Set default headers if not already set
    if (!options.headers.containsKey('Content-Type')) {
      options.headers['Content-Type'] = 'application/json';
    }
    if (!options.headers.containsKey('Accept')) {
      options.headers['Accept'] = 'application/json';
    }
    
    return handler.next(options);
  }
  
  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    // Process response if needed
    return handler.next(response);
  }
  
  Future<void> _onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle token expiration, but only for specific endpoints
    if (err.response?.statusCode == 401) {
      final path = err.requestOptions.path;
      
      // Only clear auth data for critical auth endpoints like login, logout, or token refresh
      // For other 401 errors, let the calling code handle it
      if (path.contains('/auth/login') || path.contains('/auth/logout') || path.contains('/auth/refresh')) {
        // Clear token and user data
        await _secureStorage.clearAuthData();
      }
    }
    
    return handler.next(err);
  }
  
  // GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }
  
  // POST request
  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }
  
  // POST request with form URL encoded data
  Future<Response> postFormUrlEncoded(String path, {required Map<String, dynamic> data}) {
    final options = Options(
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      contentType: 'application/x-www-form-urlencoded',
    );
    
    // Convert map to form data
    final formData = data.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
    
    return _dio.post(
      path, 
      data: formData,
      options: options,
    );
  }
  
  // PUT request
  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }
  
  // PATCH request
  Future<Response> patch(String path, {dynamic data}) {
    return _dio.patch(path, data: data);
  }
  
  // DELETE request
  Future<Response> delete(String path, {dynamic data}) {
    return _dio.delete(path, data: data);
  }
} 