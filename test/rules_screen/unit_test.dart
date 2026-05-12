import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/rules_screen.dart';

void main() {
  group('RulesScreen Unit Tests', () {
    testWidgets('RulesScreen renders passed values correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RulesScreen(
              birthRule: 5,
              surviveMin: 4,
              surviveMax: 6,
              onBirthChanged: (_) {},
              onSurviveMinChanged: (_) {},
              onSurviveMaxChanged: (_) {},
            ),
          ),
        ),
      );

      // Verify text displays
      expect(find.text('5'), findsOneWidget); // Birth rule
      expect(find.text('4'), findsOneWidget); // Survive min
      expect(find.text('6'), findsOneWidget); // Survive max
    });
  });
}
