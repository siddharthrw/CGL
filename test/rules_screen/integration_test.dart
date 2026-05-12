import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/rules_screen.dart';

void main() {
  group('RulesScreen Integration Tests', () {
    testWidgets('Sliders trigger callbacks with correct values', (WidgetTester tester) async {
      int tappedBirth = -1;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RulesScreen(
              birthRule: 3,
              surviveMin: 2,
              surviveMax: 3,
              onBirthChanged: (v) {
                tappedBirth = v;
              },
              onSurviveMinChanged: (_) {},
              onSurviveMaxChanged: (_) {},
            ),
          ),
        ),
      );

      final sliders = find.byType(Slider);
      expect(sliders, findsNWidgets(3));

      // Tap on the right side of the Birth Rule slider
      final targetSlider = sliders.first;
      final Rect sliderRect = tester.getRect(targetSlider);
      
      await tester.tapAt(Offset(sliderRect.right - 10, sliderRect.center.dy));
      await tester.pump();

      // Since max is 8, tapping the far right should send 8
      expect(tappedBirth, equals(8));
    });
  });
}
