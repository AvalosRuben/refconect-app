import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Existencia con color, ícono y texto (nunca solo color).
class ExistenciaChip extends StatelessWidget {
  const ExistenciaChip({super.key, required this.existencia, this.grande = false});

  final int existencia;
  final bool grande;

  /// Poca existencia: de 1 a 3 piezas.
  static const pocaMaxima = 3;

  static String texto(int existencia) => switch (existencia) {
        0 => 'Sin existencia',
        <= pocaMaxima => 'Poca: $existencia',
        _ => '$existencia en existencia',
      };

  @override
  Widget build(BuildContext context) {
    final (color, fondo, icono) = switch (existencia) {
      0 => (AppColores.error, AppColores.errorTenue, Icons.block),
      <= pocaMaxima => (AppColores.advertencia, AppColores.advertenciaTenue, Icons.warning_amber_rounded),
      _ => (AppColores.exito, AppColores.exitoTenue, Icons.check_circle),
    };
    final tamano = grande ? 18.0 : 16.0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: grande ? 14 : 10, vertical: grande ? 8 : 6),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: tamano + 2, color: color),
          const SizedBox(width: 6),
          Text(texto(existencia), style: TextStyle(color: color, fontSize: tamano, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
