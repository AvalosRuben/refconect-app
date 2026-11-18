// API de prueba con datos ficticios para desarrollar la app sin backend real.
//
// Uso (desde la raíz del proyecto):
//   dart run tool/mock_api.dart            -> escucha en el puerto 3000
//   PORT=4000 dart run tool/mock_api.dart  -> otro puerto
//
// Implementa el mismo contrato que espera lib/core/api:
//   POST /v1/auth/login   GET /v1/auth/me
//   GET  /v1/categorias   GET /v1/productos   GET /v1/productos/:id
// Errores con el formato { "error": { "codigo", "mensaje" } }.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

// ---------------------------------------------------------------------------
// Datos ficticios
// ---------------------------------------------------------------------------

const _usuarios = [
  {'id': 1, 'nombre': 'Juan Pérez', 'usuario': 'empleado1', 'password': 'Refconect2026!', 'rol': 'empleado'},
  {'id': 2, 'nombre': 'María López', 'usuario': 'admin', 'password': 'Admin2026!', 'rol': 'administrador'},
];

const _categorias = [
  {'id': 1, 'nombre': 'Filtros'},
  {'id': 2, 'nombre': 'Frenos'},
  {'id': 3, 'nombre': 'Encendido'},
  {'id': 4, 'nombre': 'Suspensión'},
  {'id': 5, 'nombre': 'Bandas y distribución'},
  {'id': 6, 'nombre': 'Eléctrico'},
];

/// Grupos de piezas intercambiables entre sí.
const _grupos = {
  1: 'Filtro de aceite Nissan Tsuru / Sentra 1.6',
  2: 'Filtro de aire VW Jetta A4 2.0',
  3: 'Balatas delanteras Chevrolet Aveo 2008-2017',
  4: 'Bujía Nissan Versa / March 1.6',
  5: 'Amortiguador delantero Honda Civic 2006-2011',
  6: 'Banda de distribución VW Pointer / Gol 1.8',
  7: 'Bomba de gasolina Ford Focus 2.0',
};

