import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/models/user_model.dart';
import '../../core/utils/format.dart';
import '../admin/admin_dashboard_screen.dart';
import '../admin/barang_keluar_screen.dart';
import '../admin/distributor_screen.dart';
import '../admin/kategori_screen.dart';
import '../admin/koreksi_stok_screen.dart';
import '../admin/pembelian_screen.dart';
import '../admin/produk_screen.dart';
import '../admin/riwayat_stok_screen.dart';
import '../auth/auth_controller.dart';
import '../kasir/kasir_dashboard_screen.dart';
import '../kasir/pembeli_screen.dart';
import '../kasir/penjualan_screen.dart';
import '../owner/laporan_screen.dart';
import '../owner/owner_dashboard_screen.dart';
import '../owner/user_management_screen.dart';
import '../profile/profile_screen.dart';

/// Entry data model untuk navigasi sidebar.
class _SidebarEntry {
  const _SidebarEntry.header(this.title)
      : isHeader = true,
        label = '',
        icon = Icons.circle,
        screen = null,
        tabIndex = -1;

  const _SidebarEntry.item({
    required this.label,
    required this.icon,
    required this.screen,
    required this.tabIndex,
  })  : isHeader = false,
        title = '';

  final bool isHeader;
  final String title;
  final String label;
  final IconData icon;
  final Widget? screen;
  final int tabIndex;
}

