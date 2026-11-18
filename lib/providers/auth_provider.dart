import 'package:flutter/foundation.dart';

import '../core/api/api_client.dart';
import '../core/api/api_exception.dart';
import '../core/api/auth_repositorio.dart';
import '../core/storage/token_storage.dart';
import '../models/usuario.dart';

enum EstadoSesion { verificando, sinSesion, conSesion }

class AuthProvider extends ChangeNotifier {
  AuthProvider({required this._api, required this._repositorio, required this._almacen}) {
    _api.alSesionVencida = sesionVencida;
  }

  static const avisoSesionVencida = 'Tu sesión venció. Inicia sesión de nuevo.';

  final ApiClient _api;
  final AuthRepositorio _repositorio;
  final TokenStorage _almacen;

  EstadoSesion _estado = EstadoSesion.verificando;
  Usuario? _usuario;
  bool _cargando = false;
  String? _error;
  String? _aviso;

  EstadoSesion get estado => _estado;
  Usuario? get usuario => _usuario;
  bool get cargando => _cargando;

  /// Error del último intento de login.
  String? get error => _error;

  /// Aviso informativo para la pantalla de login (sesión vencida, servidor caído al abrir).
  String? get aviso => _aviso;
  String get urlBase => _api.urlBase;

  /// Al abrir la app: valida el token guardado con GET /v1/auth/me.
  Future<void> restaurarSesion() async {
    final token = await _almacen.leer();
    if (token == null) return _cambiar(EstadoSesion.sinSesion);
    _api.token = token;
    try {
      _usuario = await _repositorio.yo();
      _cambiar(EstadoSesion.conSesion);
    } on ApiException catch (e) {
      _api.token = null;
      if (e.tipo == TipoErrorApi.noAutorizado) {
        await _almacen.borrar();
        _aviso = avisoSesionVencida;
      } else {
        // Sin servidor no se entra con datos viejos; el token se conserva para el siguiente intento.
        _aviso = '${e.mensaje} Inicia sesión cuando el servidor esté disponible.';
      }
      _cambiar(EstadoSesion.sinSesion);
    }
  }

  Future<bool> login(String usuario, String password) async {
    _cargando = true;
    _error = null;
    _aviso = null;
    notifyListeners();
    try {
      final r = await _repositorio.login(usuario.trim(), password);
      await _almacen.guardar(r.token);
      _api.token = r.token;
      _usuario = r.usuario;
      _cargando = false;
      _cambiar(EstadoSesion.conSesion);
      return true;
    } on ApiException catch (e) {
      _error = switch (e.tipo) {
        TipoErrorApi.credencialesInvalidas => 'Usuario o contraseña incorrectos.',
        TipoErrorApi.sinConexion => '${e.mensaje} Verifica que la API esté encendida.',
        _ => e.mensaje,
      };
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout({String? aviso}) async {
    _api.token = null;
    _usuario = null;
    _error = null;
    _aviso = aviso;
    await _almacen.borrar();
    _cambiar(EstadoSesion.sinSesion);
  }

  /// Lo llama ApiClient cuando cualquier petición con token responde 401.
  void sesionVencida() {
    if (_estado == EstadoSesion.conSesion) logout(aviso: avisoSesionVencida);
  }

  void _cambiar(EstadoSesion nuevo) {
    _estado = nuevo;
    notifyListeners();
  }
}
