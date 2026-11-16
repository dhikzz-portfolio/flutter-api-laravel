import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x334F46E5),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Text(
                        'FK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Fin-Ku',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF111827),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Masuk ke akun Anda', textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7280),
                    )),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _username,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.username],
                    decoration: InputDecorationX.field(
                      label: 'Username',
                      hint: 'admin / kasir / owner',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Username wajib diisi.' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecorationX.field(
                      label: 'Password',
                      hint: '••••••••',
                      // Toggle lihat kata sandi.
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Password wajib diisi.' : null,
                  ),
                  const SizedBox(height: 20),
                  if (_generalError.isNotEmpty || _fieldError.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        border: Border.all(color: const Color(0xFFFECACA)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _generalError + _fieldError,
                        style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _submitting
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
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Login menggunakan akun yang sama seperti aplikasi web.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF9CA3AF),
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
