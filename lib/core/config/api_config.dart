import 'package:flutter/foundation.dart';

/// Dirección base de la API. Nunca se escribe en las pantallas.
///
/// 1. `--dart-define=API_BASE_URL=http://192.168.1.50:3000` tiene prioridad.
/// 2. Si no se define: Android usa `http://10.0.2.2:3000` (la laptop vista desde el emulador)
///    e iOS y el resto `http://localhost:3000`.
abstract final class ApiConfig {
  static const String _definida = String.fromEnvironment('API_BASE_URL');

  static String get urlBase => resolver(definida: _definida, plataforma: defaultTargetPlatform);

  static String resolver({required String definida, required TargetPlatform plataforma}) {
    final valor = definida.trim();
    if (valor.isNotEmpty) return valor.endsWith('/') ? valor.substring(0, valor.length - 1) : valor;
    return plataforma == TargetPlatform.android ? 'http://10.0.2.2:3000' : 'http://localhost:3000';
  }
}
