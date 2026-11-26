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
    return TarjetaRC(
      alTocar: alTocar,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Refuerzo visual del estado; el texto de la pastilla es la señal principal.
            ExcludeSemantics(child: Container(width: 5, color: ExistenciaChip.colorDe(p.existencia))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(p.numeroParte, style: Fuentes.numeroParte())),
                        const SizedBox(width: 8),
                        ExistenciaChip(existencia: p.existencia),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('${p.marca} · ${p.categoria}',
                        style: tema.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColores.primario)),
                    const SizedBox(height: 2),
                    Text(p.descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: tema.bodyMedium?.copyWith(color: AppColores.textoSecundario)),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
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
                        ),
                        const Icon(Icons.arrow_forward, size: 22, color: AppColores.textoSecundario,
                            semanticLabel: 'Ver detalle'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
