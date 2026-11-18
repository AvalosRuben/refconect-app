import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/api/api_exception.dart';
import '../core/api/catalogo_repositorio.dart';
import '../models/categoria.dart';
import '../models/producto_resumen.dart';

enum EstadoBusqueda { cargando, listo, vacio, error }

class BusquedaProvider extends ChangeNotifier {
  BusquedaProvider(this._repositorio, {this.espera = const Duration(milliseconds: 400)});

  final CatalogoRepositorio _repositorio;

  /// Debounce de la búsqueda mientras se escribe.
  final Duration espera;
  static const _limite = 20;

  String _q = '';
  int? _categoriaId;
  List<Categoria> _categorias = [];
  final List<ProductoResumen> _resultados = [];
  int _pagina = 0;
  int _total = 0;
  bool _hayMas = false;
  bool _cargandoMas = false;
  EstadoBusqueda _estado = EstadoBusqueda.cargando;
  String? _error;
  bool _sinConexion = false;

  Timer? _temporizador;
  // Cada búsqueda nueva incrementa este número; las respuestas de búsquedas anteriores se descartan.
  int _consulta = 0;
  bool _desechado = false;

  String get q => _q;
  int? get categoriaId => _categoriaId;
  List<Categoria> get categorias => List.unmodifiable(_categorias);
  List<ProductoResumen> get resultados => List.unmodifiable(_resultados);
  int get total => _total;
  bool get hayMas => _hayMas;
  bool get cargandoMas => _cargandoMas;
  EstadoBusqueda get estado => _estado;
  String? get error => _error;
  bool get sinConexion => _sinConexion;

  Future<void> iniciar() async {
    await Future.wait([_cargarCategorias(), _buscar()]);
  }

  void cambiarTexto(String texto) {
    _temporizador?.cancel();
    if (texto.trim() == _q) return;
    _temporizador = Timer(espera, () {
      _q = texto.trim();
      _buscar();
    });
  }

  void seleccionarCategoria(int? id) {
    if (id == _categoriaId) return;
    _categoriaId = id;
    _buscar();
  }

  Future<void> reintentar() async {
    await Future.wait([if (_categorias.isEmpty) _cargarCategorias(), _buscar()]);
  }

  /// Scroll infinito: pide la siguiente página si la hay.
  Future<void> cargarMas() async {
    if (!_hayMas || _cargandoMas || _estado != EstadoBusqueda.listo) return;
    final consulta = _consulta;
    _cargandoMas = true;
    _notificar();
    try {
      final r = await _repositorio.buscar(q: _q, categoriaId: _categoriaId, pagina: _pagina + 1, limite: _limite);
      if (consulta != _consulta) return;
      _resultados.addAll(r.datos);
      _pagina = r.pagina;
      _total = r.total;
      _hayMas = r.hayMas;
    } on ApiException catch (e) {
      if (consulta != _consulta) return;
      _ponerError(e);
    } finally {
      if (consulta == _consulta) {
        _cargandoMas = false;
        _notificar();
      }
    }
  }

  Future<void> _buscar() async {
    final consulta = ++_consulta;
    _estado = EstadoBusqueda.cargando;
    _cargandoMas = false;
    _resultados.clear();
    _notificar();
    try {
      final r = await _repositorio.buscar(q: _q, categoriaId: _categoriaId, limite: _limite);
      if (consulta != _consulta) return; // llegó tarde: ya hay una búsqueda más reciente
      _resultados.addAll(r.datos);
      _pagina = r.pagina;
      _total = r.total;
      _hayMas = r.hayMas;
      _estado = r.datos.isEmpty ? EstadoBusqueda.vacio : EstadoBusqueda.listo;
    } on ApiException catch (e) {
      if (consulta != _consulta) return;
      _ponerError(e);
    }
    _notificar();
  }

  Future<void> _cargarCategorias() async {
    try {
      _categorias = await _repositorio.categorias();
      _notificar();
    } on ApiException {
      // El error de conexión ya lo muestra la búsqueda; las categorías se reintentan con "Reintentar".
    }
  }

  // Nunca se muestran resultados viejos junto con un error.
  void _ponerError(ApiException e) {
    _resultados.clear();
    _hayMas = false;
    _total = 0;
    _estado = EstadoBusqueda.error;
    _sinConexion = e.tipo == TipoErrorApi.sinConexion;
    _error = e.tipo == TipoErrorApi.sinConexion
        ? '${e.mensaje}\nVerifica que la API esté encendida y en la misma red.'
        : e.mensaje;
  }

  void _notificar() {
    if (!_desechado) notifyListeners();
  }

  @override
  void dispose() {
    _desechado = true;
    _temporizador?.cancel();
    super.dispose();
  }
}
