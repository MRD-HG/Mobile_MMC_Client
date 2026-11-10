import 'package:flutter/material.dart';

/// MMC palette: Fluent-style brand blue + the four colours of the MMC logo.
class MmcColors {
  const MmcColors._();

  static const brand = Color(0xFF0F6CBD); // Fluent 2 brand blue
  static const brandDark = Color(0xFF115EA3);
  static const brandLight = Color(0xFF479EF5);

  // Logo tiles
  static const red = Color(0xFFE5532D);
  static const green = Color(0xFF7BB73A);
  static const blue = Color(0xFF3E9BD8);
  static const yellow = Color(0xFFF2B630);

  static const logoColors = [red, green, blue, yellow];

  /// Stable colour for a topic label.
  static Color forTopic(String topic) =>
      logoColors[topic.codeUnits.fold<int>(0, (a, b) => a + b) % logoColors.length];
}

class MmcSpacing {
  const MmcSpacing._();
  static const xs = 4.0;
  static const s = 8.0;
  static const m = 12.0;
  static const l = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

class MmcRadius {
  const MmcRadius._();
  static const card = 16.0;
  static const chip = 999.0;
  static const button = 12.0;
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static const _lightBg = Color(0xFFF5F7FA);
  static const _darkBg = Color(0xFF121214);

  /// Card / sheet colour (kept outside ThemeData to stay compatible across
  /// Flutter versions while CardTheme → CardThemeData is migrating).
  static Color cardColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E23)
          : Colors.white;

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? _darkBg : _lightBg;
    final scheme = ColorScheme.fromSeed(
      seedColor: MmcColors.brand,
      brightness: brightness,
      primary: isDark ? MmcColors.brandLight : MmcColors.brand,
      surface: bg,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
    );
    final text = base.textTheme;

    return base.copyWith(
      textTheme: text.copyWith(
        headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF1A1A1E) : Colors.white,
        indicatorColor: scheme.primaryContainer,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MmcRadius.button)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MmcRadius.button)),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
    );
  }
}
