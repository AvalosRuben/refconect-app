import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:refconect_app/core/storage/token_storage.dart';

/// Almacenamiento en memoria para no depender del Keystore/Keychain en pruebas.
class TokenStorageMemoria implements TokenStorage {
  TokenStorageMemoria([this.valor]);
  String? valor;

  @override
  Future<String?> leer() async => valor;
  @override
  Future<void> guardar(String token) async => valor = token;
  @override
  Future<void> borrar() async => valor = null;
}

http.Response json(Object cuerpo, [int estado = 200]) => http.Response.bytes(
      utf8.encode(jsonEncode(cuerpo)),
      estado,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

const usuarioJson = {'id': 1, 'nombre': 'Juan Pérez', 'usuario': 'empleado1', 'rol': 'empleado'};

/// API falsa con el mismo contrato que refconect-api para login y me.
MockClient apiFalsa({bool caida = false}) => MockClient((req) async {
      if (caida) throw http.ClientException('Connection refused', req.url);
      final ruta = req.url.path;
      if (ruta == '/v1/auth/login') {
        final cuerpo = jsonDecode(req.body) as Map<String, dynamic>;
        if (cuerpo['usuario'] == 'empleado1' && cuerpo['password'] == 'Refconect2026!') {
          return json({'token': 'token-valido', 'tipo': 'Bearer', 'expira_en': 28800, 'usuario': usuarioJson});
        }
        return json({
          'error': {'codigo': 'CREDENCIALES_INVALIDAS', 'mensaje': 'Usuario o contraseña incorrectos.'}
        }, 401);
      }
      if (req.headers['Authorization'] != 'Bearer token-valido') {
        return json({
          'error': {'codigo': 'NO_AUTORIZADO', 'mensaje': 'Token inválido o vencido.'}
        }, 401);
      }
      if (ruta == '/v1/auth/me') return json({'usuario': usuarioJson});
      return json({
        'error': {'codigo': 'NO_ENCONTRADO', 'mensaje': 'Ruta no encontrada.'}
      }, 404);
    });
