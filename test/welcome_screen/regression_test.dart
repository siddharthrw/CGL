import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/welcome_screen.dart';

void main() {
  group('WelcomeScreen Regression Tests', () {
    testWidgets('Timers and animations clean up without exceptions', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
      
      // Let animation play a bit
      await tester.pump(const Duration(milliseconds: 600));

      // Replace the widget to force dispose
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      
      // Fast forward time. If timer isn't cancelled, this would throw "pending timer" exceptions.
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      expect(find.byType(WelcomeScreen), findsNothing);
    });
  });
}
