import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'core/api/auth_repositorio.dart';
import 'core/api/catalogo_repositorio.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/busqueda_provider.dart';
import 'screens/inicio_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

class RefConectApp extends StatefulWidget {
  const RefConectApp({super.key, required this.api, required this.almacen});

  final ApiClient api;
  final TokenStorage almacen;

  @override
  State<RefConectApp> createState() => _RefConectAppState();
}

class _RefConectAppState extends State<RefConectApp> {
  final _navegador = GlobalKey<NavigatorState>();
  late final AuthProvider _auth;
  late final CatalogoRepositorio _catalogo;

  @override
  void initState() {
    super.initState();
    _catalogo = CatalogoRepositorio(widget.api);
    _auth = AuthProvider(api: widget.api, repositorio: AuthRepositorio(widget.api), almacen: widget.almacen)
      ..addListener(_alCambiarSesion)
      ..restaurarSesion();
  }

  // Al cerrar o vencer la sesión se quitan las pantallas abiertas encima (ej. un detalle).
  void _alCambiarSesion() {
    if (_auth.estado != EstadoSesion.conSesion) _navegador.currentState?.popUntil((r) => r.isFirst);
  }

  @override
  void dispose() {
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _auth),
        Provider.value(value: _catalogo),
      ],
      child: MaterialApp(
        navigatorKey: _navegador,
        title: 'RefConect',
        debugShowCheckedModeBanner: false,
        theme: construirTema(),
        // La raíz cambia según la sesión: al iniciar sesión, el login se reemplaza y "atrás" no regresa a él.
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) => switch (auth.estado) {
            EstadoSesion.verificando => const SplashScreen(),
            EstadoSesion.sinSesion => const LoginScreen(),
            EstadoSesion.conSesion => ChangeNotifierProvider(
                key: ValueKey(auth.usuario?.id),
                create: (_) => BusquedaProvider(_catalogo),
                child: const InicioScreen(),
              ),
          },
        ),
      ),
    );
  }
}
