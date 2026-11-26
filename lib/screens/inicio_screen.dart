import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/categoria.dart';
import '../models/producto_resumen.dart';
import '../providers/auth_provider.dart';
import '../providers/busqueda_provider.dart';
import '../widgets/estado_error.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/icono_categoria.dart';
import '../widgets/logo.dart';
import '../widgets/producto_card.dart';
import 'detalle_screen.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final _texto = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<BusquedaProvider>().iniciar());
  }

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _confirmarSalida() async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Tendrás que volver a ingresar tu usuario y contraseña.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(48, 48), padding: const EdgeInsets.symmetric(horizontal: 20)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (salir == true && mounted) await context.read<AuthProvider>().logout();
  }

  /// Regresa a los bloques: limpia el texto y el filtro.
  void _volverAlInicio() {
    _texto.clear();
    context.read<BusquedaProvider>().volverAlInicio();
  }

  @override
  Widget build(BuildContext context) {
    final nombre = context.select<AuthProvider, String>((a) => a.usuario?.nombre ?? '');
    final enInicio = context.select<BusquedaProvider, bool>((b) => b.enInicio);
    // Con un filtro o texto activo, "atrás" regresa a los bloques en lugar de cerrar la app.
    return PopScope(
      canPop: enInicio,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _volverAlInicio();
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: Medidas.anchoMaximo),
              // Búsqueda abajo: zona alcanzable con el pulgar al usar el celular con una mano.
              child: Column(
                children: [
                  _Encabezado(nombre: nombre, alSalir: _confirmarSalida),
                  AnimatedSwitcher(
                    duration: Movimiento.de(context, Movimiento.medio),
                    child: enInicio ? const SizedBox(width: double.infinity) : _BarraFiltro(alVolver: _volverAlInicio),
                  ),
                  const Expanded(child: _Resultados()),
                  _PanelBusqueda(texto: _texto),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.nombre, required this.alSalir});

  final String nombre;
  final VoidCallback alSalir;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final b = context.watch<BusquedaProvider>();
    final dondeBusca = b.categoriaNombre == null ? '' : ' en ${b.categoriaNombre}';
    final resumen = switch (b.estado) {
      EstadoBusqueda.inicio => 'Elige una categoría o busca abajo',
      EstadoBusqueda.listo when b.q.isEmpty => '${b.total} ${b.total == 1 ? 'pieza' : 'piezas'}$dondeBusca',
      EstadoBusqueda.listo =>
        '${b.total} ${b.total == 1 ? 'resultado' : 'resultados'} para «${b.q}»$dondeBusca',
      EstadoBusqueda.cargando => 'Buscando…',
      _ => 'Consulta de piezas',
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(Medidas.margen + 4, 12, 8, 8),
      child: Row(
        children: [
          const ExcludeSemantics(child: LogoMarca(tamano: 44)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hola, $nombre', maxLines: 1, overflow: TextOverflow.ellipsis, style: tema.headlineSmall),
                Semantics(
                  liveRegion: true,
                  child: Text(resumen,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tema.bodyMedium?.copyWith(color: AppColores.textoSecundario)),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            style: IconButton.styleFrom(backgroundColor: AppColores.superficieHundida),
            icon: const Icon(Icons.logout_rounded),
            onPressed: alSalir,
          ),
        ],
      ),
    );
  }
}

/// Con filtro o texto activo: botón para volver a los bloques y chips para cambiar de categoría.
class _BarraFiltro extends StatelessWidget {
  const _BarraFiltro({required this.alVolver});

  final VoidCallback alVolver;

