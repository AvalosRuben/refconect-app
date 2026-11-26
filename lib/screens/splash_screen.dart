import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../widgets/logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Logo(),
            SizedBox(height: 40),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColores.primario,
                semanticsLabel: 'Verificando sesión',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