/// [id, numero_parte, marca, categoria_id, descripcion, existencia, ubicacion, grupo_id]
const _productosCrudos = [
  [1, 'PH3593A', 'Fram', 1, 'Filtro de aceite Nissan Tsuru III / Sentra 1.6L', 14, 'A-01-03', 1],
  [2, 'GP-321', 'Gonher', 1, 'Filtro de aceite Nissan Tsuru / Sentra 1.6L', 0, 'A-01-04', 1],
  [3, 'W 67/1', 'Mann-Filter', 1, 'Filtro de aceite Nissan 1.6L', 6, 'A-01-05', 1],
  [4, 'OF-121', 'Interfil', 1, 'Filtro de aceite Nissan Tsuru 1.6L', 3, null, 1],
  [5, 'CA8755A', 'Fram', 1, 'Filtro de aire VW Jetta A4 / Golf 2.0L', 9, 'A-02-01', 2],
  [6, 'C 31 143', 'Mann-Filter', 1, 'Filtro de aire VW Jetta A4 2.0L', 2, 'A-02-02', 2],
  [7, 'GA-505', 'Gonher', 1, 'Filtro de aire Jetta / Golf / Beetle 2.0L', 11, 'A-02-03', 2],
  [8, 'CF10285', 'Fram', 1, 'Filtro de cabina con carbón activado VW Jetta A6', 4, 'A-03-01', null],
  [9, 'MD-1035', 'Wagner', 2, 'Balatas delanteras cerámicas Chevrolet Aveo', 7, 'B-01-01', 3],
  [10, 'BRK-1035', 'Brembo', 2, 'Balatas delanteras Chevrolet Aveo 2008-2017', 1, 'B-01-02', 3],
  [11, 'D1035', 'Bosch', 2, 'Juego de balatas delanteras Aveo 1.6L', 0, 'B-01-03', 3],
  [12, 'DF4402', 'Brembo', 2, 'Disco de freno delantero ventilado Nissan Versa', 5, 'B-02-01', null],
  [13, 'LM-500', 'Raybestos', 2, 'Líquido de frenos DOT 4, 500 ml', 23, 'B-03-02', null],
  [14, 'LZKAR6AP-11', 'NGK', 3, 'Bujía iridio Nissan Versa / March 1.6L', 32, 'C-01-01', 4],
  [15, 'FR5KPP332S', 'Bosch', 3, 'Bujía platino doble Nissan 1.6L', 12, 'C-01-02', 4],
  [16, 'SK16PR-L11', 'Denso', 3, 'Bujía iridio Nissan Versa 1.6L', 0, 'C-01-03', 4],
  [17, 'UF-549', 'Standard', 3, 'Bobina de encendido Nissan Sentra 2.0L', 3, 'C-02-01', null],
  [18, 'KYB-341477', 'KYB', 4, 'Amortiguador delantero Honda Civic 2006-2011 (der.)', 2, 'D-01-01', 5],
  [19, 'MS-72417', 'Monroe', 4, 'Amortiguador delantero Honda Civic 2006-2011', 4, 'D-01-02', 5],
  [20, 'GB-33017', 'Gabriel', 4, 'Amortiguador delantero Civic 1.8L', 0, null, 5],
  [21, 'RT-1120', 'Syd', 4, 'Rótula inferior Chevrolet Chevy 1994-2012', 8, 'D-02-01', null],
  [22, 'CT1028', 'Contitech', 5, 'Banda de distribución VW Pointer / Gol 1.8L', 5, 'E-01-01', 6],
  [23, 'T-288', 'Gates', 5, 'Banda de distribución VW Gol 1.8L', 3, 'E-01-02', 6],
  [24, 'K015578XS', 'Gates', 5, 'Kit de distribución con tensor VW Pointer 1.8L', 1, 'E-01-03', null],
  [25, '6PK1070', 'Dayco', 5, 'Banda poly-V accesorios Nissan Tsuru', 10, 'E-02-01', null],
  [26, 'E2471M', 'Delphi', 6, 'Bomba de gasolina eléctrica Ford Focus 2.0L', 2, 'F-01-01', 7],
  [27, 'P76145M', 'Airtex', 6, 'Módulo de bomba de gasolina Ford Focus', 0, 'F-01-02', 7],
  [28, 'AL-1520', 'Bosch', 6, 'Alternador 90A Nissan Tsuru 1.6L', 1, 'F-02-01', null],
  [29, 'LTH-L-47', 'LTH', 6, 'Batería 12V 47 meses 600 CCA', 6, 'F-03-01', null],
  [30, 'H4-55', 'Philips', 6, 'Foco halógeno H4 60/55W', 18, 'F-04-02', null],
];

final _productos = [
  for (final p in _productosCrudos)
    {
      'id': p[0],
      'numero_parte': p[1],
      'marca': p[2],
      'categoria_id': p[3],
      'categoria': _categorias.firstWhere((c) => c['id'] == p[3])['nombre'],
      'descripcion': p[4],
      'existencia': p[5],
      'ubicacion': p[6],
      'grupo_id': p[7],
    }
];

// ---------------------------------------------------------------------------
// Servidor
// ---------------------------------------------------------------------------

/// token -> id de usuario. En memoria: al reiniciar el servidor hay que volver a iniciar sesión.
final _sesiones = <String, int>{};
const _duracionSesion = 8 * 60 * 60;

