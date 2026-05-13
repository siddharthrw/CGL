import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/tutorial_screen.dart';
import 'package:life_lab/home_screen.dart';

void main() {
  group('TutorialScreen Integration & System Tests', () {
    
    Future<void> setupTutorialScreen(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 2560);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const MaterialApp(home: TutorialScreen()));
      await tester.pump();
    }

    testWidgets('Renders first slide and can navigate to next slides', (WidgetTester tester) async {
      await setupTutorialScreen(tester);
      
      expect(find.text("About the Game"), findsOneWidget);
      expect(find.text("NEXT"), findsOneWidget);

      // Tap NEXT
      await tester.tap(find.text("NEXT"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text("The Grid & Cells"), findsOneWidget);
    });

    testWidgets('Tapping SKIP navigates to the final slide', (WidgetTester tester) async {
      await setupTutorialScreen(tester);

      expect(find.text("SKIP"), findsOneWidget);
      await tester.tap(find.text("SKIP"));
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Should be on the final slide
      expect(find.text("Ready to Evolve?"), findsOneWidget);
      expect(find.text("LEARN MORE"), findsOneWidget);
      expect(find.text("PLAY GAME"), findsOneWidget);
    });

    testWidgets('Tapping PLAY GAME on final slide navigates to HomeScreen', (WidgetTester tester) async {
      await setupTutorialScreen(tester);

      // Skip to end
      await tester.tap(find.text("SKIP"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Tap Play Game
      await tester.tap(find.text("PLAY GAME"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Should find HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Interactive Demo slide works correctly', (WidgetTester tester) async {
      await setupTutorialScreen(tester);

      // Navigate to Interactive Demo (Slide index 4)
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.text("NEXT"));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
      }

      expect(find.text("Interactive Demo"), findsOneWidget);
      expect(find.text("Play Demo"), findsOneWidget);

      // Tap Play Demo
      await tester.tap(find.text("Play Demo"));
      await tester.pump();
      
      // Wait for the simulation to finish (stabilize or die)
      // The demo is 10x10 and updates every 300ms
      await tester.pump(const Duration(seconds: 4));

      // Reset Demo should be visible
      expect(find.text("Reset Demo"), findsOneWidget);

      // Tap Reset Demo
      await tester.tap(find.text("Reset Demo"));
      await tester.pump();

      expect(find.text("Play Demo"), findsOneWidget);
    });
  });
}
