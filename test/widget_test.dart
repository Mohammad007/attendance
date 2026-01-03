// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:attendance/main.dart';

void main() {
  testWidgets('Laborbook app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LaborbookApp());

    // Verify that the app title is displayed
    expect(find.text('Laborbook'), findsOneWidget);

    // Verify that quick actions are displayed
    expect(find.text('Workers'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);
    expect(find.text('Wages'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
  });
}
