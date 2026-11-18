import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda el token en el almacenamiento seguro del sistema (Keystore / Keychain).
class TokenStorage {
  TokenStorage([FlutterSecureStorage? almacen]) : _almacen = almacen ?? const FlutterSecureStorage();

  static const _clave = 'refconect_token';
  final FlutterSecureStorage _almacen;

  Future<String?> leer() => _almacen.read(key: _clave);
  Future<void> guardar(String token) => _almacen.write(key: _clave, value: token);
  Future<void> borrar() => _almacen.delete(key: _clave);
}
