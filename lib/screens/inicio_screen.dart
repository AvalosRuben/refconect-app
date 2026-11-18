import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/producto_resumen.dart';
import '../providers/auth_provider.dart';
import '../providers/busqueda_provider.dart';
import '../widgets/estado_error.dart';
import '../widgets/estado_vacio.dart';
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
            style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (salir == true && mounted) await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final nombre = context.select<AuthProvider, String>((a) => a.usuario?.nombre ?? '');
    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, $nombre'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: _confirmarSalida,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Medidas.anchoMaximo),
            // Búsqueda y filtros abajo: zona alcanzable con el pulgar al usar el celular con una mano.
            child: Column(
              children: [
                const Expanded(child: _Resultados()),
                _PanelBusqueda(texto: _texto),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PanelBusqueda extends StatelessWidget {
  const _PanelBusqueda({required this.texto});

  final TextEditingController texto;

  @override
  Widget build(BuildContext context) {
    final busqueda = context.watch<BusquedaProvider>();
    return Material(
      color: Colors.white,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, Medidas.margen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Medidas.margen),
                children: [
                  _ChipCategoria(
                    nombre: 'Todas',
                    seleccionada: busqueda.categoriaId == null,
                    alTocar: () => busqueda.seleccionarCategoria(null),
                  ),
                  for (final c in busqueda.categorias)
                    _ChipCategoria(
                      nombre: c.nombre,
                      seleccionada: busqueda.categoriaId == c.id,
                      alTocar: () => busqueda.seleccionarCategoria(c.id),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Medidas.margen),
              child: ListenableBuilder(
                listenable: texto,
                builder: (context, _) => TextField(
                  controller: texto,
                  autofocus: true,
                  autocorrect: false,
                  textInputAction: TextInputAction.search,
                  onChanged: busqueda.cambiarTexto,
                  style: const TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    hintText: 'Número de parte, marca o descripción',
                    hintStyle: const TextStyle(fontSize: 18),
                    prefixIcon: const Icon(Icons.search, size: 28),
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
          ],
        ),
      ),
    );
  }
}

class _ChipCategoria extends StatelessWidget {
  const _ChipCategoria({required this.nombre, required this.seleccionada, required this.alTocar});

  final String nombre;
  final bool seleccionada;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(nombre),
        selected: seleccionada,
        onSelected: (_) => alTocar(),
        selectedColor: AppColores.primario,
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: seleccionada ? Colors.white : AppColores.primario,
        ),
        checkmarkColor: Colors.white,
        backgroundColor: Colors.white,
        side: const BorderSide(color: AppColores.primario),
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
      EstadoBusqueda.cargando => const Center(child: CircularProgressIndicator(semanticsLabel: 'Buscando piezas')),
      EstadoBusqueda.error => EstadoError(
          titulo: b.sinConexion ? 'Sin conexión con el servidor' : 'No se pudo completar la consulta',
          mensaje: b.error ?? '',
          alReintentar: b.reintentar,
        ),
      EstadoBusqueda.vacio => b.q.isNotEmpty
          ? EstadoVacio(
              titulo: 'No encontramos piezas para «${b.q}»',
              detalle: 'Revisa el número de parte o busca por marca o descripción.',
            )
          : const EstadoVacio(titulo: 'No hay piezas en esta categoría'),
      EstadoBusqueda.listo => const _Lista(),
    };
  }
}

class _Lista extends StatelessWidget {
  const _Lista();

  @override
  Widget build(BuildContext context) {
    final b = context.watch<BusquedaProvider>();
    final tema = Theme.of(context).textTheme;
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
              padding: const EdgeInsets.all(Medidas.margen),
              itemCount: filas.length + 2,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Text(
                    b.q.isEmpty
                        ? 'Catálogo: ${b.total} piezas. Escribe abajo un número de parte, marca o descripción.'
                        : '${b.total} ${b.total == 1 ? 'resultado' : 'resultados'} para «${b.q}»',
                    style: tema.bodyMedium?.copyWith(color: AppColores.textoSecundario),
                  );
                }
                if (i == filas.length + 1) return _PieLista(cargando: b.cargandoMas, hayMas: b.hayMas);
                final fila = filas[i - 1];
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
