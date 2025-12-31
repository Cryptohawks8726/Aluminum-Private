// gutted test since we haven't written any tests yet.

import 'package:flutter_test/flutter_test.dart';

import 'package:driver_dashboard/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DriverDashboard());
  });
}
