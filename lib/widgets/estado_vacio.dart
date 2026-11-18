import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class EstadoVacio extends StatelessWidget {
  const EstadoVacio({super.key, required this.titulo, this.detalle, this.icono = Icons.search_off});

  final String titulo;
  final String? detalle;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 64, color: AppColores.textoSecundario),
            const SizedBox(height: 16),
            Text(titulo, textAlign: TextAlign.center, style: tema.titleLarge),
            if (detalle != null) ...[
              const SizedBox(height: 8),
              Text(detalle!, textAlign: TextAlign.center, style: tema.bodyLarge?.copyWith(color: AppColores.textoSecundario)),
            ],
          ],
        ),
      ),
    );
  }
}
