import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/play_screen.dart';

void main() {
  group('PlayScreen Integration Tests: User Interactions', () {
    
    // Helper to setup PlayScreen
    Future<void> setupPlayScreen(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 2560);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayScreen(
              birthRule: 3,
              surviveMin: 2,
              surviveMax: 3,
              gridKey: GlobalKey(),
              playBtnKey: GlobalKey(),
              onHelpTap: () {},
            ),
          ),
        ),
      );
      await tester.pump();
    }

    // Helper for coordinate tapping
    Future<void> tapCell(WidgetTester tester, int row, int col) async {
      final dynamic state = tester.state(find.byType(PlayScreen));
      final int size = state.size;
      final int index = row * size + col;
      final gridCells = find.descendant(
        of: find.byType(GridView),
        matching: find.byType(GestureDetector),
      );
      final cell = gridCells.at(index);
      await tester.ensureVisible(cell);
      await tester.tap(cell);
      await tester.pump();
    }

    testWidgets('Tapping a cell toggles its state', (WidgetTester tester) async {
      await setupPlayScreen(tester);
      
      // Tap (5,5)
      await tapCell(tester, 5, 5);
      
      // Verify Alive count becomes 1
      expect(find.textContaining('Alive: 1'), findsOneWidget);
      expect(find.textContaining('Status: Active'), findsOneWidget);

      // Tap (5,5) again
      await tapCell(tester, 5, 5);

      // Verify Alive count becomes 0
      expect(find.textContaining('Alive: 0'), findsOneWidget);
      expect(find.textContaining('All cells dead'), findsOneWidget);
    });

    testWidgets('Play, Pause, and Clear buttons exist and behave correctly', (WidgetTester tester) async {
      await setupPlayScreen(tester);

      expect(find.text("Play"), findsWidgets); // Finds in nav bar and in action buttons
      expect(find.text("Pause"), findsOneWidget);
      expect(find.text("Clear"), findsOneWidget);
      expect(find.byIcon(Icons.help_outline), findsOneWidget);

      // Tap cell to allow start
      await tapCell(tester, 0, 0);

      // Start
      await tester.tap(find.widgetWithText(ElevatedButton, "Play"));
      await tester.pump();

      // Pause
      await tester.tap(find.text("Pause"));
      await tester.pump();

      // Clear
      await tester.tap(find.text("Clear"));
      await tester.pump();

      // Generation reset
      expect(find.text("GEN 0"), findsOneWidget);
      expect(find.textContaining('Alive: 0'), findsOneWidget);
    });
  });
}
