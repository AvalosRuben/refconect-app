import '../../models/categoria.dart';
import '../../models/paginado.dart';
import '../../models/producto_detalle.dart';
import '../../models/producto_resumen.dart';
import 'api_client.dart';

/// Consultas de solo lectura al catálogo.
class CatalogoRepositorio {
  CatalogoRepositorio(this._api);
  final ApiClient _api;

  Future<List<Categoria>> categorias() async {
    final json = await _api.get('/categorias');
    return (json['datos'] as List).map((e) => Categoria.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Paginado<ProductoResumen>> buscar({String q = '', int? categoriaId, int pagina = 1, int limite = 20}) async {
    final json = await _api.get('/productos', query: {
      if (q.trim().isNotEmpty) 'q': q.trim(),
      if (categoriaId != null) 'categoria_id': '$categoriaId',
      'pagina': '$pagina',
      'limite': '$limite',
    });
    return Paginado.fromJson(json, ProductoResumen.fromJson);
  }

  /// URL y encabezados para mostrar la foto de una pieza.
  String urlImagen(String ruta) => _api.recurso(ruta).toString();
  Map<String, String> get encabezadosImagen => _api.encabezadosArchivo;

  Future<ProductoDetalle> detalle(int id) async => ProductoDetalle.fromJson(await _api.get('/productos/$id'));
}
