import 'package:flutter_test/flutter_test.dart';
import 'package:refconect_app/models/categoria.dart';
import 'package:refconect_app/models/paginado.dart';
import 'package:refconect_app/models/producto_detalle.dart';
import 'package:refconect_app/models/producto_resumen.dart';
import 'package:refconect_app/models/usuario.dart';

void main() {
  test('Usuario y Categoria desde JSON', () {
    final u = Usuario.fromJson({'id': 1, 'nombre': 'Juan Pérez', 'usuario': 'empleado1', 'rol': 'empleado'});
    expect(u.nombre, 'Juan Pérez');
    expect(Categoria.fromJson({'id': 3, 'nombre': 'Filtros'}).nombre, 'Filtros');
  });

  test('Paginado de ProductoResumen con ubicación nula y hayMas', () {
    final p = Paginado.fromJson({
      'datos': [
        {
          'id': 9,
          'numero_parte': 'W 712/75',
          'marca': 'Mann-Filter',
          'categoria': 'Filtros',
          'descripcion': 'Filtro de aceite',
          'existencia': 0,
          'ubicacion': null,
          'tiene_equivalentes': true,
        }
      ],
      'pagina': 1,
      'limite': 20,
      'total': 42,
    }, ProductoResumen.fromJson);
    expect(p.datos.single.numeroParte, 'W 712/75');
    expect(p.datos.single.ubicacion, isNull);
    expect(p.datos.single.tieneEquivalentes, isTrue);
    expect(p.hayMas, isTrue);
    expect(Paginado(datos: const [], pagina: 3, limite: 20, total: 42).hayMas, isFalse);
  });

  test('ProductoDetalle con grupo y equivalentes, y sin grupo', () {
    final d = ProductoDetalle.fromJson({
      'id': 9,
      'numero_parte': 'W 712/75',
      'numero_parte_norm': 'W71275',
      'marca': 'Mann-Filter',
      'categoria': 'Filtros',
      'descripcion': 'Filtro de aceite',
      'existencia': 0,
      'ubicacion': 'P1-A3',
      'imagen_url': '/v1/imagenes/w712-75-mann.jpg',
      'grupo': {'id': 1, 'descripcion': 'Filtro de aceite 1.6L', 'existencia_total': 17},
      'equivalentes': [
        {'id': 14, 'numero_parte': 'F 026 407 157', 'marca': 'Bosch', 'descripcion': 'Filtro de aceite', 'existencia': 12, 'ubicacion': 'P1-A4'},
        {'id': 1, 'numero_parte': 'PH 5796', 'marca': 'Fram', 'descripcion': 'Filtro de aceite', 'existencia': 5, 'ubicacion': 'P2-B1'},
      ],
    });
    expect(d.imagenUrl, '/v1/imagenes/w712-75-mann.jpg');
    expect(d.grupo!.existenciaTotal, 17);
    expect(d.equivalentes.map((e) => e.marca), ['Bosch', 'Fram']);

    final sinGrupo = ProductoDetalle.fromJson({
      'id': 37,
      'numero_parte': 'T-295',
      'numero_parte_norm': 'T295',
      'marca': 'Gates',
      'categoria': 'Correas y bandas',
      'descripcion': 'Banda de distribución',
      'existencia': 1,
      'ubicacion': 'P6-B2',
      'grupo': null,
      'equivalentes': <Object>[],
    });
    expect(sinGrupo.imagenUrl, isNull);
    expect(sinGrupo.grupo, isNull);
    expect(sinGrupo.equivalentes, isEmpty);
  });
}
