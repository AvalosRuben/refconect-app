import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:refconect_app/core/api/api_client.dart';
import 'package:refconect_app/core/api/auth_repositorio.dart';
import 'package:refconect_app/core/theme/app_theme.dart';
import 'package:refconect_app/providers/auth_provider.dart';
import 'package:refconect_app/screens/login_screen.dart';

import 'fakes.dart';

Future<AuthProvider> montar(WidgetTester tester, {bool caida = false}) async {
  final api = ApiClient(urlBase: 'http://prueba', cliente: apiFalsa(caida: caida));
  final auth = AuthProvider(api: api, repositorio: AuthRepositorio(api), almacen: TokenStorageMemoria());
  await tester.pumpWidget(ChangeNotifierProvider.value(
    value: auth,
    child: MaterialApp(theme: construirTema(), home: const LoginScreen()),
  ));
  return auth;
}

void main() {
  testWidgets('valida campos vacíos sin llamar a la API', (tester) async {
    final auth = await montar(tester);
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pump();
    expect(find.text('Ingresa tu usuario.'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña.'), findsOneWidget);
    expect(auth.estado, isNot(EstadoSesion.conSesion));
  });

  testWidgets('muestra error de credenciales incorrectas', (tester) async {
    await montar(tester);
    await tester.enterText(find.widgetWithText(TextFormField, 'Usuario'), 'empleado1');
    await tester.enterText(find.widgetWithText(TextFormField, 'Contraseña'), 'mal');
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Usuario o contraseña incorrectos.'), findsOneWidget);
  });

  testWidgets('servidor caído: indica que no se pudo conectar y la URL', (tester) async {
    await montar(tester, caida: true);
    await tester.enterText(find.widgetWithText(TextFormField, 'Usuario'), 'empleado1');
    await tester.enterText(find.widgetWithText(TextFormField, 'Contraseña'), 'Refconect2026!');
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No se pudo conectar con el servidor (http://prueba)'), findsOneWidget);
    expect(find.text('Servidor: http://prueba'), findsOneWidget);
  });

  testWidgets('botón mostrar/ocultar contraseña tiene etiqueta accesible', (tester) async {
    await montar(tester);
    expect(find.byTooltip('Mostrar contraseña'), findsOneWidget);
    await tester.tap(find.byTooltip('Mostrar contraseña'));
    await tester.pump();
    expect(find.byTooltip('Ocultar contraseña'), findsOneWidget);
  });
}
