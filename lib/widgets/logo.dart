import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

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
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(color: AppColores.primario, borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.settings_suggest, size: 52, color: AppColores.acento),
          ),
          const SizedBox(height: 16),
          const Text.rich(
            TextSpan(children: [
              TextSpan(text: 'Ref', style: TextStyle(color: AppColores.primario)),
              TextSpan(text: 'Conect', style: TextStyle(color: AppColores.acento)),
            ]),
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.5),
          ),
          const SizedBox(height: 4),
          const Text('Existencias y equivalencias',
              style: TextStyle(fontSize: 16, color: AppColores.textoSecundario)),
        ],
      ),
    );
  }
}
