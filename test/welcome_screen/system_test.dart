import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/welcome_screen.dart';
import 'package:life_lab/home_screen.dart';

void main() {
  group('WelcomeScreen System Tests', () {
    testWidgets('Tapping ENTER THE GRID transitions to HomeScreen', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
      
      await tester.tap(find.text("ENTER THE GRID"));
      
      // The transition takes 800ms according to the code
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 850));

      // Should be on HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
