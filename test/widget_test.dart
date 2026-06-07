import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_islamic/main.dart';

void main() {
  testWidgets('AppIslamic dashboard smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AppIslamic());

    // Verify that our title is present.
    expect(find.text('APP ISLAMIC Dashboard'), findsOneWidget);
  });
}
