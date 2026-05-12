import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/welcome_screen.dart';

void main() {
  group('WelcomeScreen Integration Tests', () {
    testWidgets('UI elements render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
      
      expect(find.text("WELCOME TO"), findsOneWidget);
      expect(find.text("CONWAY'S\nGAME OF LIFE"), findsOneWidget);
      expect(find.text("ENTER THE GRID"), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });
  });
}
