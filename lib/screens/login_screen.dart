import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formulario = GlobalKey<FormState>();
  final _usuario = TextEditingController();
  final _password = TextEditingController();
  bool _ocultar = true;

  @override
  void dispose() {
    _usuario.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    FocusScope.of(context).unfocus();
    if (!_formulario.currentState!.validate()) return;
    // Si sale bien, app.dart cambia a la pantalla de inicio (reemplaza la ruta).
    await context.read<AuthProvider>().login(_usuario.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final tema = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: Medidas.anchoFormulario),
              child: Form(
                key: _formulario,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Logo(),
                    const SizedBox(height: 36),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColores.superficie,
                        borderRadius: BorderRadius.circular(Medidas.radioGrande),
                        boxShadow: Sombras.flotante,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(Medidas.margenGrande),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Inicia sesión', style: tema.headlineSmall),
                            const SizedBox(height: 4),
                            Text('Consulta existencias y equivalencias desde el mostrador.',
                                style: tema.bodyMedium?.copyWith(color: AppColores.textoSecundario)),
                            const SizedBox(height: 24),
                            if (auth.aviso != null) ...[
                              _Mensaje(texto: auth.aviso!, icono: Icons.info_outline, color: AppColores.advertencia),
                              const SizedBox(height: 16),
                            ],
                            TextFormField(
                              controller: _usuario,
                              enabled: !auth.cargando,
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
                              style: const TextStyle(fontSize: 18),
                              decoration: const InputDecoration(labelText: 'Usuario', prefixIcon: Icon(Icons.person_outline)),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu usuario.' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _password,
                              enabled: !auth.cargando,
                              obscureText: _ocultar,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _enviar(),
                              style: const TextStyle(fontSize: 18),
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip: _ocultar ? 'Mostrar contraseña' : 'Ocultar contraseña',
                                  icon: Icon(_ocultar ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                  onPressed: () => setState(() => _ocultar = !_ocultar),
                                ),
                              ),
                              validator: (v) => (v == null || v.isEmpty) ? 'Ingresa tu contraseña.' : null,
                            ),
                            if (auth.error != null) ...[
                              const SizedBox(height: 16),
                              _Mensaje(texto: auth.error!, icono: Icons.error_outline, color: AppColores.error),
                            ],
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: auth.cargando ? null : _enviar,
                              child: auth.cargando
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 3, color: Colors.white, semanticsLabel: 'Iniciando sesión'),
                                    )
                                  : const Text('Iniciar sesión'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Servidor: ${auth.urlBase}',
                        textAlign: TextAlign.center,
                        style: tema.bodySmall?.copyWith(color: AppColores.textoSecundario)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Mensaje extends StatelessWidget {
  const _Mensaje({required this.texto, required this.icono, required this.color});

  final String texto;
  final IconData icono;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(Medidas.radioChico),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, color: color),
            const SizedBox(width: 8),
            Expanded(child: Text(texto, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }
}
