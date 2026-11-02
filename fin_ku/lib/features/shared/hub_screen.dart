import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../auth/auth_controller.dart';

/// Satu baris menu pada halaman hub (pengganti sidebar web di mobile).
class HubTile extends StatelessWidget {
  const HubTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: FinKuColors.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: FinKuColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: FinKuColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: FinKuColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: FinKuColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Halaman pengelompokan menu, mengikuti grup sidebar aplikasi web.
class HubScreen extends StatelessWidget {
  const HubScreen({
    required this.title,
    required this.tiles,
    this.header,
    super.key,
  });

  final String title;
  final List<Widget> tiles;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(
                child: Text(
                  user.nama,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: FinKuColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
      backgroundColor: FinKuColors.bg,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (header != null) ...[header!, const SizedBox(height: 14)],
          ...tiles,
        ],
      ),
    );
  }
}
