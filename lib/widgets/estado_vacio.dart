import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Ícono dentro de un círculo tenue (estados vacío y error).
class IconoEstado extends StatelessWidget {
  const IconoEstado({super.key, required this.icono, this.color = AppColores.primario, this.fondo});

  final IconData icono;
  final Color color;
  final Color? fondo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(color: fondo ?? AppColores.superficieHundida, shape: BoxShape.circle),
      child: Icon(icono, size: 44, color: color),
    );
  }
}

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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Medidas.anchoFormulario),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconoEstado(icono: icono),
              const SizedBox(height: 20),
              Text(titulo, textAlign: TextAlign.center, style: tema.titleLarge),
              if (detalle != null) ...[
                const SizedBox(height: 8),
                Text(detalle!,
                    textAlign: TextAlign.center, style: tema.bodyLarge?.copyWith(color: AppColores.textoSecundario)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
