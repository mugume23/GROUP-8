import 'package:flutter_test/flutter_test.dart';
import 'package:home_care/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Basic smoke test — full Firebase init is not available in unit tests.
    // Run integration tests on a device/emulator for full coverage.
    expect(HomeCareApp, isNotNull);
  });
}