Future<void> main() async {
  final puerto = int.tryParse(Platform.environment['PORT'] ?? '') ?? 3000;
  // anyIPv4 para que también responda a un teléfono físico en la misma red.
  final servidor = await HttpServer.bind(InternetAddress.anyIPv4, puerto);
  stdout.writeln('API de prueba escuchando en http://localhost:$puerto/v1');
  stdout.writeln('Usuarios: empleado1 / Refconect2026!   admin / Admin2026!');

  await for (final req in servidor) {
    final inicio = DateTime.now();
    try {
      await _atender(req);
    } catch (e) {
      _error(req, 500, 'ERROR_INTERNO', 'Error inesperado: $e');
    }
    final ms = DateTime.now().difference(inicio).inMilliseconds;
    stdout.writeln('${req.method} ${req.uri} -> ${req.response.statusCode} (${ms}ms)');
  }
}

Future<void> _atender(HttpRequest req) async {
  final ruta = req.uri.path;
  final metodo = req.method;

  if (metodo == 'POST' && ruta == '/v1/auth/login') return _login(req);

  if (!ruta.startsWith('/v1/')) return _error(req, 404, 'NO_ENCONTRADO', 'Ruta no encontrada.');

  // Todo lo demás requiere sesión.
  final usuario = _usuarioDeToken(req.headers.value('authorization'));
  if (usuario == null) return _error(req, 401, 'NO_AUTORIZADO', 'Token inválido o vencido.');

  if (metodo != 'GET') return _error(req, 404, 'NO_ENCONTRADO', 'Ruta no encontrada.');

  if (ruta == '/v1/auth/me') return _json(req, {'usuario': _publico(usuario)});
  if (ruta == '/v1/categorias') return _json(req, {'datos': _categorias});
  if (ruta == '/v1/productos') return _buscar(req);

  final detalle = RegExp(r'^/v1/productos/(\d+)$').firstMatch(ruta);
  if (detalle != null) return _detalle(req, int.parse(detalle.group(1)!));

  _error(req, 404, 'NO_ENCONTRADO', 'Ruta no encontrada.');
}

Future<void> _login(HttpRequest req) async {
  Object? cuerpo;
  try {
    cuerpo = jsonDecode(await utf8.decodeStream(req));
  } on FormatException {
    cuerpo = null;
  }
  if (cuerpo is! Map || cuerpo['usuario'] is! String || cuerpo['password'] is! String) {
    return _error(req, 400, 'PETICION_INVALIDA', 'Se requieren usuario y password.');
  }
  final usuario = _usuarios.where(
    (u) => u['usuario'] == (cuerpo as Map)['usuario'].trim() && u['password'] == cuerpo['password'],
  );
  if (usuario.isEmpty) return _error(req, 401, 'CREDENCIALES_INVALIDAS', 'Usuario o contraseña incorrectos.');

  final token = _nuevoToken();
  _sesiones[token] = usuario.first['id'] as int;
  _json(req, {'token': token, 'tipo': 'Bearer', 'expira_en': _duracionSesion, 'usuario': _publico(usuario.first)});
}

void _buscar(HttpRequest req) {
  final p = req.uri.queryParameters;
  final pagina = int.tryParse(p['pagina'] ?? '1');
  final limite = int.tryParse(p['limite'] ?? '20');
  final categoriaId = p['categoria_id'] == null ? null : int.tryParse(p['categoria_id']!);
  if (pagina == null || pagina < 1 || limite == null || limite < 1 || limite > 100 ||
      (p['categoria_id'] != null && categoriaId == null)) {
    return _error(req, 400, 'PETICION_INVALIDA', 'Parámetros de búsqueda inválidos.');
  }

  final q = _normalizar(p['q'] ?? '');
  final palabras = q.split(' ').where((w) => w.isNotEmpty).toList();

  final coinciden = _productos.where((prod) {
    if (categoriaId != null && prod['categoria_id'] != categoriaId) return false;
    if (palabras.isEmpty) return true;
    final texto = _normalizar('${prod['numero_parte']} ${prod['marca']} ${prod['descripcion']} ${prod['categoria']}');
    // El número de parte también se compara sin guiones ni espacios ("GP321" encuentra "GP-321").
    final parte = _compacto(prod['numero_parte'] as String);
    return palabras.every((w) => texto.contains(w) || parte.contains(_compacto(w)));
  }).toList()
    // Primero lo que hay en existencia.
    ..sort((a, b) => (b['existencia'] as int).compareTo(a['existencia'] as int));

  final desde = min((pagina - 1) * limite, coinciden.length);
  final hasta = min(desde + limite, coinciden.length);

  _json(req, {
    'datos': [for (final prod in coinciden.sublist(desde, hasta)) _resumen(prod)],
    'pagina': pagina,
    'limite': limite,
    'total': coinciden.length,
  });
}

