import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api/api_exception.dart';
import '../core/api/catalogo_repositorio.dart';
import '../core/theme/app_theme.dart';
import '../models/producto_detalle.dart';
import '../widgets/estado_error.dart';
import '../widgets/etiqueta.dart';
import '../widgets/existencia_chip.dart';

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
      appBar: AppBar(title: Text(widget.numeroParte)),
      body: SafeArea(top: false, child: cuerpo),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.detalle});

  final ProductoDetalle detalle;

  @override
  Widget build(BuildContext context) {
    final d = detalle;
    final tema = Theme.of(context).textTheme;
    final equivalenteConExistencia = d.equivalentes.any((e) => e.existencia > 0);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Medidas.anchoMaximo * 0.75),
        child: ListView(
          padding: const EdgeInsets.all(Medidas.margen),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(Medidas.margen),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.numeroParte,
                        style: tema.headlineMedium?.copyWith(color: AppColores.primario, fontWeight: FontWeight.w800)),
                    Text('${d.marca} · ${d.categoria}', style: tema.titleMedium),
                    Text(d.descripcion, style: tema.bodyLarge?.copyWith(color: AppColores.textoSecundario)),
                    const Divider(height: 32),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Existencia', style: tema.bodyMedium?.copyWith(color: AppColores.textoSecundario)),
                            Text('${d.existencia}',
                                style: tema.displayMedium?.copyWith(fontWeight: FontWeight.w800, height: 1.1)),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ExistenciaChip(existencia: d.existencia, grande: true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Etiqueta(icono: Icons.place_outlined, texto: 'Ubicación: ${d.ubicacion ?? 'sin asignar'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (d.grupo != null) ...[
              Container(
                padding: const EdgeInsets.all(Medidas.margen),
                decoration: BoxDecoration(
                  color: AppColores.primario,
                  borderRadius: BorderRadius.circular(Medidas.radio),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Existencia total del grupo',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                          Text(d.grupo!.descripcion, style: const TextStyle(color: Color(0xFFD5E2EF), fontSize: 16)),
                        ],
                      ),
                    ),
                    Text('${d.grupo!.existenciaTotal}',
                        style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              if (d.existencia == 0 && equivalenteConExistencia) ...[
                const SizedBox(height: 12),
                const Etiqueta(
                  icono: Icons.swap_horiz,
                  texto: 'Sin existencia: ofrece una equivalente',
                  color: AppColores.acentoOscuro,
                  fondo: AppColores.acentoTenue,
                ),
              ],
              const SizedBox(height: 20),
              Text('Equivalentes (${d.equivalentes.length})', style: tema.titleLarge),
              const SizedBox(height: 8),
              for (final (i, e) in d.equivalentes.indexed) ...[
                // La API las ordena por existencia: la primera con existencia es la destacada.
                _EquivalenteCard(equivalente: e, destacado: i == 0 && e.existencia > 0),
                const SizedBox(height: 12),
              ],
            ] else
              Text('Esta pieza no tiene equivalencias registradas.',
                  style: tema.bodyLarge?.copyWith(color: AppColores.textoSecundario)),
          ],
        ),
      ),
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
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: destacado
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Medidas.radio),
              side: const BorderSide(color: AppColores.acento, width: 3),
            )
          : null,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => DetalleScreen(id: e.id, numeroParte: e.numeroParte),
        )),
        child: Padding(
          padding: const EdgeInsets.all(Medidas.margen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (destacado) ...[
                const Etiqueta(
                  icono: Icons.star,
                  texto: 'Mayor existencia',
                  color: AppColores.acentoOscuro,
                  fondo: AppColores.acentoTenue,
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.numeroParte, style: tema.titleLarge?.copyWith(color: AppColores.primario)),
                        Text(e.marca, style: tema.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                        Text(e.descripcion, style: tema.bodyMedium?.copyWith(color: AppColores.textoSecundario)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColores.textoSecundario, semanticLabel: 'Ver detalle'),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ExistenciaChip(existencia: e.existencia),
                  if (e.ubicacion != null) Etiqueta(icono: Icons.place_outlined, texto: e.ubicacion!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
