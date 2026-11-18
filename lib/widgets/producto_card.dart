import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/producto_resumen.dart';
import 'etiqueta.dart';
import 'existencia_chip.dart';

class ProductoCard extends StatelessWidget {
  const ProductoCard({super.key, required this.producto, required this.alTocar});

  final ProductoResumen producto;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final p = producto;
    final tema = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: alTocar,
        child: Padding(
          padding: const EdgeInsets.all(Medidas.margen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.numeroParte,
                            style: tema.titleLarge?.copyWith(color: AppColores.primario, letterSpacing: 0.3)),
                        const SizedBox(height: 2),
                        Text('${p.marca} · ${p.categoria}',
                            style: tema.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                        Text(p.descripcion, style: tema.bodyMedium?.copyWith(color: AppColores.textoSecundario)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColores.textoSecundario, semanticLabel: 'Ver detalle'),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ExistenciaChip(existencia: p.existencia),
                  if (p.ubicacion != null) Etiqueta(icono: Icons.place_outlined, texto: p.ubicacion!),
                  if (p.existencia == 0 && p.tieneEquivalentes)
                    const Etiqueta(
                      icono: Icons.swap_horiz,
                      texto: 'Tiene equivalentes',
                      color: AppColores.acentoOscuro,
                      fondo: AppColores.acentoTenue,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
