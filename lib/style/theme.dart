import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

/// Método que incluye la paleta de colores para los diferentes componentes y las fuentes de Google Fonts.
ThemeData appTheme(Brightness brightness, ThemeColors colors) {
  return ThemeData(
    textTheme: GoogleFonts.handleeTextTheme().apply(
      bodyColor: colors.text,
      displayColor: colors.text,
    ),
    colorScheme: ColorScheme.fromSeed(
      brightness: brightness,
      seedColor: colors.primary,
      primary: colors.primary,
      secondary: colors.secondary,
    ),
    scaffoldBackgroundColor: colors.background,
    appBarTheme: AppBarTheme(
      toolbarHeight: 50,
      elevation: 5,
      backgroundColor: colors.background,
      foregroundColor: colors.text,
      shadowColor: colors.border,
      titleTextStyle: GoogleFonts.notoSerifOttomanSiyaq(
        color: colors.text,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors.secondary,
      foregroundColor: colors.text,
      elevation: 5,
      splashColor: colors.accent,
      shape: CircleBorder()
    ),
    cardTheme: CardTheme(
      color: colors.background,
      shadowColor: colors.accent,
      elevation: 4,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 8,
      enableFeedback: true,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.background,
      shadowColor: colors.border,
      indicatorColor: colors.secondary,
      elevation: 8,
      height: 75,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      indicatorShape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(20, 50),
        maximumSize: Size(double.infinity, 50),
        backgroundColor: colors.secondary,
        foregroundColor: colors.text,
        shadowColor: colors.border,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
    iconTheme: IconThemeData(
      color: colors.text,
      size: 24,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor:
      WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return colors.secondary; // Color de fondo cuando está seleccionado
        }
        return colors
            .accent; // Color de fondo cuando no está seleccionado (contraste suave)
      }),
      checkColor: WidgetStatePropertyAll(colors.text), // Color del check
      side: BorderSide(color: colors.border, width: 1.5), // Estilo del borde
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5)), // Forma redondeada
      visualDensity:
      VisualDensity.adaptivePlatformDensity, // Densidad visual adaptativa
    ),

  );
}
