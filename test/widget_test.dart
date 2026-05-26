import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:the_pyrometer_forge/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(MyApp(preferences: preferences));
    expect(find.text('THE\nPYROMETER\nFORGE.'), findsOneWidget);
  });
}
