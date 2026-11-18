import 'package:flutter_test/flutter_test.dart';
import 'package:refconect_app/core/api/api_client.dart';
import 'package:refconect_app/core/api/auth_repositorio.dart';
import 'package:refconect_app/providers/auth_provider.dart';

import 'fakes.dart';

AuthProvider crear(TokenStorageMemoria almacen, {bool caida = false}) {
  final api = ApiClient(urlBase: 'http://prueba', cliente: apiFalsa(caida: caida));
  return AuthProvider(api: api, repositorio: AuthRepositorio(api), almacen: almacen);
}

void main() {
  test('login correcto guarda el token y abre sesión', () async {
    final almacen = TokenStorageMemoria();
    final auth = crear(almacen);
    expect(await auth.login('empleado1', 'Refconect2026!'), isTrue);
    expect(auth.estado, EstadoSesion.conSesion);
    expect(auth.usuario!.nombre, 'Juan Pérez');
    expect(almacen.valor, 'token-valido');
  });

  test('credenciales incorrectas dan mensaje claro y no guardan token', () async {
    final almacen = TokenStorageMemoria();
    final auth = crear(almacen);
    expect(await auth.login('empleado1', 'mal'), isFalse);
    expect(auth.error, 'Usuario o contraseña incorrectos.');
    expect(auth.estado, isNot(EstadoSesion.conSesion));
    expect(almacen.valor, isNull);
  });

  test('servidor caído: mensaje con la URL intentada', () async {
    final auth = crear(TokenStorageMemoria(), caida: true);
    expect(await auth.login('empleado1', 'Refconect2026!'), isFalse);
    expect(auth.error, contains('No se pudo conectar con el servidor (http://prueba)'));
  });

  test('restaura la sesión con un token guardado válido', () async {
    final auth = crear(TokenStorageMemoria('token-valido'));
    await auth.restaurarSesion();
    expect(auth.estado, EstadoSesion.conSesion);
    expect(auth.usuario!.usuario, 'empleado1');
  });

  test('token guardado vencido: lo borra y va al login con aviso', () async {
    final almacen = TokenStorageMemoria('token-viejo');
    final auth = crear(almacen);
    await auth.restaurarSesion();
    expect(auth.estado, EstadoSesion.sinSesion);
    expect(almacen.valor, isNull);
    expect(auth.aviso, AuthProvider.avisoSesionVencida);
  });

  test('sin servidor al abrir: va al login sin entrar con datos viejos', () async {
    final auth = crear(TokenStorageMemoria('token-valido'), caida: true);
    await auth.restaurarSesion();
    expect(auth.estado, EstadoSesion.sinSesion);
    expect(auth.aviso, contains('No se pudo conectar'));
  });

  test('un 401 durante la sesión la cierra con aviso "Tu sesión venció"', () async {
    final almacen = TokenStorageMemoria();
    final auth = crear(almacen);
    await auth.login('empleado1', 'Refconect2026!');
    auth.sesionVencida();
    await Future<void>.delayed(Duration.zero);
    expect(auth.estado, EstadoSesion.sinSesion);
    expect(auth.aviso, AuthProvider.avisoSesionVencida);
    expect(almacen.valor, isNull);
  });

  test('logout borra el token', () async {
    final almacen = TokenStorageMemoria();
    final auth = crear(almacen);
    await auth.login('empleado1', 'Refconect2026!');
    await auth.logout();
    expect(auth.estado, EstadoSesion.sinSesion);
    expect(almacen.valor, isNull);
  });
}
