import 'package:flutter/material.dart';

/// Ícono fijo por categoría; las que no estén en la lista usan uno genérico.
IconData iconoDeCategoria(String nombre) {
  final n = nombre.toLowerCase();
  if (n.contains('filtro')) return Icons.filter_alt_outlined;
  if (n.contains('fren')) return Icons.album_outlined;
  if (n.contains('encend') || n.contains('eléctr') || n.contains('electr')) return Icons.bolt_rounded;
  if (n.contains('suspens')) return Icons.unfold_more_rounded;
  if (n.contains('correa') || n.contains('banda')) return Icons.sync_rounded;
  if (n.contains('lubric') || n.contains('aceite')) return Icons.water_drop_outlined;
  return Icons.category_outlined;
}
