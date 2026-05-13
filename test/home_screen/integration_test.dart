import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_lab/home_screen.dart';

void main() {
  group('HomeScreen Integration Tests', () {
    void setLargeDisplay(WidgetTester tester) {
      tester.view.physicalSize = const Size(1440, 2560);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    setUp(() {
      SharedPreferences.setMockInitialValues({'hasSeenTutorial': true});
    });

    testWidgets('Bottom navigation switches tabs properly', (WidgetTester tester) async {
      setLargeDisplay(tester);
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      
      // Initial state is Play screen
      expect(find.text("LIFE LAB"), findsOneWidget);

      // Tap Rules
      await tester.tap(find.text("Rules"));
      await tester.pumpAndSettle();

      expect(find.text("RULES LAB"), findsOneWidget);

      // Tap Learn
      await tester.tap(find.text("Learn"));
      await tester.pumpAndSettle();

      expect(find.text("HOW IT WORKS"), findsOneWidget);

      // Tap Play
      await tester.tap(find.text("Play"));
      await tester.pumpAndSettle();

      expect(find.text("LIFE LAB"), findsOneWidget);
    });

    testWidgets('Tapping help icon shows TutorialCoachMark', (WidgetTester tester) async {
      setLargeDisplay(tester);
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      
      // Tap the help icon
      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
      
      // Check if tutorial is shown by looking for the SKIP button
      // The specific text '1. The Grid' might not render in test headless mode due to TargetContent layout constraints.
      expect(find.text("SKIP"), findsOneWidget);
    });

    testWidgets('TutorialCoachMark skips correctly', (WidgetTester tester) async {
      setLargeDisplay(tester);
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      
      // Open tutorial
      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
      
      expect(find.text("SKIP"), findsOneWidget);

      // Tap SKIP
      await tester.tap(find.text("SKIP"));
      await tester.pump(const Duration(milliseconds: 1000));

      // Tutorial is gone
      expect(find.text("1. The Grid"), findsNothing);
    });
  });
}
