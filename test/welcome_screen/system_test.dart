import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/welcome_screen.dart';
import 'package:life_lab/home_screen.dart';
import 'package:life_lab/tutorial_screen.dart';

void main() {
  group('WelcomeScreen System Tests', () {
    testWidgets('Tapping ENTER GRID transitions to HomeScreen', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
      
      await tester.tap(find.text("ENTER GRID"));
      
      // Delay of 1000ms + transition of 800ms
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1850));

      // Should be on HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Tapping START TUTORIAL transitions to TutorialScreen', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
      
      await tester.tap(find.text("START TUTORIAL"));
      
      // Delay of 1000ms + transition of 800ms
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1850));

      // Should be on TutorialScreen
      expect(find.byType(TutorialScreen), findsOneWidget);
    });
  });
}
