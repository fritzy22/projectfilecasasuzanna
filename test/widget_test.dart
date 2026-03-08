import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:projectfilecasasuzanna/main.dart';

void main() {
  testWidgets('HomePage renders correctly', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const CasaSuzannaApp());

    // Verify that the HomePage is displayed by checking for a known widget or text
    expect(find.byType(MaterialApp), findsOneWidget);

    // If your HomePage has a title or button, check it:
    // Replace 'Book Now' with actual text in your HomePage button
    expect(find.text('Book Now'), findsOneWidget);
  });
}
