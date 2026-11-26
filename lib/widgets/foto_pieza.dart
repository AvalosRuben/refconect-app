import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/api/catalogo_repositorio.dart';
import '../core/theme/app_theme.dart';
import 'icono_categoria.dart';

/// Foto 4:3 de la pieza. Sin foto (o si falla la descarga) muestra el ícono de su categoría.
/// Al tocarla se abre a pantalla completa con zoom.
class FotoPieza extends StatelessWidget {
  const FotoPieza({
    super.key,
    required this.idPieza,
    required this.numeroParte,
    required this.categoria,
    required this.imagenUrl,
  });

  final int idPieza;
  final String numeroParte;
  final String categoria;
  final String? imagenUrl;

  @override
  Widget build(BuildContext context) {
    final url = imagenUrl;
    final radio = BorderRadius.circular(Medidas.radio + 4);
    if (url == null) {
      return AspectRatio(
        aspectRatio: 4 / 3,
        child: ClipRRect(borderRadius: radio, child: _SinFoto(categoria: categoria, texto: 'Sin foto')),
      );
    }
    final repo = context.read<CatalogoRepositorio>();
    final direccion = repo.urlImagen(url);
    final encabezados = repo.encabezadosImagen;
    final etiqueta = 'Hero-foto-$idPieza';
    return Semantics(
      button: true,
      label: 'Foto de $numeroParte. Toca para ampliar',
      excludeSemantics: true,
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: ClipRRect(
          borderRadius: radio,
          child: Material(
            color: Colors.white,
            child: InkWell(
              onTap: () => Navigator.of(context).push(PageRouteBuilder<void>(
                opaque: false,
                barrierColor: Colors.black,
                pageBuilder: (_, _, _) => _FotoAmpliada(
                  url: direccion,
                  encabezados: encabezados,
                  etiqueta: etiqueta,
                  numeroParte: numeroParte,
                ),
                transitionsBuilder: (_, animacion, _, hijo) => FadeTransition(opacity: animacion, child: hijo),
              )),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: etiqueta,
                    child: Image.network(
                      direccion,
                      headers: encabezados,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, hijo, progreso) => progreso == null
                          ? hijo
                          : const Center(child: CircularProgressIndicator(semanticsLabel: 'Cargando foto')),
                      errorBuilder: (_, _, _) =>
                          _SinFoto(categoria: categoria, texto: 'No se pudo cargar la foto'),
                    ),
                  ),
                  const Positioned(
                    right: 10,
                    bottom: 10,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Color(0x990F1B2D), shape: BoxShape.circle),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.zoom_out_map_rounded, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SinFoto extends StatelessWidget {
  const _SinFoto({required this.categoria, required this.texto});

  final String categoria;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColores.tintaSuave,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(iconoDeCategoria(categoria), size: 56, color: AppColores.textoSobreTinta),
          const SizedBox(height: 10),
          Text(texto, style: const TextStyle(color: AppColores.textoSobreTinta, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Foto a pantalla completa: zoom con dos dedos y botón para cerrar.
class _FotoAmpliada extends StatelessWidget {
  const _FotoAmpliada({
    required this.url,
    required this.encabezados,
    required this.etiqueta,
    required this.numeroParte,
  });

  final String url;
  final Map<String, String> encabezados;
  final String etiqueta;
  final String numeroParte;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        automaticallyImplyLeading: false,
        title: Text(numeroParte, style: Fuentes.numeroParte(tamano: 18, color: Colors.white)),
        actions: [
          IconButton(
            tooltip: 'Cerrar',
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: InteractiveViewer(
        minScale: 1,
        maxScale: 5,
        child: Center(
          child: Hero(
            tag: etiqueta,
            child: Image.network(
              url,
              headers: encabezados,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Text('No se pudo cargar la foto',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ),
      ),
    );
  }
}
