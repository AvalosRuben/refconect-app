enum TipoErrorApi {
  sinConexion,
  credencialesInvalidas,
  noAutorizado,
  noEncontrado,
  peticionInvalida,
  demasiadosIntentos,
  servidor,
}

/// Error de la API ya traducido a algo que la interfaz sabe mostrar.
class ApiException implements Exception {
  const ApiException(this.tipo, this.mensaje, {this.estado});

  factory ApiException.sinConexion(String urlBase) => ApiException(
        TipoErrorApi.sinConexion,
        'No se pudo conectar con el servidor ($urlBase).',
      );

  /// Traduce el formato único `{ "error": { "codigo", "mensaje" } }`.
  factory ApiException.desdeRespuesta(int estado, String? codigo, String? mensaje) {
    final tipo = switch (codigo) {
      'CREDENCIALES_INVALIDAS' => TipoErrorApi.credencialesInvalidas,
      'NO_AUTORIZADO' => TipoErrorApi.noAutorizado,
      'NO_ENCONTRADO' => TipoErrorApi.noEncontrado,
      'PETICION_INVALIDA' => TipoErrorApi.peticionInvalida,
      'DEMASIADOS_INTENTOS' => TipoErrorApi.demasiadosIntentos,
      _ => estado == 401 ? TipoErrorApi.noAutorizado : TipoErrorApi.servidor,
    };
    return ApiException(tipo, mensaje ?? 'El servidor respondió con un error ($estado).', estado: estado);
  }

  final TipoErrorApi tipo;
  final String mensaje;
  final int? estado;

  @override
  String toString() => 'ApiException($tipo, $estado): $mensaje';
}
