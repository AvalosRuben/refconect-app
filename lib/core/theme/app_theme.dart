import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Paleta de RefConect. La existencia nunca se comunica solo con color: siempre va con ícono y texto.
abstract final class AppColores {
  /// Texto principal y superficies oscuras (cabeceras, logo).
  static const tinta = Color(0xFF0F1B2D);
  static const tintaSuave = Color(0xFF22324A);
  static const primario = Color(0xFF1B3A5C);
  /// Acento: solo para lo destacado. Nunca como fondo de texto blanco (contraste bajo).
  static const acento = Color(0xFFF28C28);
  static const fondo = Color(0xFFF6F4F0);
  static const superficie = Colors.white;
  static const superficieHundida = Color(0xFFEFECE6);
  static const borde = Color(0xFFE6E1D9);

  static const exito = Color(0xFF2E7D32);
  static const advertencia = Color(0xFF8A5300);
  static const error = Color(0xFFC62828);

  // Fondos tenues para pastillas (contraste AA con el texto de su color).
  static const exitoTenue = Color(0xFFE6F4E7);
  static const advertenciaTenue = Color(0xFFFFF1DC);
  static const errorTenue = Color(0xFFFDECEA);
  static const acentoTenue = Color(0xFFFFEEDC);
  static const acentoOscuro = Color(0xFF8F4A00); // texto sobre acentoTenue
  static const textoSecundario = Color(0xFF4A5868);
  /// Texto secundario sobre fondos de tinta.
  static const textoSobreTinta = Color(0xFFB9C6D6);
}

/// Medidas compartidas (escala de 4).
abstract final class Medidas {
  static const double margen = 16;
  static const double margenGrande = 24;
  static const double radio = 16;
  static const double radioChico = 12;
  static const double radioGrande = 24;
  static const double alturaBoton = 56;
  /// A partir de este ancho se considera tablet: lista en dos columnas.
  static const double anchoTablet = 700;
  /// Ancho máximo del contenido en pantallas grandes.
  static const double anchoMaximo = 960;
  /// Ancho máximo de formularios (login).
  static const double anchoFormulario = 480;
}

/// Sombras suaves en dos capas (en lugar de bordes grises).
abstract final class Sombras {
  static const tarjeta = [
    BoxShadow(color: Color(0x0F0F1B2D), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x140F1B2D), blurRadius: 16, offset: Offset(0, 6)),
  ];
  static const flotante = [
    BoxShadow(color: Color(0x140F1B2D), blurRadius: 4, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x290F1B2D), blurRadius: 32, offset: Offset(0, 12)),
  ];
}

/// Tipografías: Manrope para la interfaz, JetBrains Mono para números de parte.
abstract final class Fuentes {
  static const interfaz = 'Manrope';
  static const mono = 'JetBrainsMono';

  /// Número de parte: lo primero que busca el vendedor con la vista.
  static TextStyle numeroParte({double tamano = 20, Color color = AppColores.tinta}) => TextStyle(
        fontFamily: mono,
        fontSize: tamano,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.2,
        color: color,
      );
}

/// Duraciones de movimiento (cortas: nada debe retrasar la consulta).
abstract final class Movimiento {
  static const corto = Duration(milliseconds: 150);
  static const medio = Duration(milliseconds: 220);

  /// Respeta "quitar animaciones" del sistema.
  static Duration de(BuildContext context, Duration d) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false ? Duration.zero : d;
}

ThemeData construirTema() {
  final esquema = ColorScheme.fromSeed(
    seedColor: AppColores.primario,
    primary: AppColores.primario,
    onPrimary: Colors.white,
    secondary: AppColores.acento,
    onSecondary: AppColores.tinta,
    error: AppColores.error,
    surface: AppColores.superficie,
    onSurface: AppColores.tinta,
    outline: AppColores.borde,
  );
  final base = ThemeData(useMaterial3: true, colorScheme: esquema, fontFamily: Fuentes.interfaz);
  final t = base.textTheme.apply(bodyColor: AppColores.tinta, displayColor: AppColores.tinta);
  final radio = BorderRadius.circular(Medidas.radio);

  return base.copyWith(
    scaffoldBackgroundColor: AppColores.fondo,
    // Textos de cuerpo de al menos 16 sp; importantes de 18 a 22 sp.
    textTheme: t.copyWith(
      displayMedium: t.displayMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1.5),
      headlineMedium: t.headlineMedium?.copyWith(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6),
      headlineSmall: t.headlineSmall?.copyWith(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.4),
      titleLarge: t.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.2),
      titleMedium: t.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
      bodyLarge: t.bodyLarge?.copyWith(fontSize: 18, height: 1.4),
      bodyMedium: t.bodyMedium?.copyWith(fontSize: 16, height: 1.4),
      bodySmall: t.bodySmall?.copyWith(fontSize: 14),
      labelLarge: t.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColores.fondo,
      foregroundColor: AppColores.tinta,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontFamily: Fuentes.interfaz,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColores.tinta,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColores.superficieHundida,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      labelStyle: const TextStyle(color: AppColores.textoSecundario, fontWeight: FontWeight.w600),
      hintStyle: const TextStyle(color: AppColores.textoSecundario),
      prefixIconColor: AppColores.textoSecundario,
      suffixIconColor: AppColores.textoSecundario,
      border: OutlineInputBorder(borderRadius: radio, borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: radio, borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: radio,
        borderSide: const BorderSide(color: AppColores.primario, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radio,
        borderSide: const BorderSide(color: AppColores.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radio,
        borderSide: const BorderSide(color: AppColores.error, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColores.tinta,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColores.tintaSuave,
        disabledForegroundColor: Colors.white70,
        minimumSize: const Size.fromHeight(Medidas.alturaBoton),
        textStyle: const TextStyle(fontFamily: Fuentes.interfaz, fontSize: 18, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: radio),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColores.primario,
        minimumSize: const Size(48, 48),
        textStyle: const TextStyle(fontFamily: Fuentes.interfaz, fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size(48, 48), foregroundColor: AppColores.tinta),
    ),
    cardTheme: CardThemeData(
      color: AppColores.superficie,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: radio),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColores.superficie,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Medidas.radioGrande)),
      titleTextStyle: const TextStyle(
        fontFamily: Fuentes.interfaz,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColores.tinta,
      ),
      contentTextStyle: const TextStyle(fontFamily: Fuentes.interfaz, fontSize: 16, color: AppColores.textoSecundario),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColores.primario),
    dividerTheme: const DividerThemeData(color: AppColores.borde, thickness: 1),
    chipTheme: base.chipTheme.copyWith(labelStyle: const TextStyle(fontSize: 16)),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

/// Tarjeta blanca con sombra suave y respuesta al toque.
class TarjetaRC extends StatelessWidget {
  const TarjetaRC({super.key, required this.child, this.alTocar, this.padding, this.borde});

  final Widget child;
  final VoidCallback? alTocar;
  final EdgeInsetsGeometry? padding;
  final BorderSide? borde;

  @override
  Widget build(BuildContext context) {
    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Medidas.radio),
      side: borde ?? BorderSide.none,
    );
    return DecoratedBox(
      decoration: ShapeDecoration(shape: forma, shadows: Sombras.tarjeta),
      child: Material(
        color: AppColores.superficie,
        shape: forma,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: alTocar,
          splashColor: AppColores.primario.withValues(alpha: 0.06),
          highlightColor: AppColores.primario.withValues(alpha: 0.04),
          child: Padding(padding: padding ?? const EdgeInsets.all(Medidas.margen), child: child),
        ),
      ),
    );
  }
}
