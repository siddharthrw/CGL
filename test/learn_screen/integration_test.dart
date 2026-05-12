import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/learn_screen.dart';

void main() {
  group('LearnScreen Integration Tests', () {
    void setLargeDisplay(WidgetTester tester) {
      tester.view.physicalSize = const Size(1440, 2560);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets('FAQ ExpansionTile expands and shows answer', (WidgetTester tester) async {
      setLargeDisplay(tester);
      await tester.pumpWidget(const MaterialApp(home: LearnScreen()));
      
      const question = "What are Gliders?";
      const answer = "Gliders are special patterns of cells that move across the grid infinitely. They 'fly' diagonally across the board. Try drawing a small asymmetrical shape and see if it moves!";
      
      expect(find.text(question), findsOneWidget);
      
      // Assert the text is actually hidden from the widget tree before tap
      expect(find.text(answer), findsNothing);

      // Before tap, the text is collapsed, so it should not be visible
      // Note: ExpansionTile actually renders children but hides them, or doesn't build them depending on setup.
      // In Flutter, it usually exists in the tree but is clipped. Let's tap to expand.
      await tester.tap(find.text(question));
      await tester.pumpAndSettle();
      
      expect(find.text(answer), findsOneWidget);
    });
  });
}
