import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/welcome_screen.dart';

void main() {
  group('WelcomeScreen Unit Tests: Background Logic', () {
    testWidgets('Background simulation calculates next generation properly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
      
      final dynamic state = tester.state(find.byType(WelcomeScreen));
      
      // Override internal grid
      List<List<int>> testGrid = List.generate(state.bgRows, (_) => List.filled(state.bgCols, 0));
      testGrid[10][10] = 1;
      testGrid[10][11] = 1;
      testGrid[11][10] = 1;
      testGrid[11][11] = 1;

      state.bgGrid = testGrid;

      // The timer ticks every 600ms. Pump to trigger it.
      await tester.pump(const Duration(milliseconds: 650));

      List<List<int>> next = state.bgGrid;

      // Block should survive
      expect(next[10][10], equals(1));
      expect(next[11][11], equals(1));
    });
  });
}
