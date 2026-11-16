import 'package:flutter_test/flutter_test.dart';

import 'package:fin_ku/app/app.dart';

void main() {
  testWidgets('FinKuApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FinKuApp());
    expect(find.byType(FinKuApp), findsOneWidget);
  });
}
