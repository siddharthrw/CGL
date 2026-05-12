import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_lab/home_screen.dart';

void main() {
  group('HomeScreen System Tests', () {
    testWidgets('TutorialCoachMark skips correctly', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'hasSeenTutorial': false});

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 300));
      
      // Look for the "SKIP" text
      expect(find.text("SKIP"), findsOneWidget);

      // Tap SKIP
      await tester.tap(find.text("SKIP"));
      await tester.pumpAndSettle();

      // Tutorial is gone
      expect(find.text("1. The Grid"), findsNothing);
    });
  });
}
