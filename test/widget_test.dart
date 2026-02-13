// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stockid/main.dart';

void main() {
  testWidgets('Dashboard smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StockIDApp());

    // Verify that the logo or a key dashboard element is present.
    // Dashboard app bar has an Image.asset for the logo.
    expect(find.byType(Image), findsWidgets);

    // Check for "AI Predictions" text on the dashboard
    expect(find.text('AI Predictions'), findsOneWidget);
  });
}
