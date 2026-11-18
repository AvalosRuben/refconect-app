import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:refconect_app/core/config/api_config.dart';

void main() {
  test('sin dart-define: Android usa 10.0.2.2 e iOS localhost', () {
    expect(ApiConfig.resolver(definida: '', plataforma: TargetPlatform.android), 'http://10.0.2.2:3000');
    expect(ApiConfig.resolver(definida: '', plataforma: TargetPlatform.iOS), 'http://localhost:3000');
    expect(ApiConfig.resolver(definida: '', plataforma: TargetPlatform.linux), 'http://localhost:3000');
  });

  test('API_BASE_URL tiene prioridad y se le quita la diagonal final', () {
    expect(
      ApiConfig.resolver(definida: 'http://192.168.1.50:3000/', plataforma: TargetPlatform.android),
      'http://192.168.1.50:3000',
    );
  });

  test('en pruebas no hay dart-define: usa la URL por plataforma', () {
    expect(ApiConfig.urlBase, anyOf('http://10.0.2.2:3000', 'http://localhost:3000'));
  });
}