/// Shell utama Fin-Ku dengan Sidebar persis seperti proyek web Laravel.
/// - Desktop/Web (lebar >= 800px): Sidebar gelap di sebelah kiri (w-64) dan konten di kanan.
/// - Mobile/Layar Sempit (< 800px): Sidebar dapat dibuka sebagai Drawer via tombol hamburger.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;
    if (user == null) return const _NoUserFallback();

    final isWide = MediaQuery.of(context).size.width >= 800;
    final entries = _entriesFor(user.role);
    final pages = entries.where((e) => !e.isHeader).map((e) => e.screen!).toList();

    // Reset index jika melebihi panjang halaman saat pergantian role/sesi.
    if (_selectedIndex >= pages.length) {
      _selectedIndex = 0;
    }

    final sidebarWidget = _FinKuSidebar(
      entries: entries,
      selectedIndex: _selectedIndex,
      user: user,
      isDrawer: !isWide,
      onSelect: (index) {
        if (auth.flashMessage != null) auth.clearFlash();
        setState(() => _selectedIndex = index);
        if (!isWide && _scaffoldKey.currentState?.isDrawerOpen == true) {
          Navigator.of(context).pop();
        }
      },
      onProfileTap: () {
        final profileIdx = _profileIndexFor(user.role, entries);
        if (profileIdx != -1) {
          if (auth.flashMessage != null) auth.clearFlash();
          setState(() => _selectedIndex = profileIdx);
          if (!isWide && _scaffoldKey.currentState?.isDrawerOpen == true) {
            Navigator.of(context).pop();
          }
        }
      },
      onLogout: () => _confirmLogout(context, auth),
    );

    return Scaffold(
      key: _scaffoldKey,
      drawer: isWide
          ? null
          : Drawer(
              width: 280,
              backgroundColor: FinKuColors.dark,
              child: SafeArea(child: sidebarWidget),
            ),
      body: Row(
        children: [
          if (isWide)
            SizedBox(
              width: 264,
              child: sidebarWidget,
            ),
          Expanded(
            child: Stack(
              children: [
                IndexedStack(
                  index: _selectedIndex,
                  children: pages,
                ),
                // Tombol menu mengapung di kanan bawah agar tidak menutupi
                // judul halaman pada AppBar tiap layar.
                if (!isWide)
                  Positioned(
                    left: 18,
                    bottom: 18 + MediaQuery.of(context).padding.bottom,
                    child: FloatingActionButton(
                      heroTag: 'sidebar-menu',
                      mini: false,
                      backgroundColor: FinKuColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      tooltip: 'Menu Sidebar',
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onPressed: () =>
                          _scaffoldKey.currentState?.openDrawer(),
                      child: const Icon(Icons.menu_rounded, size: 24),
                    ),
                  ),
                if ((auth.flashMessage ?? '').isNotEmpty)
                  _FlashBanner(
                    message: auth.flashMessage!,
                    onClose: auth.clearFlash,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _profileIndexFor(String role, List<_SidebarEntry> entries) {
    for (final e in entries) {
      if (!e.isHeader && e.screen is ProfileScreen) {
        return e.tabIndex;
      }
    }
    return -1;
  }

  List<_SidebarEntry> _entriesFor(String role) {
    switch (role) {
      case 'kasir':
        return [
          _SidebarEntry.item(
            label: 'Dashboard',
            icon: Icons.dashboard_outlined,
            screen: KasirDashboardScreen(
              onOpenPenjualan: () => setState(() => _selectedIndex = 1),
              onOpenPembeli: () => setState(() => _selectedIndex = 2),
            ),
            tabIndex: 0,
          ),
          const _SidebarEntry.header('Menu'),
          const _SidebarEntry.item(
            label: 'Transaksi Penjualan',
            icon: Icons.receipt_long_outlined,
            screen: PenjualanScreen(),
            tabIndex: 1,
          ),
          const _SidebarEntry.item(
            label: 'Data Pembeli',
            icon: Icons.people_alt_outlined,
            screen: PembeliScreen(),
            tabIndex: 2,
          ),
          const _SidebarEntry.header('Pengaturan'),
          const _SidebarEntry.item(
            label: 'Profil & Sesi',
            icon: Icons.person_outline_rounded,
            screen: ProfileScreen(),
            tabIndex: 3,
          ),
        ];

      case 'admin':
        return [
          const _SidebarEntry.item(
            label: 'Dashboard',
            icon: Icons.dashboard_outlined,
            screen: AdminDashboardScreen(),
            tabIndex: 0,
          ),
          const _SidebarEntry.header('Menu'),
          const _SidebarEntry.item(
            label: 'Pembelian',
            icon: Icons.shopping_bag_outlined,
            screen: PembelianScreen(),
            tabIndex: 1,
          ),
          const _SidebarEntry.item(
            label: 'Distributor',
            icon: Icons.storefront_outlined,
            screen: DistributorScreen(isEmbedded: false),
            tabIndex: 2,
          ),
          const _SidebarEntry.item(
            label: 'Produk',
            icon: Icons.inventory_2_outlined,
            screen: ProdukScreen(isEmbedded: false),
            tabIndex: 3,
          ),
          const _SidebarEntry.item(
            label: 'Kategori',
            icon: Icons.label_outlined,
            screen: KategoriScreen(isEmbedded: false),
            tabIndex: 4,
          ),
          const _SidebarEntry.header('Stok'),
          const _SidebarEntry.item(
            label: 'Barang Keluar',
            icon: Icons.outbox_rounded,
            screen: BarangKeluarScreen(isEmbedded: false),
            tabIndex: 5,
          ),
          const _SidebarEntry.item(
            label: 'Koreksi Stok',
            icon: Icons.tune_rounded,
            screen: KoreksiStokScreen(isEmbedded: false),
            tabIndex: 6,
          ),
          const _SidebarEntry.item(
            label: 'Riwayat Stok',
            icon: Icons.history_rounded,
            screen: RiwayatStokScreen(isEmbedded: false),
            tabIndex: 7,
          ),
          const _SidebarEntry.header('Pengaturan'),
          const _SidebarEntry.item(
            label: 'Profil & Sesi',
            icon: Icons.person_outline_rounded,
            screen: ProfileScreen(),
            tabIndex: 8,
          ),
        ];

      case 'owner':
      default:
        return [
          _SidebarEntry.item(
            label: 'Dashboard',
            icon: Icons.dashboard_outlined,
            screen: OwnerDashboardScreen(
              onOpenLaporan: () => setState(() => _selectedIndex = 5),
            ),
            tabIndex: 0,
          ),
          const _SidebarEntry.header('Menu'),
          const _SidebarEntry.item(
            label: 'Produk',
            icon: Icons.inventory_2_outlined,
            screen: ProdukScreen(readOnly: true, isEmbedded: false),
            tabIndex: 1,
          ),
          const _SidebarEntry.item(
            label: 'Kategori',
            icon: Icons.label_outlined,
            screen: KategoriScreen(readOnly: true, isEmbedded: false),
            tabIndex: 2,
          ),
          const _SidebarEntry.item(
            label: 'Barang Keluar',
            icon: Icons.outbox_rounded,
            screen: BarangKeluarScreen(readOnly: true, isEmbedded: false),
            tabIndex: 3,
          ),
          const _SidebarEntry.item(
            label: 'Riwayat Stok',
            icon: Icons.history_rounded,
            screen: RiwayatStokScreen(readOnly: true, isEmbedded: false),
            tabIndex: 4,
          ),
          const _SidebarEntry.header('Laporan'),
          const _SidebarEntry.item(
            label: 'Laporan Laba/Rugi',
            icon: Icons.assessment_outlined,
            screen: OwnerLaporanScreen(),
            tabIndex: 5,
          ),
          const _SidebarEntry.header('Pengaturan'),
          const _SidebarEntry.item(
            label: 'Manajemen User',
            icon: Icons.people_alt_outlined,
            screen: OwnerUserManagementScreen(),
            tabIndex: 6,
          ),
          const _SidebarEntry.item(
            label: 'Profil & Sesi',
            icon: Icons.person_outline_rounded,
            screen: ProfileScreen(),
            tabIndex: 7,
          ),
        ];
    }
  }

  void _confirmLogout(BuildContext context, AuthController auth) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: FinKuColors.danger, size: 24),
              SizedBox(width: 10),
              Text(
                'Konfirmasi Logout',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin mengakhiri sesi dan keluar dari aplikasi Fin-Ku?',
            style: TextStyle(fontSize: 14, color: FinKuColors.textPrimary),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Batal', style: TextStyle(color: FinKuColors.textSecondary)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: FinKuColors.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(dialogCtx);
                auth.logout();
              },
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }
}

/// Widget Sidebar bergaya Laravel Tailwind (bg-gray-900 border-gray-800).
class _FinKuSidebar extends StatelessWidget {
  const _FinKuSidebar({
    required this.entries,
    required this.selectedIndex,
    required this.user,
    required this.onSelect,
    required this.onProfileTap,
    required this.onLogout,
    required this.isDrawer,
  });

  final List<_SidebarEntry> entries;
  final int selectedIndex;
  final AppUser user;
  final ValueChanged<int> onSelect;
  final VoidCallback onProfileTap;
  final VoidCallback onLogout;
  final bool isDrawer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF111827), Color(0xFF0B1120)],
        ),
      ),
      child: Column(
        children: [
          // Header / Logo Brand
          Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1F2937))),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: FinKuColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: FinKuColors.primary.withValues(alpha: 0.45),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    'FK',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Fin-Ku',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'Sistem Keuangan',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menu Navigasi
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              itemCount: entries.length,
              itemBuilder: (context, i) {
                final item = entries[i];
                if (item.isHeader) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(12, 18, 12, 6),
                    child: Text(
                      item.title.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF6B7280), // Tailwind text-gray-500
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  );
                }

                final isActive = item.tabIndex == selectedIndex;
                return _SidebarItemTile(
                  label: item.label,
                  icon: item.icon,
                  isActive: isActive,
                  onTap: () => onSelect(item.tabIndex),
                );
              },
            ),
          ),

          // Footer Profil & Tombol Logout
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF1F2937))),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: onProfileTap,
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: FinKuColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      Fmt.inisial(user.nama),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: onProfileTap,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            user.nama,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            user.role[0].toUpperCase() +
                                user.role.substring(1),
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFF9CA3AF),
                    size: 20,
                  ),
                  tooltip: 'Logout',
                  hoverColor: const Color(0xFF1F2937),
                  onPressed: onLogout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Item navigasi dengan hover state & active state bergaya Tailwind.
