import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:refconect_app/core/api/api_client.dart';
import 'package:refconect_app/core/api/catalogo_repositorio.dart';
import 'package:refconect_app/providers/busqueda_provider.dart';

import 'fakes.dart';

Map<String, Object?> producto(int id, String np) => {
      'id': id,
      'numero_parte': np,
      'marca': 'Bosch',
      'categoria': 'Filtros',
      'descripcion': 'Filtro',
      'existencia': 1,
      'ubicacion': 'P1-A1',
      'tiene_equivalentes': false,
    };

void main() {
  test('una respuesta lenta no pisa a una más reciente', () async {
    final lenta = Completer<http.Response>();
    final cliente = MockClient((req) {
      final q = req.url.queryParameters['q'];
      final r = json({'datos': [producto(q == 'viejo' ? 1 : 2, q ?? '')], 'pagina': 1, 'limite': 20, 'total': 1});
      return q == 'viejo' ? lenta.future : Future.value(r);
    });
    final b = BusquedaProvider(CatalogoRepositorio(ApiClient(urlBase: 'http://prueba', cliente: cliente)),
        espera: Duration.zero);

    b.cambiarTexto('viejo');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    b.cambiarTexto('nuevo');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    lenta.complete(json({'datos': [producto(1, 'viejo')], 'pagina': 1, 'limite': 20, 'total': 1}));
    await Future<void>.delayed(const Duration(milliseconds: 5));

    expect(b.estado, EstadoBusqueda.listo);
    expect(b.resultados.single.numeroParte, 'nuevo');
  });

  test('error de conexión deja la lista vacía y permite reintentar', () async {
    var caida = true;
    final cliente = MockClient((req) async {
      if (caida) throw http.ClientException('Connection refused', req.url);
      if (req.url.path == '/v1/categorias') return json({'datos': [{'id': 1, 'nombre': 'Filtros'}]});
      return json({'datos': [producto(1, 'A')], 'pagina': 1, 'limite': 20, 'total': 1});
    });
    final b = BusquedaProvider(CatalogoRepositorio(ApiClient(urlBase: 'http://prueba', cliente: cliente)));
    await b.iniciar();
    expect(b.estado, EstadoBusqueda.error);
    expect(b.sinConexion, isTrue);
    expect(b.resultados, isEmpty);

    caida = false;
    await b.reintentar();
    expect(b.estado, EstadoBusqueda.inicio);
    expect(b.categorias, hasLength(1));

    await b.seleccionarCategoria(1);
    expect(b.estado, EstadoBusqueda.listo);
    expect(b.resultados, hasLength(1));
  });

  test('al iniciar solo pide categorías y muestra los bloques', () async {
    final rutas = <String>[];
    final cliente = MockClient((req) async {
      rutas.add(req.url.path);
      if (req.url.path == '/v1/categorias') return json({'datos': [{'id': 1, 'nombre': 'Frenos'}]});
      return json({'datos': [producto(1, 'A')], 'pagina': 1, 'limite': 20, 'total': 1});
    });
    final b = BusquedaProvider(CatalogoRepositorio(ApiClient(urlBase: 'http://prueba', cliente: cliente)));
    await b.iniciar();
    expect(rutas, ['/v1/categorias']);
    expect(b.estado, EstadoBusqueda.inicio);
    expect(b.enInicio, isTrue);

    await b.seleccionarCategoria(1);
    expect(b.categoriaNombre, 'Frenos');
    expect(b.resultados, hasLength(1));
    expect(rutas.last, '/v1/productos');

    await b.volverAlInicio();
    expect(b.estado, EstadoBusqueda.inicio);
    expect(b.resultados, isEmpty);
    expect(b.categoriaId, isNull);
  });

  test('scroll infinito agrega la siguiente página', () async {
    final cliente = MockClient((req) async {
      if (req.url.path == '/v1/categorias') return json({'datos': []});
      final pagina = int.parse(req.url.queryParameters['pagina']!);
      return json({
        'datos': [for (var i = 0; i < (pagina == 1 ? 20 : 5); i++) producto(pagina * 100 + i, 'P$pagina-$i')],
        'pagina': pagina,
        'limite': 20,
        'total': 25,
      });
    });
    final b = BusquedaProvider(CatalogoRepositorio(ApiClient(urlBase: 'http://prueba', cliente: cliente)));
    await b.iniciar();
    await b.seleccionarCategoria(1);
    expect(b.hayMas, isTrue);
    await b.cargarMas();
    expect(b.resultados, hasLength(25));
    expect(b.hayMas, isFalse);
  });
}
