import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme Provider - Manages light/dark mode for entire app
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  // Load theme preference from storage
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
    notifyListeners();
  }

  // Set specific theme
  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', mode == ThemeMode.dark);
    notifyListeners();
  }
}

/// App Themes - Light and Dark theme definitions
class AppThemes {
  // ============ LIGHT THEME ============
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Colors
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF00D4AA), // Nemu.in cyan
      secondary: Color(0xFF7C4DFF), // Purple accent
      surface: Color(0xFFFFFFFF),
      background: Color(0xFFF8F9FA),
      error: Color(0xFFFF6B6B),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF1A1A1A),
      onBackground: Color(0xFF1A1A1A),
    ),

    // Scaffold
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF00D4AA),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),

    // Card
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Icon
    iconTheme: const IconThemeData(
      color: Color(0xFF6B7280),
    ),

    // Text
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Color(0xFF1A1A1A)),
      displayMedium: TextStyle(color: Color(0xFF1A1A1A)),
      displaySmall: TextStyle(color: Color(0xFF1A1A1A)),
      headlineLarge: TextStyle(color: Color(0xFF1A1A1A)),
      headlineMedium: TextStyle(color: Color(0xFF1A1A1A)),
      headlineSmall: TextStyle(color: Color(0xFF1A1A1A)),
      titleLarge: TextStyle(color: Color(0xFF1A1A1A)),
      titleMedium: TextStyle(color: Color(0xFF1A1A1A)),
      titleSmall: TextStyle(color: Color(0xFF6B7280)),
      bodyLarge: TextStyle(color: Color(0xFF1A1A1A)),
      bodyMedium: TextStyle(color: Color(0xFF6B7280)),
      bodySmall: TextStyle(color: Color(0xFF9CA3AF)),
    ),
  );

  // ============ DARK THEME ============
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Colors
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00D4AA), // Nemu.in cyan
      secondary: Color(0xFF7C4DFF), // Purple accent
      surface: Color(0xFF1E1E1E), // Dark surface
      background: Color(0xFF121212), // Dark background
      error: Color(0xFFFF6B6B),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFFE5E7EB),
      onBackground: Color(0xFFE5E7EB),
    ),

    // Scaffold
    scaffoldBackgroundColor: const Color(0xFF121212),

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Color(0xFFE5E7EB),
      elevation: 0,
      centerTitle: false,
    ),

    // Card
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Icon
    iconTheme: const IconThemeData(
      color: Color(0xFF9CA3AF),
    ),

    // Text
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Color(0xFFE5E7EB)),
      displayMedium: TextStyle(color: Color(0xFFE5E7EB)),
      displaySmall: TextStyle(color: Color(0xFFE5E7EB)),
      headlineLarge: TextStyle(color: Color(0xFFE5E7EB)),
      headlineMedium: TextStyle(color: Color(0xFFE5E7EB)),
      headlineSmall: TextStyle(color: Color(0xFFE5E7EB)),
      titleLarge: TextStyle(color: Color(0xFFE5E7EB)),
      titleMedium: TextStyle(color: Color(0xFFE5E7EB)),
      titleSmall: TextStyle(color: Color(0xFF9CA3AF)),
      bodyLarge: TextStyle(color: Color(0xFFE5E7EB)),
      bodyMedium: TextStyle(color: Color(0xFF9CA3AF)),
      bodySmall: TextStyle(color: Color(0xFF6B7280)),
    ),
  );

  // ============ COLOR HELPERS ============

  /// Get color based on theme mode
  static Color getBackgroundColor(bool isDark) {
    return isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
  }

  static Color getCardColor(bool isDark) {
    return isDark ? const Color(0xFF1E1E1E) : Colors.white;
  }

  static Color getTextPrimary(bool isDark) {
    return isDark ? const Color(0xFFE5E7EB) : const Color(0xFF1A1A1A);
  }

  static Color getTextSecondary(bool isDark) {
    return isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
  }

  static Color getBorderColor(bool isDark) {
    return isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
  }

  static Color getDividerColor(bool isDark) {
    return isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
  }

  static Color getShadowColor(bool isDark) {
    return isDark
        ? Colors.black.withOpacity(0.3)
        : Colors.black.withOpacity(0.08);
  }

  // Primary cyan stays same in both themes
  static const Color primaryCyan = Color(0xFF00D4AA);
  static const Color primaryDark = Color(0xFF00B894);
  static const Color accentPurple = Color(0xFF7C4DFF);
  static const Color accentRed = Color(0xFFFF6B6B);
  static const Color successGreen = Color(0xFF00C853);
  static const Color warningOrange = Color(0xFFFF8F00);
}
