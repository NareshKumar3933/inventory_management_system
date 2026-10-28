import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management/main.dart';

void main() {
  testWidgets('App launches without error', (WidgetTester tester) async {
    await tester.pumpWidget(const InventoryApp());
    expect(find.byType(InventoryApp), findsOneWidget);
  });
}
