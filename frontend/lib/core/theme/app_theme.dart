import 'package:flutter/material.dart';

/// Zentrale Markenfarben & Design-Tokens der App.
class AppColors {
  AppColors._();

  // Marke
  static const teal = Color(0xFF0E6E62); // Primär – Vertrauen/Reise
  static const tealDeep = Color(0xFF0A4A41);
  static const blue = Color(0xFF0A4A63); // Verlauf-Endpunkt
  static const amber = Color(0xFFE8A33D); // Akzent – Wärme/Heimat
  static const amberDeep = Color(0xFFC9842A);

  // Status
  static const success = Color(0xFF2E9E5B);
  static const warning = Color(0xFFE0A100);
  static const danger = Color(0xFFD2553F);
  static const info = Color(0xFF3E78B2);

  // Flächen
  static const lightBg = Color(0xFFF5F7F6);
  static const darkBg = Color(0xFF0E1413);
  static const darkSurface = Color(0xFF161D1C);

  /// Diagonaler Markenverlauf (Hero-Header, Buttons, Logo).
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0E6E62), Color(0xFF0A4A63)],
  );

  /// Wärmerer Akzentverlauf (sekundäre Aktionen / Highlights).
  static const amberGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEFB457), Color(0xFFD98A2B)],
  );
}

/// Einheitliche Eckenradien.
class AppRadius {
  AppRadius._();
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 18.0;
  static const xl = 26.0;
}

/// Erzeugt das vollständige App-Theme (Light/Dark) aus den Marken-Tokens.
ThemeData buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.teal,
    brightness: brightness,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
  );

  final radiusMd = BorderRadius.circular(AppRadius.md);
  final outline = scheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.8);

  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
    borderRadius: radiusMd,
    borderSide: BorderSide(color: c, width: w),
  );

  final text = base.textTheme.copyWith(
    displaySmall: base.textTheme.displaySmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    headlineMedium: base.textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    headlineSmall: base.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
    titleLarge: base.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    ),
    titleMedium: base.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
    ),
    labelLarge: base.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
    textTheme: text,
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 3,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      centerTitle: false,
      titleTextStyle: text.titleLarge,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: isDark ? AppColors.darkSurface : Colors.white,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: outline),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: border(outline),
      enabledBorder: border(outline),
      focusedBorder: border(scheme.primary, 1.6),
      errorBorder: border(scheme.error),
      focusedErrorBorder: border(scheme.error, 1.6),
      floatingLabelStyle: TextStyle(
        color: scheme.primary,
        fontWeight: FontWeight.w600,
      ),
      prefixIconColor: scheme.onSurfaceVariant,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        textStyle: text.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: radiusMd),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(0, 52),
        elevation: 0,
        textStyle: text.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: radiusMd),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 52),
        textStyle: text.labelLarge,
        side: BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: radiusMd),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(textStyle: text.labelLarge),
    ),
    chipTheme: ChipThemeData(
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      labelStyle: text.labelLarge?.copyWith(fontSize: 12.5),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    ),
    dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 1),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      elevation: 3,
      indicatorColor: scheme.primary.withValues(alpha: 0.16),
      labelTextStyle: WidgetStateProperty.all(
        text.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: radiusMd),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    ),
    // Flüssige, plattformübergreifende Seitenübergänge (Material-3-Zoom).
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
        TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}
