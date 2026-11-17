import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/errors/api_exception.dart';
import '../../core/utils/format.dart';
import 'auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  String _generalError = '';
  String _fieldError = '';
  bool _submitting = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthController>();

    setState(() {
      _submitting = true;
      _generalError = '';
      _fieldError = '';
    });

    try {
      await auth.login(_username.text.trim(), _password.text);
      if (mounted && auth.isAuthenticated) {
        context.read<AuthController>().clearFlash();
      }
    } on ApiException catch (e) {
      setState(() {
        _generalError = e.statusCode == 422 && e.fieldErrors.isEmpty
            ? e.message
            : (e.statusCode != 422 ? e.message : '');
        _fieldError = e.fieldError('username') +
            (e.fieldError('password').isEmpty
                ? ''
                : ' · ${e.fieldError('password')}');
        // Kombinasi pesan kecil di atas tombol.
        if (_generalError.isEmpty && _fieldError.isEmpty) _generalError = e.message;
      });
    } catch (e) {
      setState(() {
        _generalError = 'Terjadi kesalahan: $e';
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: FinKuColors.bg,
      body: Stack(
        children: [
          const _LoginBackdrop(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: wide ? 40 : 20,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: wide ? 1000 : 420),
                  child: wide
                      ? IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Expanded(flex: 6, child: _BrandPanel()),
                              const SizedBox(width: 32),
                              Expanded(
                                flex: 5,
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 420,
                                    ),
                                    child: _LoginCard(
                                      formKey: _formKey,
                                      username: _username,
                                      password: _password,
                                      obscure: _obscure,
                                      submitting: _submitting,
                                      generalError: _generalError,
                                      fieldError: _fieldError,
                                      onToggleObscure: () => setState(
                                        () => _obscure = !_obscure,
                                      ),
                                      onSubmit: _submit,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const _MobileBrand(),
                            const SizedBox(height: 26),
                            _LoginCard(
                              formKey: _formKey,
                              username: _username,
                              password: _password,
                              obscure: _obscure,
                              submitting: _submitting,
                              generalError: _generalError,
                              fieldError: _fieldError,
                              onToggleObscure: () =>
                                  setState(() => _obscure = !_obscure),
                              onSubmit: _submit,
                            ),
                            const SizedBox(height: 22),
                            const _Copyright(),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Latar lembut dengan dua sorotan indigo, menjaga halaman tetap terasa
/// seperti aplikasi web Fin-Ku tanpa mengganggu keterbacaan formulir.
class _LoginBackdrop extends StatelessWidget {
  const _LoginBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -140,
              right: -100,
              child: _Glow(
                size: 380,
                color: FinKuColors.primary.withValues(alpha: 0.10),
              ),
            ),
            Positioned(
              bottom: -160,
              left: -120,
              child: _Glow(
                size: 420,
                color: FinKuColors.info.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF111827), Color(0xFF1E1B4B)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29111827),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: FinKuColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: FinKuColors.primary.withValues(alpha: 0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'FK',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Fin-Ku',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            'Keuangan usaha,\nlebih rapi dan terukur.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              height: 1.2,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Pantau penjualan, stok, dan laba dalam satu dasbor '
            'yang ringkas — untuk kasir, admin, dan owner.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.68),
              fontSize: 13.5,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 28),
          const _FeatureRow(
            icon: Icons.insights_rounded,
            label: 'Laporan penjualan & laba otomatis',
          ),
          const SizedBox(height: 12),
          const _FeatureRow(
            icon: Icons.inventory_2_outlined,
            label: 'Kontrol stok dan riwayat pergerakan',
          ),
          const SizedBox(height: 12),
          const _FeatureRow(
            icon: Icons.shield_outlined,
            label: 'Akses terpisah sesuai peran pengguna',
          ),
          const Spacer(),
          Text(
            '© ${DateTime.now().year} Fin-Ku. All rights reserved.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.38),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFFC7D2FE)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _MobileBrand extends StatelessWidget {
  const _MobileBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: FinKuColors.primary,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: FinKuColors.primary.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Text(
            'FK',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Fin-Ku',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
            color: FinKuColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Sistem Informasi Keuangan',
          style: TextStyle(fontSize: 13, color: FinKuColors.textSecondary),
        ),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.username,
    required this.password,
    required this.obscure,
    required this.submitting,
    required this.generalError,
    required this.fieldError,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController username;
  final TextEditingController password;
  final bool obscure;
  final bool submitting;
  final String generalError;
  final String fieldError;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final hasError = generalError.isNotEmpty || fieldError.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FinKuColors.cardBorder),
        boxShadow: FinKuColors.cardShadow,
      ),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Masuk ke akun Anda',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: FinKuColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Gunakan akun yang sama seperti aplikasi web.',
              style: TextStyle(fontSize: 12.5, color: FinKuColors.textSecondary),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: username,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username],
              decoration: InputDecorationX.field(
                label: 'Username',
                hint: 'admin / kasir / owner',
              ).copyWith(
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 19),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Username wajib diisi.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: password,
              obscureText: obscure,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => onSubmit(),
              autofillHints: const [AutofillHints.password],
              decoration: InputDecorationX.field(
                label: 'Password',
                hint: '••••••••',
                // Toggle lihat kata sandi.
              ).copyWith(
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 19),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    size: 19,
                  ),
                  tooltip: obscure ? 'Lihat password' : 'Sembunyikan password',
                  onPressed: onToggleObscure,
                ),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Password wajib diisi.' : null,
            ),
            if (hasError) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: FinKuColors.dangerSoft,
                  border: Border.all(color: const Color(0xFFFECACA)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 17,
                      color: FinKuColors.danger,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        generalError + fieldError,
                        style: const TextStyle(
                          color: Color(0xFFB91C1C),
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 22),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: submitting ? null : onSubmit,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Masuk',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 13,
                  color: FinKuColors.textMuted,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    'Sesi aman terhubung ke server Fin-Ku.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: FinKuColors.textMuted,
                          fontSize: 11.5,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Copyright extends StatelessWidget {
  const _Copyright();

  @override
  Widget build(BuildContext context) {
    return Text(
      '© ${DateTime.now().year} Fin-Ku. All rights reserved.',
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 11, color: FinKuColors.textMuted),
    );
  }
}
