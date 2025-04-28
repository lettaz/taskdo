import 'package:dio/dio.dart';
import 'package:taskdo/data/models/user.dart';
import 'package:taskdo/data/providers/api_provider.dart';
import 'package:taskdo/data/providers/secure_storage.dart';
import 'package:uuid/uuid.dart';

class AuthRepository {
  final ApiProvider _apiProvider;
  final SecureStorageProvider _secureStorageProvider;
  
  AuthRepository({
    required ApiProvider apiProvider,
    required SecureStorageProvider secureStorageProvider,
  })  : _apiProvider = apiProvider,
        _secureStorageProvider = secureStorageProvider;
  
  // Login
  Future<User> login(String email, String password, {bool rememberMe = false}) async {
    try {
      final response = await _apiProvider.postFormUrlEncoded('/auth/login', data: {
        'grant_type': '',
        'username': email,
        'password': password,
        'scope': '',
        'client_id': '',
        'client_secret': '',
      });
      
      final data = response.data;
      final token = data['access_token'];
      
      // Save token and user info
      await _secureStorageProvider.saveAuthToken(token);
      await _secureStorageProvider.setRememberMe(rememberMe);
      await _secureStorageProvider.saveUserEmail(email);
      
      // If we have user data in the response, use it
      if (data['user'] != null) {
        final user = User.fromJson(data['user']);
        await _secureStorageProvider.saveUserId(user.id);
        return user;
      }
      
      // Otherwise fetch the user data from /me endpoint
      try {
        final userResponse = await _apiProvider.get('/auth/me');
        final user = User.fromJson(userResponse.data);
        await _secureStorageProvider.saveUserId(user.id);
        return user;
      } catch (e) {
        // If /me also fails, create a basic user object
        final uuid = const Uuid().v4();
        final now = DateTime.now();
        return User(
          id: uuid,
          email: email,
          isVerified: true,
          createdAt: now,
        );
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      print('DioException details:');
      print('Status code: ${e.response?.statusCode}');
      print('Response data: $responseData');
      print('Error message: ${e.message}');
      
      if (e.response?.statusCode == 401) {
        // Check for a specific message about verification
        // The API might return different formats for this error
        if (responseData is Map && responseData['detail'] != null) {
          final errorDetail = responseData['detail'].toString().toLowerCase();
          print('Error detail: $errorDetail');
          if (errorDetail.contains('not verified') || 
              errorDetail.contains('verification') || 
              errorDetail.contains('verify')) {
            throw 'Email not verified';
          }
        }
        throw 'Invalid email or password';
      } else if (e.response?.statusCode == 422) {
        throw 'Login failed: Invalid form data';
      }
      throw 'Login failed: ${e.message}';
    } catch (e) {
      print('Non-Dio exception during login: $e');
      throw 'Login failed: $e';
    }
  }
  
  // Register
  Future<void> register(String email, String password) async {
    try {
      await _apiProvider.post('/auth/register', data: {
        'email': email,
        'password': password,
      });
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw 'Email already registered';
      }
      throw 'Registration failed: ${e.message}';
    } catch (e) {
      throw 'Registration failed: $e';
    }
  }
  
  // Verify Email
  Future<User> verifyEmail(String email, String code) async {
    try {
      print('Verifying email: $email with code: $code');
      final response = await _apiProvider.post('/auth/verify', data: {
        'email': email,
        'verification_code': code,
      });
      
      print('Verification response: ${response.data}');
      final data = response.data;
      
      // Make sure we have a token
      final token = data['access_token'];
      if (token == null || token.isEmpty) {
        throw 'Invalid server response: No access token';
      }
      
      // Save token
      await _secureStorageProvider.saveAuthToken(token);
      await _secureStorageProvider.saveUserEmail(email);
      
      // If the response contains user data, use it
      if (data['user'] != null) {
        final user = User.fromJson(data['user']);
        await _secureStorageProvider.saveUserId(user.id);
        return user;
      }
      
      // Otherwise create a generic user object
      final uuid = const Uuid().v4();
      final now = DateTime.now();
      final user = User(
        id: uuid,
        email: email,
        isVerified: true,
        createdAt: now,
      );
      await _secureStorageProvider.saveUserId(user.id);
      return user;
    } on DioException catch (e) {
      print('DioException in verifyEmail:');
      print('Status code: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      print('Error message: ${e.message}');
      
      if (e.response?.statusCode == 400) {
        throw 'Invalid verification code';
      }
      throw 'Verification failed: ${e.message}';
    } catch (e) {
      print('Non-Dio exception in verifyEmail: $e');
      throw 'Verification failed: $e';
    }
  }
  
  // Request Password Reset
  Future<void> requestPasswordReset(String email) async {
    try {
      await _apiProvider.post('/auth/reset-password-request', data: {
        'email': email,
      });
    } on DioException catch (e) {
      throw 'Password reset request failed: ${e.message}';
    } catch (e) {
      throw 'Password reset request failed: $e';
    }
  }
  
  // Reset Password
  Future<void> resetPassword(String email, String code, String newPassword) async {
    try {
      await _apiProvider.post('/auth/reset-password', data: {
        'email': email,
        'reset_code': code,
        'new_password': newPassword,
      });
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw 'Invalid reset code';
      }
      throw 'Password reset failed: ${e.message}';
    } catch (e) {
      throw 'Password reset failed: $e';
    }
  }
  
  // Get Current User
  Future<User?> getCurrentUser() async {
    final token = await _secureStorageProvider.getAuthToken();
    
    if (token == null || token.isEmpty) {
      return null;
    }
    
    try {
      final response = await _apiProvider.get('/users/me');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      // Token might be invalid, clear it
      await _secureStorageProvider.deleteAuthToken();
      return null;
    } catch (e) {
      // Other errors
      return null;
    }
  }
  
  // Logout
  Future<void> logout() async {
    try {
      // Call logout endpoint to invalidate token on the server
      await _apiProvider.post('/auth/logout');
    } on DioException catch (e) {
      // Log the error but continue with local logout
      print('Error during logout: ${e.message}');
    } catch (e) {
      // Ignore errors
    } finally {
      // Clear local storage regardless of server response
      final rememberMe = await _secureStorageProvider.getRememberMe();
      if (rememberMe) {
        // Just clear the token but keep the email
        await _secureStorageProvider.deleteAuthToken();
      } else {
        // Clear all auth data
        await _secureStorageProvider.clearAuthData();
      }
    }
  }
  
  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _secureStorageProvider.getAuthToken();
    return token != null && token.isNotEmpty;
  }
  
  // Demo login for testing with mock data
  Future<User> mockLogin(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    if (password.length < 6) {
      throw 'Invalid email or password';
    }
    
    final uuid = const Uuid().v4();
    final now = DateTime.now();
    
    final user = User(
      id: uuid,
      email: email,
      isVerified: true,
      createdAt: now,
    );
    
    // Save mock token and user info
    await _secureStorageProvider.saveAuthToken('mock_token_$uuid');
    await _secureStorageProvider.saveUserId(uuid);
    await _secureStorageProvider.saveUserEmail(email);
    
    return user;
  }
} 