class _SidebarItemTile extends StatefulWidget {
  const _SidebarItemTile({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_SidebarItemTile> createState() => _SidebarItemTileState();
}

class _SidebarItemTileState extends State<_SidebarItemTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isActive
        ? const Color(0xFF1F2937) // Tailwind bg-gray-800
        : (_isHovered
            ? const Color(0xFF1F2937).withValues(alpha: 0.6)
            : Colors.transparent);

    final textColor = widget.isActive
        ? Colors.white
        : (_isHovered ? Colors.white : const Color(0xFFD1D5DB)); // text-gray-300

    final iconColor = widget.isActive
        ? Colors.white
        : (_isHovered ? Colors.white : const Color(0xFF9CA3AF)); // text-gray-400

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                width: 3,
                height: 18,
                margin: const EdgeInsets.only(right: 9),
                decoration: BoxDecoration(
                  color: widget.isActive
                      ? FinKuColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Icon(
                widget.icon,
                size: 20,
                color: widget.isActive ? const Color(0xFFC7D2FE) : iconColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Banner notifikasi flash di atas layar (sesuai flash message Laravel).
class _FlashBanner extends StatelessWidget {
  const _FlashBanner({required this.message, required this.onClose});

  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 0,
      right: 0,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Material(
              elevation: 8,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF15803D), Color(0xFF166534)],
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Tutup',
                    ),
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

class _NoUserFallback extends StatelessWidget {
  const _NoUserFallback();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
