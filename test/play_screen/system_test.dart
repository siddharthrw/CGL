import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/main.dart';
import 'package:life_lab/play_screen.dart';

void main() {
  group('PlayScreen System Tests: End-to-End Simulation Flows', () {
    
    void setLargeDisplay(WidgetTester tester) {
      tester.view.physicalSize = const Size(1440, 2560);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

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

    Future<void> navigateToPlayScreen(WidgetTester tester) async {
      setLargeDisplay(tester);
      await tester.pumpWidget(const LifeLab());
      await tester.pump();
      await tester.tap(find.text('ENTER GRID'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 850));
    }

    testWidgets('EMPTY GRID detection', (WidgetTester tester) async {
      await navigateToPlayScreen(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, "Play"));
      await tester.pump();

      expect(find.text('EMPTY GRID'), findsOneWidget);
    });

    testWidgets('THE END detection (all cells die)', (WidgetTester tester) async {
      await navigateToPlayScreen(tester);

      // Tap one center cell (10, 10)
      await tapCell(tester, 10, 10);

      await tester.tap(find.widgetWithText(ElevatedButton, "Play"));
      
      // Generation ticks at 250ms
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('THE END'), findsOneWidget);
    });

    testWidgets('STABILIZED detection (Block)', (WidgetTester tester) async {
      await navigateToPlayScreen(tester);

      // Draw a 2x2 block in the center
      await tapCell(tester, 10, 10);
      await tapCell(tester, 10, 11);
      await tapCell(tester, 11, 10);
      await tapCell(tester, 11, 11);

      await tester.tap(find.widgetWithText(ElevatedButton, "Play"));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('STABILIZED!'), findsOneWidget);
    });

    testWidgets('ENDLESS LOOP detection (Blinker)', (WidgetTester tester) async {
      await navigateToPlayScreen(tester);

      // Draw a 3x1 line (blinker) in the center
      await tapCell(tester, 10, 9);
      await tapCell(tester, 10, 10);
      await tapCell(tester, 10, 11);

      await tester.tap(find.widgetWithText(ElevatedButton, "Play"));
      
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();

      expect(find.text('ENDLESS LOOP!'), findsOneWidget);

      // Cleanup
      await tester.tap(find.text('Pause'));
      await tester.pump();
    });
  });
}
