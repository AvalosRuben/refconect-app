import 'package:flutter/material.dart';

/// Paleta de RefConect. La existencia nunca se comunica solo con color: siempre va con texto.
abstract final class AppColores {
  static const primario = Color(0xFF1F4E79);
  static const acento = Color(0xFFF28C28);
  static const fondo = Color(0xFFF5F7FA);
  static const exito = Color(0xFF2E7D32);
  static const advertencia = Color(0xFFB26A00);
  static const error = Color(0xFFC62828);

  // Fondos tenues para chips (contraste AA con el texto de su color).
  static const exitoTenue = Color(0xFFE8F5E9);
  static const advertenciaTenue = Color(0xFFFFF3E0);
  static const errorTenue = Color(0xFFFDECEA);
  static const acentoTenue = Color(0xFFFFF1E3);
  static const acentoOscuro = Color(0xFF9A4F00); // texto sobre acentoTenue
  static const textoSecundario = Color(0xFF4A5868);
}

/// Medidas compartidas de diseño (evita números mágicos repartidos en las pantallas).
abstract final class Medidas {
  static const double margen = 16;
  static const double radio = 12;
  static const double alturaBoton = 56;
  /// A partir de este ancho se considera tablet: lista en dos columnas.
  static const double anchoTablet = 700;
  /// Ancho máximo del contenido en pantallas grandes.
  static const double anchoMaximo = 960;
  /// Ancho máximo de formularios (login).
  static const double anchoFormulario = 480;
}

ThemeData construirTema() {
  final esquema = ColorScheme.fromSeed(
    seedColor: AppColores.primario,
    primary: AppColores.primario,
    secondary: AppColores.acento,
    error: AppColores.error,
    surface: Colors.white,
  );
  final base = ThemeData(useMaterial3: true, colorScheme: esquema);
  return base.copyWith(
    scaffoldBackgroundColor: AppColores.fondo,
    // Textos de cuerpo de al menos 16 sp; importantes de 18 a 22 sp.
    textTheme: base.textTheme.copyWith(
      bodySmall: base.textTheme.bodySmall?.copyWith(fontSize: 14),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(fontSize: 16),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(fontSize: 18),
      titleMedium: base.textTheme.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge: base.textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
      labelLarge: base.textTheme.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColores.primario,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(Medidas.radio)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Medidas.radio),
        borderSide: const BorderSide(color: Color(0xFFC5CED8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Medidas.radio),
        borderSide: const BorderSide(color: AppColores.primario, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(Medidas.alturaBoton),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Medidas.radio)),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Medidas.radio),
        side: const BorderSide(color: Color(0xFFDDE3EA)),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(labelStyle: const TextStyle(fontSize: 16)),
  );
}
