import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic UI rendering test', (WidgetTester tester) async {
    // Build a simple widget to verify the test environment is working.
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('nyxdex'))),
    );

    // Verify that the text is found.
    expect(find.text('nyxdex'), findsOneWidget);
  });
}
