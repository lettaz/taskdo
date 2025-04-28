import 'package:taskdo/config/constants.dart';

class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    
    return null;
  }
  
  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    
    return null;
  }
  
  // Password confirmation validation
  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    return null;
  }
  
  // Pomodoro count validation
  static String? validatePomodoroCount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Estimated Pomodoros is required';
    }
    
    int? count = int.tryParse(value);
    if (count == null || count <= 0) {
      return 'Please enter a valid number of Pomodoros';
    }
    
    return null;
  }
  
  // Due date validation based on estimated Pomodoros
  static String? validateDueDate(DateTime? dueDate, int estimatedPomodoros) {
    if (dueDate == null) {
      return 'Due date is required';
    }
    
    final now = DateTime.now();
    
    // Calculate minimum time needed for task completion
    final pomodoroDuration = AppConstants.defaultPomodoroDuration;
    final breakDuration = AppConstants.defaultShortBreakDuration;
    final totalMinutes = (pomodoroDuration * estimatedPomodoros) + 
                         (breakDuration * (estimatedPomodoros - 1));
    
    final minimumDueDate = now.add(Duration(minutes: totalMinutes));
    
    if (dueDate.isBefore(minimumDueDate)) {
      return 'Due date too soon for estimated Pomodoros';
    }
    
    return null;
  }
} 