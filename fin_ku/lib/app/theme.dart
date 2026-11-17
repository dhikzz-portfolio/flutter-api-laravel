import 'package:flutter/material.dart';

/// Palet Fin-Ku, mengikuti Tailwind yang dipakai aplikasi web Laravel:
/// indigo-600 sebagai brand, gray-900/800 untuk sidebar, gray-50 untuk latar,
/// dan gray-200 untuk border kartu.
class FinKuColors {
  FinKuColors._();

  static const primary = Color(0xFF4F46E5); // indigo-600 (brand)
  static const primaryDark = Color(0xFF4338CA); // indigo-700
  static const primarySoft = Color(0xFFEEF2FF); // indigo-50

  static const dark = Color(0xFF111827); // gray-900 sidebar
  static const darkSoft = Color(0xFF1F2937); // gray-800 item aktif

  static const bg = Color(0xFFF9FAFB); // gray-50 body
  static const surface = Color(0xFFFFFFFF);
  static const cardBorder = Color(0xFFE5E7EB);
  static const borderSoft = Color(0xFFF3F4F6);

  static const textPrimary = Color(0xFF111827); // gray-900
  static const textBody = Color(0xFF1F2937); // gray-800
  static const textSecondary = Color(0xFF6B7280); // gray-500
  static const textMuted = Color(0xFF9CA3AF); // gray-400

  static const success = Color(0xFF15803D); // green-700
  static const successSoft = Color(0xFFF0FDF4); // green-50
  static const info = Color(0xFF2563EB); // blue-600
  static const infoSoft = Color(0xFFEFF6FF); // blue-50
  static const warning = Color(0xFFB45309); // amber-700
  static const warningSoft = Color(0xFFFFF7ED); // orange-50
  static const danger = Color(0xFFDC2626); // red-600
  static const dangerSoft = Color(0xFFFEF2F2); // red-50

  /// Bayangan kartu ganda: tipis dan lebar, seperti `shadow-sm` Tailwind.
  static const cardShadow = [
    BoxShadow(color: Color(0x0A111827), blurRadius: 10, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x05000000), blurRadius: 2, offset: Offset(0, 1)),
  ];
}

/// Tema aplikasi mengikuti identitas web Fin-Ku: indigo-600, permukaan putih
/// di atas latar gray-50, teks gray-900/gray-500, dan border gray-200.
class FinKuTheme {
  FinKuTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: FinKuColors.primary,
      ).copyWith(
        primary: FinKuColors.primary,
        onPrimary: Colors.white,
        secondary: FinKuColors.primary,
        surface: FinKuColors.surface,
        error: FinKuColors.danger,
        outline: FinKuColors.cardBorder,
        outlineVariant: FinKuColors.borderSoft,
      ),
      scaffoldBackgroundColor: FinKuColors.bg,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: FinKuColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        toolbarHeight: 62,
        titleSpacing: 20,
        shape: Border(bottom: BorderSide(color: FinKuColors.cardBorder)),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: FinKuColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: FinKuColors.textSecondary, size: 22),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: FinKuColors.cardBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        contentPadding: const EdgeInsets.fromLTRB(14, 19, 14, 11),
        border: UnderlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: const BorderSide(color: FinKuColors.primary, width: 1.4),
          borderRadius: BorderRadius.circular(10),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFFCA5A5), width: 1.2),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: const BorderSide(color: FinKuColors.danger, width: 1.4),
          borderRadius: BorderRadius.circular(10),
        ),
        hintStyle: const TextStyle(color: FinKuColors.textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: FinKuColors.textSecondary, fontSize: 14),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        errorStyle: const TextStyle(color: FinKuColors.danger, fontSize: 12),
        prefixIconColor: FinKuColors.textMuted,
        suffixIconColor: FinKuColors.textMuted,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: FinKuColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFC7D2FE),
          disabledForegroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: FinKuColors.textBody,
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFD1D5DB)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: FinKuColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: FinKuColors.textSecondary,
          highlightColor: FinKuColors.primarySoft,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: FinKuColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        extendedTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13.5,
          letterSpacing: 0,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: FinKuColors.bg,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: FinKuColors.textBody,
        ),
        side: const BorderSide(color: FinKuColors.cardBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: FinKuColors.dark,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13.5),
        actionTextColor: const Color(0xFFC7D2FE),
        elevation: 2,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        titleTextStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: FinKuColors.textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          height: 1.5,
          color: FinKuColors.textSecondary,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 13.5, color: FinKuColors.textBody),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: FinKuColors.textSecondary,
        textColor: FinKuColors.textBody,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      ),
      dividerTheme: const DividerThemeData(
        color: FinKuColors.cardBorder,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: FinKuColors.primary,
        linearTrackColor: FinKuColors.primarySoft,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: FinKuColors.dark,
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 11.5),
        waitDuration: const Duration(milliseconds: 400),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStateProperty.all(6),
        radius: const Radius.circular(999),
        thumbColor: WidgetStateProperty.all(const Color(0xFFD1D5DB)),
        crossAxisMargin: 2,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: FinKuColors.primary,
        headerForegroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
          color: FinKuColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: FinKuColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: FinKuColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 15.5,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: FinKuColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: FinKuColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 14.5,
          height: 1.45,
          color: FinKuColors.textBody,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.45,
          color: FinKuColors.textBody,
        ),
        bodySmall: TextStyle(
          fontSize: 12.5,
          height: 1.4,
          color: FinKuColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: FinKuColors.textBody,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: FinKuColors.textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: FinKuColors.textSecondary,
        ),
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: FinKuColors.dark),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: FinKuColors.primarySoft,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
        ),
      ),
    );
    return base;
  }

  static ThemeData get dark => light;
}
