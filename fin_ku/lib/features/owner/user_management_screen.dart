import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/models/user_model.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../auth/auth_controller.dart';
import '../katalog/data/katalog_repository.dart';

/// Manajemen user owner, mengikuti owner/user/index.blade.php:
/// pencarian + filter role, daftar user, tambah/edit lewat modal, hapus,
/// dan pagination.
class OwnerUserManagementScreen extends StatefulWidget {
  const OwnerUserManagementScreen({super.key});

  @override
  State<OwnerUserManagementScreen> createState() =>
      _OwnerUserManagementScreenState();
}

class _OwnerUserManagementScreenState extends State<OwnerUserManagementScreen> {
  final _repo = OwnerRepository();
  final _searchController = TextEditingController();

  List<AppUserRow> _users = [];
  String _roleFilter = '';
  int _page = 1;
  int _lastPage = 1;
  int _total = 0;
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load(page: 1);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({required int page}) async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final result = await _repo.users(
        search: _searchController.text.trim(),
        role: _roleFilter,
        page: page,
        perPage: 15,
      );
      if (!mounted) return;
      setState(() {
        _users = result.items;
        _page = result.currentPage;
        _lastPage = result.lastPage;
        _total = result.total;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openForm([AppUserRow? user]) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _UserFormDialog(repo: _repo, user: user),
    );
    if (saved == true) {
      _load(page: user == null ? 1 : _page);
    }
  }

  Future<void> _deleteUser(AppUserRow user) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Konfirmasi Hapus',
      message: 'Yakin ingin menghapus user "${user.nama}"?',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (!ok || !mounted) return;

    try {
      await _repo.deleteUser(user.id);
      if (!mounted) return;
      showInfoSnack(context, 'User "${user.nama}" berhasil dihapus.');
      _load(page: 1);
    } catch (e) {
      if (!mounted) return;
      showErrorSnack(context, errorText(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.watch<AuthController>().user?.id ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen User')),
      backgroundColor: FinKuColors.bg,
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _loading
                ? const LoadingView()
                : _error.isNotEmpty
                ? ErrorView(
                    message: _error,
                    onRetry: () => _load(page: _page),
                  )
                : _users.isEmpty
                ? const EmptyView(
                    icon: Icons.people_alt_outlined,
                    title: 'Belum ada data user',
                    subtitle: 'Tambahkan user baru lewat tombol di atas.',
                  )
                : RefreshIndicator(
                    onRefresh: () => _load(page: _page),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: _users.length,
                      itemBuilder: (context, i) {
                        final user = _users[i];
                        final nomor = (_page - 1) * 15 + i + 1;
                        return _UserTile(
                          nomor: nomor,
                          user: user,
                          canDelete: user.id != currentUserId,
                          onEdit: () => _openForm(user),
                          onDelete: () => _deleteUser(user),
                        );
                      },
                    ),
                  ),
          ),
          if (!_loading && _error.isEmpty && _users.isNotEmpty)
            _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 230,
            child: TextField(
              controller: _searchController,
              decoration: InputDecorationX.search(hint: 'Cari user...'),
              onSubmitted: (_) => _load(page: 1),
            ),
          ),
          SizedBox(
            width: 160,
            child: DropdownButtonFormField<String?>(
              initialValue: _roleFilter.isEmpty ? null : _roleFilter,
              isDense: true,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
              items: const [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Semua Role'),
                ),
                DropdownMenuItem<String?>(value: 'kasir', child: Text('Kasir')),
                DropdownMenuItem<String?>(value: 'admin', child: Text('Admin')),
                DropdownMenuItem<String?>(value: 'owner', child: Text('Owner')),
              ],
              onChanged: (v) => setState(() => _roleFilter = v ?? ''),
            ),
          ),
          OutlinedButton(
            onPressed: () => _load(page: 1),
            child: const Text('Cari'),
          ),
          FilledButton.icon(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Tambah User'),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Menampilkan ${_users.length} dari $_total user',
              style: const TextStyle(
                fontSize: 12,
                color: FinKuColors.textSecondary,
              ),
            ),
          ),
          Text(
            '$_page / $_lastPage',
            style: const TextStyle(
              fontSize: 12,
              color: FinKuColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _page > 1 ? () => _load(page: _page - 1) : null,
            child: const Text('Prev'),
          ),
          TextButton(
            onPressed: _page < _lastPage ? () => _load(page: _page + 1) : null,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.nomor,
    required this.user,
    required this.canDelete,
    required this.onEdit,
    required this.onDelete,
  });

  final int nomor;
  final AppUserRow user;
  final bool canDelete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FinKuColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 26,
                child: Text(
                  '$nomor',
                  style: const TextStyle(
                    fontSize: 12,
                    color: FinKuColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  user.nama,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              StatusChip(
                label: user.role.toUpperCase(),
                color: _roleColor(user.role),
              ),
              const SizedBox(width: 6),
              StatusChip(
                label: user.isActive ? 'Aktif' : 'Nonaktif',
                color: user.isActive
                    ? FinKuColors.success
                    : FinKuColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 15,
                  color: FinKuColors.textSecondary,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    user.username,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: FinKuColors.textSecondary,
                    ),
                  ),
                ),
                TextButton(onPressed: onEdit, child: const Text('Edit')),
                if (canDelete)
                  TextButton(
                    onPressed: onDelete,
                    style: TextButton.styleFrom(
                      foregroundColor: FinKuColors.danger,
                    ),
                    child: const Text('Hapus'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'kasir':
        return const Color(0xFF2563EB);
      case 'admin':
        return const Color(0xFF9333EA);
      case 'owner':
        return const Color(0xFFCA8A04);
      default:
        return FinKuColors.textSecondary;
    }
  }
}

