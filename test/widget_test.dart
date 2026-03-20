import 'package:flutter_test/flutter_test.dart';
import 'package:gc_employee_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GcEmployeeApp());
    await tester.pump();
    expect(find.byType(GcEmployeeApp), findsOneWidget);
  });
}
