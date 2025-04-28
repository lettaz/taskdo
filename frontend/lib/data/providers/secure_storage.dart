import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:taskdo/config/constants.dart';

class SecureStorageProvider {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  
  // Token management
  
  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: AppConstants.authTokenKey, value: token);
  }
  
  Future<String?> getAuthToken() async {
    return await _storage.read(key: AppConstants.authTokenKey);
  }
  
  Future<void> deleteAuthToken() async {
    await _storage.delete(key: AppConstants.authTokenKey);
  }
  
  // User data management
  
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: AppConstants.userIdKey, value: userId);
  }
  
  Future<String?> getUserId() async {
    return await _storage.read(key: AppConstants.userIdKey);
  }
  
  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: AppConstants.userEmailKey, value: email);
  }
  
  Future<String?> getUserEmail() async {
    return await _storage.read(key: AppConstants.userEmailKey);
  }
  
  Future<void> setRememberMe(bool rememberMe) async {
    await _storage.write(key: AppConstants.rememberMeKey, value: rememberMe.toString());
  }
  
  Future<bool> getRememberMe() async {
    final value = await _storage.read(key: AppConstants.rememberMeKey);
    return value == 'true';
  }
  
  // Clear all auth data
  Future<void> clearAuthData() async {
    await deleteAuthToken();
    await _storage.delete(key: AppConstants.userIdKey);
    await _storage.delete(key: AppConstants.userEmailKey);
    // Don't clear rememberMe preference
  }
  
  // Clear all stored data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
  
  // General settings methods
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }
  
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }
} 