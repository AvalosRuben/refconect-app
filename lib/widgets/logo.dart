import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Monograma «RC» en un cuadro de tinta con un punto de acento.
class LogoMarca extends StatelessWidget {
  const LogoMarca({super.key, this.tamano = 76});

  final double tamano;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColores.tintaSuave, AppColores.tinta],
        ),
        borderRadius: BorderRadius.circular(tamano * 0.3),
        boxShadow: Sombras.flotante,
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              'RC',
              style: TextStyle(
                fontFamily: Fuentes.interfaz,
                fontSize: tamano * 0.38,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
                color: Colors.white,
                height: 1,
              ),
            ),
          ),
          Positioned(
            right: tamano * 0.17,
            top: tamano * 0.17,
            child: Container(
              width: tamano * 0.13,
              height: tamano * 0.13,
              decoration: const BoxDecoration(color: AppColores.acento, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'RefConect',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LogoMarca(),
          const SizedBox(height: 20),
          const Text.rich(
            TextSpan(children: [
              TextSpan(text: 'RefConect'),
              TextSpan(text: '.', style: TextStyle(color: AppColores.acento)),
            ]),
            style: TextStyle(
              fontFamily: Fuentes.interfaz,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              color: AppColores.tinta,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Existencias y equivalencias',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColores.textoSecundario),
          ),
        ],
      ),
    );
  }
}
