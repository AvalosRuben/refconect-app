import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Pastilla pequeña con ícono y texto (ubicación, "Tiene equivalentes", "Mayor existencia").
class Etiqueta extends StatelessWidget {
  const Etiqueta({
    super.key,
    required this.icono,
    required this.texto,
    this.color = AppColores.textoSecundario,
    this.fondo = const Color(0xFFEDF1F5),
  });

  final IconData icono;
  final String texto;
  final Color color;
  final Color fondo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 18, color: color),
          const SizedBox(width: 6),
          Text(texto, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
