import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AccentColor { blue, red, purple, yellow }

const Map<AccentColor, Color> accentColors = {
  AccentColor.blue:   Color(0xFF7EB8D4),
  AccentColor.red:    Color(0xFFD47E7E),
  AccentColor.purple: Color(0xFFAA8ED4),
  AccentColor.yellow: Color(0xFFD4C47E),
};

const Map<AccentColor, String> accentNames = {
  AccentColor.blue:   'Azul',
  AccentColor.red:    'Vermelho',
  AccentColor.purple: 'Roxo',
  AccentColor.yellow: 'Amarelo',
};

class KioColors {
  static const background    = Color(0xFFF5F0E8);
  static const surface       = Color(0xFFEDE8DC);
  static const cardBg        = Color(0xFFFFFFFF);
  static const textPrimary   = Color(0xFF3A3530);
  static const textSecondary = Color(0xFF8A8075);
  static const textHint      = Color(0xFFB8B0A5);
  static const divider       = Color(0xFFDDD8CC);
  static const shadow        = Color(0x18000000);
}

ThemeData buildTheme(Color accent) {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: KioColors.background,
    colorScheme: ColorScheme.light(
      primary:   accent,
      secondary: accent.withOpacity(0.7),
      surface:   KioColors.surface,
      onPrimary: Colors.white,
      onSurface: KioColors.textPrimary,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: KioColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: KioColors.textPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: KioColors.cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: KioColors.divider, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

Future<AccentColor> loadAccentColor() async {
  final prefs = await SharedPreferences.getInstance();
  final index = prefs.getInt('accent_color') ?? 0;
  return AccentColor.values[index];
}

Future<void> saveAccentColor(AccentColor color) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('accent_color', color.index);
}