  @override
  Widget build(BuildContext context) {
    final b = context.watch<BusquedaProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: Medidas.margen - 4),
          child: TextButton.icon(
            onPressed: alVolver,
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Inicio'),
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Medidas.margen),
            children: [
              _ChipCategoria(
                nombre: 'Todas',
                seleccionada: b.categoriaId == null,
                alTocar: () => b.seleccionarCategoria(null),
              ),
              for (final c in b.categorias)
                _ChipCategoria(
                  nombre: c.nombre,
                  icono: iconoDeCategoria(c.nombre),
                  seleccionada: b.categoriaId == c.id,
                  alTocar: () => b.seleccionarCategoria(c.id),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PanelBusqueda extends StatelessWidget {
  const _PanelBusqueda({required this.texto});

  final TextEditingController texto;

  @override
  Widget build(BuildContext context) {
    final busqueda = context.read<BusquedaProvider>();
    final categoria = context.select<BusquedaProvider, String?>((b) => b.categoriaNombre);
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColores.superficie,
          borderRadius: BorderRadius.circular(Medidas.radioGrande + 4),
          boxShadow: Sombras.flotante,
        ),
        child: ListenableBuilder(
          listenable: texto,
          builder: (context, _) => TextField(
            controller: texto,
            autocorrect: false,
            textInputAction: TextInputAction.search,
            onChanged: busqueda.cambiarTexto,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: categoria == null ? 'Número de parte, marca o descripción' : 'Buscar en $categoria',
              hintStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              prefixIcon: const Icon(Icons.search_rounded, size: 28, color: AppColores.tinta),
              suffixIcon: texto.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Borrar búsqueda',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        texto.clear();
                        busqueda.cambiarTexto('');
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipCategoria extends StatelessWidget {
  const _ChipCategoria({required this.nombre, required this.seleccionada, required this.alTocar, this.icono});

  final String nombre;
  final bool seleccionada;
  final VoidCallback alTocar;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    final color = seleccionada ? Colors.white : AppColores.tinta;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        avatar: icono == null ? null : Icon(icono, size: 18, color: color),
        label: Text(nombre),
        selected: seleccionada,
        onSelected: (_) => alTocar(),
        showCheckmark: false,
        selectedColor: AppColores.tinta,
        backgroundColor: AppColores.superficieHundida,
        shape: const StadiumBorder(),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        labelStyle: TextStyle(fontFamily: Fuentes.interfaz, fontSize: 16, fontWeight: FontWeight.w700, color: color),
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
    );
  }
}

class _Resultados extends StatelessWidget {
  const _Resultados();

  @override
  Widget build(BuildContext context) {
    final b = context.watch<BusquedaProvider>();
    return switch (b.estado) {
      EstadoBusqueda.inicio => b.categorias.isEmpty
          ? EstadoError(
              titulo: 'No hay categorías disponibles',
              mensaje: 'Puedes buscar abajo por número de parte, marca o descripción.',
              alReintentar: b.reintentar,
            )
          : _Bloques(categorias: b.categorias),
      EstadoBusqueda.cargando => const Center(child: CircularProgressIndicator(semanticsLabel: 'Buscando piezas')),
      EstadoBusqueda.error => EstadoError(
          titulo: b.sinConexion ? 'Sin conexión con el servidor' : 'No se pudo completar la consulta',
          mensaje: b.error ?? '',
          alReintentar: b.reintentar,
        ),
      EstadoBusqueda.vacio => b.q.isNotEmpty
          ? EstadoVacio(
              titulo: 'No encontramos piezas para «${b.q}»',
              detalle: b.categoriaNombre == null
                  ? 'Revisa el número de parte o busca por marca o descripción.'
                  : 'Buscamos solo en ${b.categoriaNombre}. Prueba con «Todas».',
            )
          : const EstadoVacio(titulo: 'No hay piezas en esta categoría'),
      EstadoBusqueda.listo => const _Lista(),
    };
  }
}

/// Pantalla de entrada: una tarjeta por categoría.
class _Bloques extends StatelessWidget {
  const _Bloques({required this.categorias});

  final List<Categoria> categorias;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(Medidas.margen + 4, 12, Medidas.margen, 8),
          sliver: SliverToBoxAdapter(child: Text('Categorías', style: tema.titleLarge)),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(Medidas.margen, 4, Medidas.margen, Medidas.margen),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 240,
              mainAxisExtent: 150,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: categorias.length,
            itemBuilder: (context, i) => _Bloque(categoria: categorias[i]),
          ),
        ),
      ],
    );
  }
}

class _Bloque extends StatelessWidget {
  const _Bloque({required this.categoria});

  final Categoria categoria;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    // El InkWell de la tarjeta ya expone el toque; el nombre es su etiqueta para lectores de pantalla.
    return TarjetaRC(
        alTocar: () => context.read<BusquedaProvider>().seleccionarCategoria(categoria.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColores.superficieHundida,
                    borderRadius: BorderRadius.circular(Medidas.radioChico + 2),
                  ),
                  child: Icon(iconoDeCategoria(categoria.nombre), size: 28, color: AppColores.primario),
                ),
                const Spacer(),
                const Icon(Icons.arrow_outward_rounded, size: 20, color: AppColores.textoSecundario),
              ],
            ),
            const Spacer(),
            Text(categoria.nombre, maxLines: 2, overflow: TextOverflow.ellipsis, style: tema.titleMedium),
          ],
        ),
    );
  }
}

class _Lista extends StatelessWidget {
  const _Lista();

  @override
  Widget build(BuildContext context) {
    final b = context.watch<BusquedaProvider>();
    return LayoutBuilder(
      builder: (context, restricciones) {
        // En tablet, dos columnas.
        final columnas = restricciones.maxWidth >= Medidas.anchoTablet ? 2 : 1;
        final filas = <List<ProductoResumen>>[
          for (var i = 0; i < b.resultados.length; i += columnas)
            b.resultados.sublist(i, (i + columnas).clamp(0, b.resultados.length)),
        ];
        return NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.extentAfter < 400) b.cargarMas();
            return false;
          },
          child: RefreshIndicator(
            onRefresh: b.reintentar,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(Medidas.margen, 8, Medidas.margen, Medidas.margen),
              itemCount: filas.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                if (i == filas.length) return _PieLista(cargando: b.cargandoMas, hayMas: b.hayMas);
                final fila = filas[i];
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var c = 0; c < columnas; c++) ...[
                        if (c > 0) const SizedBox(width: 12),
                        Expanded(
                          child: c < fila.length
                              ? ProductoCard(
                                  producto: fila[c],
                                  alTocar: () => Navigator.of(context).push(MaterialPageRoute<void>(
                                    builder: (_) => DetalleScreen(id: fila[c].id, numeroParte: fila[c].numeroParte),
                                  )),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _PieLista extends StatelessWidget {
  const _PieLista({required this.cargando, required this.hayMas});

  final bool cargando;
  final bool hayMas;

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator(semanticsLabel: 'Cargando más piezas')),
      );
    }
    if (hayMas) return const SizedBox(height: 48);
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: Text('Fin de los resultados', style: TextStyle(color: AppColores.textoSecundario))),
    );
  }
}
