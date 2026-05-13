/// app_theme.dart
/// ─────────────────────────────────────────────────────────────────────────────
/// ThemeData Material 3 lengkap untuk aplikasi Pace.
///
/// ATURAN:
///   • useMaterial3: true  → WAJIB
///   • TIDAK ADA hardcode warna di dalam widget — semua via ColorScheme /
///     Theme.of(context).colorScheme  atau  Theme.of(context).textTheme
///   • Font: Plus Jakarta Sans (Google Fonts)
///   • Spacing/radius: selalu dari AppSpacing & AppRadius
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

// ── Barrel export untuk kemudahan import ─────────────────────────────────────
export 'app_colors.dart';
export 'app_spacing.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppTheme
// ─────────────────────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  // ══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ══════════════════════════════════════════════════════════════════════════
  static ThemeData get lightTheme {
    final cs = AppColors.lightScheme;
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: cs,
    );

    return base.copyWith(
      // ── Scaffold ──────────────────────────────────────────────────────────
      scaffoldBackgroundColor: cs.surface,

      // ── SystemUI (status bar) ─────────────────────────────────────────────
      appBarTheme: _buildAppBarTheme(cs, Brightness.light),

      // ── Typography ────────────────────────────────────────────────────────
      textTheme: _buildTextTheme(cs),

      // ── Komponen wajib ────────────────────────────────────────────────────
      cardTheme:                   _buildCardTheme(cs),
      inputDecorationTheme:        _buildInputDecorationTheme(cs),
      floatingActionButtonTheme:   _buildFabTheme(cs),
      bottomNavigationBarTheme:    _buildBottomNavTheme(cs),
      snackBarTheme:               _buildSnackBarTheme(cs),
      dialogTheme:                 _buildDialogTheme(cs),
      chipTheme:                   _buildChipTheme(cs),

      // ── Button themes ─────────────────────────────────────────────────────
      elevatedButtonTheme:  _buildElevatedButtonTheme(cs),
      outlinedButtonTheme:  _buildOutlinedButtonTheme(cs),
      textButtonTheme:      _buildTextButtonTheme(cs),

      // ── Misc ──────────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return cs.primary;
          return cs.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return cs.primaryContainer;
          return cs.surfaceContainerHighest;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: cs.primary,
        linearTrackColor: cs.primaryContainer,
        circularTrackColor: cs.primaryContainer,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DARK THEME
  // ══════════════════════════════════════════════════════════════════════════
  static ThemeData get darkTheme {
    final cs = AppColors.darkScheme;
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: cs,
    );

    return base.copyWith(
      // ── Scaffold ──────────────────────────────────────────────────────────
      scaffoldBackgroundColor: cs.surface,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: _buildAppBarTheme(cs, Brightness.dark),

      // ── Typography ────────────────────────────────────────────────────────
      textTheme: _buildTextTheme(cs),

      // ── Komponen wajib ────────────────────────────────────────────────────
      cardTheme:                   _buildCardTheme(cs),
      inputDecorationTheme:        _buildInputDecorationTheme(cs),
      floatingActionButtonTheme:   _buildFabTheme(cs),
      bottomNavigationBarTheme:    _buildBottomNavTheme(cs),
      snackBarTheme:               _buildSnackBarTheme(cs),
      dialogTheme:                 _buildDialogTheme(cs),
      chipTheme:                   _buildChipTheme(cs),

      // ── Button themes ─────────────────────────────────────────────────────
      elevatedButtonTheme:  _buildElevatedButtonTheme(cs),
      outlinedButtonTheme:  _buildOutlinedButtonTheme(cs),
      textButtonTheme:      _buildTextButtonTheme(cs),

      // ── Misc ──────────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return cs.primary;
          return cs.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return cs.primaryContainer;
          return cs.surfaceContainerHighest;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: cs.primary,
        linearTrackColor: cs.primaryContainer,
        circularTrackColor: cs.primaryContainer,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PRIVATE BUILDERS — setiap builder menerima ColorScheme sehingga
  // tidak ada hardcode warna di luar file ini.
  // ══════════════════════════════════════════════════════════════════════════

  // ── AppBarTheme ───────────────────────────────────────────────────────────
  static AppBarTheme _buildAppBarTheme(ColorScheme cs, Brightness brightness) {
    return AppBarTheme(
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 2,
      shadowColor: cs.shadow,
      centerTitle: false,
      systemOverlayStyle: brightness == Brightness.light
          ? SystemUiOverlayStyle(
              statusBarBrightness: Brightness.light,
              statusBarIconBrightness: Brightness.dark,
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: cs.surface,
            )
          : SystemUiOverlayStyle(
              statusBarBrightness: Brightness.dark,
              statusBarIconBrightness: Brightness.light,
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: cs.surface,
            ),
      iconTheme: IconThemeData(color: cs.onSurface, size: 24),
      actionsIconTheme: IconThemeData(color: cs.onSurfaceVariant, size: 24),
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: cs.onSurface,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    );
  }

  // ── TextTheme ─────────────────────────────────────────────────────────────
  /// Plus Jakarta Sans — clean, readable, cocok untuk productivity app.
  static TextTheme _buildTextTheme(ColorScheme cs) {
    // Basis lengkap dari GoogleFonts, lalu override warna dari ColorScheme.
    final base = GoogleFonts.plusJakartaSansTextTheme();
    return base.copyWith(
      // Display
      displayLarge:  GoogleFonts.plusJakartaSans(
        fontSize: 57, fontWeight: FontWeight.w800,
        letterSpacing: -2, color: cs.onSurface,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 45, fontWeight: FontWeight.w700,
        letterSpacing: -1.5, color: cs.onSurface,
      ),
      displaySmall:  GoogleFonts.plusJakartaSans(
        fontSize: 36, fontWeight: FontWeight.w600,
        letterSpacing: -1, color: cs.onSurface,
      ),
      // Headline
      headlineLarge:  GoogleFonts.plusJakartaSans(
        fontSize: 32, fontWeight: FontWeight.w700,
        letterSpacing: -0.5, color: cs.onSurface,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 28, fontWeight: FontWeight.w700,
        letterSpacing: -0.3, color: cs.onSurface,
      ),
      headlineSmall:  GoogleFonts.plusJakartaSans(
        fontSize: 24, fontWeight: FontWeight.w600,
        color: cs.onSurface,
      ),
      // Title
      titleLarge:  GoogleFonts.plusJakartaSans(
        fontSize: 20, fontWeight: FontWeight.w700,
        color: cs.onSurface,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16, fontWeight: FontWeight.w600,
        letterSpacing: 0.1, color: cs.onSurface,
      ),
      titleSmall:  GoogleFonts.plusJakartaSans(
        fontSize: 14, fontWeight: FontWeight.w600,
        letterSpacing: 0.1, color: cs.onSurface,
      ),
      // Body
      bodyLarge:  GoogleFonts.plusJakartaSans(
        fontSize: 16, fontWeight: FontWeight.w400,
        color: cs.onSurface,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: cs.onSurface,
      ),
      bodySmall:  GoogleFonts.plusJakartaSans(
        fontSize: 12, fontWeight: FontWeight.w400,
        color: cs.onSurfaceVariant,
      ),
      // Label
      labelLarge:  GoogleFonts.plusJakartaSans(
        fontSize: 14, fontWeight: FontWeight.w600,
        letterSpacing: 0.1, color: cs.onSurface,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 12, fontWeight: FontWeight.w600,
        letterSpacing: 0.5, color: cs.onSurfaceVariant,
      ),
      labelSmall:  GoogleFonts.plusJakartaSans(
        fontSize: 11, fontWeight: FontWeight.w500,
        letterSpacing: 0.5, color: cs.onSurfaceVariant,
      ),
    );
  }

  // ── CardTheme ─────────────────────────────────────────────────────────────
  static CardThemeData _buildCardTheme(ColorScheme cs) {
    return CardThemeData(
      color: cs.surfaceContainerHighest,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
        side: BorderSide(color: cs.outlineVariant, width: 1),
      ),
    );
  }

  // ── InputDecorationTheme ──────────────────────────────────────────────────
  static InputDecorationTheme _buildInputDecorationTheme(ColorScheme cs) {
    final borderRadius = BorderRadius.circular(AppRadius.medium);
    return InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        color: cs.onSurfaceVariant,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        color: cs.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        color: cs.primary,
        fontWeight: FontWeight.w600,
      ),
      errorStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        color: cs.error,
      ),
      // Borders
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: cs.outline, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: cs.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: cs.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: cs.outlineVariant, width: 1),
      ),
      // Icon colors
      prefixIconColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) return cs.primary;
        return cs.onSurfaceVariant;
      }),
      suffixIconColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) return cs.primary;
        return cs.onSurfaceVariant;
      }),
    );
  }

  // ── FloatingActionButtonTheme ─────────────────────────────────────────────
  static FloatingActionButtonThemeData _buildFabTheme(ColorScheme cs) {
    return FloatingActionButtonThemeData(
      backgroundColor: cs.primaryContainer,
      foregroundColor: cs.onPrimaryContainer,
      elevation: 3,
      focusElevation: 5,
      hoverElevation: 5,
      splashColor: cs.primary.withAlpha(40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      largeSizeConstraints: const BoxConstraints.tightFor(
        width: 96, height: 96,
      ),
      sizeConstraints: const BoxConstraints.tightFor(
        width: 56, height: 56,
      ),
      smallSizeConstraints: const BoxConstraints.tightFor(
        width: 40, height: 40,
      ),
      extendedPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      extendedTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    );
  }

  // ── BottomNavigationBarTheme ──────────────────────────────────────────────
  static BottomNavigationBarThemeData _buildBottomNavTheme(ColorScheme cs) {
    return BottomNavigationBarThemeData(
      backgroundColor: cs.surface,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: cs.primary,
      unselectedItemColor: cs.onSurfaceVariant,
      selectedLabelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12, fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12, fontWeight: FontWeight.w400,
      ),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedIconTheme: IconThemeData(
        size: 24, color: cs.primary,
      ),
      unselectedIconTheme: IconThemeData(
        size: 24, color: cs.onSurfaceVariant,
      ),
    );
  }

  // ── SnackBarTheme ─────────────────────────────────────────────────────────
  static SnackBarThemeData _buildSnackBarTheme(ColorScheme cs) {
    return SnackBarThemeData(
      backgroundColor: cs.inverseSurface,
      contentTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: cs.onInverseSurface,
      ),
      actionTextColor: cs.inversePrimary,
      closeIconColor: cs.onInverseSurface,
      elevation: 4,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      showCloseIcon: false,
    );
  }

  // ── DialogTheme ───────────────────────────────────────────────────────────
  static DialogThemeData _buildDialogTheme(ColorScheme cs) {
    return DialogThemeData(
      backgroundColor: cs.surfaceContainerHighest,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      shadowColor: cs.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: cs.onSurface,
        letterSpacing: -0.2,
      ),
      contentTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: cs.onSurfaceVariant,
        height: 1.5,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, AppSpacing.lg,
      ),
      clipBehavior: Clip.antiAlias,
    );
  }

  // ── ChipTheme ─────────────────────────────────────────────────────────────
  static ChipThemeData _buildChipTheme(ColorScheme cs) {
    return ChipThemeData(
      backgroundColor: cs.surfaceContainerHighest,
      selectedColor: cs.primaryContainer,
      secondarySelectedColor: cs.secondaryContainer,
      disabledColor: cs.surfaceContainerHighest.withAlpha(100),
      deleteIconColor: cs.onSurfaceVariant,
      side: BorderSide(color: cs.outlineVariant, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: cs.onSurface,
      ),
      secondaryLabelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: cs.onSecondaryContainer,
      ),
      selectedShadowColor: Colors.transparent,
      showCheckmark: true,
      checkmarkColor: cs.onPrimaryContainer,
      elevation: 0,
      pressElevation: 0,
    );
  }

  // ── ElevatedButtonTheme ───────────────────────────────────────────────────
  static ElevatedButtonThemeData _buildElevatedButtonTheme(ColorScheme cs) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        disabledBackgroundColor: cs.onSurface.withAlpha(30),
        disabledForegroundColor: cs.onSurface.withAlpha(100),
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ── OutlinedButtonTheme ───────────────────────────────────────────────────
  static OutlinedButtonThemeData _buildOutlinedButtonTheme(ColorScheme cs) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: cs.primary,
        disabledForegroundColor: cs.onSurface.withAlpha(100),
        side: BorderSide(color: cs.outline, width: 1.5),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ── TextButtonTheme ───────────────────────────────────────────────────────
  static TextButtonThemeData _buildTextButtonTheme(ColorScheme cs) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: cs.primary,
        disabledForegroundColor: cs.onSurface.withAlpha(100),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
