import 'package:flutter/material.dart';

class AppTheme {
  // ─── Light Theme Colors ───────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF9FAFE);
  static const Color lightAppBarBg = Color(0xFFF9FAFE);
  static const Color lightSurface = Color.fromARGB(255, 207, 212, 227);
  static const Color lightNavBarBg = Color.fromARGB(255, 244, 246, 255);
  static const Color lightNavActive = Color.fromARGB(255, 44, 56, 89);
  static const Color lightNavInactive = Color.fromARGB(255, 34, 39, 54);
  static const Color lightFabBg = Color.fromARGB(255, 44, 56, 89);
  static const Color lightToggleBg = Color.fromARGB(255, 6, 10, 12);
  static const Color lightDarkText = Color.fromARGB(255, 44, 56, 89);
  static const Color lightLightText = Color(0xFFF7FCFF);

  // ─── Dark Theme Colors ────────────────────────────────────────────────────
static const Color darkBackground = Color.fromARGB(255, 24, 27, 28);
static const Color darkAppBarBg =    Color.fromARGB(255, 24, 27, 28);  // WhatsApp app bar
static const Color darkSurface =      Color.fromARGB(255, 53, 59, 64)  ;  // Chat bubbles / cards
static const Color darkNavBarBg =     Color.fromARGB(255, 23, 26, 28);// Bottom nav bg
static const Color darkNavActive =     Color.fromARGB(255, 186, 190, 210); // WhatsApp green accent
static const Color darkNavInactive =Color.fromARGB(255, 199, 203, 207)  ;          // Muted gray
static const Color darkFabBg =Color.fromARGB(255, 53, 59, 64)  ;           // WhatsApp green FAB
static const Color darkToggleBg =        Color.fromARGB(255, 7, 131, 214)  ;      // Toggle/track bg
static const Color darkLightText =        Color.fromARGB(255, 186, 190, 210);  // Primary text white
static const Color darkDarkText =    Color.fromARGB(255, 236, 241, 245)  ;          // Secondary text gray

  // ─── Light ThemeData ──────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      primaryColor: lightNavActive,
      cardColor: Colors.white, // ✅ Simple cardColor

      colorScheme: const ColorScheme.light(
        primary: lightNavActive,
        onPrimary: lightLightText,
        secondary: lightSurface,
        onSecondary: lightDarkText,
        surface: lightSurface,
        onSurface: lightDarkText,
        background: lightBackground,
        onBackground: lightDarkText,
        error: Colors.red,
        onError: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: lightAppBarBg,
        foregroundColor: lightDarkText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightDarkText,
        ),
        iconTheme: IconThemeData(color: lightDarkText),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightNavBarBg,
        selectedItemColor: lightNavActive,
        unselectedItemColor: lightNavInactive,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: lightFabBg,
        foregroundColor: lightLightText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          borderSide: BorderSide(color: lightNavActive, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(
          fontFamily: 'Poppins',
          color: Color(0xFF9CA3AF),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightFabBg,
          foregroundColor: lightLightText,
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      textTheme: _buildTextTheme(lightDarkText),
    );
  }

  // ─── Dark ThemeData ───────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: darkNavActive,
      cardColor: const Color(0xFF2A2E36), // ✅ Simple cardColor

      colorScheme: const ColorScheme.dark(
        primary: darkNavActive,
        onPrimary: darkLightText,
        secondary: darkSurface,
        onSecondary: darkLightText,
        surface: darkSurface,
        onSurface: darkLightText,
        background: darkBackground,
        onBackground: darkLightText,
        error: Colors.red,
        onError: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: darkAppBarBg,
        foregroundColor: darkLightText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkLightText,
        ),
        iconTheme: IconThemeData(color: darkLightText),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkNavBarBg,
        selectedItemColor: darkNavActive,
        unselectedItemColor: darkNavInactive,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: darkFabBg,
        foregroundColor: darkDarkText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          borderSide: BorderSide(color: darkNavActive, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(
          fontFamily: 'Poppins',
          color: Color(0xFF6B7280),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkFabBg,
          foregroundColor: darkDarkText,
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      textTheme: _buildTextTheme(darkLightText),
    );
  }

  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(fontFamily: 'Poppins', color: textColor),
      displayMedium: TextStyle(fontFamily: 'Poppins', color: textColor),
      displaySmall: TextStyle(fontFamily: 'Poppins', color: textColor),
      headlineLarge: TextStyle(fontFamily: 'Poppins', color: textColor),
      headlineMedium: TextStyle(fontFamily: 'Poppins', color: textColor),
      headlineSmall: TextStyle(fontFamily: 'Poppins', color: textColor),
      titleLarge: TextStyle(fontFamily: 'Poppins', color: textColor),
      titleMedium: TextStyle(fontFamily: 'Poppins', color: textColor),
      titleSmall: TextStyle(fontFamily: 'Poppins', color: textColor),
      bodyLarge: TextStyle(fontFamily: 'Poppins', color: textColor),
      bodyMedium: TextStyle(fontFamily: 'Poppins', color: textColor),
      bodySmall: TextStyle(fontFamily: 'Poppins', color: textColor),
      labelLarge: TextStyle(fontFamily: 'Poppins', color: textColor),
      labelMedium: TextStyle(fontFamily: 'Poppins', color: textColor),
      labelSmall: TextStyle(fontFamily: 'Poppins', color: textColor),
    );
  }
}