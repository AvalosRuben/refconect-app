import 'package:flutter/material.dart';

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
            SizedBox(height: 32),
            CircularProgressIndicator(semanticsLabel: 'Verificando sesión'),
          ],
        ),
      ),
    );
  }
}
