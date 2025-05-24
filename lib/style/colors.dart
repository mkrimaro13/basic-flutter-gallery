import 'package:flutter/material.dart';

// La paleta de colores que mas se va a usar.

class GeneralColors {
  static const Color transparent = Color.fromARGB(0, 255, 255, 255);
}

/// Clase abstracta (interfaz) que define los colores de la aplicación.
/// Se definen los colores primarios, secundarios, de fondo, de acento, de texto y de borde.
abstract class ThemeColors {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color accent;
  final Color text;
  final Color border;
  final Color transparent;

  const ThemeColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.accent,
    required this.text,
    required this.border,
    this.transparent = const Color.fromARGB(0, 255, 255, 255),
  });
}

class LightThemeColors extends ThemeColors {
  static LightThemeColors instance = LightThemeColors._();

  const LightThemeColors._()
    : super(
        primary: const Color(0xFF7F8CAA),
        secondary: const Color(0xFF9EC6F3),
        background: const Color(0xFFEAEFEF),
        accent: const Color(0xFFD4C9BE),
        text: const Color(0xFF333446),
        border: const Color(0xFFB8CFCE),
      );
}

class DarkThemeColors extends ThemeColors {
  static DarkThemeColors instance = DarkThemeColors._();

  const DarkThemeColors._()
    : super(
        background: const Color(0xFF333446),
        primary: const Color(0xFFB8CFCE),
        secondary: const Color(0xFF7F8CAA),
        accent: const Color(0xFF123458),
        text: const Color(0xFFEAEFEF),
        border: const Color(0xFFD4C9BE),
      );
}
