import 'package:flutter/material.dart';

class AppTheme {
  // --- Core palette ---
  static const Color primaryYellow = Color(0xFFFFD600);
  static const Color redAccent = Color(0xFFE53935);
  static const Color background = Color(0xFFF9FAFB);
  static const Color card = Colors.white;

  // --- Text colors ---
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  // --- Icon colors ---
  static const Color iconGray = Color(0xFF9E9E9E);

  // --- Additional colors ---
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);

  // --- Full light theme builder ---
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryYellow,
        secondary: redAccent,
        background: background,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: textDark),
      ),
      iconTheme: const IconThemeData(color: iconGray),
      cardColor: card,
    );
  }

  /// --- Helpers for charts and gradients ---
  static List<Color> get redGradient => [redAccent, redAccent.withOpacity(0.6)];
  static List<Color> get yellowGradient => [primaryYellow, primaryYellow.withOpacity(0.6)];
  static List<Color> get greenGradient => [success, success.withOpacity(0.6)];
  static List<Color> get orangeGradient => [Colors.orange, Colors.orange.withOpacity(0.6)];
}
