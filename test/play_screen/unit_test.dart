import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/play_screen.dart';

void main() {
  group('PlayScreen Unit Tests: Game Logic', () {
    // Helper to get the private State object dynamically
    Future<dynamic> getPlayState(WidgetTester tester) async {
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
      return tester.state(find.byType(PlayScreen));
    }

    testWidgets('countNeighbors - counts correctly for various grid setups', (WidgetTester tester) async {
      final state = await getPlayState(tester);
      
      // Override the internal grid for testing
      state.grid = List.generate(state.size, (_) => List.filled(state.size, 0));
      
      // Create a 3x3 block of alive cells
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 3; c++) {
          state.grid[r][c] = 1;
        }
      }

      // Center cell should have 8 neighbors
      expect(state.countNeighbors(1, 1), equals(8));
      
      // Top-left corner (0,0) should have 3 neighbors
      expect(state.countNeighbors(0, 0), equals(3));
      
      // Edge cell (0,1) should have 5 neighbors
      expect(state.countNeighbors(0, 1), equals(5));

      // Far away cell should have 0 neighbors
      expect(state.countNeighbors(10, 10), equals(0));
    });

    testWidgets('nextGeneration - Standard Rules (Conway)', (WidgetTester tester) async {
      final state = await getPlayState(tester);
      
      // Clear grid
      state.grid = List.generate(state.size, (_) => List.filled(state.size, 0));
      
      // Set up a Blinker (oscillator)
      state.grid[5][5] = 1;
      state.grid[5][6] = 1;
      state.grid[5][7] = 1;

      // Calculate next generation
      List<List<int>> next = state.nextGeneration();

      // Original blinker cells
      expect(next[5][5], equals(0)); // Underpopulation
      expect(next[5][6], equals(1)); // Survival
      expect(next[5][7], equals(0)); // Underpopulation

      // New born cells
      expect(next[4][6], equals(1)); // Reproduction
      expect(next[6][6], equals(1)); // Reproduction
    });

    testWidgets('nextGeneration - Custom Rules (HighLife)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayScreen(
              birthRule: 6, // Custom rule
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
      final dynamic state = tester.state(find.byType(PlayScreen));
      
      state.grid = List.generate(state.size, (_) => List.filled(state.size, 0));
      
      // Set up exactly 6 neighbors around an empty cell (5,5)
      state.grid[4][4] = 1;
      state.grid[4][5] = 1;
      state.grid[4][6] = 1;
      state.grid[6][4] = 1;
      state.grid[6][5] = 1;
      state.grid[6][6] = 1;

      List<List<int>> next = state.nextGeneration();

      // With birthRule = 6, the center cell should be born
      expect(next[5][5], equals(1));
    });
  });
}
