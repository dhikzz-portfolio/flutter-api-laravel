import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:fin_ku/core/models/user_model.dart';
import 'package:fin_ku/features/auth/auth_controller.dart';
import 'package:fin_ku/features/auth/data/auth_repository.dart';
import 'package:fin_ku/features/shell/app_shell.dart';

class _FakeAuthRepo extends AuthRepository {
  @override
  Future<Session?> restore() async => null;
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id');
  });

  testWidgets('AppShell renders sidebar with brand and role menus', (tester) async {
    final auth = AuthController(_FakeAuthRepo());
    auth.refreshUser(AppUser(
      id: 1,
      nama: 'Admin Toko',
      username: 'admin',
      role: 'admin',
      status: 'aktif',
    ));

    // Set screen size wide enough to show fixed desktop sidebar (>= 800)
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: auth,
        child: const MaterialApp(
          home: AppShell(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Brand Logo & Text
    expect(find.text('Fin-Ku'), findsOneWidget);
    expect(find.text('FK'), findsOneWidget);

    // Verify Admin menu items from Laravel sidebar
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('MENU'), findsOneWidget);
    expect(find.text('Pembelian'), findsOneWidget);
    expect(find.text('Distributor'), findsOneWidget);
    expect(find.text('Produk'), findsOneWidget);
    expect(find.text('Kategori'), findsOneWidget);
    expect(find.text('STOK'), findsOneWidget);
    expect(find.text('Barang Keluar'), findsOneWidget);
    expect(find.text('Koreksi Stok'), findsOneWidget);
    expect(find.text('Riwayat Stok'), findsOneWidget);

    // Verify User section
    expect(find.text('Admin Toko'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
  });
}
