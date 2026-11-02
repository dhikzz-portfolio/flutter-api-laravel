import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'produk_screen.dart';

/// Submenu "Master" admin: produk.
class AdminMasterScreen extends StatelessWidget {
  const AdminMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Master Data')),
      backgroundColor: FinKuColors.bg,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _MenuTile(
            icon: Icons.inventory_2_outlined,
            title: 'Produk',
            subtitle: 'Kelola daftar produk dan harga jual',
            page: ProdukScreen(isEmbedded: true),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.page,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(icon, color: const Color(0xFF4F46E5), size: 24),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12.5)),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        ),
      ),
    );
  }
}
