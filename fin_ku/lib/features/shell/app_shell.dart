import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/utils/format.dart';
import '../auth/auth_controller.dart';
import '../kasir/kasir_dashboard_screen.dart';
import '../kasir/pembeli_screen.dart';
import '../kasir/penjualan_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../admin/admin_master_screen.dart';
import '../admin/pembelian_screen.dart';
import '../owner/owner_dashboard_screen.dart';
import '../owner/laporan_screen.dart';
import '../owner/user_management_screen.dart';

/// Shell utama: bottom navigation dan menu disesuaikan dengan role yang
/// terverifikasi backend (kasir / admin), mengikuti sidebar web.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;
    if (user == null) return const _NoUserFallback();

    final tabs = _tabsFor(user.role);

    // Reset index jika out-of-range setelah pergantian jenis sesi.
    if (_index >= tabs.length) _index = 0;

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _index, children: tabs.map((t) => t.body).toList()),
          if ((auth.flashMessage ?? '').isNotEmpty)
            _FlashBanner(message: auth.flashMessage!),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          if (auth.flashMessage != null) auth.clearFlash();
          setState(() => _index = i);
        },
        indicatorColor: FinKuColors.primary.withValues(alpha: 0.12),
        destinations: [
          for (final t in tabs)
            NavigationDestination(
              icon: Icon(t.icon, color: FinKuColors.textSecondary),
              selectedIcon: Icon(t.icon, color: FinKuColors.primary),
              label: t.label,
            ),
        ],
      ),
    );
  }

  List<_ShellTab> _tabsFor(String role) {
    switch (role) {
      case 'kasir':
        return [
          _ShellTab('Home', Icons.home_outlined, KasirDashboardScreen()),
          _ShellTab('Penjualan', Icons.receipt_long_outlined, PenjualanScreen()),
          _ShellTab('Pembeli', Icons.people_alt_outlined, PembeliScreen()),
        ];
      case 'admin':
        return [
          _ShellTab('Home', Icons.home_outlined, AdminDashboardScreen()),
          _ShellTab('Pembelian', Icons.shopping_cart_outlined, PembelianScreen()),
          _ShellTab('Master', Icons.inventory_2_outlined, AdminMasterScreen()),
        ];
      case 'owner':
        return [
          _ShellTab('Dashboard', Icons.dashboard_outlined, OwnerDashboardScreen()),
          _ShellTab('Laporan', Icons.description_outlined, OwnerLaporanScreen()),
          _ShellTab('User', Icons.people_outlined, OwnerUserManagementScreen()),
        ];
      default:
        return [
          _ShellTab('Dashboard', Icons.home_outlined, OwnerDashboardScreen()),
          _ShellTab('Laporan', Icons.remove_shopping_cart, OwnerLaporanScreen()),
          _ShellTab('User', Icons.person_outlined, OwnerUserManagementScreen()),
        ];
    }
  }
}

class _ShellTab {
  const _ShellTab(this.label, this.icon, this.body);

  final String label;
  final IconData icon;
  final Widget body;
}

/// Banner overlay singkat untuk notifikasi global (login/logout).
class _FlashBanner extends StatefulWidget {
  const _FlashBanner({required this.message});

  final String message;

  @override
  State<_FlashBanner> createState() => _FlashBannerState();
}

class _FlashBannerState extends State<_FlashBanner> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: const Color(0xFF15803D),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Text(
              widget.message,
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoUserFallback extends StatelessWidget {
  const _NoUserFallback();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

/// Header halaman bertuliskan judul + nama user, mengikuti header web.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, required this.actions});

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          ...actions,
          if ((user?.nama ?? '').isNotEmpty) ...[
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 16,
              backgroundColor: FinKuColors.primary,
              child: Text(
                Fmt.inisial(user!.nama),
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}