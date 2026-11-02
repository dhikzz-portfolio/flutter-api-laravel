import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/config/api_config.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/login_screen.dart';
import '../features/shell/app_shell.dart';
import 'theme.dart';

class FinKuApp extends StatefulWidget {
  const FinKuApp({super.key});

  @override
  State<FinKuApp> createState() => _FinKuAppState();
}

class _FinKuAppState extends State<FinKuApp> {
  late final AuthController _auth;

  @override
  void initState() {
    super.initState();
    _auth = AuthController(AuthRepository());
    _auth.bindApiClient();
    _bootstrap();
  }

  /// Base URL yang tersimpan harus dimuat sebelum token dipakai untuk
  /// memanggil /auth/me, sehingga urutannya: muat konfigurasi lalu sesi.
  Future<void> _bootstrap() async {
    await ApiConfig.loadCachedBaseUrl();
    if (!mounted) return;
    await _auth.bootstrap();
  }

  @override
  void dispose() {
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthController>.value(
      value: _auth,
      child: MaterialApp(
        title: 'Fin-Ku',
        debugShowCheckedModeBanner: false,
        theme: FinKuTheme.light,
        home: const RootSwitch(),
      ),
    );
  }
}

class RootSwitch extends StatelessWidget {
  const RootSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    switch (auth.status) {
      case SessionStatus.loading:
        return const SplashScreen();
      case SessionStatus.loggedOut:
      case SessionStatus.logging:
        return const LoginScreen();
      case SessionStatus.loggedIn:
        return const AppShell();
    }
  }
}

/// Splash kecil dengan branding FK sebelum sesi dipulihkan.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinKuColors.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: FinKuColors.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'FK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Fin-Ku',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          ],
        ),
      ),
    );
  }
}
