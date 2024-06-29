import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock/main.dart';

void main() {
  testWidgets('App has a title and BottomNavigationBar', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Verify that the title is displayed
    expect(find.text('Flutter Clock'), findsOneWidget);

    // Verify that BottomNavigationBar is displayed
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
