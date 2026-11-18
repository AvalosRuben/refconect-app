import '../../models/usuario.dart';
import 'api_client.dart';

class ResultadoLogin {
  const ResultadoLogin(this.token, this.usuario);
  final String token;
  final Usuario usuario;
}

class AuthRepositorio {
  AuthRepositorio(this._api);
  final ApiClient _api;

  Future<ResultadoLogin> login(String usuario, String password) async {
    final json = await _api.post('/auth/login', {'usuario': usuario, 'password': password});
    return ResultadoLogin(json['token'] as String, Usuario.fromJson(json['usuario'] as Map<String, dynamic>));
  }

  Future<Usuario> yo() async {
    final json = await _api.get('/auth/me');
    return Usuario.fromJson(json['usuario'] as Map<String, dynamic>);
  }
}
