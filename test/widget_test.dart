import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart' as firebase_test;
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    firebase_test.setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PortfolioApp());
    // Fixed pumps instead of pumpAndSettle: the portfolio screen contains
    // intentionally infinite animations (marquees) that never settle.
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(PortfolioApp), findsOneWidget);
  });
}
