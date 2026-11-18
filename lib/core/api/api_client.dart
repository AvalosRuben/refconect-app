import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

/// Único punto de contacto con la red. Las pantallas nunca usan `http` directamente,
/// así se puede cambiar después a la API real del punto de venta sin tocarlas.
class ApiClient {
  ApiClient({
    required this.urlBase,
    http.Client? cliente,
    this.tiempoLimite = const Duration(seconds: 8),
  }) : _http = cliente ?? http.Client();

  final String urlBase;
  final Duration tiempoLimite;
  final http.Client _http;

  /// Token de la sesión actual; lo administra AuthProvider.
  String? token;

  /// Se invoca cuando una petición con token responde 401 (sesión vencida o usuario inactivo).
  void Function()? alSesionVencida;

  Future<Map<String, dynamic>> get(String ruta, {Map<String, String>? query}) =>
      _enviar(() => _http.get(_uri(ruta, query), headers: _encabezados()));

  Future<Map<String, dynamic>> post(String ruta, Map<String, Object?> cuerpo) =>
      _enviar(() => _http.post(_uri(ruta, null), headers: _encabezados(), body: jsonEncode(cuerpo)));

  Uri _uri(String ruta, Map<String, String>? query) {
    final uri = Uri.parse('$urlBase/v1$ruta');
    return query == null || query.isEmpty ? uri : uri.replace(queryParameters: query);
  }

  Map<String, String> _encabezados() => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<Map<String, dynamic>> _enviar(Future<http.Response> Function() peticion) async {
    final conToken = token != null;
    final http.Response res;
    try {
      res = await peticion().timeout(tiempoLimite);
    } on TimeoutException {
      throw ApiException.sinConexion(urlBase);
    } on SocketException {
      throw ApiException.sinConexion(urlBase);
    } on http.ClientException {
      throw ApiException.sinConexion(urlBase);
    }

    Object? cuerpo;
    try {
      cuerpo = jsonDecode(utf8.decode(res.bodyBytes));
    } on FormatException {
      cuerpo = null;
    }

    if (res.statusCode >= 200 && res.statusCode < 300 && cuerpo is Map<String, dynamic>) return cuerpo;

    final error = cuerpo is Map<String, dynamic> ? cuerpo['error'] : null;
    final ex = ApiException.desdeRespuesta(
      res.statusCode,
      error is Map ? error['codigo'] as String? : null,
      error is Map ? error['mensaje'] as String? : null,
    );
    if (ex.tipo == TipoErrorApi.noAutorizado && conToken) alSesionVencida?.call();
    throw ex;
  }
}
