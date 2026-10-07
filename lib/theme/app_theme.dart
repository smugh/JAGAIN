import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract final class JagainColors {
  // Brand accents
  static const primary = Color(0xFF14B8A6);
  static const primaryLight = Color(0xFF2DD4BF);
  static const primaryDark = Color(0xFF0F766E);
  static const secondary = Color(0xFF3B82F6);
  static const secondaryLight = Color(0xFF60A5FA);

  // Dark Palette (dominant)
  static const darkBackground = Color(0xFF0B0F19);
  static const darkSurface = Color(0xFF131C2E);
  static const darkSurfaceElevated = Color(0xFF1B263B);
  static const darkBorder = Color(0xFF1F2E45);
  static const darkText = Color(0xFFF8FAFC);
  static const darkMuted = Color(0xFF94A3B8);
  static const darkAccentBg = Color(0xFF0D2B28);
  static const darkBlueBg = Color(0xFF0F2238);

  // Light Palette
  static const ink = Color(0xFF111827);
  static const muted = Color(0xFF667085);
  static const canvas = Color(0xFFF7FAF9);
  static const mint = Color(0xFFECFDF5);
  static const lightBlue = Color(0xFFE0F2FE);
  static const border = Color(0xFFE7EEEC);
}

abstract final class AppTheme {
  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: JagainColors.primary,
      brightness: Brightness.dark,
      primary: JagainColors.primaryLight,
      onPrimary: JagainColors.darkBackground,
      secondary: JagainColors.secondaryLight,
      surface: JagainColors.darkSurface,
      onSurface: JagainColors.darkText,
      outline: JagainColors.darkBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: JagainColors.darkBackground,
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
          color: JagainColors.darkText,
          letterSpacing: -0.6,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          color: JagainColors.darkText,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
          color: JagainColors.darkText,
        ),
        bodyLarge: TextStyle(color: JagainColors.darkText, height: 1.45),
        bodyMedium: TextStyle(color: JagainColors.darkMuted, height: 1.4),
        bodySmall: TextStyle(color: JagainColors.darkMuted),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: JagainColors.darkBackground,
        foregroundColor: JagainColors.darkText,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: JagainColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: JagainColors.darkBorder),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: JagainColors.darkSurface,
        indicatorColor: JagainColors.darkAccentBg,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? JagainColors.primaryLight : JagainColors.darkMuted,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? JagainColors.primaryLight : JagainColors.darkMuted,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: JagainColors.darkBorder,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: JagainColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: JagainColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: JagainColors.darkBorder),
        ),
      ),
    );
  }

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: JagainColors.primary,
      primary: JagainColors.primaryDark,
      secondary: JagainColors.secondary,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: JagainColors.canvas,
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
          color: JagainColors.ink,
          letterSpacing: -0.6,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          color: JagainColors.ink,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
          color: JagainColors.ink,
        ),
        bodyLarge: TextStyle(color: JagainColors.ink, height: 1.45),
        bodyMedium: TextStyle(color: JagainColors.muted, height: 1.4),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: JagainColors.canvas,
        foregroundColor: JagainColors.ink,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: JagainColors.border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: JagainColors.mint,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? JagainColors.primaryDark : JagainColors.muted,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: JagainColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: JagainColors.border),
        ),
      ),
    );
  }
}

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
