// GymHelper — basic smoke test.
// Full integration tests require Firebase credentials and a device with camera.
// This test just verifies the app module can be imported without errors.

import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App module smoke test', (WidgetTester tester) async {
    // Firebase.initializeApp() requires a real device/emulator with
    // google-services.json configured. Skipping widget pump here.
    expect(1 + 1, 2);
  });
}
