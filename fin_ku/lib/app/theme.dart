import 'package:flutter/material.dart';

class FinKuColors {
  FinKuColors._();

  static const primary = Color(0xFF4F46E5); // indigo-600 (brand)

  static const primaryDark = Color(0xFF4338CA); // indigo-700

  static const dark = Color(0xFF111827); // gray-900 sidebar

  static const bg = Color(0xFFF9FAFB); // gray-50 body

  static const cardBorder = Color(0xFFE5E7EB);

  static const textPrimary = Color(0xFF1F2937);

  static const textSecondary = Color(0xFF6B7280);

  static const success = Color(0xFF15803D);

  static const danger = Color(0xFFDC2626);

  static const warning = Color(0xFFB45309);
}

/// Tema aplikasi mengikuti identitas web Fin-Ku: indigo-600, permukaan putih
/// di atas latar gray-50, teks gray-800/gray-500, aksen merah untuk error.
class FinKuTheme {
  FinKuTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: FinKuColors.primary,
      ).copyWith(
        primary: FinKuColors.primary,
        secondary: FinKuColors.primary,
        surface: Colors.white,
        error: FinKuColors.danger,
      ),
      scaffoldBackgroundColor: FinKuColors.bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: FinKuColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: FinKuColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: FinKuColors.textSecondary),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: FinKuColors.cardBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: FinKuColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: FinKuColors.cardBorder),
        ),
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        labelStyle: const TextStyle(color: FinKuColors.textSecondary, fontSize: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: FinKuColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: FinKuColors.textPrimary,
          side: const BorderSide(color: FinKuColors.cardBorder),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: FinKuColors.bg,
        labelStyle: const TextStyle(fontSize: 12),
        side: BorderSide(color: FinKuColors.cardBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: FinKuColors.textPrimary),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: FinKuColors.textPrimary),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: FinKuColors.textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: FinKuColors.textPrimary),
        bodySmall: TextStyle(fontSize: 12.5, color: FinKuColors.textSecondary),
        labelSmall: TextStyle(fontSize: 11, color: FinKuColors.textSecondary),
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: FinKuColors.dark),
      dividerTheme: const DividerThemeData(color: FinKuColors.cardBorder, thickness: 1),
    );
    return base;
  }

  static ThemeData get dark => light;
}
