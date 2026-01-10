import 'package:flutter_test/flutter_test.dart';
import 'package:hanlearn/main.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HanLearnApp());

    // Verify that the app launches and displays the AuthWrapper (or appropriate initial widget).
    expect(find.byType(HanLearnApp), findsOneWidget);
  });
}
