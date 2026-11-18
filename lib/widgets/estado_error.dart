import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class EstadoError extends StatelessWidget {
  const EstadoError({
    super.key,
    required this.mensaje,
    required this.alReintentar,
    this.titulo = 'Sin conexión con el servidor',
  });

  final String titulo;
  final String mensaje;
  final VoidCallback alReintentar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Medidas.anchoFormulario),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: AppColores.error),
              const SizedBox(height: 16),
              Text(titulo, textAlign: TextAlign.center, style: tema.titleLarge),
              const SizedBox(height: 8),
              Text(mensaje, textAlign: TextAlign.center, style: tema.bodyLarge?.copyWith(color: AppColores.textoSecundario)),
              const SizedBox(height: 8),
              Text('No se muestran existencias hasta recuperar la conexión.',
                  textAlign: TextAlign.center, style: tema.bodyMedium?.copyWith(color: AppColores.textoSecundario)),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: alReintentar,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
