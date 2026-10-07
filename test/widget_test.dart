import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jagain/app.dart';

void main() {
  testWidgets('JAGAIN app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: JagainApp()));
    expect(find.text('JAGAIN'), findsWidgets);
  });
}
