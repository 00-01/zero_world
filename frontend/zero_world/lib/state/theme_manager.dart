import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme manager for easy UI customization
/// Users can change colors, fonts, layouts with simple options
class AppThemeManager extends ChangeNotifier {
  static const String _themeKey = 'app_theme';
  static const String _colorKey = 'accent_color';
  static const String _layoutKey = 'layout_density';
  static const String _fontSizeKey = 'font_size_scale';

  // Theme modes
  ThemeMode _themeMode = ThemeMode.system;

  // Customization options
  Color _accentColor = Colors.blue;
  LayoutDensity _layoutDensity = LayoutDensity.comfortable;
  double _fontSizeScale = 1.0;

  // Getters
  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;
  LayoutDensity get layoutDensity => _layoutDensity;
  double get fontSizeScale => _fontSizeScale;

  // Predefined color schemes
  static const List<AppColorScheme> colorSchemes = [
    AppColorScheme('Blue', Colors.blue),
    AppColorScheme('Green', Colors.green),
    AppColorScheme('Purple', Colors.purple),
    AppColorScheme('Orange', Colors.orange),
    AppColorScheme('Pink', Colors.pink),
    AppColorScheme('Teal', Colors.teal),
    AppColorScheme('Red', Colors.red),
    AppColorScheme('Indigo', Colors.indigo),
  ];

  AppThemeManager() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme mode
    final themeName = prefs.getString(_themeKey) ?? 'system';
    _themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == themeName,
      orElse: () => ThemeMode.system,
    );

    // Load accent color
    final colorValue = prefs.getInt(_colorKey);
    if (colorValue != null) {
      _accentColor = Color(colorValue);
    }

    // Load layout density
    final densityName = prefs.getString(_layoutKey) ?? 'comfortable';
    _layoutDensity = LayoutDensity.values.firstWhere(
      (density) => density.name == densityName,
      orElse: () => LayoutDensity.comfortable,
    );

    // Load font size scale
    _fontSizeScale = prefs.getDouble(_fontSizeKey) ?? 1.0;

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
    notifyListeners();
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorKey, color.value);
    notifyListeners();
  }

  Future<void> setLayoutDensity(LayoutDensity density) async {
    _layoutDensity = density;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_layoutKey, density.name);
    notifyListeners();
  }

  Future<void> setFontSizeScale(double scale) async {
    _fontSizeScale = scale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, scale);
    notifyListeners();
  }

  // Build light theme
  ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: _accentColor,

      // Typography scaled by user preference
      textTheme: _getScaledTextTheme(Brightness.light),

      // Visual density based on layout preference
      visualDensity: _layoutDensity.visualDensity,

      // Simple, clean app bar
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),

      // Card style
      cardTheme: CardThemeData(
        elevation: _layoutDensity == LayoutDensity.compact ? 1 : 2,
        margin: EdgeInsets.symmetric(
          horizontal: _layoutDensity == LayoutDensity.compact ? 8 : 16,
          vertical: _layoutDensity == LayoutDensity.compact ? 4 : 8,
        ),
      ),

      // Floating action button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: _layoutDensity == LayoutDensity.compact ? 4 : 6,
      ),

      // Bottom navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 8,
        selectedItemColor: _accentColor,
        showUnselectedLabels: _layoutDensity != LayoutDensity.compact,
      ),
    );
  }

  // Build dark theme
  ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: _accentColor,
      textTheme: _getScaledTextTheme(Brightness.dark),
      visualDensity: _layoutDensity.visualDensity,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: _layoutDensity == LayoutDensity.compact ? 1 : 2,
        margin: EdgeInsets.symmetric(
          horizontal: _layoutDensity == LayoutDensity.compact ? 8 : 16,
          vertical: _layoutDensity == LayoutDensity.compact ? 4 : 8,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: _layoutDensity == LayoutDensity.compact ? 4 : 6,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 8,
        selectedItemColor: _accentColor,
        showUnselectedLabels: _layoutDensity != LayoutDensity.compact,
      ),
    );
  }

  TextTheme _getScaledTextTheme(Brightness brightness) {
    final baseTheme = brightness == Brightness.light ? ThemeData.light().textTheme : ThemeData.dark().textTheme;

    return TextTheme(
      displayLarge: baseTheme.displayLarge?.copyWith(fontSize: 57 * _fontSizeScale),
      displayMedium: baseTheme.displayMedium?.copyWith(fontSize: 45 * _fontSizeScale),
      displaySmall: baseTheme.displaySmall?.copyWith(fontSize: 36 * _fontSizeScale),
      headlineLarge: baseTheme.headlineLarge?.copyWith(fontSize: 32 * _fontSizeScale),
      headlineMedium: baseTheme.headlineMedium?.copyWith(fontSize: 28 * _fontSizeScale),
      headlineSmall: baseTheme.headlineSmall?.copyWith(fontSize: 24 * _fontSizeScale),
      titleLarge: baseTheme.titleLarge?.copyWith(fontSize: 22 * _fontSizeScale),
      titleMedium: baseTheme.titleMedium?.copyWith(fontSize: 16 * _fontSizeScale),
      titleSmall: baseTheme.titleSmall?.copyWith(fontSize: 14 * _fontSizeScale),
      bodyLarge: baseTheme.bodyLarge?.copyWith(fontSize: 16 * _fontSizeScale),
      bodyMedium: baseTheme.bodyMedium?.copyWith(fontSize: 14 * _fontSizeScale),
      bodySmall: baseTheme.bodySmall?.copyWith(fontSize: 12 * _fontSizeScale),
      labelLarge: baseTheme.labelLarge?.copyWith(fontSize: 14 * _fontSizeScale),
      labelMedium: baseTheme.labelMedium?.copyWith(fontSize: 12 * _fontSizeScale),
      labelSmall: baseTheme.labelSmall?.copyWith(fontSize: 11 * _fontSizeScale),
    );
  }
}

/// Layout density options
enum LayoutDensity {
  compact('Compact', VisualDensity.compact),
  comfortable('Comfortable', VisualDensity.standard),
  spacious('Spacious', VisualDensity.comfortable);

  final String displayName;
  final VisualDensity visualDensity;

  const LayoutDensity(this.displayName, this.visualDensity);
}

/// Color scheme option
class AppColorScheme {
  final String name;
  final Color color;

  const AppColorScheme(this.name, this.color);
}
