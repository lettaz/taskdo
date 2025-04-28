// Application-wide constants

class AppConstants {
  // API
  static const String apiBaseUrl = 'http://localhost:8000/api';
  static const String apiKey = 'DEB75753613316B1989F44065319D5F'; // Replace with your actual API key
  
  // Pomodoro settings
  static const int defaultPomodoroDuration = 25; // in minutes
  static const int defaultShortBreakDuration = 5; // in minutes
  static const int defaultLongBreakDuration = 15; // in minutes
  static const int longBreakInterval = 4; // after how many pomodoros
  
  // Storage keys
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String rememberMeKey = 'remember_me';
  static const String pomodoroSettingsKey = 'pomodoro_settings';
  
  // Validation
  static const int minPasswordLength = 8;
  
  // Animation durations
  static const int pageTransitionDuration = 300; // in milliseconds
} 