import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/common.dart';
import '../../../core/models/user_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/errors/api_exception.dart';

class OwnerUserManagementScreen extends StatefulWidget {
  const OwnerUserManagementScreen({super.key});

  @override
  State<OwnerUserManagementScreen> createState() =>
      _OwnerUserManagementScreenState();
}

class _OwnerUserManagementScreenState
    extends State<OwnerUserManagementScreen> {
  // Pagination state
  final PageController _pageController = PageController();
  final int _currentPage = 1;
  final int _perPage = 15;
  int _total = 0;
  int _lastPage = 1;

  // Filter & Search
  final TextEditingController _searchController = TextEditingController();
  String? _selectedRole;
  bool _isLoading = false;
  String? _error;

  // Current editing user
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _selectedRoleValue;
  String? _selectedStatusValue;
  bool _isEditing = false;
  int? _editUserId;

  // Data user
  List<Map<String, dynamic>> _users = [];
  Map<String, dynamic>? _pagination;

  // Mode form
  static const _roleOptions = ['kasir', 'admin', 'owner'];
  static const _statusOptions = ['aktif', 'nonaktif'];

  @override
  void initState() {
    super.initState();
    _loadUsers(page: 1);
  }

  Future<void> _loadUsers({
    required int page,
    String? search,
    String? role,
  }) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final body = await ApiClient.get(
        '/api/v1/owner/user',
        query: {
          'page': page.toString(),
          'per_page': _perPage.toString(),
          if (search != null) 'search': search,
          if (role != null) 'role': role,
        },
      );

      final data = body['data'] as Map<String, dynamic>;
      final usersList =
          (data['users'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
              [];

      setState(() {
        _users = usersList;
        _pagination = data['meta'] as Map<String, dynamic>?;
        _total = _pagination?['total'] ?? 0;
        _lastPage = _pagination?['last_page'] ?? 1;
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- Form: Create/Edit ---
  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> body = {
        'nama': _namaController.text.trim(),
        'username': _usernameController.text.trim(),
        'role': _selectedRoleValue,
        'status': _selectedStatusValue,
      };

      // Hanya kirim password jika bukan mode edit atau password diisi
      if (!_isEditing || _passwordController.text.isNotEmpty) {
        body['password'] = _passwordController.text.trim();
      }

      String endpoint;
      if (_isEditing && _editUserId != null) {
        endpoint = '/api/v1/owner/user/${_editUserId}';
      } else {
        endpoint = '/api/v1/owner/user';
      }

      final responseBody = await ApiClient.post(endpoint, body);

      // Refresh data setelah save
      _loadUsers(page: 1);
      _clearForm();

      if (!_isEditing) {
        _showSnackbar('User berhasil ditambahkan.');
      } else {
        _showSnackbar('User berhasil diupdate.');
      }
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Gagal menyimpan: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _namaController.clear();
    _usernameController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _selectedRoleValue = null;
    _selectedStatusValue = null;
    _isEditing = false;
    _editUserId = null;
    _formKey.currentState?.reset();
    _loadUsers(page: 1);
  }

  void _editUser(Map<String, dynamic> user) {
    setState(() {
      _isEditing = true;
      _editUserId = user['id'] as int;
      _namaController.text = user['nama'] as String;
      _usernameController.text = user['username'] as String;
      _selectedRoleValue = user['role'] as String?;
      _selectedStatusValue = user['status'] as String?;
      _confirmPasswordController.text = '';
    });
  }

  void _deleteUser(int userId, String nama) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin menghapus user "$nama"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final endpoint = '/api/v1/owner/user/$userId';
      await ApiClient.delete(endpoint);
      _loadUsers(page: 1);
      _showSnackbar('User "$nama" berhasil dihapus.');
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Gagal menghapus: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- Widget Build ---
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppUser>();
    final isOwner = auth.isOwner;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen User'),
        actions: [],
      ),
      body: _buildBody(isOwner),
    );
  }

  Widget _buildBody(bool isOwner) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorState(_error!);
    }

    if (_users.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Filter & Search Section
        _buildFilterSection(),

        const Divider(height: 1),

        // User Table
        Expanded(
          child: _buildUserTable(),
        ),

        // Pagination
        _buildPagination(),
      ],
    );
  }

  Widget _buildFilterSection() {
    return FinKuCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter & Cari',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Cari nama atau username',
                    border: OutlineInputBorder(),
                    hintText: 'Masukkan nama atau username',
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadUsers(page: 1);
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _loadUsers(page: 1),
                ),
              ),
              const SizedBox(width: 12),
              // Filter Role
              _buildRoleFilter(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleFilter() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _selectedRole,
          hint: const Text('Filter Role'),
          icon: const Icon(Icons.arrow_drop_down),
          items: [
            const DropdownMenuItem(value: null, child: Text('Semua')),
            ..._roleOptions.map((role) => DropdownMenuItem(
              value: role,
              child: Text(role[0].toUpperCase() + role.substring(1)),
            )),
          ],
          onChanged: (val) {
            setState(() => _selectedRole = val);
            _loadUsers(page: 1);
          },
        ),
      ),
    );
  }

  Widget _buildUserTable() {
    if (_users.isEmpty) {
      return const Center(child: Text('Tidak ada user ditemukan'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        final isCurrentUser = user['id'] ==
            (context.watch<AppUser>().id ?? 0);

        return FinKuCard(
          padding: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        user['nama'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getRoleColor(user['role'] as String?)?.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        (_getRoleLabel(user['role'] as String?)),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getRoleColor(user['role'] as String?),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14,
                        color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      user['username'] as String,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Spacer(),
                    _buildActionButtons(user, isCurrentUser),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(
    Map<String, dynamic> user,
    bool isCurrentUser,
  ) {
    final canEdit = !isCurrentUser;
    final canDelete = !isCurrentUser;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (canEdit)
          Tooltip(
            message: 'Edit',
            child: IconButton(
              icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
              onPressed: () => _editUser(user),
            ),
          ),
        if (canDelete)
          Tooltip(
            message: 'Hapus',
            child: IconButton(
              icon: const Icon(Icons.delete, size: 18, color: Colors.red),
              onPressed: () => _deleteUser(
                user['id'] as int,
                user['nama'] as String,
              ),
            ),
          ),
      ],
    );
  }

  Color? _getRoleColor(String? role) {
    if (role == 'kasir') return const Color(0xFF10B981);
    if (role == 'admin') return const Color(0xFFF59E0B);
    if (role == 'owner') return const Color(0xFFEF4444);
    return Colors.grey;
  }

  String _getRoleLabel(String? role) {
    if (role == 'kasir') return 'Kasir';
    if (role == 'admin') return 'Admin';
    if (role == 'owner') return 'Owner';
    return 'Tidak Diketahui';
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Tidak ada user ditemukan'),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        color: const Color(0xFFFEF3F2),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _loadUsers(page: 1),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    if (_lastPage <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text('Halaman: '),
          TextButton(
            onPressed: _currentPage > 1
                ? () => _loadUsers(page: _currentPage - 1)
                : null,
            child: const Text('Prev'),
          ),
          const SizedBox(width: 4),
          Text(
            '$_currentPage/$_lastPage',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: _currentPage < _lastPage
                ? () => _loadUsers(page: _currentPage + 1)
                : null,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}