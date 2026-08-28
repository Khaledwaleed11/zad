import 'package:flutter/material.dart';

class AppTheme {
  static const Color indigo = Color(0xFF5B4B9A);

  static const Color lavender = Color(0xFF8B7CC8);

  static const Color lavenderLight = Color(0xFFEAE6FA);

  static const Color lightBackground = Color(0xFFF7F7FC);

  static const Color darkBackground = Color(0xFF0D0C14);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    scaffoldBackgroundColor: lightBackground,

    colorScheme: const ColorScheme.light(
      primary: indigo,
      onPrimary: Colors.white,

      primaryContainer: Color(0xFFE7E2F8),
      onPrimaryContainer: Color(0xFF20154A),

      secondary: lavender,
      onSecondary: Colors.white,

      secondaryContainer: Color(0xFFEDE9FB),
      onSecondaryContainer: Color(0xFF302A51),

      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF20202A),

      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFFBFAFF),
      surfaceContainer: Color(0xFFF4F2FA),
      surfaceContainerHigh: Color(0xFFEDEAF5),
      surfaceContainerHighest: Color(0xFFE5E2EE),

      onSurfaceVariant: Color(0xFF757383),

      outline: Color(0xFFC8C5D2),
      outlineVariant: Color(0xFFE1DEE9),

      error: Color(0xFFBA1A1A),
      onError: Colors.white,

      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,

      foregroundColor: Color(0xFF20202A),

      elevation: 0,

      scrolledUnderElevation: 0,

      centerTitle: true,

      surfaceTintColor: Colors.transparent,
    ),

    cardTheme: CardThemeData(
      elevation: 0,

      color: const Color(0xFFFFFFFF),

      surfaceTintColor: Colors.transparent,

      margin: EdgeInsets.zero,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,

      fillColor: const Color(0xFFFFFFFF),

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),

      hintStyle: const TextStyle(
        color: Color(0xFF858390),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE1DEE9)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: indigo, width: 1.4),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: indigo,

        foregroundColor: Colors.white,

        elevation: 0,

        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: indigo,

        foregroundColor: Colors.white,

        elevation: 0,

        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: indigo,

        side: BorderSide(color: indigo.withValues(alpha: 0.28)),

        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFFE1DEE9),
      thickness: 1,
      space: 1,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFF0EEF7),

      selectedColor: indigo,

      labelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF20202A),
      ),

      secondaryLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),

      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

      side: BorderSide.none,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }

        return const Color(0xFF7E7B88);
      }),

      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return indigo;
        }

        return const Color(0xFFD8D5E0);
      }),

      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    scaffoldBackgroundColor: darkBackground,

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFB5A7F4),
      onPrimary: Color(0xFF2A2157),

      primaryContainer: Color(0xFF40366A),
      onPrimaryContainer: Color(0xFFE6DEFF),

      secondary: Color(0xFF9E8EDA),
      onSecondary: Color(0xFF241942),

      secondaryContainer: Color(0xFF3A3157),
      onSecondaryContainer: Color(0xFFE9DDFF),

      surface: Color(0xFF171620),
      onSurface: Color(0xFFF1EEF8),

      surfaceContainerLowest: Color(0xFF0A0910),
      surfaceContainerLow: Color(0xFF12111A),
      surfaceContainer: Color(0xFF1B1924),
      surfaceContainerHigh: Color(0xFF24222F),
      surfaceContainerHighest: Color(0xFF2D2A39),

      onSurfaceVariant: Color(0xFFAAA5B7),

      outline: Color(0xFF595565),
      outlineVariant: Color(0xFF3B3847),

      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),

      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,

      foregroundColor: Color(0xFFF1EEF8),

      elevation: 0,

      scrolledUnderElevation: 0,

      centerTitle: true,

      surfaceTintColor: Colors.transparent,
    ),

    cardTheme: CardThemeData(
      elevation: 0,

      color: const Color(0xFF171620),

      surfaceTintColor: Colors.transparent,

      margin: EdgeInsets.zero,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,

      fillColor: const Color(0xFF1B1924),

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),

      hintStyle: const TextStyle(
        color: Color(0xFF8C8898),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF3B3847)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFB5A7F4), width: 1.4),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFB5A7F4),

        foregroundColor: const Color(0xFF2A2157),

        elevation: 0,

        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFB5A7F4),

        foregroundColor: const Color(0xFF2A2157),

        elevation: 0,

        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFB5A7F4),

        side: BorderSide(
          color: const Color(0xFFB5A7F4).withValues(alpha: 0.28),
        ),

        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFF3B3847),
      thickness: 1,
      space: 1,
    ),

    chipTheme: const ChipThemeData(
      backgroundColor: Color(0xFF24222F),

      selectedColor: Color(0xFFB5A7F4),

      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFFF1EEF8),
      ),

      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),

      side: BorderSide.none,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF2A2157);
        }

        return const Color(0xFF8C8898);
      }),

      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFFB5A7F4);
        }

        return const Color(0xFF3B3847);
      }),

      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
  );
}
