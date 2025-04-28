import 'package:flutter/material.dart';

class AppTheme {
  // Primary Color: Coral/Orange
  static const Color primaryColor = Color(0xFFFF5A5A);
  
  // Secondary Color: White
  static const Color secondaryColor = Color(0xFFFFFFFF);
  
  // Background Color: Light Gray
  static const Color backgroundColor = Color(0xFFF5F5F5);
  
  // Text Color: Dark Gray
  static const Color textColor = Color(0xFF333333);
  
  // Accent Colors
  static const Color highPriorityColor = Color(0xFFFF3B30); // Red
  static const Color mediumPriorityColor = Color(0xFFFF9500); // Orange
  static const Color lowPriorityColor = Color(0xFF34C759); // Green
  
  // Additional Colors
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color disabledColor = Color(0xFFCCCCCC);
  static const Color errorColor = Color(0xFFFF3B30);
  static const Color successColor = Color(0xFF34C759);
  static const Color warningColor = Color(0xFFFF9500);

  // Text Styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textColor,
    fontFamily: 'BasicSans, Helvetica',
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textColor,
    fontFamily: 'BasicSans, Helvetica',
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textColor,
    fontFamily: 'BasicSans, Helvetica',
  );
  
  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textColor,
    fontFamily: 'BasicSans, Helvetica',
  );
  
  static const TextStyle smallText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textColor,
    fontFamily: 'BasicSans, Helvetica',
  );

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    dividerColor: dividerColor,
    disabledColor: disabledColor,
    fontFamily: 'BasicSans',
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      background: backgroundColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: secondaryColor,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      displayLarge: heading1,
      displayMedium: heading2,
      displaySmall: heading3,
      bodyLarge: bodyText,
      bodyMedium: smallText,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: secondaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    ),
    cardTheme: CardTheme(
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 1,
    ),
  );
} 