void _detalle(HttpRequest req, int id) {
  final encontrados = _productos.where((p) => p['id'] == id);
  if (encontrados.isEmpty) return _error(req, 404, 'NO_ENCONTRADO', 'La pieza $id no existe.');
  final prod = encontrados.first;
  final grupoId = prod['grupo_id'] as int?;
  final miembros = grupoId == null ? <Map<String, Object?>>[] : _productos.where((p) => p['grupo_id'] == grupoId).toList();
  final equivalentes = miembros.where((p) => p['id'] != id).toList()
    ..sort((a, b) => (b['existencia'] as int).compareTo(a['existencia'] as int));

  _json(req, {
    ..._resumen(prod)..remove('tiene_equivalentes'),
    'grupo': grupoId == null
        ? null
        : {
            'id': grupoId,
            'descripcion': _grupos[grupoId],
            'existencia_total': miembros.fold<int>(0, (s, p) => s + (p['existencia'] as int)),
          },
    'equivalentes': [
      for (final e in equivalentes)
        {
          'id': e['id'],
          'numero_parte': e['numero_parte'],
          'marca': e['marca'],
          'descripcion': e['descripcion'],
          'existencia': e['existencia'],
          'ubicacion': e['ubicacion'],
        }
    ],
  });
}

// ---------------------------------------------------------------------------
// Utilidades
// ---------------------------------------------------------------------------

Map<String, Object?> _resumen(Map<String, Object?> p) {
  final grupoId = p['grupo_id'];
  return {
    'id': p['id'],
    'numero_parte': p['numero_parte'],
    'marca': p['marca'],
    'categoria': p['categoria'],
    'descripcion': p['descripcion'],
    'existencia': p['existencia'],
    'ubicacion': p['ubicacion'],
    'tiene_equivalentes': grupoId != null && _productos.where((o) => o['grupo_id'] == grupoId).length > 1,
  };
}

Map<String, Object?> _publico(Map<String, Object> u) =>
    {'id': u['id'], 'nombre': u['nombre'], 'usuario': u['usuario'], 'rol': u['rol']};

Map<String, Object>? _usuarioDeToken(String? encabezado) {
  if (encabezado == null || !encabezado.startsWith('Bearer ')) return null;
  final id = _sesiones[encabezado.substring(7)];
  if (id == null) return null;
  return _usuarios.firstWhere((u) => u['id'] == id);
}

String _nuevoToken() {
  final r = Random.secure();
  return base64Url.encode(List.generate(24, (_) => r.nextInt(256))).replaceAll('=', '');
}

String _normalizar(String s) {
  const conAcento = 'áéíóúüñ';
  const sinAcento = 'aeiouun';
  final b = StringBuffer();
  for (final c in s.toLowerCase().split('')) {
    final i = conAcento.indexOf(c);
    b.write(i >= 0 ? sinAcento[i] : c);
  }
  return b.toString().trim();
}

String _compacto(String s) => _normalizar(s).replaceAll(RegExp(r'[^a-z0-9]'), '');

void _json(HttpRequest req, Object cuerpo, [int estado = 200]) {
  req.response
    ..statusCode = estado
    ..headers.contentType = ContentType.json
    ..add(utf8.encode(jsonEncode(cuerpo)))
    ..close();
}

void _error(HttpRequest req, int estado, String codigo, String mensaje) =>
    _json(req, {'error': {'codigo': codigo, 'mensaje': mensaje}}, estado);