/// Modal tambah/edit user. Mengembalikan `true` bila berhasil disimpan.
class _UserFormDialog extends StatefulWidget {
  const _UserFormDialog({required this.repo, this.user});

  final OwnerRepository repo;
  final AppUserRow? user;

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  late final TextEditingController _nama;
  late final TextEditingController _username;
  final _password = TextEditingController();
  late String _role;
  late String _status;
  bool _saving = false;
  String _error = '';

  bool get _isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    _nama = TextEditingController(text: widget.user?.nama ?? '');
    _username = TextEditingController(text: widget.user?.username ?? '');
    _role = widget.user?.role ?? 'kasir';
    _status = widget.user?.status ?? 'aktif';
  }

  @override
  void dispose() {
    _nama.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final nama = _nama.text.trim();
    final username = _username.text.trim();
    final password = _password.text;

    if (nama.isEmpty || username.isEmpty) {
      setState(() => _error = 'Nama dan username wajib diisi.');
      return;
    }
    if (!_isEdit && password.length < 6) {
      setState(() => _error = 'Password minimal 6 karakter.');
      return;
    }
    if (_isEdit && password.isNotEmpty && password.length < 6) {
      setState(() => _error = 'Password minimal 6 karakter.');
      return;
    }

    setState(() {
      _error = '';
      _saving = true;
    });

    try {
      if (_isEdit) {
        await widget.repo.updateUser(
          widget.user!.id,
          nama: nama,
          username: username,
          role: _role,
          status: _status,
          password: password,
        );
      } else {
        await widget.repo.createUser(
          nama: nama,
          username: username,
          password: password,
          role: _role,
          status: _status,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = errorText(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(_isEdit ? 'Edit User' : 'Tambah User'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nama,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _username,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: _isEdit
                      ? 'Password (kosongkan jika tidak diubah)'
                      : 'Password',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _role,
                      isDense: true,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'kasir', child: Text('Kasir')),
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        DropdownMenuItem(value: 'owner', child: Text('Owner')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _role = v);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _status,
                      isDense: true,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'aktif', child: Text('Aktif')),
                        DropdownMenuItem(
                          value: 'nonaktif',
                          child: Text('Nonaktif'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _status = v);
                      },
                    ),
                  ),
                ],
              ),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  _error,
                  style: const TextStyle(
                    color: FinKuColors.danger,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}
