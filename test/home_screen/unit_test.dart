import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_lab/home_screen.dart';

void main() {
  group('HomeScreen Unit Tests', () {
    testWidgets('SharedPreferences triggers tutorial on first launch', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'hasSeenTutorial': false});

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      
      // The tutorial triggers after a 600ms delay.
      await tester.pump(const Duration(milliseconds: 600));
      // Pump to let the coach mark render (300ms transition)
      await tester.pump(const Duration(milliseconds: 400));
      // Pump once more for good measure to avoid infinite pulse
      await tester.pump(const Duration(milliseconds: 100));
      
      // TutorialCoachMark draws an overlay with SKIP button
      expect(find.text("SKIP"), findsOneWidget);
    });

    testWidgets('SharedPreferences respects hasSeenTutorial = true', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'hasSeenTutorial': true});

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      
      await tester.pump(const Duration(milliseconds: 1000));
      
      // Should not show tutorial
      expect(find.text("1. The Grid"), findsNothing);
    });
  });
}
