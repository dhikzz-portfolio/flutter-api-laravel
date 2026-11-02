import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/config/api_config.dart';
import '../../core/errors/api_exception.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../auth/auth_controller.dart';

/// Halaman akun: identitas sesi, konfigurasi alamat API, dan logout.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _baseUrl;
  bool _savingUrl = false;
  bool _testing = false;
  String _urlNote = '';
  String _urlNoteColor = '';

  @override
  void initState() {
    super.initState();
    _baseUrl = TextEditingController(text: ApiConfig.baseUrl);
  }

  @override
  void dispose() {
    _baseUrl.dispose();
    super.dispose();
  }

  Future<void> _saveUrl() async {
    final value = _baseUrl.text.trim();
    if (value.isEmpty || !value.startsWith('http')) {
      setState(() {
        _urlNote = 'Alamat harus diawali http:// atau https://';
        _urlNoteColor = 'error';
      });
      return;
    }

    setState(() {
      _savingUrl = true;
      _urlNote = '';
    });
    await ApiConfig.saveBaseUrl(value);
    if (!mounted) return;
    setState(() {
      _savingUrl = false;
      _baseUrl.text = ApiConfig.baseUrl;
      _urlNote = 'Alamat API disimpan. Data akan diambil dari alamat ini.';
      _urlNoteColor = 'success';
    });
  }

  Future<void> _resetUrl() async {
    await ApiConfig.removeBaseUrl();
    if (!mounted) return;
    setState(() {
      _baseUrl.text = ApiConfig.baseUrl;
      _urlNote = 'Alamat API dikembalikan ke default platform.';
      _urlNoteColor = 'success';
    });
  }

  /// Memanggil endpoint profil: 200 berarti server + token valid, 401 berarti
  /// server terjangkau namun sesi tidak valid, kegagalan jaringan berarti
  /// alamat server tidak dapat dijangkau.
  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _urlNote = '';
    });
    try {
      await ApiClient.get('/api/v1/auth/me');
      if (!mounted) return;
      setState(() {
        _urlNote = 'Server terjangkau dan sesi valid.';
        _urlNoteColor = 'success';
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.statusCode == 401) {
          _urlNote = 'Server terjangkau, tetapi token tidak valid. Login ulang.';
          _urlNoteColor = 'error';
        } else if (e.statusCode < 0) {
          _urlNote = 'Server tidak dapat dijangkau di ${ApiConfig.baseUrl}.';
          _urlNoteColor = 'error';
        } else {
          _urlNote = 'Server menjawab dengan status ${e.statusCode}: ${e.message}';
          _urlNoteColor = 'error';
        }
      });
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _logout() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Logout',
      message: 'Anda akan keluar dari akun ini. Lanjutkan?',
      confirmLabel: 'Logout',
      destructive: true,
    );
    if (!ok || !mounted) return;
    await context.read<AuthController>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Akun')),
      backgroundColor: FinKuColors.bg,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FinKuCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: FinKuColors.primary,
                  child: Text(
                    user == null ? '?' : Fmt.inisial(user.nama),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.nama ?? '-',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${user?.username ?? '-'}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: FinKuColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          StatusChip(
                            label: (user?.role ?? '-').toUpperCase(),
                            color: FinKuColors.primary,
                          ),
                          const SizedBox(width: 6),
                          StatusChip(
                            label: (user?.status ?? '-').toUpperCase(),
                            color: (user?.isActive ?? false)
                                ? FinKuColors.success
                                : FinKuColors.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FinKuCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alamat Server API',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Android Emulator memakai 10.0.2.2, perangkat fisik memakai IP '
                  'komputer server pada jaringan yang sama.',
                  style: TextStyle(fontSize: 12, color: FinKuColors.textSecondary),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _baseUrl,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Base URL',
                    hintText: 'http://192.168.1.10:8000',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: _savingUrl ? null : _saveUrl,
                        child: _savingUrl
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Simpan'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: _savingUrl ? null : _resetUrl,
                      child: const Text('Default'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _testing ? null : _testConnection,
                  icon: const Icon(Icons.wifi_tethering, size: 17),
                  label: Text(_testing ? 'Menguji...' : 'Tes Koneksi'),
                ),
                if (_urlNote.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    _urlNote,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: _urlNoteColor == 'error'
                          ? FinKuColors.danger
                          : FinKuColors.success,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          FinKuCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sesi',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Logout akan mencabut token di server dan menghapus sesi lokal.',
                  style: TextStyle(fontSize: 12, color: FinKuColors.textSecondary),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: FinKuColors.danger,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Fin-Ku · Aplikasi mobile',
              style: TextStyle(fontSize: 11.5, color: Color(0xFF9CA3AF)),
            ),
          ),
        ],
      ),
    );
  }
}
