import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/main.dart';
import 'package:life_lab/play_screen.dart';

void main() {
  group('PlayScreen Regression Tests: Timers and Lazy UI', () {
    
    void setLargeDisplay(WidgetTester tester) {
      tester.view.physicalSize = const Size(1440, 2560);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    Future<void> tapCell(WidgetTester tester, int row, int col) async {
      // Reverted to index-based finder until Keys are implemented in app code
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

    Future<void> initPlay(WidgetTester tester) async {
      setLargeDisplay(tester);
      await tester.pumpWidget(const LifeLab());
      await tester.pump();
      await tester.tap(find.text('ENTER GRID'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1850));
    }

    testWidgets('Pause button explicitly stops simulation timer', (WidgetTester tester) async {
      await initPlay(tester);

      await tapCell(tester, 10, 10);
      await tapCell(tester, 10, 11);
      await tapCell(tester, 11, 10);
      await tapCell(tester, 11, 11);

      await tester.tap(find.widgetWithText(ElevatedButton, "Play"));
      // Let the simulation run for one generation to prove it started successfully
      await tester.pump(const Duration(milliseconds: 300)); 
      expect(find.text("GEN 1"), findsOneWidget);

      await tester.tap(find.text("Pause"));
      await tester.pump();

      // Wait a significant amount of time to ensure the pause holds
      await tester.pump(const Duration(seconds: 2)); 
      
      expect(find.text("GEN 1"), findsOneWidget);
    });

    testWidgets('Clear button resets state and cancels timer', (WidgetTester tester) async {
      await initPlay(tester);

      await tapCell(tester, 10, 10);

      await tester.tap(find.widgetWithText(ElevatedButton, "Play"));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text("GEN 1"), findsOneWidget);

      await tester.tap(find.text("Clear"));
      await tester.pump();

      expect(find.text("GEN 0"), findsOneWidget);
      expect(find.text("THE END"), findsNothing);
      
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('Dialogs are cleared when interacting with grid', (WidgetTester tester) async {
      await initPlay(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, "Play"));
      await tester.pump();
      expect(find.text("EMPTY GRID"), findsOneWidget);

      await tapCell(tester, 10, 10);

      expect(find.text("EMPTY GRID"), findsNothing);
    });
  });
}
