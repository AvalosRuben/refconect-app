import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/api/api_exception.dart';
import '../core/api/catalogo_repositorio.dart';
import '../core/theme/app_theme.dart';
import '../models/producto_detalle.dart';
import '../widgets/estado_error.dart';
import '../widgets/etiqueta.dart';
import '../widgets/existencia_chip.dart';
import '../widgets/foto_pieza.dart';

/// Detalle de la pieza con existencia, ubicación, total del grupo y equivalentes.
class DetalleScreen extends StatefulWidget {
  const DetalleScreen({super.key, required this.id, required this.numeroParte});

  final int id;
  final String numeroParte;

  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  ProductoDetalle? _detalle;
  ApiException? _error;
  /// El número de parte aparece en la barra solo cuando la cabecera ya salió de la vista.
  bool _tituloVisible = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _detalle = null;
      _error = null;
    });
    try {
      final d = await context.read<CatalogoRepositorio>().detalle(widget.id);
      if (mounted) setState(() => _detalle = d);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  /// Desplazamiento a partir del cual el número de parte de la cabecera ya no se ve (foto 4:3 + textos).
  double _umbralTitulo(BuildContext context) {
    final ancho = math.min(MediaQuery.sizeOf(context).width, _Contenido._anchoContenido) - 40;
    return ancho * 3 / 4 + 70;
  }

  @override
  Widget build(BuildContext context) {
    final Widget cuerpo;
    if (_error != null) {
      cuerpo = EstadoError(
        titulo: _error!.tipo == TipoErrorApi.sinConexion ? 'Sin conexión con el servidor' : 'No se pudo cargar la pieza',
        mensaje: _error!.mensaje,
        alReintentar: _cargar,
      );
    } else if (_detalle == null) {
      cuerpo = const Center(child: CircularProgressIndicator(semanticsLabel: 'Cargando detalle'));
    } else {
      cuerpo = _Contenido(detalle: _detalle!);
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColores.tinta,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: ExcludeSemantics(
          excluding: !_tituloVisible,
          child: AnimatedOpacity(
            opacity: _tituloVisible ? 1 : 0,
            duration: Movimiento.de(context, Movimiento.corto),
            child: Text(widget.numeroParte, style: Fuentes.numeroParte(tamano: 18, color: Colors.white)),
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.depth == 0 && n.metrics.axis == Axis.vertical) {
            final visible = n.metrics.pixels > _umbralTitulo(context);
            if (visible != _tituloVisible) setState(() => _tituloVisible = visible);
          }
          return false;
        },
        child: SafeArea(top: false, child: cuerpo),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.detalle});

  final ProductoDetalle detalle;

  static const _anchoContenido = Medidas.anchoMaximo * 0.75;

  @override
  Widget build(BuildContext context) {
    final d = detalle;
    final tema = Theme.of(context).textTheme;
    final equivalenteConExistencia = d.equivalentes.any((e) => e.existencia > 0);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _Cabecera(detalle: d),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _anchoContenido),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Medidas.margen, 20, Medidas.margen, Medidas.margenGrande),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (d.grupo != null) ...[
                    TarjetaRC(
                      child: Row(
                        children: [
                          const IconoCirculo(icono: Icons.hub_outlined),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Existencia total del grupo', style: tema.titleMedium),
                                Text(d.grupo!.descripcion,
                                    style: tema.bodyMedium?.copyWith(color: AppColores.textoSecundario)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${d.grupo!.existenciaTotal}',
                              style: tema.headlineMedium?.copyWith(fontSize: 34, color: AppColores.primario)),
                        ],
                      ),
                    ),
                    if (d.existencia == 0 && equivalenteConExistencia) ...[
                      const SizedBox(height: 12),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Etiqueta(
                          icono: Icons.swap_horiz,
                          texto: 'Sin existencia: ofrece una equivalente',
                          color: AppColores.acentoOscuro,
                          fondo: AppColores.acentoTenue,
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Text('Equivalentes', style: tema.titleLarge),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColores.superficieHundida,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text('${d.equivalentes.length}',
                              style: tema.labelLarge?.copyWith(color: AppColores.textoSecundario)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (final (i, e) in d.equivalentes.indexed) ...[
                      // La API las ordena por existencia: la primera con existencia es la destacada.
                      _EquivalenteCard(equivalente: e, destacado: i == 0 && e.existencia > 0),
                      const SizedBox(height: 12),
                    ],
                  ] else
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const IconoCirculo(icono: Icons.link_off, color: AppColores.textoSecundario),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text('Esta pieza no tiene equivalencias registradas.',
                                style: tema.bodyLarge?.copyWith(color: AppColores.textoSecundario)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Cabecera oscura: foto, identidad de la pieza y su existencia.
class _Cabecera extends StatelessWidget {
  const _Cabecera({required this.detalle});

  final ProductoDetalle detalle;

  @override
  Widget build(BuildContext context) {
    final d = detalle;
    final tema = Theme.of(context).textTheme;
    return Container(
      decoration: const BoxDecoration(
        color: AppColores.tinta,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(Medidas.radioGrande + 4)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _Contenido._anchoContenido),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Medidas.margen + 4, 4, Medidas.margen + 4, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FotoPieza(
                  idPieza: d.id,
                  numeroParte: d.numeroParte,
                  categoria: d.categoria,
                  imagenUrl: d.imagenUrl,
                ),
                const SizedBox(height: 20),
                Text('${d.marca} · ${d.categoria}'.toUpperCase(),
                    style: tema.labelLarge?.copyWith(
                        color: AppColores.textoSobreTinta, letterSpacing: 1.2, fontSize: 14)),
                const SizedBox(height: 6),
                Text(d.numeroParte, style: Fuentes.numeroParte(tamano: 30, color: Colors.white)),
                const SizedBox(height: 6),
                Text(d.descripcion, style: tema.bodyLarge?.copyWith(color: AppColores.textoSobreTinta)),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ExistenciaChip(existencia: d.existencia, grande: true),
                    Etiqueta(
                      icono: Icons.place_outlined,
                      texto: 'Ubicación: ${d.ubicacion ?? 'sin asignar'}',
                      color: Colors.white,
                      fondo: AppColores.tintaSuave,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ícono en un círculo tenue, para filas informativas.
class IconoCirculo extends StatelessWidget {
  const IconoCirculo({super.key, required this.icono, this.color = AppColores.primario});

  final IconData icono;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(color: AppColores.superficieHundida, shape: BoxShape.circle),
      child: Icon(icono, color: color),
    );
  }
}

class _EquivalenteCard extends StatelessWidget {
  const _EquivalenteCard({required this.equivalente, required this.destacado});

  final Equivalente equivalente;
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    final e = equivalente;
    final tema = Theme.of(context).textTheme;
    return TarjetaRC(
      borde: destacado ? const BorderSide(color: AppColores.acento, width: 2) : null,
      padding: EdgeInsets.zero,
      alTocar: () => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => DetalleScreen(id: e.id, numeroParte: e.numeroParte),
      )),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExcludeSemantics(child: Container(width: 5, color: ExistenciaChip.colorDe(e.existencia))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (destacado) ...[
                      const Etiqueta(
                        icono: Icons.star_rounded,
                        texto: 'Mayor existencia',
                        color: AppColores.acentoOscuro,
                        fondo: AppColores.acentoTenue,
                      ),
                      const SizedBox(height: 10),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(e.numeroParte, style: Fuentes.numeroParte())),
                        const SizedBox(width: 8),
                        ExistenciaChip(existencia: e.existencia),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(e.marca,
                        style: tema.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColores.primario)),
                    const SizedBox(height: 2),
                    Text(e.descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: tema.bodyMedium?.copyWith(color: AppColores.textoSecundario)),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: e.ubicacion == null
                              ? const SizedBox.shrink()
                              : Align(
                                  alignment: Alignment.centerLeft,
                                  child: Etiqueta(icono: Icons.place_outlined, texto: e.ubicacion!),
                                ),
                        ),
                        const Icon(Icons.arrow_forward, size: 22, color: AppColores.textoSecundario,
                            semanticLabel: 'Ver detalle'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
