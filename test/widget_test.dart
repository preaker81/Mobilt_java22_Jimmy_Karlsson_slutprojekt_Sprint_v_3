import 'package:flutter_test/flutter_test.dart';
import 'package:mtg_companion/main.dart';
import 'package:mtg_companion/login.dart'; // import LoginScreen

void main() {
  testWidgets('App starts on login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app starts on the LoginScreen.
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
